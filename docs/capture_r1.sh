#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$HOME/workspace/tools/godot/Godot_v4.3-stable_linux.x86_64"
export TMPDIR="$ROOT/game/.tmp"
mkdir -p "$TMPDIR" "$ROOT/docs/shots"
df -h /tmp
if [[ -z "${DISPLAY:-}" ]]; then
  echo 'FAIL: no DISPLAY. Run this script through xvfb-run -a on a host permitting X sockets.' >&2
  exit 2
fi
for kind in spirit reality ending; do
  timeout 30 "$GODOT" --path "$ROOT/game" --audio-driver Dummy -- --capture="$kind" --capture-path="$ROOT/docs/shots/${kind}_r1.png"
done
python3 "$ROOT/docs/verify_shots.py"
