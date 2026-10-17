"""Small terminal UI toolkit: colours, spinner steps, logged subprocesses.

Stdlib only, so the scripts work on a fresh machine before anything is
installed. Degrades to plain line-by-line output when not on a TTY.
"""

from __future__ import annotations

import itertools
import os
import re
import shutil
import subprocess
import sys
import threading
import time
from collections.abc import Sequence
from datetime import datetime
from pathlib import Path

TTY = sys.stdout.isatty()
COLOR = TTY and "NO_COLOR" not in os.environ

_CODES = {
    "bold": "1",
    "dim": "2",
    "red": "31",
    "green": "32",
    "yellow": "33",
    "blue": "34",
    "magenta": "35",
    "cyan": "36",
}


def paint(text: str, *styles: str) -> str:
    if not COLOR:
        return text
    prefix = "".join(f"\033[{_CODES[s]}m" for s in styles)
    return f"{prefix}{text}\033[0m"


OK = paint("✓", "green")
FAIL = paint("✗", "red")
WARN = paint("!", "yellow")
SKIP = paint("–", "dim")
INFO = paint("•", "blue")

_ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")


def strip_ansi(text: str) -> str:
    return _ANSI.sub("", text)


def width() -> int:
    return shutil.get_terminal_size((80, 20)).columns


def fit(text: str, room: int) -> str:
    """Truncate to `room` visible columns."""
    text = strip_ansi(text).replace("\t", " ").strip()
    return text if len(text) <= room else text[: max(room - 1, 0)] + "…"


def fmt_duration(seconds: float) -> str:
    if seconds < 60:
        return f"{seconds:.1f}s"
    minutes, secs = divmod(int(seconds), 60)
    return f"{minutes}m{secs:02d}s"


def header(title: str, subtitle: str = "") -> None:
    sub = f"  {paint(subtitle, 'dim')}" if subtitle else ""
    print(f"\n{paint(title, 'bold', 'cyan')}{sub}\n")


def line(symbol: str, label: str, detail: str = "") -> None:
    tail = f"  {paint(detail, 'dim')}" if detail else ""
    print(f"  {symbol} {label}{tail}")


def note(text: str, indent: int = 4) -> None:
    for row in text.splitlines():
        print(" " * indent + paint(row, "dim"))


# --------------------------------------------------------------------------
# Logs
# --------------------------------------------------------------------------

LOG_KEEP = 15


def log_dir() -> Path:
    state = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
    path = state / "dotfiles" / "logs"
    path.mkdir(parents=True, exist_ok=True)
    return path


def new_log(name: str) -> Path:
    """Create `<name>-<timestamp>.log` outside the repo and point `<name>-latest.log` at it."""
    directory = log_dir()
    path = directory / f"{name}-{datetime.now().astimezone():%Y%m%d-%H%M%S}.log"
    path.touch()
    latest = directory / f"{name}-latest.log"
    latest.unlink(missing_ok=True)
    latest.symlink_to(path.name)
    for old in sorted(directory.glob(f"{name}-2*.log"))[:-LOG_KEEP]:
        old.unlink(missing_ok=True)
    return path


def pretty_path(path: Path) -> str:
    try:
        return "~/" + str(path.relative_to(Path.home()))
    except ValueError:
        return str(path)


# --------------------------------------------------------------------------
# Running things
# --------------------------------------------------------------------------


class Result:
    def __init__(self, code: int, lines: list[str], seconds: float) -> None:
        self.code = code
        self.lines = lines
        self.seconds = seconds

    @property
    def ok(self) -> bool:
        return self.code == 0

    @property
    def last_line(self) -> str:
        """Last non-empty output line, for one-line failure details."""
        return next((strip_ansi(r).strip() for r in reversed(self.lines) if r.strip()), "")

    @property
    def text(self) -> str:
        return "\n".join(self.lines)


_FRAMES = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"


def run(
    label: str,
    cmd: Sequence[str | Path],
    *,
    log: Path | None = None,
    verbose: bool = False,
    cwd: Path | None = None,
    env: dict[str, str] | None = None,
) -> Result:
    """Run `cmd` showing a spinner with the latest output line.

    Combined stdout/stderr is appended to `log` (when given). The caller
    prints the final ✓/✗ line itself, so it can add context to it.
    With `verbose`, output is streamed raw instead of spinning.
    """
    start = time.monotonic()
    lines: list[str] = []
    logfile = log.open("a") if log else None
    if logfile:
        logfile.write(f"$ {' '.join(map(str, cmd))}\n")
    proc = subprocess.Popen(
        [str(c) for c in cmd],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        stdin=subprocess.DEVNULL,
        text=True,
        errors="replace",
        cwd=cwd,
        env={**os.environ, **(env or {})},
    )
    latest = [""]
    stop = threading.Event()

    def spin() -> None:
        for frame in itertools.cycle(_FRAMES):
            if stop.is_set():
                return
            elapsed = fmt_duration(time.monotonic() - start)
            head = f"  {paint(frame, 'cyan')} {label}  {paint(elapsed, 'dim')}"
            room = width() - len(strip_ansi(head)) - 3
            tail = paint(fit(latest[0], room), "dim") if room > 10 else ""
            sys.stdout.write(f"\r\033[K{head}  {tail}")
            sys.stdout.flush()
            time.sleep(0.08)

    spinner = None
    if TTY and not verbose:
        spinner = threading.Thread(target=spin, daemon=True)
        spinner.start()
    elif not verbose:
        print(f"  … {label}", flush=True)
    assert proc.stdout is not None
    try:
        for raw in proc.stdout:
            text = raw.rstrip("\n")
            lines.append(text)
            if logfile:
                logfile.write(raw)
            if verbose:
                print(text)
            elif text.strip():
                latest[0] = text
        code = proc.wait()
    except KeyboardInterrupt:
        proc.terminate()
        proc.wait()
        raise
    finally:
        stop.set()
        if spinner:
            spinner.join()
            sys.stdout.write("\r\033[K")
            sys.stdout.flush()
        if logfile:
            logfile.close()
    return Result(code, lines, time.monotonic() - start)


def run_interactive(cmd: Sequence[str | Path], **kwargs) -> int:
    """Run with the terminal attached (prompts, logins)."""
    return subprocess.run([str(c) for c in cmd], check=False, **kwargs).returncode


def capture(cmd: Sequence[str | Path], **kwargs) -> str:
    """Run quietly and return stripped stdout ('' on failure)."""
    proc = subprocess.run(
        [str(c) for c in cmd],
        capture_output=True,
        check=False,
        text=True,
        stdin=subprocess.DEVNULL,
        **kwargs,
    )
    return proc.stdout.strip() if proc.returncode == 0 else ""


# --------------------------------------------------------------------------
# Nix output digestion
# --------------------------------------------------------------------------


def nix_error_summary(lines: list[str], limit: int = 18) -> str:
    """Boil a noisy Nix failure down to the part that matters.

    Takes from the last `error:` line onward (that is where Nix puts the
    actual cause; everything above is progress and traces), dropping blank
    lines and `show-trace` hints.
    """
    clean = [strip_ansi(row).rstrip() for row in lines]
    starts = [i for i, row in enumerate(clean) if re.match(r"^\s*error(\[.*\])?:", row)]
    tail = clean[starts[-1] :] if starts else clean[-limit:]
    tail = [row for row in tail if row.strip() and "--show-trace" not in row]
    if len(tail) > limit:
        tail = tail[:limit] + [f"… ({len(tail) - limit} more lines in the log)"]
    return "\n".join(tail)


def nix_warnings(lines: list[str]) -> list[str]:
    seen: dict[str, None] = {}
    for row in lines:
        match = re.match(r"^\s*(?:evaluation )?warning:\s*(.*)", strip_ansi(row))
        if match and match.group(1).strip():
            seen.setdefault(match.group(1).strip(), None)
    return list(seen)
