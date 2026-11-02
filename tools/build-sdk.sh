#!/usr/bin/env bash
# Build the Quagmire Godot SDK and install it into the app's addon folder.
#   tools/build-sdk.sh [release|debug] [linux|windows|web|all ...]      (default: release linux)
# The compile step is the engine's own (quagmire-engine/sdk-godot/build.sh); this script only
# knows where Testing Reality keeps the binaries. They are committed so a fresh clone opens in
# Godot without a Rust toolchain. Each file is installed through a temporary file + rename so
# a Godot that has the library mapped (tests, editor) is not corrupted, and stripped in release.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROFILE="${1:-release}"; shift || true
TARGETS=("$@"); [ ${#TARGETS[@]} -eq 0 ] && TARGETS=(linux)
[ "${TARGETS[0]}" = "all" ] && TARGETS=(linux windows web)
BIN="$ROOT/app/addons/quagmire/bin"
for t in "${TARGETS[@]}"; do
  echo "== Quagmire SDK ($t, $PROFILE)"
  if ! SRC="$("$ROOT/quagmire-engine/sdk-godot/build.sh" "$t" "$PROFILE")"; then
    echo "   skipped $t (toolchain missing, see above)"; continue
  fi
  case "$t" in
    linux)   DEST="$BIN/linux/libquagmire_godot.so";   STRIP="strip --strip-unneeded" ;;
    windows) DEST="$BIN/windows/quagmire_godot.dll";   STRIP="x86_64-w64-mingw32-strip --strip-unneeded" ;;
    web)     DEST="$BIN/web/quagmire_godot.wasm";      STRIP="" ;;   # already minimal (panic=abort, hidden symbols)
  esac
  mkdir -p "$(dirname "$DEST")"
  cp "$SRC" "$DEST.tmp"
  # SOURCE_DATE_EPOCH: binutils' strip otherwise stamps the time into the PE header, so the
  # committed Windows DLL would change on every rebuild (the link itself is reproducible).
  if [ "$PROFILE" = "release" ] && [ -n "$STRIP" ] && command -v "${STRIP%% *}" >/dev/null; then SOURCE_DATE_EPOCH=0 $STRIP "$DEST.tmp"; fi
  mv -f "$DEST.tmp" "$DEST"
  echo "   installed -> ${DEST#"$ROOT/"} ($(du -h "$DEST" | cut -f1))"
done
