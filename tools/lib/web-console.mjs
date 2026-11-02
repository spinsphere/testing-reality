// Drive a headless Chromium at a URL over the DevTools protocol and collect its console.
//   node web-console.mjs <url> <seconds> <out.json> [screenshot.png] [done-regex]
// Writes {console: [{level, text}], exceptions: [text], done: bool} and exits 0; the caller
// decides what counts as success. Stops early when a console line matches done-regex.
// Needs Node 22+ (global WebSocket) and `chromium` or `google-chrome` on PATH.
import { spawn, execSync } from "node:child_process";
import { writeFileSync } from "node:fs";

const [url, secondsArg, outPath, shotPath, doneRe] = process.argv.slice(2);
const seconds = Number(secondsArg || 60);
const browser = [process.env.CHROME || "", "chromium", "chromium-browser", "google-chrome"].filter(Boolean).find((b) => {
  try { execSync(`command -v ${b}`, { stdio: "ignore" }); return true; } catch { return false; }
});
if (!browser) { console.error("no chromium/google-chrome on PATH"); process.exit(2); }

// GPU flags: CHROME_FLAGS overrides the default (software WebGL 2 through SwiftShader);
// CHROME_HEADLESS="" runs a windowed Chromium (for xvfb-run), default "--headless=new".
const gpuFlags = process.env.CHROME_FLAGS !== undefined
  ? process.env.CHROME_FLAGS.split(" ").filter(Boolean)
  : ["--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--use-gl=angle"];
const headless = process.env.CHROME_HEADLESS !== undefined ? process.env.CHROME_HEADLESS : "--headless=new";
// A headless Chromium must not see a DISPLAY: ANGLE's SwiftShader (Vulkan) still opens an
// XCB connection when one is set, and a forwarded or stale DISPLAY (ssh -X) then leaves the
// page without WebGL 2 ("DisplayVkXcb: xcb_connect() failed").
const withoutDisplay = (env) => { const e = { ...env }; delete e.DISPLAY; delete e.WAYLAND_DISPLAY; return e; };
const chrome = spawn(browser, [
  ...(headless ? [headless] : []), "--no-sandbox", "--disable-dev-shm-usage", "--no-first-run",
  ...gpuFlags, "--window-size=1280,720", "--remote-debugging-port=0", "about:blank",
].filter(Boolean), { stdio: ["ignore", "ignore", "pipe"], env: headless ? withoutDisplay(process.env) : process.env });

const wsUrl = await new Promise((resolve, reject) => {
  let buf = "";
  chrome.stderr.on("data", (d) => {
    buf += d.toString();
    const m = buf.match(/DevTools listening on (ws:\/\/\S+)/);
    if (m) resolve(m[1]);
  });
  chrome.on("exit", () => reject(new Error("chromium exited before DevTools came up\n" + buf)));
  setTimeout(() => reject(new Error("no DevTools endpoint after 20 s\n" + buf)), 20000);
});

const ws = new WebSocket(wsUrl);
await new Promise((r) => (ws.onopen = r));
let nextId = 1;
const pending = new Map();
const result = { url, console: [], exceptions: [], done: false };
let sessionId = null;
const send = (method, params = {}, sid = sessionId) =>
  new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject });
    ws.send(JSON.stringify(sid ? { id, method, params, sessionId: sid } : { id, method, params }));
  });
let finish;
const finished = new Promise((r) => (finish = r));
ws.onmessage = (ev) => {
  const msg = JSON.parse(ev.data);
  if (msg.id && pending.has(msg.id)) {
    const p = pending.get(msg.id); pending.delete(msg.id);
    msg.error ? p.reject(new Error(JSON.stringify(msg.error))) : p.resolve(msg.result);
    return;
  }
  if (msg.method === "Runtime.consoleAPICalled") {
    const text = msg.params.args.map((a) => a.value ?? a.description ?? "").join(" ");
    result.console.push({ level: msg.params.type, text });
    if (doneRe && new RegExp(doneRe).test(text)) { result.done = true; finish(); }
  } else if (msg.method === "Runtime.exceptionThrown") {
    result.exceptions.push(msg.params.exceptionDetails.exception?.description ?? msg.params.exceptionDetails.text);
  } else if (msg.method === "Log.entryAdded") {
    result.console.push({ level: msg.params.entry.level, text: `[${msg.params.entry.source}] ${msg.params.entry.text}` });
  }
};

const { targetId } = await send("Target.createTarget", { url: "about:blank" }, null);
sessionId = (await send("Target.attachToTarget", { targetId, flatten: true }, null)).sessionId;
await send("Runtime.enable");
await send("Log.enable");
await send("Page.enable");
await send("Page.navigate", { url });
setTimeout(finish, seconds * 1000);
await finished;
if (shotPath) {
  try {
    const shot = await send("Page.captureScreenshot", { format: "png" });
    writeFileSync(shotPath, Buffer.from(shot.data, "base64"));
  } catch (e) { result.exceptions.push("screenshot failed: " + e.message); }
}
writeFileSync(outPath, JSON.stringify(result, null, 1));
ws.close();
chrome.kill("SIGKILL");
process.exit(0);
