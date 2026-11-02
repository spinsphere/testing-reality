#!/usr/bin/env bash
# Build the Quagmire Godot SDK for one target and print the path of the resulting library.
#   sdk-godot/build.sh <linux|windows|web> [release|debug]
# This script belongs to the engine (it knows nothing about any host project); a host copies
# the printed file into its addon folder (Testing Reality: tools/build-sdk.sh).
#
# linux    stable Rust, native toolchain
# windows  stable Rust, `rustup target add x86_64-pc-windows-gnu` + mingw-w64
# web      wasm32-unknown-emscripten Emscripten side module for Godot's single-threaded
#          "Extensions Support" web templates. Needs nightly Rust with rust-src
#          (`rustup toolchain install nightly -c rust-src` and
#          `rustup target add wasm32-unknown-emscripten --toolchain nightly`) and the
#          Emscripten version Godot's web templates were built with — 4.0.20 for Godot 4.7.2
#          (`~/emsdk`, or EMSDK=/path). The flags live in ../.cargo/config.toml.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?target: linux | windows | web}"
PROFILE="${2:-release}"
export PATH="$HOME/.cargo/bin:$PATH"
FLAG=""; [ "$PROFILE" = "release" ] && FLAG="--release"
cd "$HERE/.."
case "$TARGET" in
  linux)
    cargo build -p quagmire-godot $FLAG >&2
    echo "$PWD/target/$PROFILE/libquagmire_godot.so" ;;
  windows)
    rustup target list --installed | grep -q x86_64-pc-windows-gnu || { echo "rustup target x86_64-pc-windows-gnu not installed" >&2; exit 3; }
    cargo build -p quagmire-godot $FLAG --target x86_64-pc-windows-gnu >&2
    echo "$PWD/target/x86_64-pc-windows-gnu/$PROFILE/quagmire_godot.dll" ;;
  web)
    EMSDK="${EMSDK:-$HOME/emsdk}"
    if ! command -v emcc >/dev/null 2>&1; then
      [ -f "$EMSDK/emsdk_env.sh" ] || { echo "Emscripten not found: install emsdk 4.0.20 in $EMSDK or set EMSDK" >&2; exit 3; }
      # shellcheck disable=SC1091
      source "$EMSDK/emsdk_env.sh" >/dev/null 2>&1
    fi
    WANT="${EMCC_VERSION:-4.0.20}"
    HAVE="$(emcc --version | head -1 | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    [ "$HAVE" = "$WANT" ] || echo "warning: emcc $HAVE, Godot 4.7.2 templates were built with $WANT (set EMCC_VERSION to silence)" >&2
    rustup run nightly rustc --version >/dev/null 2>&1 || { echo "nightly Rust not installed (rustup toolchain install nightly -c rust-src)" >&2; exit 3; }
    cargo +nightly build -p quagmire-godot $FLAG --features web-nothreads -Zbuild-std=std,panic_abort --target wasm32-unknown-emscripten >&2
    echo "$PWD/target/wasm32-unknown-emscripten/$PROFILE/quagmire_godot.wasm" ;;
  *) echo "unknown target $TARGET" >&2; exit 2 ;;
esac
