#!/usr/bin/env bash
# Boot the exported web build (builds/webgl) in headless Chromium and check that the Quagmire
# GDExtension loaded and a laboratory ran through the engine. Usage: tools/check-web.sh [route]
# (default route lab:exp1). Needs node >= 22 and chromium/google-chrome; prints WEB OK / WEB FAIL.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROUTE="${1:-lab:exp1}"
DIR="$ROOT/builds/webgl"
LOG="$ROOT/builds/test-logs"; mkdir -p "$LOG"
[ -f "$DIR/index.html" ] || { echo "WEB FAIL: $DIR/index.html missing (run tools/export.sh)"; exit 1; }
export PATH="$HOME/.nvm/versions/node/v22.13.1/bin:$PATH"
command -v node >/dev/null || { echo "WEB FAIL: node not found"; exit 1; }

# a static server on a free port (the single-threaded build needs no special headers)
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$DIR" >"$LOG/web-http.log" 2>&1 &
HTTP=$!
trap 'kill $HTTP 2>/dev/null || true' EXIT
sleep 1

URL="http://127.0.0.1:$PORT/index.html?go=$ROUTE&perf=1"
OUT="$LOG/web-${ROUTE//:/-}.json"
node "$ROOT/tools/lib/web-console.mjs" "$URL" 240 "$OUT" "$LOG/web-${ROUTE//:/-}.png" '^PERF route='
python3 - "$OUT" "$ROUTE" <<'PY'
import json, sys, re
r = json.load(open(sys.argv[1])); route = sys.argv[2]
lines = [c["text"] for c in r["console"]]
errs = [l for l in lines if re.search(r"ERROR|Can't open dynamic library|GDExtension|not declared|Parser Error|Failed to load", l)] + r["exceptions"]
# not errors: Godot's own build banner mentions "GDExtension support"; the PagedAllocator line
# is Godot's known exit-time report in single-threaded web builds (we quit after --perf).
errs = [e for e in errs if "V-Sync" not in e and not e.startswith("Build configuration") and "Pages in use exist at exit" not in e]
boot = [l for l in lines if l.startswith("BOOT ")]
perf = [l for l in lines if l.startswith("PERF ")]
ok = bool(boot) and "quagmire=" in boot[0] and "quagmire=none" not in boot[0] and bool(perf) and route.split(":")[1] in perf[0] and not errs
print("\n".join(boot + perf))
for e in errs[:20]: print("  !", e[:300])
print(f"{'WEB OK' if ok else 'WEB FAIL'}: {len(lines)} console lines, {len(errs)} errors, route {route}")
sys.exit(0 if ok else 1)
PY
