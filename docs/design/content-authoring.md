# Content authoring guide

How chapters are written for the Testing Reality app. Source material: `docs/content/*.md`
(faithful transcriptions of the site). Target: `app/content/<chapter>/pages.json` +
`app/content/<chapter>/equations.json`, rendered by `app/ui/chapter/chapter.gd` and
`app/ui/chapter/block_factory.gd`.

Chapter ids: `intro`, `exp1` … `exp7` (the Home page is the app's hub, not a chapter).

## Pedagogy rules

1. **Faithful to the site, in the site's voice.** Keep the author's framing (the "paradox",
   "Try it yourself", "Is that real?", lab photos, raw data, FAQs) and all its equations, in
   the same order. You may split long pages into several app pages (each page = one screen
   of reading, 150–350 words plus figures).
2. **Teach the maths just in time.** The reader is assumed to know no trigonometry, linear
   algebra or complex numbers. Before an idea is used for the first time in the whole
   course, insert a `callout` of kind `math` ("Maths check-in") that explains it in plain
   words with a picture (a `widget` or `figure`), then use it. Required check-ins and where
   they first appear:
   - intro: states as labels → arrows in a plane (vectors) → adding arrows / scaling arrows
     → length of an arrow (Pythagoras) → unit length = "valid state" → perpendicular =
     distinguishable → squaring amplitudes = probabilities → linear maps (R45) →
     constructive/destructive interference as algebra.
   - exp1: angles and the cosine as a projection (shadow) → cos² as a probability →
     changing basis (writing ↔ in terms of the diagonals) → chaining operators.
   - exp2: paths as states → the complex phase as a rotating arrow (e^{iks}), wave number k
     → adding two arrows with different phases → |sum|² gives 1 + cos → small-angle geometry
     (path difference d·y/L) → the sinc² envelope (qualitative: narrower slit, wider spread).
   - exp3: tensor product = "and" list |pol⟩|path⟩ → orthogonal environment states add in
     intensity, not amplitude → rewriting a state in another basis is a free choice.
   - exp4: two-particle states, correlation vs independence, cos(α−β) identity.
   - exp5–7: tracing over a partner (what the signal alone can show), post-selection =
     sorting data by the partner's outcome, why timing does not matter.
3. **Every experiment chapter ends with a lab hand-off**: a `lab` block with a concrete
   task list ("Set P1 to 0°, P2 out, P3 to 90°. Confirm 0 %. Now put P2 in at 45°.").
4. **Use the site's notation exactly**: `|↔⟩`, `|↕⟩`, `|↗↙⟩`, `|↘↖⟩`, `|lost⟩`, `P_↔`,
   `Ψ_0`, `I = Prob · I_0`, `(sin α/α)²`, `|Φ⁺⟩`. In BBCode text, kets written as `|↔⟩` are
   automatically styled; in TeX use `\ket{\H}`, `\ket{\V}`, `\diag`, `\antidiag`, `\lost`.
5. Keep prose short. One idea per paragraph. Headings every 2–4 paragraphs.

## pages.json

```json
{
  "sections": [
    {"id": "abstract", "title": "Abstract", "pages": [
      {"title": "Page heading", "blocks": [ ...blocks... ]}
    ]},
    {"id": "lab", "title": "Lab experiment", "pages": [...]},
    {"id": "results", "title": "Result and analysis", "pages": [...]},
    {"id": "theory", "title": "Theory and equations", "pages": [...]},
    {"id": "literature", "title": "Literature and video", "pages": [...]}
  ]
}
```

Block types (see `block_factory.gd`):

| type | fields | notes |
|---|---|---|
| `text` | `text` (BBCode) | `[b]`, `[i]`, `[color=#hex]`, `[url=…]…[/url]` allowed |
| `subheading` | `text` | H2 inside a page |
| `list` | `items: [BBCode…]` | bullets |
| `equation` | `id`, `caption?` | id from equations.json; caption in BBCode |
| `figure` | `src`, `caption?`, `height?` | `src` is a `res://` path; site images live in `res://assets/figures/<chapter>/…` (copy what you need from `docs/site-assets/<page-slug>/` and keep file names) |
| `table` | `header: [...]`, `rows: [[...]]` | cells are BBCode |
| `callout` | `kind: math\|note\|paradox\|lab\|video\|history`, `title?`, `text` | "Maths check-in" = `math` |
| `widget` | `scene`, `params?`, `height?` | interactive widget, see below |
| `lab` | `label?` | button into the chapter's 3D lab |
| `video` | `title`, `url` | external link card |
| `spacer` | `height` | |

## equations.json

```json
{"macros": {}, "equations": {"psi0": "\\ket{\\Psi_0} = …", "...": "..."}}
```
Built-in macros: `\ket{}`, `\bra{}`, `\braket{}{}`, `\H` (↔), `\V` (↕), `\diag` (↗↙),
`\antidiag` (↘↖), `\lost` (|lost⟩). Render with
`cd tools/mathgen && node mathgen.mjs --in ../../app/content/<chapter>/equations.json --out ../../app/assets/math/<chapter>/ --png`.
Multi-line derivations: use `\begin{aligned} … \end{aligned}`. Keep one equation per id;
ids are snake_case and stable.

## Widgets (interactive blocks)

All widgets are `Control` scenes under `res://ui/widgets/`, expose `configure(params: Dictionary)`,
fill their parent (`size_flags_vertical = EXPAND_FILL`), use `Palette`/`ThemeBuilder`, and
draw with `_draw()` or `PatternPlot`. Physics must come from the Quagmire SDK
(`QuagmireSystem`, `QuagmireScreen`), never re-implemented by hand.

| scene | params | what it shows |
|---|---|---|
| `vector_playground.tscn` | `labels:["A","B"]`, `angle:60`, `mode:"unit"\|"superposition"\|"projection"\|"basis_change"`, `show_probabilities:true` | A draggable unit arrow between two perpendicular basis arrows; live components, length check (Pythagoras), probabilities as squares; `basis_change` also shows the diagonal basis |
| `apple_evolution.tscn` | — | Slider t∈[0,1]: amplitudes of red/rotten/eaten flow as in the Introduction; bars + the current ket |
| `probability_bars.tscn` | `amplitudes:[…]`, `labels:[…]` | Amplitude → squared probability bars, editable amplitudes with auto-normalisation |
| `phasor_widget.tscn` | `mode:"single"\|"sum"`, `wavelength_nm:405` | A rotating arrow e^{iks} vs distance s; in `sum` mode two arrows with a path-difference slider and the resulting |sum|² |
| `malus_widget.tscn` | `input_angle:45` | Polarizer angle dial; projection drawing, cos² curve, transmission % (uses QuagmireSystem) |
| `polarizer_chain.tscn` | `polarizers:[0,45,90]`, `input_angle:45`, `max:3` | The site's Exp 1 simulator: add/remove polarizers, drag angles (pink handles), transmission % |
| `slit_pattern.tscn` | `wavelength_nm:808`, `slit_width_um:200`, `separation_um:400`, `slits:2`, `distance_m:0.5` | The site's Exp 2 simulator: sliders N, w, d, λ, "cover one slit", envelope vs full pattern (QuagmireScreen) |
| `eraser_widget.tscn` | `p1_angle:45`, `entangled:false`, `p2_angle:45` | Exp 3/5/6 simulator: marked double slit, P1 (and optional idler P2) dials; singles and coincidence curves |
| `coincidence_widget.tscn` | `alpha:0`, `beta:0` | Exp 4: two polarizer dials, live ½cos²(α−β), heat-map of all angle pairs |
| `tensor_widget.tscn` | `left:["↔","↕"]`, `right:["A","B"]` | "and" lists: pick amplitudes for each factor and watch the product state expand |

Widgets must work at 860×360 px (chapter column) and degrade gracefully when smaller.

## Figures

Copy site images you reference into `app/assets/figures/<chapter>/` (keep names, PNG/JPG
only). Prefer the site's schematics (LASER → P1 → D1 with Ψ labels) and lab photos; skip
screenshots of the StackBlitz simulators (the widgets replace them).

## Checklist before finishing a chapter

- `python3 -I -c "import json;json.load(open('app/content/<id>/pages.json'))"` passes
- every `equation` id exists in equations.json and rendered without error
- every `figure` src exists; every `widget` scene name is from the table above
- maths check-ins appear before first use; the chapter ends with a `lab` block (except intro)
- do NOT run Godot yourself (imports clash between processes); the integrator screenshots pages
