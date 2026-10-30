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

## Status

Phase 1 (core) complete. Next: the Godot SDK, then a C ABI crate for other engines.
