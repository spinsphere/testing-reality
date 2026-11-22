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
| 4 | Blender apparatus pipeline | model scripts per instrument, glTF export, import into Godot | done |
| 5 | Chapters | Home, Introduction, Experiments 1–7 (story pages + labs) | done |
| 6 | Polish, builds, docs | Linux + Windows exports, README, engine docs for split-off | done |

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
- [x] Review content specs, fix gaps, write `docs/design/physics-model.md` (unified model of all 7 experiments)
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
- [x] Commit

### Phase 2 — Quagmire SDK for Godot
- [x] Crate `quagmire-godot` (gdext 0.5, `api-4-7`), classes `QuagmireSystem`, `QuagmireOptics`, `QuagmireScreen`
- [x] `app/addons/quagmire/quagmire.gdextension` + build script `tools/build-sdk.sh` (copies `.so` into addon)
- [x] Headless Godot smoke test (`godot --headless -s`) that computes the 12.5 % result through the extension
- [x] Commit

### Phase 3 — App framework (Godot)
- [x] `app/project.godot` (Forward+ or Compatibility renderer — pick Compatibility for broad desktop GPUs; verify visuals), window 1600×900, blue/purple theme resource, fonts
- [x] Navigation: `Main` → `Hub` (experiment cards like the site's grid) → `Chapter` (TOC sidebar + page stack) → `Lab` (3D)
- [x] Story page system: data-driven pages (`.tres`/JSON) with blocks: text, equation (SVG), figure, interactive widget, "enter lab" button
- [x] Math pipeline: `tools/mathgen` (MathJax → SVG into `app/assets/math/`), equation manifest per chapter
- [x] Math primers (reusable widgets): 2D vector playground, Pythagoras/unit-length, projection = cosine, phasor/complex number, adding phasors (interference), "and" (tensor) lists, probability bars
- [x] Lab framework: orbit/pan/zoom camera, click-to-select apparatus, inspector panel (sliders/dials/presets), live state ket display, pattern plot widget, photon-by-photon mode, lab-data overlay hooks
- [x] Commit

### Phase 4 — Blender apparatus
- [x] `blender/lib/` shared helpers (materials, posts/mounts, breadboard, export)
- [x] Models: optical table, laser module (405 nm / 808 nm), polarizer in rotation mount, HWP in rotation mount, PBS cube, plano-convex lens in mount, mirror in kinematic mount, beam dump, double-slit mask, adjustable single slit, BBO crystal mount, Berek compensator, SPCM detector on translation stage (+ 200 µm slit, filters, fibre collimator), coincidence counter box
- [x] Export glTF (`.glb`) with baked textures where procedural; import check in Godot headless
- [x] Commit

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
- [x] Commit after each chapter

### Phase 6 — Polish and release
- [x] Settings (reduce motion, quality), save progress, keyboard map
- [x] Linux x86_64 and Windows x86_64 exports (`tools/export.sh`), smoke-run Linux build
- [x] README with screenshots, engine docs ready for split-off (now `quagmire-engine/docs/hosting.md`; engine split out to spinsphere/quagmire-engine as a submodule, 2026-11-04)
- [x] Final commit

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

## Phase 7 — QA hardening (started 2026-10-31)

User report: opening `app/project.godot` in Godot 4.7.2 shows parse errors; the chapter menus
raise "Identifier QuagmireSystem not declared". Root cause under investigation: the GDExtension
binaries (`app/addons/quagmire/bin/`) were git-ignored so a clone has no extension.

- [x] Ship the GDExtension binaries (Linux .so + Windows .dll) in the repo; keep `tools/build-sdk.sh` as the rebuild path (95114d1)
- [x] `app/tests/run_all.gd`: loads every script, instantiates every scene, drives hub → settings → every chapter page → every lab (presets, every apparatus parameter, overlays, photons, keys); exits non-zero on any engine error line
- [x] `tools/test.sh`: cargo tests + Godot import + smoke tests + run_all under xvfb and headless, failing on `SCRIPT ERROR` / `ERROR:` output
- [x] Fix every error/warning surfaced; re-run until clean; verify a fresh `git clone` of the repo opens without errors
- [x] Commit + push; update README "Testing" section

### Status 2026-10-31 02:45 (cut off by usage limit — resume here)
Full `tools/test.sh` run (logs in builds/test-logs): headless run_all OK (1049 checks); GL run_all
was clean through exp4 then hit the 900 s timeout (llvmpipe is slow). Remaining fixes, in order:
- [x] `quagmire-engine/core/tests/golden.rs` no longer compiles on rustc 1.99 (E0689, 7 errors: `deg.to_radians()` on `{float}` in tuple-array loops, e.g. line ~410 `exp6_idler_polarizer_selects_fringes`). Fix by typing the arrays (`let cases: [(f64, f64, f64); 5] = [...]`) wherever the error appears; `cargo test` must show 26 passed.
- [x] `app/tests/smoke_widgets.gd` leaks at exit — real cause: `static var` in apple_evolution.gd and widget_kit.gd kept the scripts (and theme/fonts/textures) alive; replaced with an instance var / `WidgetKit.hv()`. `tests/leak_probe.gd` attributes exit leaks per widget.
- [x] `tools/test.sh`: add `V-Sync` to IGNORE; raise the GL run_all timeout to 3600 and run Xvfb at 1280x720 for that step (keep 1600x900 for screenshots).
- [x] The 141 `app/assets/models/*.png` were NOT Blender leftovers: Godot's glTF importer extracts embedded textures by default (`gltf/embedded_image_handling=1`) and the editor then rewrote their `.import` files (detect-3D) — the churn seen in GitHub Desktop. Fixed by `gltf/embedded_image_handling=2` (Basis Universal inside the imported scene) in all 17 `.glb.import`; the PNGs are gone for good.
- [x] Re-run `tools/test.sh` until ALL OK; then `git clone` into a scratch dir and run `xvfb-run godot -e --path <clone>/app --quit-after 400` and `git status` there to prove the editor changes no tracked files.
- [x] Commit each step and push; README "Testing" section is already written (uncommitted edit in README.md — commit it).

Phase 7 closed 2026-10-31 09:10: `tools/test.sh` ALL OK (cargo 28 tests, import, smoke, run_all headless 1307 checks, run_all xvfb/GL, 10 screenshots); `tools/check-clone.sh` CLONE OK (fresh clone imports, opens in the headless and GL editor, runs the harness, changes no tracked file).

## Phase 8 — Run the experiment (after Phase 7 closes)

Goal: the labs should feel like operating the real bench from start to finish, not only
reading a computed result. User request 2026-10-31.

- [x] Laser shutter and power: `enabled` (shutter) and `power` (photons/s, default the lab's I₀)
      params on `Optics.Laser`; beam renderer and all rates follow them; state panel says "laser off".
- [x] Acquisition mode (Run / Pause / Reset in the HUD): counts accumulate per detector in real
      time (Poisson draws from the engine's probabilities × power × dt), coincidences via the
      coincidence predicate; elapsed time, rates with √N error bars; live digits on the
      coincidence-counter model (Label3D) and in the results panel.
- [x] Detector scan: "Scan" sweeps the scanning detector over its range with a dwell time,
      plotting measured points progressively over the prediction and the lab's CSV data; the
      detector carriage moves on the model.
- [x] Photon-pair animation for branched layouts (Experiments 4–7) along `beam_paths`, outcomes
      sampled from the engine (detected / lost / coincidence), so the eraser and delayed-choice
      stories can be watched one pair at a time.
- [x] Stage stepping: clicking a stage in the state panel focuses the camera on that element and
      dims the beam beyond it, so a run can be read beginning → middle → end.
- [x] Harness coverage for all of the above (shutter closed → zero rates; 2 s acquisition →
      counts > 0 within tolerance; scan completes; pair animation runs without errors).
- [x] Engine-boundary audit (user request): Poisson counts, joint outcome draw, rate normalisation, interpolation and λL/d, λL/w moved from GDScript into the Quagmire core + SDK with golden tests; rule documented in docs/design/architecture.md and quagmire-engine/README.md.
- [x] Rebuild the Linux (and Windows) exports with `tools/export.sh` (09:13: Linux 126 MB, Windows 162 MB; exported Linux binary verified with a lab screenshot); commit + push.

## Phase 9 — Bench accuracy and performance (user request 2026-10-31)

- [x] Bench audit: nothing floats; out-of-beam = set aside on the table; PA/PB as films on the mask (new `polarizer_film` model); PBS dumps + stray beams; undepleted-pump dump; `L` per experiment from the measured fringe spacing; harness consistency checks. Documented in `docs/design/bench-accuracy.md`.
- [x] Quality presets (Low / Medium / High: MSAA, shadows, glow, 3D render scale) in Settings; labs apply them; Low targets integrated graphics.
- [x] Rendering cost: single-cascade 2048 shadow map limited to the table, cheaper glow; acquisition panel updates labels in place instead of rebuilding every frame.
- [x] `--perf` run mode: objects / primitives / draw calls / VRAM per lab, machine-independent budget checked by `tools/test.sh` (≤ 1500 draw calls, ≤ 2 M triangles per frame).
- [x] Document the targets and results in `docs/design/performance.md`; commit + push.

## Phase 10 — Web (WebGL 2) export (user request 2026-11-03)

- [x] Engine: `web` / `web-nothreads` features, wasm flags in `.cargo/config.toml`,
      `sdk-godot/build.sh` per-target build (engine-owned, host copies the artifact)
- [x] `quagmire_core::VERSION`, `QuagmireSystem.engine_version()`; `BOOT` line in main.gd
- [x] `bin/web/quagmire_godot.wasm` committed (Emscripten 4.0.20 = Godot 4.7.2 templates)
- [x] Export preset "Web" (Extensions Support on, Thread Support off) → `builds/webgl/`
- [x] `tools/export.sh [targets]`, `tools/build-sdk.sh [profile] [targets]`
- [x] `tools/check-web.sh`: headless Chromium (DevTools protocol, SwiftShader) boots the
      export, requires `BOOT … quagmire=<version>` and a `PERF` line from the lab
- [x] Docs: README (builds, hosting), engine README (targets, portability), architecture
      (platform layering), performance (web counters)
- [ ] Later: threaded web build if Godot ships a wasm32 threaded template again, or when
      Rust gains wasm64-emscripten; macOS binary; `sdk-c` for Unity/Unreal

## Phase 11 — Mobile UI, site parity, Android (user request 2026-11-22)

- [x] Content: real CSV download links (CDN URLs) and vendor equipment links in every
      experiment, as on testing-reality.webflow.io
- [x] `carousel` block (arrows, dots, caption, 5 s auto-rotation, swipe) for the lab photos
      of Exp 1–6; the four photos the app lacked added from docs/site-assets
- [x] Figures at the width of the text column (`FitWidthBox`), mipmaps on all figure imports
- [x] Touch: pages scroll by finger (RichTextLabel PASS + no selection on touch screens),
      lab camera one-finger orbit / two-finger pan / pinch zoom, Android back button
- [x] Phone layouts (`ui/layout.gd`: `touch()`, `compact()` under 1000 px, `scale()` from
      screen density; main.gd switches touch screens to a 1:1 canvas): hub single column,
      chapter top bar + contents overlay, settings fits the window, lab HUD as a tabbed
      sheet (bottom in portrait, right in landscape) with presets in a scrolling row;
      orientation = sensor. Debug: `godot --resolution 480x960 -- --touch --go=lab:exp1`
- [ ] Polish: in the compact lab sheet the state rows are wider than the sheet (the
      percentage column is clipped); widgets have not been reviewed one by one at 450 px
- [x] Android export: engine `build.sh android` (NDK clang, 16 KB pages, pushed as
      a152b49), `android.*.arm64` gdextension entries + committed `bin/android/*.so`,
      preset "Android" (arm64-v8a, gradle off, `space.quagmire.testingreality`, sensor
      orientation), `tools/export.sh android`, `tools/check-android.sh` (ANDROID OK),
      distribution packages in `builds/dist/testing-reality-quagmire-<platform>.*`
- [ ] Later: run the APK on a device (no emulator on the server); Play Store icons
      (`launcher_icons/*` are empty, Godot's default icon is used)
