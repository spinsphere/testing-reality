# Quagmire Engine

A small, deterministic quantum-state engine for games and educational simulations.
Built for the *Testing Reality* app; designed to be split into its own repository.

```
core/        quagmire-core   pure Rust library (no engine dependencies)
sdk-godot/   quagmire-godot  GDExtension for Godot 4.7 (godot-rust gdext)
docs/        design notes and the physics conventions
```

## Model

- A **System** is a register of labelled qudits ("properties"): a photon's polarization
  with labels `["↔", "↕"]`, its path `["S", "A", "B"]`, an idler's polarization, …
- The state is a **sparse pure state** over label tuples, `f64` complex amplitudes,
  deterministic iteration order.
- **Operators** act on one or two properties with identity elsewhere: Jones matrices
  (rotation, half-wave plate, general retarder), diagonal phases, conditional relabels
  (polarizing beam splitters, mirrors, detectors), splits (slits), and
  **projection-with-sink** (a polarizer keeps the state normalised by sending blocked
  amplitude to a `|lost⟩` label, exactly like the site's derivations).
- **Predicates** (`pol == ↔`, `path != lost`, `alive(pol)`) drive conditional operators,
  probability queries and post-selection (coincidence counting).
- **Measurement** follows the Born rule with a seedable PCG32 RNG; forced outcomes allow
  replay.
- **Screen profiles** turn a path property into a continuous detector pattern
  `I(y) = Σ_env |Σ_path c · φ_path(y)|²` with a Fraunhofer envelope, giving single/double-slit
  diffraction, which-path marking, quantum erasure and delayed-choice coincidences with no
  special cases. The incoherent reference profile is returned alongside so fringe
  visibility can be measured independently of the envelope.
- **Pretty printing** renders states as `1/(2√2) |↕⟩ + 1/√2 |lost@P1⟩ + …` (Unicode) or
  LaTeX, recognising common amplitudes.

## Example

```rust
use quagmire_core::{Pred, System, C, INV_SQRT2};
use std::f64::consts::{FRAC_PI_2, FRAC_PI_4};

let mut s = System::new();
s.add_property("pol", &["↔", "↕"])?;
s.set_state(&[(&["↔"], C::new(INV_SQRT2, 0.0)), (&["↕"], C::new(INV_SQRT2, 0.0))])?;
s.polarizer("pol", ["↔", "↕"], 0.0, "lost@P1", None)?;         // horizontal
s.polarizer("pol", ["↔", "↕"], FRAC_PI_4, "lost@P2", None)?;   // 45°
s.polarizer("pol", ["↔", "↕"], FRAC_PI_2, "lost@P3", None)?;   // vertical
assert!((s.probability(&Pred::alive("pol"))? - 0.125).abs() < 1e-12);
println!("{}", s.ket_text());
// 1/(2√2) |↕⟩ + 1/√2 |lost@P1⟩ + 1/2 |lost@P2⟩ + 1/(2√2) |lost@P3⟩
```

## Conventions

Angles in radians from horizontal, counter-clockwise looking into the beam.
`|H⟩ = (1, 0)`, `|V⟩ = (0, 1)`; HWP at θ is `[[cos 2θ, sin 2θ], [sin 2θ, −cos 2θ]]`;
a polarizer at θ projects onto `(cos θ, sin θ)`. The phase of `|lost⟩` amplitudes is a
convention chosen to match the site's derivations (see `optics::blocked_axis`).
SPDC in crossed type-I crystals maps `|H⟩_pump ↦ |V⟩|V⟩`, `|V⟩_pump ↦ e^{iφ}|H⟩|H⟩`.

Limits: 16 properties per system, 256 labels per property (packed `u128` keys).

## Tests

`cargo test` runs unit tests plus `core/tests/golden.rs`, which checks every number the
Testing Reality site derives: Malus's law, the 12.5 % three-polarizer result, the double-slit
formula, the Experiment 3 eraser table, `½cos²(α−β)` coincidences, the Experiment 5 flat
patterns (½ and ¼), the delayed-choice law `1 + sin 2γ cos kΔ`, and the wall/unplugged cases.

## Targets and portability

The engine is layered so that it can serve several game engines:

```
quagmire-core        pure Rust, no I/O, no threads, no clock, no platform code
                     → compiles for every Rust target (x86_64, aarch64, wasm32, …)
sdk-godot            GDExtension; one binary per Godot platform/architecture
sdk-c (planned)      C ABI (opaque handles, caller-allocated buffers) for Unity / Unreal / C++
```

Everything platform-specific belongs to an SDK, never to the core: the core is what makes a
new host cheap, the SDK is what makes it idiomatic. The Godot SDK's own build script
`sdk-godot/build.sh <linux|windows|web> [release|debug]` prints the artifact for one target;
host projects copy it where their engine expects it (Testing Reality: `tools/build-sdk.sh`).

| Godot target | Toolchain | Artifact |
|---|---|---|
| Linux x86_64 | stable Rust | `libquagmire_godot.so` |
| Windows x86_64 | stable Rust, `x86_64-pc-windows-gnu`, mingw-w64 | `quagmire_godot.dll` |
| macOS | stable Rust on a Mac (not built here) | `libquagmire_godot.dylib` |
| **Web** (wasm32, Emscripten) | nightly Rust + `rust-src`, Emscripten **matching Godot's templates** (4.0.20 for 4.7.2) | `quagmire_godot.wasm` |

Web notes:

- Godot loads the extension as an Emscripten *side module* (its "Extensions Support" /
  `dlink` templates). The side module must be linked by the same Emscripten version as the
  main module; the version is embedded in the template's `godot.js`
  (`_godot_js_emscripten_get_version`) and the build script warns on a mismatch.
- Features `web` (threaded templates) and `web-nothreads` (single-threaded). Godot 4.7 ships
  its threaded web template as **wasm64**, which Rust cannot target through Emscripten, so
  the single-threaded wasm32 build is the one that works today; it also needs no
  cross-origin-isolation headers from the host site.
- Built with `-Zbuild-std=std,panic_abort`, `panic=abort` and hidden default visibility
  (`.cargo/config.toml`, applies only to the wasm target). A panic aborts the page — the SDK
  never unwraps host input; every error is a `godot_error!` and a neutral return.
- `QuagmireSystem.engine_version()` (static) returns `quagmire_core::VERSION`, so a host can
  prove at boot which engine it loaded (Testing Reality prints a `BOOT … quagmire=0.1.0`
  line that its web check requires).
- The same `wasm32-unknown-emscripten` core would serve a Unity WebGL build (Unity's native
  plug-ins for WebGL are Emscripten-compiled too) and an Unreal HTML5 build; only the
  binding layer (`sdk-c`) differs.

## Status

Core and the Godot SDK (Linux, Windows, web) are complete. Next: the C ABI crate for
other engines.


## Added for interactive benches (v0.2)

| Core | SDK | Purpose |
|---|---|---|
| `System::sample_outcome()` | `QuagmireSystem.sample_outcome() -> Dictionary` | one joint Born-rule draw of every property (fates of a photon or an entangled pair), no collapse |
| `System::poisson(mean)`, `counts(rate, dt)` | `poisson(mean) -> int`, `counts(rate, dt) -> int` | detector click statistics from the engine's seeded RNG |
| `Profile::integral()`, `intensity_at(y)` | `QuagmireProfile.integral()`, `intensity_at(y)` | pattern bookkeeping without copying arrays out |
| `Profile::rate_scale(slit, flux)`, `rate_at(y, slit, flux)` | same names | click rate of a slit detector at `y` for a given countable flux |
| `ScreenGeometry::fringe_spacing()`, `envelope_zero()` | `QuagmireScreen.fringe_spacing()`, `envelope_zero()` | `λL/d`, `λL/w` |

Design rule for host applications (see the app repository's `docs/design/architecture.md`,
"Engine boundary"): everything that computes a physical quantity belongs here; the host
composes these calls, renders and narrates.
