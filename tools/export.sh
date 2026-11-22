#!/usr/bin/env bash
# Export release builds into builds/: Linux and Windows desktop, the web (WebGL 2) build and
# the Android APK, then package each one for distribution in builds/dist/ as
# testing-reality-quagmire-<platform>.<zip|tgz|apk>.
#   tools/export.sh [linux|windows|web|android|all ...]      (default: all)
# Android signs with the release keystore named by GODOT_ANDROID_KEYSTORE_RELEASE_PATH /
# _USER / _PASSWORD; when unset, a self-signed one is created once under
# ~/.local/share/godot/keystores/ (testing-reality-release.keystore, password in the .pass
# file beside it).
# Needs the Godot 4.7.2 export templates (Editor → Manage Export Templates) and, per target,
# the Quagmire SDK toolchain described in quagmire-engine/sdk-godot/build.sh (a target whose
# toolchain is missing is skipped with a message). The web build is booted in headless
# Chromium afterwards (tools/check-web.sh) when node and chromium are available.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/godot.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/godot.sh"
TARGETS=("$@"); [ ${#TARGETS[@]} -eq 0 ] && TARGETS=(all)
[ "${TARGETS[0]}" = "all" ] && TARGETS=(linux windows web android)

"$ROOT/tools/build-sdk.sh" release "${TARGETS[@]}"

echo "== Import"
$GODOT --headless --path "$ROOT/app" --import >/dev/null 2>&1 || true
for t in "${TARGETS[@]}"; do
  case "$t" in
    linux)   PRESET="Linux x86_64";   OUT="$ROOT/builds/linux/testing-reality.x86_64" ;;
    windows) PRESET="Windows x86_64"; OUT="$ROOT/builds/windows/testing-reality.exe" ;;
    web)     PRESET="Web";            OUT="$ROOT/builds/webgl/index.html" ;;
    android) PRESET="Android";        OUT="$ROOT/builds/android/testing-reality.apk"
             KS="$HOME/.local/share/godot/keystores"
             if [ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" ]; then
               mkdir -p "$KS"
               if [ ! -f "$KS/testing-reality-release.keystore" ]; then
                 (umask 077; head -c 24 /dev/urandom | base64 | tr -d '/+=' > "$KS/testing-reality-release.pass")
                 keytool -genkeypair -keystore "$KS/testing-reality-release.keystore" -alias testing-reality \
                   -storepass "$(cat "$KS/testing-reality-release.pass")" -keypass "$(cat "$KS/testing-reality-release.pass")" \
                   -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Testing Reality,O=Quagmire,C=NZ" >/dev/null 2>&1
               fi
               export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$KS/testing-reality-release.keystore"
               export GODOT_ANDROID_KEYSTORE_RELEASE_USER="testing-reality"
               GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$(cat "$KS/testing-reality-release.pass")"
               export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
             fi ;;
    *) echo "unknown target $t" >&2; exit 2 ;;
  esac
  if [ "$t" != "linux" ] && [ ! -f "$ROOT/app/addons/quagmire/bin/$t/"* ]; then
    echo "== Export $PRESET: skipped (no SDK binary for $t)"; continue
  fi
  mkdir -p "$(dirname "$OUT")"
  echo "== Export $PRESET -> ${OUT#"$ROOT/"}"
  $GODOT --headless --path "$ROOT/app" --export-release "$PRESET" "$OUT" 2>&1 | grep -i -E 'error|warning' | grep -v -E 'V-Sync' || true
  ls -la "$(dirname "$OUT")"
  # distribution package
  DIST="$ROOT/builds/dist"; mkdir -p "$DIST"
  case "$t" in
    linux)   tar -C "$ROOT/builds/linux" -czf "$DIST/testing-reality-quagmire-linux.tgz" . ;;
    windows) (cd "$ROOT/builds/windows" && rm -f "$DIST/testing-reality-quagmire-windows.zip" && zip -q -r "$DIST/testing-reality-quagmire-windows.zip" .) ;;
    web)     (cd "$ROOT/builds/webgl" && rm -f "$DIST/testing-reality-quagmire-webgl.zip" && zip -q -r "$DIST/testing-reality-quagmire-webgl.zip" .) ;;
    android) cp "$OUT" "$DIST/testing-reality-quagmire-android.apk" ;;
  esac
done

if printf '%s\n' "${TARGETS[@]}" | grep -qx web; then
  echo "== Web build check (headless Chromium)"
  "$ROOT/tools/check-web.sh" lab:exp1 || { echo "web build check failed" >&2; exit 1; }
fi
if printf '%s\n' "${TARGETS[@]}" | grep -qx android && [ -f "$ROOT/builds/android/testing-reality.apk" ]; then
  echo "== Android APK check"
  "$ROOT/tools/check-android.sh" || { echo "android build check failed" >&2; exit 1; }
fi
ls -la "$ROOT/builds/dist" 2>/dev/null || true
