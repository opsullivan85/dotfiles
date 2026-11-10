import argparse
import logging
import os
import queue
import signal
import string
import subprocess
import sys
import threading
import time

import numpy as np
from evdev import InputDevice, UInput, UInputError, ecodes, list_devices
from faster_whisper import WhisperModel
from faster_whisper.vad import VadOptions, get_speech_timestamps

FFMPEG = "@FFMPEG@"

SAMPLE_RATE = 16000
READ_BYTES = SAMPLE_RATE // 10 * 2  # 100 ms of 16-bit mono PCM
POLL_SECONDS = 0.2
PAUSE_MS = 500  # silence that ends an utterance
MAX_SECONDS = 20  # force a cut during speech with no pause
PAD_SAMPLES = SAMPLE_RATE // 5  # keep the end of each utterance
PRE_ROLL_SAMPLES = SAMPLE_RATE // 2  # keep audio before speech onset
VAD_OPTIONS = VadOptions(min_silence_duration_ms=PAUSE_MS, speech_pad_ms=0)
TYPE_LOCK = threading.Lock()
TYPE_DELAY_SECONDS = 0.002
SETUP_HELP = (
    "no access to /dev/input or /dev/uinput. Add your user to the 'input' group "
    "(sudo usermod -aG input $USER, then log in again) and install the uinput udev rule "
    "from modules/dev/faster-whisper/default.nix."
)
log = logging.getLogger("dictate")

SHIFT = ecodes.ecodes["KEY_LEFTSHIFT"]
SYMBOL_KEY_NAMES = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    "MINUS",
    "EQUAL",
    "LEFTBRACE",
    "RIGHTBRACE",
    "BACKSLASH",
    "SEMICOLON",
    "APOSTROPHE",
    "GRAVE",
    "COMMA",
    "DOT",
    "SLASH",
]
UNSHIFTED = "1234567890-=[]\\;'`,./"
SHIFTED = '!@#$%^&*()_+{}|:"~<>?'
# US layout. The compositor applies the user's own layout to these keycodes.
CHAR_KEYS = {" ": (ecodes.ecodes["KEY_SPACE"], False)}
for _letter in string.ascii_lowercase:
    _code = ecodes.ecodes[f"KEY_{_letter.upper()}"]
    CHAR_KEYS[_letter] = (_code, False)
    CHAR_KEYS[_letter.upper()] = (_code, True)
for _plain, _shifted, _name in zip(UNSHIFTED, SHIFTED, SYMBOL_KEY_NAMES, strict=True):
    CHAR_KEYS[_plain] = (ecodes.ecodes[f"KEY_{_name}"], False)
    CHAR_KEYS[_shifted] = (ecodes.ecodes[f"KEY_{_name}"], True)


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


class VirtualKeyboard:
    """Types through a uinput device, so text reaches the focused window on X11 and Wayland alike."""

    def __init__(self):
        codes = {code for code, _shift in CHAR_KEYS.values()} | {SHIFT}
        self.device = UInput({ecodes.EV_KEY: sorted(codes)}, name="faster-whisper-dictate")
        # Give the compositor a moment to register the new device before the first keystroke.
        time.sleep(0.5)

    def _emit(self, code: int, value: int) -> None:
        self.device.write(ecodes.EV_KEY, code, value)
        self.device.syn()

    def type_text(self, text: str) -> None:
        for char in text:
            if char not in CHAR_KEYS:
                log.debug("no key for character %r; skipping", char)
                continue
            code, shift = CHAR_KEYS[char]
            if shift:
                self._emit(SHIFT, 1)
            self._emit(code, 1)
            self._emit(code, 0)
            if shift:
                self._emit(SHIFT, 0)
            time.sleep(TYPE_DELAY_SECONDS)


class Session:
    """One hold of the hotkey: types each utterance as soon as a pause follows it."""

    def __init__(self, model: WhisperModel, language: str | None, keyboard: VirtualKeyboard):
        self.model = model
        self.language = language
        self.keyboard = keyboard
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
            self.keyboard.type_text(text)


def hotkey_code(name: str) -> int | None:
    name = name.upper()
    if not name.startswith("KEY_"):
        name = f"KEY_{name}"
    return ecodes.ecodes.get(name)


def open_keyboards(code: int) -> tuple[list[InputDevice], int]:
    keyboards = []
    denied = 0
    for path in list_devices():
        try:
            device = InputDevice(path)
        except PermissionError:
            denied += 1
            continue
        if code in device.capabilities().get(ecodes.EV_KEY, []):
            log.debug("listening for the hotkey on %s (%s)", path, device.name)
            keyboards.append(device)
        else:
            device.close()
    return keyboards, denied


def watch(device: InputDevice, code: int, on_key) -> None:
    for event in device.read_loop():
        # value 1 is press, 0 is release; 2 is key auto-repeat, which we ignore.
        if event.type == ecodes.EV_KEY and event.code == code and event.value in (0, 1):
            on_key(event.value == 1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Push-to-talk dictation: hold the key to dictate; text is typed as you pause."
    )
    parser.add_argument(
        "--key", default="f9", help="key to hold while speaking, e.g. f9 or KEY_RIGHTCTRL (default: f9)"
    )
    parser.add_argument("--model", default="small", help="model size or local model path (default: small)")
    parser.add_argument("--language", help="language code such as en (default: auto-detect)")
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="log devices, hotkey events, audio levels, VAD and transcription to stderr",
    )
    args = parser.parse_args()

    # Only this script's logger goes to DEBUG; libraries such as httpcore stay at WARNING.
    logging.basicConfig(
        level=logging.WARNING,
        format="%(asctime)s %(threadName)s %(levelname)s %(message)s",
        stream=sys.stderr,
    )
    log.setLevel(logging.DEBUG if args.verbose else logging.WARNING)

    code = hotkey_code(args.key)
    if code is None:
        parser.error(f"unknown key: {args.key}")

    log.debug(
        "session=%s DISPLAY=%s WAYLAND_DISPLAY=%s",
        os.environ.get("XDG_SESSION_TYPE"),
        os.environ.get("DISPLAY"),
        os.environ.get("WAYLAND_DISPLAY"),
    )
    try:
        keyboard = VirtualKeyboard()
    except (OSError, UInputError) as error:
        sys.exit(f"cannot create a virtual keyboard: {error}\n{SETUP_HELP}")
    log.debug("virtual keyboard created")

    keyboards, denied = open_keyboards(code)
    if not keyboards:
        reason = SETUP_HELP if denied else f"no keyboard has the key {args.key}"
        sys.exit(f"cannot listen for {args.key}: {reason}")

    log.debug("loading model %r", args.model)
    started = time.monotonic()
    model = WhisperModel(args.model, device="auto", compute_type="auto")
    log.debug("model loaded in %.2f s", time.monotonic() - started)

    lock = threading.Lock()
    session = None

    def on_key(pressed: bool) -> None:
        nonlocal session
        with lock:
            if pressed and session is None:
                log.debug("%s pressed; starting session", args.key)
                session = Session(model, args.language, keyboard)
            elif not pressed and session is not None:
                log.debug("%s released; ending session", args.key)
                session.stop()
                session = None

    for device in keyboards:
        threading.Thread(target=watch, args=(device, code, on_key), daemon=True).start()
    print(f"Hold {args.key} to dictate. Press Ctrl+C to quit.", file=sys.stderr)
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
