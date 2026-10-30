#!/usr/bin/env bash
# Build the Quagmire Godot SDK (release) and copy it into the app's addon folder.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$HOME/.cargo/bin:$PATH"
PROFILE="${1:-release}"
cd "$ROOT/quagmire-engine"
if [ "$PROFILE" = "release" ]; then cargo build -p quagmire-godot --release; else cargo build -p quagmire-godot; fi
mkdir -p "$ROOT/app/addons/quagmire/bin/linux"
cp "target/$PROFILE/libquagmire_godot.so" "$ROOT/app/addons/quagmire/bin/linux/libquagmire_godot.so"
echo "installed $PROFILE build -> app/addons/quagmire/bin/linux/libquagmire_godot.so"
