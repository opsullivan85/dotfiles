#!/usr/bin/env bash
# Capture a region (default) or the focused output, then annotate it in Satty.
# Enter saves to ~/Pictures/Screenshots, Ctrl+C copies; either closes Satty.
# Escape closes without saving.
# Usage: shot [area|screen]
set -euo pipefail

mode=${1:-area}
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"

case "$mode" in
  area)
    # slurp exits non-zero when the selection is cancelled; that is not an error.
    geometry=$(slurp) || exit 0
    capture=(grim -g "$geometry" -)
    ;;
  screen)
    output=$(niri msg --json focused-output | jq -r '.name')
    capture=(grim -o "$output" -)
    ;;
  *)
    echo "usage: shot [area|screen]" >&2
    exit 1
    ;;
esac

"${capture[@]}" | satty \
  --filename - \
  --output-filename "$dir/%Y-%m-%d_%H-%M-%S.png" \
  --actions-on-enter save-to-file \
  --actions-on-escape exit \
  --copy-command wl-copy \
  --early-exit all
