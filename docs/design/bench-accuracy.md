# Bench accuracy — what on the table is real, what is a teaching simplification

Audit of 2026-10-31 (user request: "recheck the positioning and configuration of all the
apparatus to be scientifically and experimentally correct"). Everything below is enforced
by `app/tests/run_all.gd` where it can be checked mechanically.

## Conventions

| Item | Value | Source |
|---|---|---|
| Table | 1.2 m × 0.6 m breadboard, 25 mm M6 grid, table top at y = 0 | site photos (Exp. 2/3): "visible area ≈ 1.2 × 0.6 m" |
| Optical axis | 0.100 m above the table (`LabBase.BEAM_HEIGHT` = `qlab.BEAM_HEIGHT`) | typical 4" beam height; photos "~10–12 cm" |
| Mounts | Ø1" optics, Ø½" posts, PH post holders, BA1 bases (Thorlabs-style) | site equipment list |
| Angles | from horizontal, counter-clockwise looking **into** the beam; the rotor turns about the beam axis (`rotation_degrees.x = −angle`) | site convention; `docs/design/physics-model.md` |
| Beam colours | 405 nm violet, 808/810 nm drawn dark red because it is infrared and invisible | `Palette.wavelength_to_color`, note in Exp. 2 results |

Every model is built around the optical centre at `BEAM_HEIGHT`, so the beam goes through
the centre of every aperture. A component's node sits **on** the table (`position.y = 0`),
and its model is never lifted; the harness fails if any model or node floats.

## "Out of the beam"

A polarizer that is "out" is set down beside the beam on the table (rotation mounts: 9 cm
to the side; films on the slit mask: 2 cm to the side). The old 6 cm lift that made P2/P3
hover in Experiment 1 was wrong and is gone. The Experiment 7 wall slides aside the same
way. The harness toggles every polarizer and checks the offset is sideways, not upward.

## Slit polarizers PA / PB

The site says "mounted linear polarizers" over slits 400 µm apart, so two full Ø1" mounts
cannot each cover one slit. PA and PB are now small polarizer films (`polarizer_film.glb`,
7 mm discs in a 1 mm ring with a glued tab) on the downstream face of the mask, 4.5 mm
either side of the axis. Their rotors still turn with the angle slider. Physically the film
would cover its slit only; the 4.5 mm separation is a visual aid.

## Beam splitters, beam dumps, the undepleted pump

Every polarizing beam splitter (Exp. 2, 3 and the pump line of 4–7) has a beam dump on its
reflected arm; the reflected beam is drawn with the brightness of the fraction the cube
rejected (zero when the laser is already horizontal, half for a diagonal input). Behind the
BBO the violet pump continues into its own dump: only ~1 in 10⁹ pump photons converts, so
in the real lab the pump beam is the brightest thing on the table and must be stopped.

## Distances from the site's data

`L` (slit → scan plane) is not stated on the site. It was fitted from the measured fringe
spacing `λL/d` in the downloadable CSVs (peak finding on the smoothed counts):

| Experiment | λ | spacing in data | L used | bench |
|---|---|---|---|---|
| 2 (double slit) | 808 nm | 1025 µm | 0.50 m | mask at x = −0.02, D1 at +0.50 (0.52 m) |
| 3 (P1 = ±45°) | 405 nm | 700 µm | 0.70 m (was 0.9) | mask moved to x = −0.20 so the table distance is 0.70 m |
| 5 (5.1 coincidences) | 810 nm | 875 µm | 0.43 m | mask placed on the arm 0.43 m from D1 |
| 6 (P2 ±45°) | 810 nm | 600–660 µm | 0.32 m | idem, 0.32 m |
| 7 (eraser reference) | 810 nm | ≈730 µm | 0.36 m | idem, 0.36 m |

The different `L` in 5/6/7 reflect different sessions of the same bench (the detector stage
was moved); the `L` slider remains available. The harness checks the table distance equals
the `L` used by the physics to within 3 cm.

## Known simplifications (on purpose)

- **SPDC opening angle**: the signal/idler arms leave the crystal at ≈13° each so they can
  be seen; type-I non-collinear BBO at 405 → 810 nm opens ≈3°.
- **Pump optics**: the real telescope (L1 f = 100 mm, L2 f = 25 mm), Berek compensator and
  pump λ/2 are present; distances between them are compressed to fit the table.
- **Singles vs pairs**: in the model every pair has both partners on the detectors; in a
  real source singles exceed coincidences by one to two orders of magnitude. Rates are
  therefore exact *per pair* (see the crystal's "Detected pair rate" help text).
- **Preparation in Experiment 1**: the site's BS + λ/2 preparation stage is folded into the
  laser's "prepared polarization" parameter (the site itself describes it as fixed).
- **Lenses** do not change the tracked quantum state; they are placed where the site puts
  them and the far-field pattern uses `L` as the effective distance.
- **Labels** alternate heights along dense arms; some still overlap at the default camera
  distance (cosmetic).

## Verified by the harness

No floating node or model; out-of-beam is sideways; PA/PB within 2 cm of the mask; table
distance = `L` ± 3 cm; every PBS has a dump and a stray beam; the shutter kills every beam;
Poisson acquisition rates match the engine's probabilities × source rate; every parameter
of every apparatus is driven through its inspector control without engine errors.
