#!/bin/bash
set -e

PORT="${KOHARU_PORT:-4000}"
EXTRA_ARGS="${KOHARU_ARGS:-}"

if command -v Xvfb &>/dev/null; then
    Xvfb :99 -screen 0 1280x720x24 -nolisten tcp 2>/dev/null &
    export DISPLAY=:99
    echo "[entrypoint] Virtual display started on :99"
fi

echo "[entrypoint] Starting Koharu on port ${PORT} (headless)"
exec ./koharu --port "${PORT}" --headless --host 0.0.0.0 ${EXTRA_ARGS}
