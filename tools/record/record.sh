#!/usr/bin/env bash
# Toggle screen recording with wf-recorder: the first run starts a recording,
# the next run stops it and keeps the file.
# Usage: record [area|screen]
set -euo pipefail

mode=${1:-area}
dir="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
pidfile="${XDG_RUNTIME_DIR:-/tmp}/rec.pid"

# Stop: SIGINT makes wf-recorder finish writing the file.
if [[ -f $pidfile ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
  kill -INT "$(cat "$pidfile")"
  rm -f "$pidfile"
  notify-send "Recording saved" "$dir"
  exit 0
fi
rm -f "$pidfile"

mkdir -p "$dir"
out="$dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"

case "$mode" in
  area)
    # slurp exits non-zero when the selection is cancelled; that is not an error.
    geometry=$(slurp) || exit 0
    wf-recorder -g "$geometry" -f "$out" >/dev/null 2>&1 &
    ;;
  screen)
    output=$(niri msg --json focused-output | jq -r '.name')
    wf-recorder -o "$output" -f "$out" >/dev/null 2>&1 &
    ;;
  *)
    echo "usage: record [area|screen]" >&2
    exit 1
    ;;
esac

echo $! >"$pidfile"
notify-send "Recording started" "$mode"
