"""Shared stage/check/build/commit flow for `scripts/rebuild` entrypoints.

Factored out so other repos that consume this one (e.g. the private work
repo) can run the same rebuild pattern against their own flake/target without
duplicating it; only the build command and host-specific bits (generation
lookup, NixOS closure diffing) stay with each caller.
"""

from __future__ import annotations

import shutil
import subprocess
import time
from collections.abc import Sequence
from pathlib import Path

from . import ui


def git(repo: Path, *args: str) -> ui.Result:
    return ui.run("git " + args[0], ["git", *args], cwd=repo, verbose=False)


def stage(repo: Path) -> bool:
    res = git(repo, "add", "-A")
    if not res.ok:
        ui.line(ui.FAIL, "Staging failed")
        ui.note(res.text)
        return False
    changed = ui.capture(["git", "diff", "--cached", "--name-only"], cwd=repo).splitlines()
    ui.line(
        ui.OK,
        "Staged",
        f"{len(changed)} changed file{'s' if len(changed) != 1 else ''}" if changed else "no changes",
    )
    return True


def run_checks(repo: Path, cmd: Sequence[str | Path], log: Path, verbose: bool) -> bool:
    """Run pre-commit-style checks on staged files; one retry after auto-fixes."""
    res = ui.run("Checking", cmd, log=log, verbose=verbose, cwd=repo)
    if not res.ok and ui.capture(["git", "diff", "--name-only"], cwd=repo):
        git(repo, "add", "-A")  # formatters rewrote files; take their fixes
        res = ui.run("Checking (after auto-fixes)", cmd, log=log, verbose=verbose, cwd=repo)
        if res.ok:
            ui.line(
                ui.OK,
                "Checks",
                f"passed after auto-formatting  ·  {ui.fmt_duration(res.seconds)}",
            )
            return True
    if res.ok:
        ui.line(ui.OK, "Checks", ui.fmt_duration(res.seconds))
        return True
    ui.line(ui.FAIL, "Checks failed")
    failed = [ui.strip_ansi(r) for r in res.lines if r.strip() and not r.startswith("[")]
    ui.note("\n".join(failed[-25:]))
    return False


def build(
    cmd: Sequence[str | Path], repo: Path, log: Path, verbose: bool, *, allow_nom: bool = True
) -> ui.Result:
    """Run the build; with -v and nom on PATH, show nom's live build tree.

    nom needs the terminal, so its output isn't captured: the log only gets
    the command, and a failure points at the scrollback instead of a summary.
    """
    nom = shutil.which("nom")
    if not (allow_nom and verbose and nom and ui.TTY):
        return ui.run("Building and activating", cmd, log=log, verbose=verbose, cwd=repo)
    start = time.monotonic()
    with log.open("a") as f:
        f.write(f"$ {' '.join(map(str, cmd))}  (via nom)\n")
    code = subprocess.run(
        ["bash", "-c", 'set -o pipefail; "$@" --log-format internal-json -v 2>&1 | nom --json', "_", *cmd],
        check=False,
        cwd=repo,
    ).returncode
    return ui.Result(code, [], time.monotonic() - start)


def report_build_failure(res: ui.Result, log: Path) -> None:
    ui.line(ui.FAIL, "Build failed", ui.fmt_duration(res.seconds))
    print()
    ui.note(ui.nix_error_summary(res.lines), indent=4)
    print(f"\n  {ui.paint('Full log:', 'bold')} {ui.pretty_path(log)}")


def report_build_success(res: ui.Result, gen: str) -> None:
    label = f"generation {gen}" if gen else "new generation"
    ui.line(ui.OK, f"Activated {label}", ui.fmt_duration(res.seconds))
    warnings = ui.nix_warnings(res.lines)
    if warnings:
        ui.line(ui.WARN, f"{len(warnings)} warning{'s' if len(warnings) != 1 else ''}")
        for w in warnings[:5]:
            print(f"      {ui.paint(ui.fit(w, ui.width() - 8), 'yellow')}")


def commit(repo: Path, message: str | None, gen: str, ran_checks: bool, *, label: str = "rebuild") -> bool:
    if not ui.capture(["git", "diff", "--cached", "--name-only"], cwd=repo):
        ui.line(ui.SKIP, "Nothing to commit")
        return True
    auto = f"{label}: generation {gen}" if gen else label
    text = f"{message}\n\n{auto}" if message else auto
    cmd = ["git", "commit", "-m", text]
    if ran_checks:
        cmd.append("--no-verify")  # hooks just passed on exactly these files
    res = ui.run("Committing", cmd, cwd=repo)
    if not res.ok:
        ui.line(ui.FAIL, "Commit failed (the system itself was switched fine)")
        ui.note(res.text)
        return False
    short = ui.capture(["git", "rev-parse", "--short", "HEAD"], cwd=repo)
    ui.line(ui.OK, "Committed", f"{short}  {message or auto}")
    return True
