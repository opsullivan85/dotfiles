import argparse
import queue
import signal
import subprocess
import sys
import threading
import time

import numpy as np
from faster_whisper import WhisperModel
from faster_whisper.vad import VadOptions, get_speech_timestamps
from pynput import keyboard

FFMPEG = "@FFMPEG@"
XDOTOOL = "@XDOTOOL@"

SAMPLE_RATE = 16000
READ_BYTES = SAMPLE_RATE // 10 * 2  # 100 ms of 16-bit mono PCM
POLL_SECONDS = 0.2
PAUSE_MS = 500  # silence that ends an utterance
MAX_SECONDS = 20  # force a cut during speech with no pause
PAD_SAMPLES = SAMPLE_RATE // 5  # keep the end of each utterance
PRE_ROLL_SAMPLES = SAMPLE_RATE // 2  # keep audio before speech onset
VAD_OPTIONS = VadOptions(min_silence_duration_ms=PAUSE_MS, speech_pad_ms=0)
TYPE_LOCK = threading.Lock()


def start_recording() -> subprocess.Popen:
    return subprocess.Popen(
        [
            FFMPEG,
            "-loglevel",
            "error",
            "-f",
            "pulse",
            "-i",
            "default",
            "-ac",
            "1",
            "-ar",
            str(SAMPLE_RATE),
            "-f",
            "s16le",
            "-",
        ],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
    )


class Session:
    """One hold of the hotkey: types each utterance as soon as a pause follows it."""

    def __init__(self, model: WhisperModel, language: str | None):
        self.model = model
        self.language = language
        self.typed = False
        self.chunks: queue.Queue = queue.Queue()
        self.recorder = start_recording()
        threading.Thread(target=self._read, daemon=True).start()
        threading.Thread(target=self._work, daemon=True).start()

    def stop(self) -> None:
        # SIGINT lets ffmpeg exit cleanly; the reader then sees EOF and the worker flushes.
        self.recorder.send_signal(signal.SIGINT)
        self.recorder.wait()

    def _read(self) -> None:
        while data := self.recorder.stdout.read(READ_BYTES):
            samples = np.frombuffer(data, dtype=np.int16)
            self.chunks.put(samples.astype(np.float32) / 32768.0)
        self.chunks.put(None)

    def _work(self) -> None:
        pending = np.zeros(0, dtype=np.float32)
        while True:
            finished = False
            while True:
                try:
                    chunk = self.chunks.get_nowait()
                except queue.Empty:
                    break
                if chunk is None:
                    finished = True
                    break
                pending = np.concatenate((pending, chunk))
            pending = self._emit(pending, finished)
            if finished:
                return
            time.sleep(POLL_SECONDS)

    def _emit(self, pending: np.ndarray, finished: bool) -> np.ndarray:
        segments = get_speech_timestamps(pending, VAD_OPTIONS, sampling_rate=SAMPLE_RATE)
        if not segments:
            return pending[-PRE_ROLL_SAMPLES:]
        # VAD only closes a segment after PAUSE_MS of silence, so an open segment ends at len(pending).
        end = segments[-1]["end"]
        if finished:
            cut = len(pending)
        elif end < len(pending):
            cut = min(end + PAD_SAMPLES, len(pending))
        elif len(pending) >= MAX_SECONDS * SAMPLE_RATE:
            cut = len(pending)
        else:
            return pending
        self._transcribe_and_type(pending[:cut])
        return pending[cut:]

    def _transcribe_and_type(self, audio: np.ndarray) -> None:
        segments, _info = self.model.transcribe(audio, language=self.language, vad_filter=False)
        text = " ".join(segment.text.strip() for segment in segments).strip()
        if not text:
            return
        if self.typed:
            text = " " + text
        self.typed = True
        with TYPE_LOCK:
            # xdotool's default 12 ms per character makes long transcripts slow to type.
            subprocess.run([XDOTOOL, "type", "--clearmodifiers", "--delay", "2", "--", text], check=True)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Push-to-talk dictation: hold the key to dictate; text is typed as you pause."
    )
    parser.add_argument("--key", default="f9", help="pynput key name to hold while speaking (default: f9)")
    parser.add_argument("--model", default="small", help="model size or local model path (default: small)")
    parser.add_argument("--language", help="language code such as en (default: auto-detect)")
    args = parser.parse_args()

    key = getattr(keyboard.Key, args.key, None)
    if key is None:
        parser.error(f"unknown key: {args.key}")

    model = WhisperModel(args.model, device="auto", compute_type="auto")
    session = None

    def on_press(pressed) -> None:
        nonlocal session
        if pressed == key and session is None:
            session = Session(model, args.language)

    def on_release(released) -> None:
        nonlocal session
        if released == key and session is not None:
            session.stop()
            session = None

    print(f"Hold {args.key} to dictate. Press Ctrl+C to quit.", file=sys.stderr)
    with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
        try:
            listener.join()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
