#!/usr/bin/env bash
# Prove that a fresh clone of the pushed repository opens in Godot without errors and that
# opening it in the editor changes no tracked file (no .import churn).
#
#   tools/check-clone.sh [git-url-or-path]   (default: this repository's origin)
#
# Steps: clone → headless import → headless editor open/quit → (xvfb) editor with the real
# renderer for a few hundred frames → run the smoke test → `git status` must be empty.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-$(command -v godot || echo "$HOME/.local/bin/godot")}"
SRC="${1:-$(git -C "$ROOT" remote get-url origin)}"
WORK="$(mktemp -d /tmp/tr-clone-XXXXXX)"
LOG="$WORK/logs"; mkdir -p "$LOG"
IGNORE='XDG_|ALSA|PulseAudio|pulseaudio|jack|libdecor|Xlib:|DRI|MESA|libEGL|GLX|glx|xkbcommon|Fontconfig|No such audio|Set Audio|audio driver|Unable to open|XOpenIM|vk_|Vulkan|godot-rust|Godot Engine|TextServer|OpenGL API|V-Sync'
status=0

echo "== fresh clone check: $SRC -> $WORK"
git clone -q "$SRC" "$WORK/repo" || { echo "clone failed"; exit 1; }
APP="$WORK/repo/app"
[ -e "$APP/addons/quagmire/bin/linux/libquagmire_godot.so" ] || { echo "FAIL: extension binary missing in clone"; status=1; }

run() {  # run <name> <command...>
	local name="$1"; shift
	printf '%-26s' "$name"
	( cd "$APP" && "$@" ) > "$LOG/$name.log" 2>&1
	local code=$?
	local bad
	bad=$(grep -E 'SCRIPT ERROR|^ERROR|USER ERROR|Parse Error|^WARNING' "$LOG/$name.log" | grep -vE "$IGNORE" | head -20)
	if [ -z "$bad" ] && { [ $code -eq 0 ] || [ $code -eq 124 ]; }; then echo "ok"; else echo "FAILED (exit $code)"; echo "$bad" | sed 's/^/    /'; status=1; fi
}

run "import"            timeout 600 "$GODOT" --headless --path . --import
run "editor (headless)" timeout 600 "$GODOT" --headless -e --path . --quit
if command -v xvfb-run > /dev/null; then
	# the editor with a real renderer: file-system scan, previews, detect-3D texture reimports
	run "editor (xvfb, GL)" timeout 900 xvfb-run -a -s "-screen 0 1600x900x24" "$GODOT" -e --path . --quit-after 600
fi
run "smoke: quagmire"   timeout 120 "$GODOT" --headless --path . -s tests/smoke_quagmire.gd
run "run_all (headless)" timeout 900 "$GODOT" --headless --path . -s tests/run_all.gd

printf '%-26s' "tracked files unchanged"
changed=$(git -C "$WORK/repo" status --porcelain)
if [ -z "$changed" ]; then echo "ok"; else echo "FAILED"; echo "$changed" | sed 's/^/    /'; status=1; fi

echo "== $( [ $status -eq 0 ] && echo CLONE OK || echo FAILURES ) — logs in $LOG"
[ $status -eq 0 ] && rm -rf "$WORK"
exit $status
