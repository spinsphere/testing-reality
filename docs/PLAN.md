# Testing Reality — Project Plan

Living plan for building the *Testing Reality* quantum-optics site as an educational desktop
game. **If you are resuming work (new session, token reset): read this file, find the first
unchecked item under "Status", and continue from there. Do not wait for the user.**

See `docs/design/architecture.md` for the system design and `docs/content/` for the
page-by-page source material.

## Goals

1. **Quagmire Engine** (`quagmire-engine/`): a reusable quantum physics engine for games,
   written in Rust with a C ABI, independent of any game engine. Will be split into its own
   repository after this project.
2. **Quagmire SDK for Godot** (`quagmire-engine/sdk-godot/`): a GDExtension exposing the engine
   to GDScript as `Quagmire*` classes, shipped as a Godot addon.
3. **Testing Reality app** (`app/`): a Godot 4.7 desktop app. One narrated chapter per site page
   (Home, Introduction, Experiments 1–7), each mixing story pages (text + equations, teaching the
   maths from scratch) with an interactive 3D laboratory that reproduces the real apparatus and
   gives physically accurate results.
4. **3D apparatus** (`blender/` → `app/assets/models/`): built with headless Blender scripts,
   realistic PBR materials, real-lab look (optical breadboard, anodised mounts, glass optics),
   physically correct laser colour (405 nm violet; 808 nm shown as "invisible infrared").

## Phases

| # | Phase | Output | Status |
|---|-------|--------|--------|
| 0 | Ingest source PDFs, research, plan | `docs/content/*.md`, this plan, architecture doc | done |
| 1 | Quagmire Engine core | `quagmire-engine/core` crate, tests with golden values from the site | done |
| 2 | Quagmire SDK for Godot | gdext crate, `app/addons/quagmire/`, headless smoke test | done |
| 3 | App framework | theme, navigation hub, chapter/page system, math rendering pipeline, lab camera, inspector UI, plot widget | done |
| 4 | Blender apparatus pipeline | model scripts per instrument, glTF export, import into Godot | in progress (agent) |
| 5 | Chapters | Home, Introduction, Experiments 1–7 (story pages + labs) | done |
| 6 | Polish, builds, docs | Linux + Windows exports, README, engine docs for split-off | pending |

Phases 1, 3 and 4 are independent and run in parallel where agents allow. Phase 5 chapters are
independent of each other once Phases 2–4 exist; Experiment 1 is built first as the template.

## Status (checklist — keep updated, tick as you go)

### Phase 0 — Ingest and plan
- [x] Extract text + render all 198 PDF pages, contact sheets (scratchpad)
- [x] Confirm `C-Quantum formalism.pdf` is a duplicate of `A-Introduction New.pdf`
- [x] Install Blender 4.3.2 (apt), Godot 4.7.2 (`~/.local/bin/godot`) + export templates
- [x] Install Rust toolchain (rustup), verify gdext 0.5.5 has `api-4-7`
- [x] Verify MathJax (node) TeX → SVG works offline
- [x] Content specs written: `docs/content/00-home.md` … `08-experiment-7-detecting-not-recording.md`
- [ ] Review content specs, fix gaps, write `docs/design/physics-model.md` (unified model of all 7 experiments)
- [x] Try to fetch the site's lab CSV files (nice-to-have; "lab data overlay" feature)
- [x] Write `docs/PLAN.md`, `docs/design/architecture.md`
- [x] Commit Phase 0

### Phase 1 — Quagmire Engine core (Rust)
- [x] Workspace `quagmire-engine/Cargo.toml`, crate `quagmire-core`
- [x] `Complex`, labelled `Property` (qudit with named basis + dynamic sink labels), `System` (sparse state vector over tuples)
- [x] Operators: unitary on one property (Jones matrices: rotation, HWP, QWP, general retarder), diagonal phase, relabel/permutation conditioned on predicates (PBS), beam splitter, `project_or_sink` (polarizer with |lost⟩)
- [x] Sources: single photon with polarization, SPDC pair `cos χ|HH⟩ + e^{iφ} sin χ|VV⟩`, double-slit path split
- [x] Queries: `probability(predicate)`, `marginals`, `conditional(predicate)`, `amplitudes`, pretty ket string (Unicode + LaTeX)
- [x] Measurement: Born sampling with seedable PCG RNG, forced outcomes, `measure_in_basis(angle)`
- [x] Optics screen: `intensity_profile(path_property, geometry, ys)` with Fraunhofer envelope + exact path phases; coincidence post-selection; box convolution (detector slit); inverse-CDF photon sampling
- [x] Golden tests from the site: 3-polarizer 12.5 %, cos² law, Exp 3 table (0/90/±45), Exp 4 table, Exp 5.x constants, Exp 6 `1 + sin 2γ cos kΔ`
- [x] `quagmire-core` README + rustdoc
- [ ] Commit

### Phase 2 — Quagmire SDK for Godot
- [x] Crate `quagmire-godot` (gdext 0.5, `api-4-7`), classes `QuagmireSystem`, `QuagmireOptics`, `QuagmireScreen`
- [x] `app/addons/quagmire/quagmire.gdextension` + build script `tools/build-sdk.sh` (copies `.so` into addon)
- [x] Headless Godot smoke test (`godot --headless -s`) that computes the 12.5 % result through the extension
- [ ] Commit

### Phase 3 — App framework (Godot)
- [x] `app/project.godot` (Forward+ or Compatibility renderer — pick Compatibility for broad desktop GPUs; verify visuals), window 1600×900, blue/purple theme resource, fonts
- [x] Navigation: `Main` → `Hub` (experiment cards like the site's grid) → `Chapter` (TOC sidebar + page stack) → `Lab` (3D)
- [x] Story page system: data-driven pages (`.tres`/JSON) with blocks: text, equation (SVG), figure, interactive widget, "enter lab" button
- [x] Math pipeline: `tools/mathgen` (MathJax → SVG into `app/assets/math/`), equation manifest per chapter
- [x] Math primers (reusable widgets): 2D vector playground, Pythagoras/unit-length, projection = cosine, phasor/complex number, adding phasors (interference), "and" (tensor) lists, probability bars
- [x] Lab framework: orbit/pan/zoom camera, click-to-select apparatus, inspector panel (sliders/dials/presets), live state ket display, pattern plot widget, photon-by-photon mode, lab-data overlay hooks
- [ ] Commit

### Phase 4 — Blender apparatus
- [ ] `blender/lib/` shared helpers (materials, posts/mounts, breadboard, export)
- [ ] Models: optical table, laser module (405 nm / 808 nm), polarizer in rotation mount, HWP in rotation mount, PBS cube, plano-convex lens in mount, mirror in kinematic mount, beam dump, double-slit mask, adjustable single slit, BBO crystal mount, Berek compensator, SPCM detector on translation stage (+ 200 µm slit, filters, fibre collimator), coincidence counter box
- [ ] Export glTF (`.glb`) with baked textures where procedural; import check in Godot headless
- [ ] Commit

### Phase 5 — Chapters
- [x] 00 Home / hub
- [x] 01 Introduction (quantum apple, kets as arrows, superposition, R45, measurement; interactive)
- [x] 02 Experiment 1 — Polarizers (lab + 16 pages)
- [x] 03 Experiment 2 — Single/double slit (lab + 16 pages)
- [x] 04 Experiment 3 — Polarized double slit (lab + 16 pages)
- [x] 05 Experiment 4 — Entanglement: lab done; pages done
- [x] 06 Experiment 5 — lab done; pages done
- [x] 07 Experiment 6 — lab done; pages done
- [x] 08 Experiment 7 — lab done; pages done
- [ ] Commit after each chapter

### Phase 6 — Polish and release
- [x] Settings (reduce motion, quality), save progress, keyboard map
- [x] Linux x86_64 and Windows x86_64 exports (`tools/export.sh`), smoke-run Linux build
- [~] README written; screenshots and engine split-off notes pending
- [ ] Final commit

## Resume notes (updated 2026-10-31)

Still running as background agents when last checked: Blender pipeline (extra models:
double_slit_mask, single_slit_adjustable, bbo_crystal, berek_compensator, beam_dump,
fibre_collimator, coincidence_counter), widgets (app/ui/widgets/*), content for exp4–exp7.
On resume: `git status`, review + commit their output; re-import; screenshot chapters and labs;
then Phase 6 (polish, exports, README). Earlier notes follow.

## Resume notes (2026-10-30, end of session 1 — usage limit hit)

Background agents were still running when the session ended; their files land in the repo
uncommitted. On resume: check `git status`, review and commit each of these if present:
- `blender/` + `app/assets/models/*.glb` (Blender pipeline agent; verify with `tools/build-models.sh`
  and a lab screenshot: `xvfb-run -a -s "-screen 0 1600x900x24" ~/.local/bin/godot --path app -- --go=lab:exp1 --shot=/tmp/x.png`)
- `app/ui/widgets/*.tscn|gd` + `app/tests/smoke_widgets.gd` (widgets agent)
- `app/content/{intro,exp1,exp2,exp3}/` + `app/assets/math/*` + `app/assets/figures/*` (content agents)
Then: run `~/.local/bin/godot --headless --path app --import`, screenshot every chapter page
(`--go=chapter:exp1:N`) and fix layout issues; write labs exp2/exp3 (scanning detector +
PatternPlot + CSV overlay from `app/data/lab/`), generalise LabController/BeamRenderer for the
two-arm SPDC layouts, then labs exp4–exp7; then launch content agents for exp4–exp7.
Headless screenshots work via Xvfb + Mesa llvmpipe (see `app/scripts/main.gd` `--shot`).

## Conventions

- Commit small, often: `feat(engine): …`, `feat(app): …`, `feat(blender): …`, `docs: …`, `chore: …`.
- Rust: `cargo fmt`, `cargo clippy -D warnings`, tests next to code; no `unsafe` in `quagmire-core`.
- GDScript: typed, `snake_case`, one scene = one script, signals up / calls down.
- Blender scripts: one file per instrument in `blender/models/`, run with `blender -b -P <file>`; never commit `.blend` files, only scripts and exported `.glb`.
- Keep the repo tidy: scratch work in the session scratchpad, not in the repo.
- Autonomous resume: a cron wake-up in the Claude session re-reads this plan after a token reset.
