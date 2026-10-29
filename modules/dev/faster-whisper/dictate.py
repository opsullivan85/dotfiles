import argparse
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

from faster_whisper import WhisperModel
from pynput import keyboard

FFMPEG = "@FFMPEG@"
XDOTOOL = "@XDOTOOL@"


def start_recording(path: Path) -> subprocess.Popen:
    return subprocess.Popen(
        [
            FFMPEG,
            "-loglevel",
            "error",
            "-y",
            "-f",
            "pulse",
            "-i",
            "default",
            "-ac",
            "1",
            "-ar",
            "16000",
            str(path),
        ],
        stdin=subprocess.DEVNULL,
    )


def stop_recording(proc: subprocess.Popen) -> None:
    # SIGINT lets ffmpeg finalize the WAV header before exiting.
    proc.send_signal(signal.SIGINT)
    proc.wait()


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Push-to-talk dictation: hold the key to record, release to type the transcript."
    )
    parser.add_argument("--key", default="f9", help="pynput key name to hold while speaking (default: f9)")
    parser.add_argument("--model", default="small", help="model size or local model path (default: small)")
    parser.add_argument("--language", help="language code such as en (default: auto-detect)")
    args = parser.parse_args()

    key = getattr(keyboard.Key, args.key, None)
    if key is None:
        parser.error(f"unknown key: {args.key}")

    model = WhisperModel(args.model, device="@DEVICE@", compute_type="@COMPUTE_TYPE@")
    transcribe_lock = threading.Lock()
    recorder = None
    audio_path = None

    def finish(path: Path) -> None:
        try:
            with transcribe_lock:
                segments, _info = model.transcribe(str(path), language=args.language)
                text = " ".join(segment.text.strip() for segment in segments).strip()
            if text:
                subprocess.run([XDOTOOL, "type", "--clearmodifiers", "--", text], check=True)
        finally:
            shutil.rmtree(path.parent, ignore_errors=True)

    def on_press(pressed) -> None:
        nonlocal recorder, audio_path
        if pressed != key or recorder is not None:
            return
        audio_path = Path(tempfile.mkdtemp()) / "dictation.wav"
        recorder = start_recording(audio_path)

    def on_release(released) -> None:
        nonlocal recorder
        if released != key or recorder is None:
            return
        stop_recording(recorder)
        recorder = None
        threading.Thread(target=finish, args=(audio_path,), daemon=True).start()

    print(f"Hold {args.key} to dictate. Press Ctrl+C to quit.", file=sys.stderr)
    with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
        try:
            listener.join()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
