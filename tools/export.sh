#!/usr/bin/env bash
# Export release builds for Linux and Windows into builds/.
# Requires the Godot export templates (installed by the setup in docs/PLAN.md) and the
# Quagmire SDK built for both platforms (tools/build-sdk.sh and the mingw cross-build).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/godot.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/godot.sh"
export PATH="$HOME/.cargo/bin:$PATH"

echo "== Quagmire SDK (linux)"
"$ROOT/tools/build-sdk.sh" release
echo "== Quagmire SDK (windows, mingw)"
if rustup target list --installed | grep -q x86_64-pc-windows-gnu; then
  (cd "$ROOT/quagmire-engine" && cargo build -p quagmire-godot --release --target x86_64-pc-windows-gnu)
  mkdir -p "$ROOT/app/addons/quagmire/bin/windows"
  cp "$ROOT/quagmire-engine/target/x86_64-pc-windows-gnu/release/quagmire_godot.dll" "$ROOT/app/addons/quagmire/bin/windows/"
else
  echo "   skipped: rustup target x86_64-pc-windows-gnu not installed"
fi

mkdir -p "$ROOT/builds/linux" "$ROOT/builds/windows"
echo "== Import"
$GODOT --headless --path "$ROOT/app" --import >/dev/null 2>&1 || true
echo "== Export Linux"
$GODOT --headless --path "$ROOT/app" --export-release "Linux x86_64" "$ROOT/builds/linux/testing-reality.x86_64"
echo "== Export Windows"
$GODOT --headless --path "$ROOT/app" --export-release "Windows x86_64" "$ROOT/builds/windows/testing-reality.exe"
ls -la "$ROOT/builds/linux" "$ROOT/builds/windows"
