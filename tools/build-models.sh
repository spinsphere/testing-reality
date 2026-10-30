#!/usr/bin/env bash
# Rebuild every apparatus model headlessly:  tools/build-models.sh [name ...]
# With no arguments every blender/models/*.py is run; otherwise only the
# named ones (e.g. `tools/build-models.sh laser_module optical_table`).
# Output: app/assets/models/<name>.glb  (+ regenerated blender/textures/)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BLENDER="${BLENDER:-blender}"
MODELS="$ROOT/blender/models"

# Textures first (deterministic; cheap). Pass FORCE_TEXTURES=1 to regenerate.
if [[ "${FORCE_TEXTURES:-0}" == "1" || ! -f "$ROOT/blender/textures/breadboard_normal.png" ]]; then
  python3 "$ROOT/blender/lib/texgen.py" all
fi

if [[ $# -gt 0 ]]; then
  scripts=()
  for n in "$@"; do scripts+=("$MODELS/${n%.py}.py"); done
else
  mapfile -t scripts < <(ls "$MODELS"/*.py | sort)
fi

fail=0
for s in "${scripts[@]}"; do
  name="$(basename "$s" .py)"
  echo "=== building $name"
  if ! "$BLENDER" -b --python-exit-code 1 -P "$s" -- "${MODEL_ARGS:-}" 2>&1 \
       | grep -E -v '^(Blender [0-9]|Read prefs|$)' | grep -E '^(  |----|Error|Traceback|  File|.*Error)' ; then
    echo "!!! $name failed"; fail=1
  fi
done
echo "=== models in $ROOT/app/assets/models:"
ls -la "$ROOT/app/assets/models"/*.glb
exit $fail
