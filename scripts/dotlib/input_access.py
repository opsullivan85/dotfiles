"""One-time input access for faster-whisper-dictate (hotkey via /dev/input, typing via /dev/uinput).

Shared by the base and root bootstrap scripts. NixOS hosts set this up declaratively
in hosts/laptop/configuration.nix, so this step skips there.
"""

from __future__ import annotations

import getpass
import grp
import shutil
import tempfile
from pathlib import Path

from dotlib import ui

UDEV_RULE = Path("/etc/udev/rules.d/99-uinput.rules")
UDEV_CONTENT = 'KERNEL=="uinput", GROUP="input", MODE="0660"\n'


def faster_whisper_uinput() -> tuple[str, str]:
    if shutil.which("faster-whisper-dictate") is None:
        return ui.SKIP, "faster-whisper-dictate not installed"
    if Path("/etc/NIXOS").exists():
        return ui.SKIP, "NixOS: set in hosts/laptop/configuration.nix"
    user = getpass.getuser()
    in_group = user in grp.getgrnam("input").gr_mem
    rule_ok = UDEV_RULE.exists() and UDEV_RULE.read_text() == UDEV_CONTENT
    if in_group and rule_ok:
        return ui.OK, "already set up (log out and back in if it still fails)"
    print("  Needs sudo to add you to the 'input' group and install a udev rule:\n")
    if not in_group and ui.run_interactive(["sudo", "usermod", "-aG", "input", user]):
        return ui.FAIL, "usermod -aG input failed"
    if not rule_ok:
        with tempfile.NamedTemporaryFile("w", suffix=".rules") as tmp:
            tmp.write(UDEV_CONTENT)
            tmp.flush()
            if ui.run_interactive(["sudo", "install", "-m", "0644", tmp.name, str(UDEV_RULE)]):
                return ui.FAIL, "installing udev rule failed"
        if ui.run_interactive(["sudo", "udevadm", "control", "--reload-rules"]) or ui.run_interactive(
            ["sudo", "udevadm", "trigger"]
        ):
            return ui.FAIL, "udevadm reload failed"
    print()
    return ui.OK, "done, log out and back in to apply the input group"
