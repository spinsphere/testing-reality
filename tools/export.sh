#!/usr/bin/env bash
# Export release builds into builds/: Linux and Windows desktop, and the web (WebGL 2) build.
#   tools/export.sh [linux|windows|web|all ...]      (default: all)
# Needs the Godot 4.7.2 export templates (Editor → Manage Export Templates) and, per target,
# the Quagmire SDK toolchain described in quagmire-engine/sdk-godot/build.sh (a target whose
# toolchain is missing is skipped with a message). The web build is booted in headless
# Chromium afterwards (tools/check-web.sh) when node and chromium are available.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/godot.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/godot.sh"
TARGETS=("$@"); [ ${#TARGETS[@]} -eq 0 ] && TARGETS=(all)
[ "${TARGETS[0]}" = "all" ] && TARGETS=(linux windows web)

"$ROOT/tools/build-sdk.sh" release "${TARGETS[@]}"

echo "== Import"
$GODOT --headless --path "$ROOT/app" --import >/dev/null 2>&1 || true
for t in "${TARGETS[@]}"; do
  case "$t" in
    linux)   PRESET="Linux x86_64";   OUT="$ROOT/builds/linux/testing-reality.x86_64" ;;
    windows) PRESET="Windows x86_64"; OUT="$ROOT/builds/windows/testing-reality.exe" ;;
    web)     PRESET="Web";            OUT="$ROOT/builds/webgl/index.html" ;;
    *) echo "unknown target $t" >&2; exit 2 ;;
  esac
  if [ "$t" != "linux" ] && [ ! -f "$ROOT/app/addons/quagmire/bin/$t/"* ]; then
    echo "== Export $PRESET: skipped (no SDK binary for $t)"; continue
  fi
  mkdir -p "$(dirname "$OUT")"
  echo "== Export $PRESET -> ${OUT#"$ROOT/"}"
  $GODOT --headless --path "$ROOT/app" --export-release "$PRESET" "$OUT" 2>&1 | grep -i -E 'error|warning' | grep -v -E 'V-Sync' || true
  ls -la "$(dirname "$OUT")"
done

if printf '%s\n' "${TARGETS[@]}" | grep -qx web; then
  echo "== Web build check (headless Chromium)"
  "$ROOT/tools/check-web.sh" lab:exp1 || { echo "web build check failed" >&2; exit 1; }
fi
