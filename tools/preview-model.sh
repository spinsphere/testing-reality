#!/usr/bin/env bash
# Render a 3/4 preview PNG of an exported model for visual checking.
#   tools/preview-model.sh <name> [--view iso|front|top|side|back] [--zoom 1.5]
#                                 [--engine EEVEE|WORKBENCH] [--res 1280x960] [--samples 32]
# <name> is a model name (app/assets/models/<name>.glb) or a path to a .glb.
# The PNG goes to $PREVIEW_DIR (default: the Claude scratchpad if set, else /tmp)
# and its path is printed last.  Re-importing the glb doubles as validation:
# the object/material inventory is printed before rendering.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLENDER="${BLENDER:-blender}"
name="$1"; shift || true
if [[ -f "$name" ]]; then glb="$name"; name="$(basename "$glb" .glb)"; else glb="$ROOT/app/assets/models/$name.glb"; fi
[[ -f "$glb" ]] || { echo "no such model: $glb" >&2; exit 1; }

suffix=""
args=("$@")
for ((i=0; i<${#args[@]}; i++)); do
  if [[ "${args[$i]}" == "--view" ]]; then suffix="_${args[$((i+1))]}"; fi
done
OUT_DIR="${PREVIEW_DIR:-${CLAUDE_SCRATCHPAD:-/tmp}/blender/previews}"
mkdir -p "$OUT_DIR"
out="$OUT_DIR/${name}${suffix}.png"

runner=()
if command -v xvfb-run >/dev/null 2>&1; then runner=(xvfb-run -a); fi
if ! "${runner[@]}" "$BLENDER" -b --python-exit-code 1 -P "$ROOT/blender/lib/preview.py" -- "$glb" "$out" "$@" 2>&1 \
     | grep -E '^(==|  |Error|Traceback|  File|.*Error)'; then
  echo "EEVEE preview failed; retrying with Workbench" >&2
  "${runner[@]}" "$BLENDER" -b --python-exit-code 1 -P "$ROOT/blender/lib/preview.py" -- "$glb" "$out" "$@" --engine WORKBENCH 2>&1 \
     | grep -E '^(==|  |Error|Traceback|  File|.*Error)'
fi
echo "$out"
