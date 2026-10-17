#!/usr/bin/env bash
# Copy stdin to the system clipboard, using whichever backend fits the session.
# Backends are taken from PATH (not bundled) so the system's own are used.
if [[ -t 0 ]]; then
  echo "usage: some-command | copy" >&2
  exit 1
fi

if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null; then
  exec wl-copy
elif [[ -n "${DISPLAY:-}" ]] && command -v xclip >/dev/null; then
  exec xclip -selection clipboard -in
elif [[ -n "${DISPLAY:-}" ]] && command -v xsel >/dev/null; then
  exec xsel --clipboard --input
elif command -v pbcopy >/dev/null; then
  exec pbcopy
fi

# No local clipboard (ssh, tty): ask the terminal via an OSC 52 escape.
# Inside tmux the sequence must be wrapped to pass through.
payload=$(base64 | tr -d '\n')
if [[ -n "${TMUX:-}" ]]; then
  printf '\033Ptmux;\033\033]52;c;%s\a\033\134' "$payload" >/dev/tty
else
  printf '\033]52;c;%s\a' "$payload" >/dev/tty
fi
