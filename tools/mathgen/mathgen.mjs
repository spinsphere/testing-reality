#!/usr/bin/env node
// mathgen: render a manifest of LaTeX equations to display-mode SVG (and
// optionally PNG) for the Godot app, using MathJax 3 in Node.
//
//   node mathgen.mjs --in <manifest.json> --out <dir> [options]
//   node mathgen.mjs --all [options]        # every app/content/*/equations.json
//
// Options
//   --color <css>          fill colour written into the SVG (default #e8e4ff)
//   --display-scale <n>    px per ex = 16 * n (default 1.0)
//   --png                  also rasterise at 3x with rsvg-convert or ImageMagick
//   --force                ignore stored hashes and re-render everything
//   --quiet                only print warnings, errors and the summary
//
// Manifest: { "macros": { "name": "expansion" | ["expansion", nargs] },
//             "equations": { "<id>": "<tex>" } }
// Output:   <out>/<id>.svg [, <out>/<id>.png], <out>/index.json

import {createHash} from 'node:crypto';
import {execFileSync, spawnSync} from 'node:child_process';
import {existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync} from 'node:fs';
import {basename, dirname, join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

import {mathjax} from 'mathjax-full/js/mathjax.js';
import {TeX} from 'mathjax-full/js/input/tex.js';
import {SVG} from 'mathjax-full/js/output/svg.js';
import {liteAdaptor} from 'mathjax-full/js/adaptors/liteAdaptor.js';
import {RegisterHTMLHandler} from 'mathjax-full/js/handlers/html.js';
import {AllPackages} from 'mathjax-full/js/input/tex/AllPackages.js';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(HERE, '..', '..');
const PX_PER_EX = 16;
const PNG_ZOOM = 3;

// Physics macros shared by every chapter. A manifest's "macros" block is
// merged on top of these, so a chapter can override or extend them.
const DEFAULT_MACROS = {
  ket: ['\\left|#1\\right\\rangle', 1],
  bra: ['\\left\\langle#1\\right|', 1],
  braket: ['\\left\\langle#1\\middle|#2\\right\\rangle', 2],
  diag: '\\nearrow\\!\\swarrow',             // |↗↙⟩  +45° polarisation
  antidiag: '\\searrow\\!\\nwarrow',         // |↘↖⟩  -45° polarisation
  lost: '\\ket{\\text{lost}}',               // the bookkeeping state |lost⟩
  H: '\\leftrightarrow',                     // ↔ horizontal
  V: '\\updownarrow',                        // ↕ vertical
};

// ---------------------------------------------------------------- CLI args

function usage(code = 0) {
  const text = readFileSync(fileURLToPath(import.meta.url), 'utf8')
    .split('\n').slice(1, 19).map((l) => l.replace(/^\/\/ ?/, '')).join('\n');
  (code ? console.error : console.log)(text);
  process.exit(code);
}

function parseArgs(argv) {
  const opts = {in: null, out: null, all: false, color: '#e8e4ff', displayScale: 1, png: false, force: false, quiet: false};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const next = () => {
      if (i + 1 >= argv.length) { console.error(`error: ${a} needs a value`); usage(2); }
      return argv[++i];
    };
    switch (a) {
      case '--in': opts.in = next(); break;
      case '--out': opts.out = next(); break;
      case '--all': opts.all = true; break;
      case '--color': opts.color = next(); break;
      case '--display-scale': {
        const v = Number(next());
        if (!Number.isFinite(v) || v <= 0) { console.error('error: --display-scale must be a positive number'); usage(2); }
        opts.displayScale = v; break;
      }
      case '--png': opts.png = true; break;
      case '--force': opts.force = true; break;
      case '--quiet': opts.quiet = true; break;
      case '-h': case '--help': usage(0); break;
      default: console.error(`error: unknown argument ${a}`); usage(2);
    }
  }
  if (!opts.all && (!opts.in || !opts.out)) { console.error('error: --in and --out are required (or use --all)'); usage(2); }
  if (opts.all && (opts.in || opts.out)) { console.error('error: --all cannot be combined with --in/--out'); usage(2); }
  return opts;
}

// ---------------------------------------------------------------- rasteriser

function which(cmd) {
  const r = spawnSync('which', [cmd], {encoding: 'utf8'});
  return r.status === 0 ? r.stdout.trim() : null;
}

function findRasteriser() {
  if (which('rsvg-convert')) {
    return {
      name: 'rsvg-convert',
      run: (svg, png) => execFileSync('rsvg-convert', ['--zoom', String(PNG_ZOOM), '--format', 'png', '--output', png, svg], {stdio: 'pipe'}),
    };
  }
  const im = which('magick') ? 'magick' : which('convert') ? 'convert' : null;
  if (im) {
    return {
      name: `ImageMagick (${im})`,
      // 96 dpi is the SVG reference resolution, so 96 * zoom gives a zoom-x raster.
      run: (svg, png) => execFileSync(im, ['-background', 'none', '-density', String(96 * PNG_ZOOM), svg, png], {stdio: 'pipe'}),
    };
  }
  return null;
}

// ---------------------------------------------------------------- MathJax

function makeRenderer(macros) {
  const adaptor = liteAdaptor();
  RegisterHTMLHandler(adaptor);
  const tex = new TeX({
    // 'noundefined' would typeset an unknown \macro as red text instead of
    // failing; drop it so typos are reported as errors.
    packages: AllPackages.filter((p) => p !== 'noundefined'),
    macros,
    // Throw instead of producing an <merror> node, so bad TeX is reported.
    formatError: (_jax, err) => { throw err; },
  });
  const svg = new SVG({fontCache: 'none'});
  const doc = mathjax.document('', {InputJax: tex, OutputJax: svg});
  return (texSource) => adaptor.innerHTML(doc.convert(texSource, {display: true}));
}

const EX = /^(-?[\d.]+)ex$/;

function exToPx(value, scale) {
  const m = EX.exec(value);
  if (!m) throw new Error(`unexpected MathJax dimension "${value}"`);
  return Number((Number(m[1]) * PX_PER_EX * scale).toFixed(2));
}

/** Post-process MathJax's SVG for Godot: explicit colour, px size, baseline. */
function finishSvg(raw, color, scale) {
  const open = raw.match(/<svg\b[^>]*>/);
  if (!open) throw new Error('MathJax produced no <svg> element');
  const attrs = {};
  for (const m of open[0].matchAll(/([\w:-]+)="([^"]*)"/g)) attrs[m[1]] = m[2];
  const width = exToPx(attrs.width, scale);
  const height = exToPx(attrs.height, scale);
  const alignMatch = /vertical-align:\s*(-?[\d.]+)ex/.exec(attrs.style || '');
  // Distance from the bottom of the image up to the text baseline, in px.
  const baseline = alignMatch ? -exToPx(`${alignMatch[1]}ex`, scale) : 0;

  let tag = open[0]
    .replace(/\swidth="[^"]*"/, ` width="${width}"`)
    .replace(/\sheight="[^"]*"/, ` height="${height}"`)
    .replace(/\sstyle="[^"]*"/, '')
    .replace(/\srole="[^"]*"/, '')
    .replace(/\sfocusable="[^"]*"/, '');
  tag = tag.replace(/>$/, ` data-baseline="${baseline}">`);

  let body = raw.slice(open[0].length);
  // MathJax wraps everything in <g fill="currentColor" stroke="currentColor">;
  // Godot has no notion of currentColor, so bake the colour in.
  body = body.replace(/currentColor/g, color);
  // ImageMagick's SVG rasteriser does not inherit fill into <rect>/<line> (stretchy
  // braces, arrow rules), so set it explicitly where missing.
  body = body.replace(/<(rect|line)\b([^>]*)>/g, (m, tag, attrs) =>
    /\bfill=/.test(attrs) ? m : `<${tag} fill="${color}" stroke="${color}"${attrs}>`);
  const svg = `<?xml version="1.0" encoding="UTF-8"?>\n${tag}${body}`;
  const textFallbacks = [...svg.matchAll(/<text\b[^>]*>([^<]*)<\/text>/g)].map((m) => m[1]);
  return {svg, width, height, baseline, textFallbacks};
}

// ---------------------------------------------------------------- one manifest

function hashOf(parts) {
  return createHash('sha256').update(JSON.stringify(parts)).digest('hex').slice(0, 16);
}

const ID_OK = /^[A-Za-z0-9][A-Za-z0-9._-]*$/;

function loadJson(path, fallback) {
  try { return JSON.parse(readFileSync(path, 'utf8')); } catch (e) {
    if (fallback !== undefined && e.code === 'ENOENT') return fallback;
    throw new Error(`cannot read ${path}: ${e.message}`);
  }
}

function buildManifest(manifestPath, outDir, opts, rasteriser, log) {
  const manifest = loadJson(manifestPath);
  if (!manifest || typeof manifest !== 'object' || typeof manifest.equations !== 'object') {
    throw new Error(`${manifestPath}: expected {"macros": {...}, "equations": {...}}`);
  }
  const macros = {...DEFAULT_MACROS, ...(manifest.macros || {})};
  mkdirSync(outDir, {recursive: true});

  const indexPath = join(outDir, 'index.json');
  const previous = loadJson(indexPath, {});
  const prevEntries = previous.equations || {};
  const render = makeRenderer(macros);
  const macroHash = hashOf(macros);

  const entries = {};
  const failures = [];
  let rendered = 0, skipped = 0, rasterised = 0;

  for (const [id, tex] of Object.entries(manifest.equations)) {
    const reject = (error) => { failures.push({id, error}); console.error(`  error: ${JSON.stringify(id)}: ${error}`); };
    if (!ID_OK.test(id)) { reject('id is not file-name safe (use letters, digits, . _ -)'); continue; }
    if (typeof tex !== 'string' || !tex.trim()) { reject('tex must be a non-empty string'); continue; }

    const svgFile = `${id}.svg`, pngFile = `${id}.png`;
    const svgPath = join(outDir, svgFile), pngPath = join(outDir, pngFile);
    const hash = hashOf({tex, macroHash, color: opts.color, scale: opts.displayScale});
    const prev = prevEntries[id];

    let entry;
    if (!opts.force && prev && prev.hash === hash && existsSync(svgPath)) {
      entry = {...prev};
      skipped++;
    } else {
      try {
        const {svg, width, height, baseline, textFallbacks} = finishSvg(render(tex), opts.color, opts.displayScale);
        writeFileSync(svgPath, svg);
        entry = {file: svgFile, width, height, baseline, tex, hash};
        rendered++;
        log(`  rendered ${id}  (${width} x ${height} px)`);
        if (textFallbacks.length) {
          console.warn(`  warning: ${id}: no glyph for ${textFallbacks.map((t) => JSON.stringify(t)).join(', ')}; ` +
            'MathJax emitted <text>, which Godot\'s SVG importer does not render. Use a \\command or another symbol.');
        }
      } catch (e) {
        const msg = (e && e.message) || String(e);
        failures.push({id, error: msg});
        console.error(`  error: ${id}: TeX error: ${msg}\n         tex: ${tex}`);
        continue;
      }
    }

    if (opts.png) {
      if (!rasteriser) {
        entry.png = undefined;
      } else if (entry.png && existsSync(pngPath) && entry.hash === hash && !opts.force && prev && prev.hash === hash) {
        // PNG is up to date.
      } else {
        try {
          rasteriser.run(svgPath, pngPath);
          entry.png = pngFile;
          rasterised++;
        } catch (e) {
          failures.push({id, error: `rasterise failed: ${(e.stderr && e.stderr.toString().trim()) || e.message}`});
          console.error(`  error: ${id}: rasterise failed: ${(e.stderr && e.stderr.toString().trim()) || e.message}`);
        }
      }
    }
    if (entry.png === undefined) delete entry.png;
    entries[id] = entry;
  }

  // Drop files for ids that left the manifest.
  let removed = 0;
  for (const id of Object.keys(prevEntries)) {
    if (!(id in manifest.equations) && !failures.some((f) => f.id === id)) {
      for (const f of [`${id}.svg`, `${id}.png`]) {
        const p = join(outDir, f);
        if (existsSync(p)) { rmSync(p); removed++; }
      }
    }
  }
  // Keep the previous entry for ids that failed this run, so the stale SVG (if any) stays usable.
  for (const f of failures) if (prevEntries[f.id] && !(f.id in entries)) entries[f.id] = {...prevEntries[f.id], stale: true};

  const index = {
    generated: new Date().toISOString(),
    manifest: basename(manifestPath),
    color: opts.color,
    displayScale: opts.displayScale,
    pxPerEx: PX_PER_EX * opts.displayScale,
    pngZoom: opts.png ? PNG_ZOOM : undefined,
    equations: entries,
  };
  if (index.pngZoom === undefined) delete index.pngZoom;
  writeFileSync(indexPath, JSON.stringify(index, null, 2) + '\n');

  return {rendered, skipped, rasterised, removed, failures, total: Object.keys(manifest.equations).length};
}

// ---------------------------------------------------------------- main

function main() {
  const opts = parseArgs(process.argv.slice(2));
  const log = opts.quiet ? () => {} : (...a) => console.log(...a);

  let rasteriser = null;
  if (opts.png) {
    rasteriser = findRasteriser();
    if (rasteriser) log(`rasteriser: ${rasteriser.name} at ${PNG_ZOOM}x`);
    else console.warn('warning: --png requested but neither rsvg-convert nor ImageMagick (magick/convert) is on PATH; skipping PNGs');
  }

  const jobs = [];
  if (opts.all) {
    const contentDir = join(REPO_ROOT, 'app', 'content');
    if (!existsSync(contentDir)) { console.error(`error: ${contentDir} does not exist`); process.exit(2); }
    for (const chapter of readdirSync(contentDir, {withFileTypes: true})) {
      if (!chapter.isDirectory()) continue;
      const m = join(contentDir, chapter.name, 'equations.json');
      if (existsSync(m)) jobs.push({manifest: m, out: join(REPO_ROOT, 'app', 'assets', 'math', chapter.name)});
    }
    if (!jobs.length) { console.warn(`warning: no app/content/*/equations.json found under ${contentDir}`); }
  } else {
    jobs.push({manifest: resolve(opts.in), out: resolve(opts.out)});
  }

  let anyFailed = false;
  for (const job of jobs) {
    log(`${job.manifest} -> ${job.out}`);
    let r;
    try {
      r = buildManifest(job.manifest, job.out, opts, rasteriser, log);
    } catch (e) {
      console.error(`error: ${e.message}`);
      anyFailed = true;
      continue;
    }
    const bits = [`${r.rendered} rendered`, `${r.skipped} unchanged`];
    if (opts.png) bits.push(`${r.rasterised} PNGs`);
    if (r.removed) bits.push(`${r.removed} stale files removed`);
    if (r.failures.length) bits.push(`${r.failures.length} FAILED`);
    console.log(`  ${r.total} equations: ${bits.join(', ')}`);
    if (r.failures.length) anyFailed = true;
  }
  process.exit(anyFailed ? 1 : 0);
}

main();
