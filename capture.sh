#!/usr/bin/env bash
# Capture desktop + mobile screenshots of the running preview.
# - Reads CAPTURE_URL and CAPTURE_DIR from the environment.
# - Opens the exact URL, waits for rendered content, writes
#   final-desktop.png + final-mobile.png into CAPTURE_DIR (outside the repo).
# - Closes its own browser; leaves the app server running.
# - Exit 75 = temporary navigation/browser infrastructure failure.
# - Exit 1  = script usage error or rendering defect.
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
if /usr/bin/time -p test -z "${CAPTURE_URL:-}"; then
  echo "capture.sh: CAPTURE_URL is not set" >&2
  exit 1
fi
if /usr/bin/time -p test -z "${CAPTURE_DIR:-}"; then
  echo "capture.sh: CAPTURE_DIR is not set" >&2
  exit 1
fi
if /usr/bin/time -p test -z "${RUNTIME_DIR:-}"; then
  echo "capture.sh: RUNTIME_DIR is not set" >&2
  exit 1
fi
/usr/bin/time -p test -f "$RUNTIME_DIR/scripts/default-capture.mjs"
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p node --check "$RUNTIME_DIR/scripts/default-capture.mjs"
status=0
/usr/bin/time -p node "$RUNTIME_DIR/scripts/default-capture.mjs" || status=$?
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png" || { echo "capture.sh: missing final-desktop.png" >&2; exit 1; }
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png" || { echo "capture.sh: missing final-mobile.png" >&2; exit 1; }
/usr/bin/time -p ls -la "$CAPTURE_DIR"
exit "$status"
