import argparse
import logging
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
log = logging.getLogger("dictate")


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
        log.debug("ffmpeg started (pid %d)", self.recorder.pid)
        threading.Thread(target=self._read, name="reader", daemon=True).start()
        threading.Thread(target=self._work, name="worker", daemon=True).start()

    def stop(self) -> None:
        # SIGINT lets ffmpeg exit cleanly; the reader then sees EOF and the worker flushes.
        log.debug("stopping ffmpeg (pid %d)", self.recorder.pid)
        self.recorder.send_signal(signal.SIGINT)
        self.recorder.wait()

    def _read(self) -> None:
        total = 0
        peak = 0.0
        while data := self.recorder.stdout.read(READ_BYTES):
            chunk = np.frombuffer(data, dtype=np.int16).astype(np.float32) / 32768.0
            total += len(chunk)
            peak = max(peak, float(np.abs(chunk).max()))
            self.chunks.put(chunk)
        # A peak near 0 means the microphone delivered silence (wrong source or muted).
        log.debug("audio ended: %.2f s recorded, peak level %.3f", total / SAMPLE_RATE, peak)
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
        log.debug(
            "pending %.2f s, %d speech segment(s), finished=%s",
            len(pending) / SAMPLE_RATE,
            len(segments),
            finished,
        )
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
            log.debug("no pause within %d s; forcing a cut", MAX_SECONDS)
        else:
            return pending
        self._transcribe_and_type(pending[:cut])
        return pending[cut:]

    def _transcribe_and_type(self, audio: np.ndarray) -> None:
        log.debug("transcribing %.2f s of audio", len(audio) / SAMPLE_RATE)
        started = time.monotonic()
        segments, info = self.model.transcribe(audio, language=self.language, vad_filter=False)
        text = " ".join(segment.text.strip() for segment in segments).strip()
        log.debug(
            "transcribed in %.2f s (language %s, p=%.2f): %r",
            time.monotonic() - started,
            info.language,
            info.language_probability,
            text,
        )
        if not text:
            return
        if self.typed:
            text = " " + text
        self.typed = True
        with TYPE_LOCK:
            log.debug("typing %r", text)
            # xdotool's default 12 ms per character makes long transcripts slow to type.
            subprocess.run([XDOTOOL, "type", "--clearmodifiers", "--delay", "2", "--", text], check=True)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Push-to-talk dictation: hold the key to dictate; text is typed as you pause."
    )
    parser.add_argument("--key", default="f9", help="pynput key name to hold while speaking (default: f9)")
    parser.add_argument("--model", default="small", help="model size or local model path (default: small)")
    parser.add_argument("--language", help="language code such as en (default: auto-detect)")
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="log key events, audio levels, VAD and transcription to stderr",
    )
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.WARNING,
        format="%(asctime)s %(threadName)s %(levelname)s %(message)s",
        stream=sys.stderr,
    )

    key = getattr(keyboard.Key, args.key, None)
    if key is None:
        parser.error(f"unknown key: {args.key}")

    log.debug("loading model %r", args.model)
    started = time.monotonic()
    model = WhisperModel(args.model, device="auto", compute_type="auto")
    log.debug("model loaded in %.2f s", time.monotonic() - started)
    session = None

    def on_press(pressed) -> None:
        nonlocal session
        if pressed == key and session is None:
            log.debug("%s pressed; starting session", args.key)
            session = Session(model, args.language)

    def on_release(released) -> None:
        nonlocal session
        if released == key and session is not None:
            log.debug("%s released; ending session", args.key)
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
