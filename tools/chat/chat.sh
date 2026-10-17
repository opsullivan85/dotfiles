#!/usr/bin/env bash
# Start an AI chat with whichever assistant is installed. Arguments pass through.
# CHAT_CMD overrides the choice, e.g. `CHAT_CMD=copilot chat`.
set -euo pipefail

if [[ -n "${CHAT_CMD:-}" ]]; then
  # Intentionally word-split so CHAT_CMD can be "gh copilot".
  # shellcheck disable=SC2086
  exec $CHAT_CMD "$@"
fi

if command -v claude >/dev/null; then
  exec claude "$@"
elif command -v copilot >/dev/null; then
  exec copilot "$@"
elif command -v gh >/dev/null && gh extension list 2>/dev/null | grep -q copilot; then
  exec gh copilot "$@"
fi

echo "chat: no assistant found (looked for claude, copilot, gh copilot)" >&2
exit 1
