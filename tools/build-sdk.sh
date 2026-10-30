#!/usr/bin/env bash
# Build the Quagmire Godot SDK (release) and copy it into the app's addon folder.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$HOME/.cargo/bin:$PATH"
PROFILE="${1:-release}"
cd "$ROOT/quagmire-engine"
if [ "$PROFILE" = "release" ]; then cargo build -p quagmire-godot --release; else cargo build -p quagmire-godot; fi
mkdir -p "$ROOT/app/addons/quagmire/bin/linux"
# The binaries are committed so a fresh clone opens in Godot without a Rust toolchain; strip
# symbols to keep the repository small. Install through a temporary file + rename so a Godot
# that currently has the library mapped (tests, editor) is not corrupted.
DEST="$ROOT/app/addons/quagmire/bin/linux/libquagmire_godot.so"
cp "target/$PROFILE/libquagmire_godot.so" "$DEST.tmp"
[ "$PROFILE" = "release" ] && strip --strip-unneeded "$DEST.tmp"
mv -f "$DEST.tmp" "$DEST"
echo "installed $PROFILE build -> app/addons/quagmire/bin/linux/libquagmire_godot.so"
