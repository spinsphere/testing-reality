# mathgen — equation renderer for the Godot app

Renders each chapter's LaTeX equations to display-mode SVG (and optionally
PNG) with MathJax 3 running in Node, so the Godot app can show typeset maths
without a runtime TeX engine.

```
tools/mathgen/mathgen.mjs            the CLI
app/content/<chapter>/equations.json a chapter's manifest (hand-written)
app/assets/math/<chapter>/           output: <id>.svg [, <id>.png], index.json
```

## Usage

```
cd tools/mathgen
npm install                        # once; installs mathjax-full

node mathgen.mjs --in <manifest.json> --out <dir> [options]
node mathgen.mjs --all [options]   # every app/content/*/equations.json

npm run build                      # = --all
npm run build:png                  # = --all --png
npm run rebuild                    # = --all --force
npm run build -- --png --color '#ffffff'   # pass extra options through npm
```

Options:

| option                 | default   | meaning                                                   |
|------------------------|-----------|-----------------------------------------------------------|
| `--color <css>`        | `#e8e4ff` | fill colour baked into the SVG (MathJax's `currentColor`)  |
| `--display-scale <n>`  | `1.0`     | size multiplier; 1 ex = 16 px x n                          |
| `--png`                | off       | also rasterise each SVG at 3x with `rsvg-convert`, else ImageMagick (`magick`/`convert`) |
| `--force`              | off       | ignore stored hashes, re-render everything                 |
| `--quiet`              | off       | print only warnings, errors and the per-manifest summary   |

Exit code is 1 if any equation failed (bad TeX, unknown macro, unsafe id,
rasteriser error); the other equations are still written.

## Manifest format

```json
{
  "macros": { "ket": ["\\left|#1\\right\\rangle", 1], "half": "\\tfrac{1}{2}" },
  "equations": {
    "psi0": "\\ket{\\Psi_0} = \\sqrt{\\tfrac{2}{3}}\\ket{\\mathrm{red}} + \\tfrac{1}{\\sqrt{3}}\\ket{\\mathrm{eaten}}",
    "evolution": "\\begin{aligned} \\ket{\\mathrm{red}} &\\mapsto \\ket{\\mathrm{rotten}} \\\\ \\ket{\\mathrm{eaten}} &\\mapsto \\ket{\\mathrm{eaten}} \\end{aligned}"
  }
}
```

- Ids must be file-name safe: letters, digits, `.`, `_`, `-`.
- `macros` uses MathJax's syntax: `"name": "expansion"` or
  `"name": ["expansion", nargs]`. They are merged on top of the built-ins.
- Multi-line equations: wrap in `\begin{aligned} ... \end{aligned}` (or
  `gathered`, `cases`, `pmatrix`...). All of MathJax's standard packages
  (ams, physics-free, color, boldsymbol, ...) are loaded.

### Built-in macros

| macro            | expands to                                | renders         |
|------------------|-------------------------------------------|-----------------|
| `\ket{x}`        | `\left|x\right\rangle`                    | \|x⟩            |
| `\bra{x}`        | `\left\langle x\right|`                   | ⟨x\|            |
| `\braket{x}{y}`  | `\left\langle x\middle|y\right\rangle`    | ⟨x\|y⟩          |
| `\H`, `\V`       | `\leftrightarrow`, `\updownarrow`         | ↔, ↕            |
| `\diag`          | `\nearrow\!\swarrow`                      | ↗↙  (+45°)      |
| `\antidiag`      | `\searrow\!\nwarrow`                      | ↘↖  (-45°)      |
| `\lost`          | `\ket{\text{lost}}`                       | \|lost⟩         |

Unicode arrows can be written directly in the TeX: `\ket{↔}`, `\ket{↕}`,
`\ket{↗}`, `\ket{↘}` all map to real glyph paths. If a character has no
glyph in MathJax's TeX font (e.g. `⟲`), MathJax emits a `<text>` element
instead; mathgen warns about it because Godot's SVG importer (ThorVG) does
not render SVG text. Use a `\command` or another symbol in that case.

## Output

For each id, `<out>/<id>.svg`:

- display-mode layout, transparent background;
- `width`/`height` attributes in px (MathJax's ex units x 16 px x scale),
  so Godot's importer picks a sensible texture size;
- `fill`/`stroke` set to `--color` (no `currentColor` left);
- `data-baseline`: px from the bottom edge up to the text baseline, for
  aligning an equation image with surrounding text.

With `--png`, `<out>/<id>.png` is the same image at 3x (transparent).

`<out>/index.json`:

```json
{
  "generated": "...", "manifest": "equations.json",
  "color": "#e8e4ff", "displayScale": 1, "pxPerEx": 16, "pngZoom": 3,
  "equations": {
    "psi0": { "file": "psi0.svg", "png": "psi0.png",
              "width": 494.21, "height": 69.39, "baseline": 25.3,
              "tex": "...", "hash": "267f32ef25952130" }
  }
}
```

In Godot, load `index.json`, then `load("res://assets/math/intro/" + entry.file)`
and size the `TextureRect` from `width`/`height` (or let the import scale do it).

## Incremental builds

Each entry's `hash` covers the TeX, the full macro set, the colour and the
scale. On the next run an id is skipped when its hash matches and the SVG
exists (and the PNG exists, with `--png`). Ids removed from the manifest
have their SVG/PNG deleted. An id that fails keeps its previous entry with
`"stale": true` so the old image stays usable until the TeX is fixed.
Use `--force` to re-render everything.

## Adding a chapter

1. Create `app/content/<chapter>/equations.json`.
2. `npm run build` (or `build:png`) from `tools/mathgen`.
3. Commit both the manifest and `app/assets/math/<chapter>/`.

Equations are transcribed from `docs/content/*.md`; the intro manifest
covers E1-E15 of `01-introduction.md` (E6's two probability lines are split
into `prob_rotten` and `prob_eaten`).
