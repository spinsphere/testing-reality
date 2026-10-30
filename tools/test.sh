#!/usr/bin/env bash
# Full test run: engine golden tests, Godot import, smoke tests and the runtime harness
# (headless and, when xvfb-run is available, with the real GL Compatibility renderer).
# Any SCRIPT ERROR / ERROR / WARNING line printed by Godot fails the run.
#
#   tools/test.sh            run everything
#   tools/test.sh --quick    skip the xvfb pass
#
# Logs: builds/test-logs/<step>.log
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/godot.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/godot.sh"
LOG="$ROOT/builds/test-logs"
mkdir -p "$LOG"
QUICK=0
[ "${1:-}" = "--quick" ] && QUICK=1

# Benign lines from the platform layer under Xvfb / no audio device.
IGNORE='XDG_|ALSA|PulseAudio|pulseaudio|jack|libdecor|Xlib:|DRI|MESA|libEGL|GLX|glx|xkbcommon|Fontconfig|No such audio|Set Audio|audio driver|Unable to open|XOpenIM|vk_|Vulkan|godot-rust|Godot Engine|TextServer|OpenGL API|V-Sync'

status=0
step() {  # step <name> <command...>   (runs in app/ unless the command cd's)
	local name="$1"; shift
	printf '%-28s' "$name"
	( cd "$ROOT/app" && "$@" ) > "$LOG/$name.log" 2>&1
	local code=$?
	local bad
	bad=$(grep -E 'SCRIPT ERROR|^ERROR|USER ERROR|USER WARNING|^WARNING|Parse Error|^FAIL|FAILED' "$LOG/$name.log" | grep -vE "$IGNORE" | head -40)
	if [ $code -eq 0 ] && [ -z "$bad" ]; then
		echo "ok"
	else
		echo "FAILED (exit $code)"
		[ -n "$bad" ] && echo "$bad" | sed 's/^/    /'
		status=1
	fi
}

echo "== Testing Reality — full test ($(date -Is))"
echo "godot: $($GODOT --version 2>/dev/null | head -1)"

printf '%-28s' "cargo test (engine)"
if ( cd "$ROOT/quagmire-engine" && cargo test --quiet ) > "$LOG/cargo-test.log" 2>&1; then
	echo "ok ($(grep -c '^test result' "$LOG/cargo-test.log") suites)"
else
	echo "FAILED"; tail -20 "$LOG/cargo-test.log" | sed 's/^/    /'; status=1
fi

[ -e "$ROOT/app/addons/quagmire/bin/linux/libquagmire_godot.so" ] || { echo "GDExtension binary missing — run tools/build-sdk.sh"; exit 1; }

step "godot import"         timeout 300 $GODOT --headless --path . --import
step "smoke: quagmire"      timeout 120 $GODOT --headless --path . -s tests/smoke_quagmire.gd
step "smoke: widgets"       timeout 120 $GODOT --headless --path . -s tests/smoke_widgets.gd
step "run_all (headless)"   timeout 600 $GODOT --headless --path . -s tests/run_all.gd
if [ $QUICK -eq 0 ] && command -v xvfb-run > /dev/null; then
	# This pass exists to catch shader/renderer errors, so it runs small: software GL (llvmpipe)
	# manages about a frame a second on the 3D labs, so it runs at 640x360 with the harness's
	# --quick sweeps (the headless pass above does the full sweep). Screenshots use the full size.
	step "run_all (xvfb, GL)" timeout 5400 xvfb-run -a -s "-screen 0 640x360x24" $GODOT --path . -s tests/run_all.gd -- --quick
	for route in hub chapter:intro:0 chapter:exp1:2 lab:exp1 lab:exp2 lab:exp3 lab:exp4 lab:exp5 lab:exp6 lab:exp7; do
		step "shot $route" timeout 300 xvfb-run -a -s "-screen 0 1600x900x24" $GODOT --path . -- "--go=$route" "--shot=$LOG/shot-${route//:/-}.png"
	done
fi

echo "== $( [ $status -eq 0 ] && echo ALL OK || echo FAILURES ) — logs in $LOG"
exit $status
