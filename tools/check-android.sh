#!/usr/bin/env bash
# Static check of the Android export (no emulator on the build server): the APK is signed,
# carries the Godot runtime and the Quagmire GDExtension for arm64-v8a with 16 KB page
# alignment, and declares the expected package. Prints ANDROID OK / ANDROID FAIL.
#   tools/check-android.sh [path/to.apk]
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APK="${1:-$ROOT/builds/android/testing-reality.apk}"
SDK="${ANDROID_HOME:-$HOME/Android/Sdk}"
BT="$(ls -d "$SDK"/build-tools/* 2>/dev/null | sort -V | tail -1)"
NDK_BIN="$(ls -d "$SDK"/ndk/*/toolchains/llvm/prebuilt/linux-x86_64/bin 2>/dev/null | sort -V | tail -1)"
fail=0
say() { printf '%-44s %s\n' "$1" "$2"; [ "$2" = ok ] || fail=1; }
[ -f "$APK" ] || { echo "ANDROID FAIL: $APK missing"; exit 1; }
if [ -x "$BT/apksigner" ]; then
  "$BT/apksigner" verify "$APK" >/dev/null 2>&1 && say "signature (apksigner verify)" ok || say "signature (apksigner verify)" FAIL
fi
LIST="$(unzip -l "$APK")"
grep -q 'lib/arm64-v8a/libgodot_android.so' <<<"$LIST" && say "lib/arm64-v8a/libgodot_android.so" ok || say "lib/arm64-v8a/libgodot_android.so" FAIL
grep -q 'lib/arm64-v8a/libquagmire_godot.so' <<<"$LIST" && say "lib/arm64-v8a/libquagmire_godot.so" ok || say "lib/arm64-v8a/libquagmire_godot.so" FAIL
grep -q 'armeabi-v7a' <<<"$LIST" && say "no 32-bit libraries" FAIL || say "no 32-bit libraries" ok
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
unzip -q -o "$APK" 'lib/arm64-v8a/libquagmire_godot.so' -d "$TMP" 2>/dev/null
if [ -x "$NDK_BIN/llvm-readelf" ] && [ -f "$TMP/lib/arm64-v8a/libquagmire_godot.so" ]; then
  ALIGN="$("$NDK_BIN/llvm-readelf" -l "$TMP/lib/arm64-v8a/libquagmire_godot.so" | awk '/LOAD/ {print $NF; exit}')"
  [ "$ALIGN" = "0x4000" ] && say "quagmire .so 16 KB page alignment ($ALIGN)" ok || say "quagmire .so 16 KB page alignment ($ALIGN)" FAIL
  "$NDK_BIN/llvm-nm" -D "$TMP/lib/arm64-v8a/libquagmire_godot.so" | grep -q ' T gdext_rust_init' && say "gdext_rust_init exported" ok || say "gdext_rust_init exported" FAIL
fi
if [ -x "$BT/aapt" ]; then
  BADGING="$("$BT/aapt" dump badging "$APK" 2>/dev/null)"
  grep -q "package: name='space.quagmire.testingreality'" <<<"$BADGING" && say "package space.quagmire.testingreality" ok || say "package name" FAIL
  grep -q "native-code: 'arm64-v8a'" <<<"$BADGING" && say "native-code arm64-v8a" ok || say "native-code arm64-v8a" FAIL
  echo "   $(grep -o "versionName='[^']*'" <<<"$BADGING")  $(grep -o "sdkVersion:'[^']*'" <<<"$BADGING")  $(grep -o "targetSdkVersion:'[^']*'" <<<"$BADGING")  $(du -h "$APK" | cut -f1)"
fi
if [ $fail -eq 0 ]; then echo "ANDROID OK"; else echo "ANDROID FAIL"; fi
exit $fail
