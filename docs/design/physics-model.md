# Physics model — one formalism for all seven experiments

This is the unified model implemented in `quagmire-engine/core` and driven by the labs in
`app/labs/`. It follows the site's own formalism (states as kets, polarizers as operators
with `|lost⟩` sinks, intensities as squared amplitudes) and makes every experiment a special
case of the same three ingredients.

## 1. Register

| Property | Labels | Created by |
|---|---|---|
| `pol` (single-photon labs) or `pump` | `↔`, `↕` (+ sinks `lost@<element>`) | `Optics.Laser` |
| `path` | `S`, `A`, `B` | `Optics.SlitMask` (`slits()`) |
| `pol1`, `pol2` (signal, idler) | `↔`, `↕` (+ sinks) | `Optics.SPDCSource` (`spdc()`, consumes `pump`) |
| `idler_path` | `D2`, `wall` | `Optics.SPDCSource`, `Optics.Wall` |

Conventions: angles from horizontal, counter-clockwise looking into the beam;
`|↗↙⟩ = (|↔⟩ + |↕⟩)/√2`, `|↘↖⟩ = (|↔⟩ − |↕⟩)/√2`. A polarizer at θ keeps `(cos θ, sin θ)` and
sends the perpendicular component to `|lost@P⟩` (`optics::blocked_axis` fixes the sink phase so
the kets match the site: `P_↔|↕⟩ = |lost⟩`, `P_↗↙|↘↖⟩ = |lost⟩`).

The site writes slit polarizer angles from vertical in Experiments 5–7 (`P_A = 0°` is
vertical). The app uses one convention everywhere (from horizontal), so the same physical
setup reads `PA = 90°`, `PB = 0°` in the labs; the chapter text notes this.

## 2. Elements as operators

| Element | Operation | Norm |
|---|---|---|
| Laser / preparation | sets `pol` to `cos θ|↔⟩ + sin θ|↕⟩` | 1 |
| Half-wave plate at θ | Jones `[[cos2θ, sin2θ],[sin2θ, −cos2θ]]` | unitary |
| Retarder (QWP, Berek) | `R(θ) diag(1, e^{−iδ}) R(−θ)` | unitary |
| Polarizer at θ (optionally only on `path == A`) | `|θ⟩⟨θ|` + sink | isometry |
| PBS | relabel `path` conditioned on `pol` | unitary |
| Slit mask | `|S⟩ → Σ_slits √(pass/N) e^{ikl}|slit⟩` (+ sink for the mask) | isometry |
| SPDC (crossed type-I BBO) | `|↔⟩_pump → |↕⟩₁|↕⟩₂`, `|↕⟩_pump → e^{iφ}|↔⟩₁|↔⟩₂`; adds `idler_path = D2` | isometry |
| Wall on the idler | relabel `idler_path: D2 → wall` (sink) | — |
| D2 unplugged | coincidences replaced by zero (electronics, not physics) | — |

## 3. Detection

Point detectors: `P(click) = probability(alive(pol…))`. Coincidences:
`probability(alive(pol1) ∧ alive(pol2) ∧ idler_path == D2)`.

Screen (scanning D1): `I(y) = Σ_env |Σ_p c[p, env] φ_p(y)|²` with
`φ_p(y) = √D(θ) e^{−i k x_p sin θ}`, `D = (sin α/α)²`, `α = π w sin θ/λ`, `θ = atan(y/L)`
(far field; the lens makes `L = f`). The "environment" is every property except `path`;
post-selection (coincidence predicate) is applied before the sum. The incoherent profile
`Σ_env Σ_p |c φ_p|²` is returned too, so visibility is measured independently of the envelope.
The detector slit convolves the profile with a 200 µm box.

## 4. The seven experiments as instances

| # | State after the source | What changes | Prediction |
|---|---|---|---|
| 1 | `|↗↙⟩` | 0–3 polarizers | `Π cos²(Δθ_i)`: 100 %, 50 %, 0 %, 12.5 % |
| 2 | `|S⟩` → `(|A⟩+|B⟩)/√2` | w, d, λ, cover a slit | `2I₀(1 + cos(2πd sinθ/λ)) sinc²` |
| 3 | `|↗↙⟩|S⟩`, PA/PB mark the slits | P1 angle | `¼(1 + sin 2θ₁ cos kΔ)·D`; flat ½ without P1 |
| 4 | `|Φ⁺⟩ = (|↔↔⟩+|↕↕⟩)/√2` (pump HWP 22.5°, Berek φ = 0) | α, β | coincidences `½cos²(α−β)`, singles ½ |
| 5 | `|Φ⁺⟩ ⊗ (|A⟩+|B⟩)/√2` | PA/PB, local P1 | 5.1 fringes; 5.2 flat ½; 5.3 flat ¼ — the idler holds the tag |
| 6 | same | idler P2 at γ (after D1 clicked) | coincidences `1 + sin 2γ cos kΔ`; singles always flat |
| 7 | same | wall / unplugged | singles unchanged; coincidences zero |

Lab imperfections the model reproduces on purpose: an unbalanced pair
(`cos χ|↕↕⟩ + e^{iφ} sin χ|↔↔⟩`) from a pump HWP away from 22.5° (Experiment 4's VV > HH), the
effective distance `L` as a slider, and the detector-slit convolution.

## 5. Golden values

`quagmire-engine/core/tests/golden.rs` checks every number above against the engine; the
Godot smoke test (`app/tests/smoke_quagmire.gd`) checks the 12.5 % result and the eraser
visibilities through the SDK.
