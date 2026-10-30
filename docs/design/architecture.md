# Architecture

Three layers, three folders, one repository (for now):

```
quagmire-engine/            reusable quantum physics engine (Rust)        ─┐ split off later
  core/      quagmire-core  pure library, no engine deps                    │
  sdk-godot/ quagmire-godot GDExtension (godot-rust gdext 0.5, api-4-7)    ─┘
app/                        Testing Reality, Godot 4.7 project
blender/                    headless Blender scripts → app/assets/models/*.glb
tools/                      mathgen (MathJax → SVG), build and export scripts
docs/                       plan, content specs, design docs, source PDFs
```

## 1. Quagmire Engine (core)

### What the site's physics needs

Every experiment on the site is a *small discrete quantum register* plus a *continuous detector
coordinate* handled analytically:

| Degree of freedom | Basis | Appears in |
|---|---|---|
| Photon 1 polarization | `H`, `V` (+ sink labels `lost@P1` …) | all |
| Photon 1 path | `S` (source), `A`, `B` (slits), later `y` on the screen | Exp 2–7 |
| Photon 2 (idler) polarization | `H`, `V` (+ sinks) | Exp 4–7 |
| Idler path / fate | `D2`, `wall`, `unplugged` | Exp 6–7 |

Polarizers are **non-unitary**: the site keeps the norm by sending blocked amplitude into
orthogonal `|lost⟩` states. The engine models that literally (a *sink* label per polarizer) so
the UI can show "lost at P1: 50 %" exactly as the site's derivations do.

Interference on the screen is computed from the register state: for each screen position `y`,

```
I(y) = Σ_e | Σ_p  c[p, e] · φ_p(y) |²
```

where `p` runs over path labels (`A`, `B`), `e` over every other basis tuple (polarizations,
idler state — the "environment"), `c[p, e]` are the register amplitudes after post-selection
(coincidence conditions are projectors on the idler), and `φ_p(y) = √D_p(y) · e^{i k r_p(y)}`
is the propagation kernel with the single-slit Fraunhofer envelope `D = (sin α / α)²`,
`α = π w sin θ_p / λ`. Orthogonal environment states add *incoherently* (sum over `e`), which
is exactly why which-path marking kills fringes and why idler projection at ±45° restores them.

### Core model (Rust, `quagmire-core`)

```
System            owns Properties, the sparse state vector, the RNG, an op log
Property          name, basis labels (Vec<String>), dynamic sink labels
State             HashMap<Key, Complex<f64>> ; Key = packed per-property indices (u64)
Op                Unitary1{prop, matrix}, Diagonal{prop, phases}, Relabel{prop, map, when: Pred},
                  ProjectOrSink{prop, projector, sink}, Unitary2{props, matrix}, Custom(fn)
Pred              conjunction of (prop == label) / (prop != label)
Source            photon(pol), spdc_pair(chi, phi), split_path(prop, from, to:[..], amps)
Query             probability(pred), marginals(prop), conditional(pred) -> System,
                  amplitudes(), ket_string(Unicode|LaTeX), purity/visibility helpers
Measure           born(prop, rng) / forced(prop, label), measure_polarization(angle)
Screen            Geometry{lambda, slit_width, slit_sep, distance, slit_positions}
                  intensity_profile(sys, path_prop, geom, ys, post_select: Pred) -> Vec<f64>
                  box_convolve(profile, width), sample_positions(profile, ys, n, rng)
```

Design rules (from the reference-engine analyses in `/home/soliax/sites/quagmire-designing`):
explicit world object, no globals; f64 everywhere; seedable PCG RNG and forced outcomes for
replay; sparse state keyed by packed indices; limits as data; typed errors; property tests for
norm preservation and unitarity; golden tests from the site's own numbers.

Jones-matrix conventions: angles measured from horizontal, counter-clockwise looking into the
beam; `|H⟩ = (1,0)`, `|V⟩ = (0,1)`, `|↗↙⟩ = (|H⟩+|V⟩)/√2`, `|↘↖⟩ = (|H⟩−|V⟩)/√2`; HWP at θ is
`[[cos2θ, sin2θ],[sin2θ, −cos2θ]]`; polarizer at θ projects onto `(cosθ, sinθ)`.

### Out of scope for this project, kept open in the design
Density matrices / noise channels, large registers (>16 qudits), continuous-space solvers.
The C ABI (`quagmire-capi`) is planned for Unity/Unreal and is not needed by Godot (gdext links
the Rust crate directly).

## 2. Quagmire SDK for Godot

GDExtension built from `quagmire-engine/sdk-godot` with gdext. Exposed classes:

- `QuagmireSystem` (RefCounted): `add_property(name, labels)`, `set_state(dict)`, `apply_polarizer(prop, angle_deg, sink_name)`, `apply_hwp(prop, angle_deg)`, `apply_retarder(...)`, `apply_pbs(pol_prop, path_prop, in_path, t_path, r_path)`, `split_path(prop, from, to, amps)`, `spdc(pol1, pol2, chi_deg, phi_deg)`, `probability(pred: Dictionary)`, `marginals(prop)`, `conditional(pred)`, `measure(prop)`, `ket_text()`, `ket_latex()`, `amplitudes()`.
- `QuagmireScreen` (RefCounted): geometry setters, `profile(system, path_prop, ys, post_select)`, `box_convolve`, `sample(n)`.
- `QuagmireRng` seed control via `QuagmireSystem.seed`.

Addon layout: `app/addons/quagmire/{quagmire.gdextension, bin/linux/libquagmire_godot.so, bin/windows/quagmire_godot.dll}`.

## 3. Testing Reality app (Godot 4.7)

### Navigation
```
Main (autoload: AppState, Theme, Narration)
 └─ Hub            the site's experiment grid as cards; progress badges
     └─ Chapter    sidebar TOC (Abstract / Lab / Results / Theory / Literature) + page stack
         ├─ StoryPage   text blocks, equation SVGs, figures, inline math-primer widgets
         └─ Lab         3D scene; orbit camera; apparatus inspector; state ket HUD; plots
```
Keyboard: `←/→` pages, `Esc` menu, `Tab` toggles inspector, `L` enter/leave lab, `Space`
run/pause photons, `R` reset apparatus. Mouse: orbit (RMB/LMB drag), pan (MMB), zoom (wheel),
click apparatus to select.

### Content pipeline
Chapters are data: `app/content/<chapter>/pages.json` (blocks) + `equations.tex` manifest →
`tools/mathgen` renders every equation to `app/assets/math/<chapter>/<id>.svg`. Story text is
authored from `docs/content/*.md`, rewritten as narration that teaches each maths idea just
before it is used (vectors → length → projection/cosine → complex phase → adding phasors →
tensor "and" lists).

### Lab scenes
A `Lab` scene composes `Apparatus` nodes (each wraps a `.glb` + a `Component` script with
parameters, e.g. `Polarizer.angle_deg`) along a `BeamPath`. A `LabController` rebuilds the
`QuagmireSystem` from the component chain every time a parameter changes, then:
1. updates the state-ket HUD after each component (`Ψ0 … Ψ3` like the site's diagrams),
2. renders the beam segments with intensity ∝ surviving probability and colour from wavelength,
3. computes the screen profile / coincidence profile and draws it in the `PatternPlot`,
4. optionally fires photons one at a time (positions sampled from the profile) onto the screen.
Lab data (CSV) can be overlaid on the plot where the site publishes it.

### Visual direction
Blue/purple palette (`#0f1020` background, `#5b5bd6` primary, `#8b5cf6` accent, `#c7d2fe`
text), dark lab room with a lit optical table, violet 405 nm beam, faint deep-red
"visualised infrared" for the 808 nm laser with an on-screen note. Equations rendered white on
dark panels matching the site's serif display headings.

## 4. Blender pipeline

`blender/lib/qlab.py`: PBR material helpers (black anodised aluminium, stainless, glass with
IOR 1.5, AR-coated optic tint, ABS plastic, PCB), parametric builders (post, post holder, base,
1-inch lens mount, rotation mount with angle scale, kinematic mirror mount, breadboard with
hole grid as baked normal map), export to glTF with `export_apply=True`. One script per
instrument under `blender/models/`, each writing `app/assets/models/<name>.glb`. Run
`tools/build-models.sh` to rebuild everything headlessly.


## Engine boundary — what lives in Quagmire and what lives in the app

Rule: **anything that computes a physical quantity lives in the Quagmire Engine** (Rust
core, exposed through the GDExtension SDK). The app composes engine calls, renders, and
narrates. The engine must stay useful for other games, so it never knows about tables,
Godot nodes or the site's chapters.

| Concern | Where | API |
|---|---|---|
| State, operators, polarizers/wave plates/retarders/PBS, slits, SPDC, sinks | engine | `QuagmireSystem.*` |
| Probabilities, marginals, conditionals, measurement, collapse | engine | `probability`, `marginals`, `measure`, `force`, `sample` |
| **Joint draw of one photon's (or one pair's) fate** | engine | `sample_outcome()` → `{property: label}` |
| **Detector statistics** (Poisson clicks in a window) | engine | `poisson(mean)`, `counts(rate, dt)` |
| Screen pattern `I(y)`, envelope, visibility, detector-slit convolution | engine | `screen_profile`, `QuagmireProfile.*` |
| **Count rate at a detector position** (`flux × slit / ∫I dy`), interpolation | engine | `QuagmireProfile.rate_scale`, `rate_at`, `intensity_at`, `integral` |
| **Textbook geometry** `λL/d`, `λL/w` | engine | `QuagmireScreen.fringe_spacing`, `envelope_zero` |
| Ket pretty-printing (Unicode / LaTeX) | engine | `ket_text`, `ket_latex`, `ket_text_mapped` |
| Which apparatus an outcome label belongs to, beam geometry, camera, HUD, plots | app | `Apparatus`, `LabController`, `LabBase` |
| Acquisition bookkeeping (elapsed time, per-channel totals, display) | app | `LabBase.acquisition_*` (counts come from `dice.counts`) |
| Lab-data CSV overlays and their scaling to the predicted peak | app | `LabData`, `SlitLabBase` |
| Shutter / power / pair-rate *parameters* and `rate_scale()` bookkeeping | app | `Optics.Laser`, `Optics.SPDCSource`, `LabController.rate_scale()` |

Each `Optics.*` apparatus is a thin adapter: its `apply()` is one or two engine calls (for
example `Optics.Polarizer.apply` → `sys.polarizer(...)`, `Optics.Wall.apply` →
`sys.relabel` + `sys.mark_sink`). Closed-form "textbook" expressions that appear in the
results panels (`½cos²(α−β)`, `|sin 2θ|`, `1 + sin 2γ cos kΔ`) are displayed **next to** the
engine's number as the formula the student has just learnt; they are labels, never the
source of a displayed measurement. Experiment 1's Malus factors are read from the engine's
stage-by-stage survival (`LabController.alive_after`).

Audit, 2026-10-31 (Phase 8): the first version of the acquisition and the pair animation
put Poisson sampling, a joint Born-rule draw over `amplitudes()`, the `∫I dy` rate
normalisation, profile interpolation and `λL/d` into GDScript. All five moved into the
engine (`core/src/system.rs`, `core/src/screen.rs`) with golden tests, and the GDScript now
calls the SDK. Future rule of thumb: if a line of GDScript contains `cos`, `sin`, `exp`,
`sqrt` or a sum over amplitudes and it is not drawing, it belongs in the engine.
