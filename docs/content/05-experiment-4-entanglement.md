# Experiment 4 : Entanglement : Bell state
Source: `G-Experiment 4 _ Entanglement and polarizers.pdf` (browser tab title "Experiment 4 : Entanglement and polarizers");
URL printed in the footer: https://testing-reality.webflow.io/experiment-4 ; 21 pages (printed 30/10/2026, 20:51).

Site navigation visible on every page: header "Testing Reality" logo (left), "Experiments" and "About" (right);
left-hand "TABLE OF CONTENT": Abstract / Lab Experiments / Result and analysis / Theory and equations.
(No "Literature and video" entry on this page.) The page title block (p.1) reads: small caps "EXPERIMENT 4",
large serif heading "Entanglement : Bell state".

## Page summary
This page introduces polarization entanglement. A 404/405 nm diode laser pumps a pair of thin BBO crystals
(placed at 90° to each other) and, by spontaneous parametric down-conversion (SPDC), occasionally converts one pump
photon into two lower-energy photons that leave the crystal at symmetric angles with entangled, *parallel*
polarizations, the Bell state |Φ⁺⟩ = (|↔⟩₁|↔⟩₂ + |↕⟩₁|↕⟩₂)/√2. Each photon goes through a motorized rotatable
polarizer (angles α and β) and a single-photon detector; a coincidence counter records simultaneous clicks.
The theory section models the polarizers with the "|lost⟩" trick from Experiment 1 applied to a two-photon
tensor-product state and derives the coincidence probability P(α,β) = ½ cos²(α−β): maximum ½ when the polarizers
are parallel, zero when perpendicular, independent of the absolute angles. The lab data (a 2D scan of both
polarizer angles from −90° to 90°, 1 s windows, downloadable as `data_allAngles.csv`) shows the expected diagonal
ridge-and-valley pattern but with a strong asymmetry: vertical–vertical pairs are far more frequent than
horizontal–horizontal ones, attributed to imperfect pump preparation (the Berek compensator "did not work as
expected"). Bell's theorem is invoked qualitatively ("the cos²(α−β) form ... cannot be reproduced by classical
correlations") but no CHSH inequality or S-value is computed on this page.

## Content (in page order)

### [p.1] Title page
- Prose: "EXPERIMENT 4" (small grey caps). Heading: "Entanglement : Bell state" (large grey serif, two lines).
- Nothing else on the page besides header/footer and "Made in Webflow" badge.

### [p.2–4] Abstract
Left column TABLE OF CONTENT: Abstract; Lab Experiments; Result and analysis; Theory and equations.

Prose (p.2):

> In this experiment, we will discover quantum entanglement and how it can be generated. Entanglement means that one or
> more properties of two particles are correlated in a way that cannot be explained by classical physics.
>
> A tempting analogy: imagine two marbles, one blue and one red. One is given to Alice, the other to Bob. When Alice
> sees her marble's color, she instantly knows Bob's. We might call their colors "correlated." However, this classical
> analogy is misleading — the marbles had definite colors all along; Alice simply learned which one she had. Quantum
> entanglement is fundamentally different: the photons do not have definite polarizations until measured. The
> measurement itself determines the outcome, and Bell's theorem proves that no classical "hidden color" explanation
> can account for the observed correlations.
>
> This experiment may seem to break the laws of physics. It took many years to understand entanglement, but rest
> assured: entanglement does not allow information to travel faster than the speed of light, nor can it be used to
> change the past. The reason is subtle but important: each individual measurement yields a random outcome that the
> observer cannot control. The correlations only become visible when the two observers compare their results — and
> that comparison requires ordinary communication, limited by the speed of light.

Prose (p.3):

> To create entanglement, we use two thin nonlinear crystals called *BBO* (beta barium borate). Through a process known
> as *Spontaneous Parametric Down-Conversion* (SPDC), a single high-energy photon from the laser is converted into two
> lower-energy photons whose polarizations are entangled. The two photons are emitted at symmetric angles from the BBO.
> We place a rotatable polarizer in each path and count coincident detections — events where both detectors register
> a photon simultaneously.

#### Try it yourself! (p.3–4)
Prose:

> The BBO produces photon pairs with parallel polarizations: if one is vertical, so is the other. Experiment with the
> animation to understand why the coincidence rate increases or decreases with different combinations of polarizer
> angles. The polarizers can be rotated using the pink handles. The presets highlight the most instructive angle
> combinations.

- Embed [p.4]: CodeSandbox React project, link text "react-vazdln-wqy5mw created by vmonette" (avatar icon), with a
  grey "Run this project" button. In the PDF the sandbox did not render (blank area with a scrollbar on the right),
  so the animation itself is not visible. From the surrounding text the simulator is: a 2D animation of laser → BBO
  → two photon paths → two polarizers (rotatable via "pink handles") → two detectors, with a coincidence-rate
  readout, plus "presets" buttons that jump to instructive angle combinations (presumably (0°,0°), (0°,90°),
  (45°,45°), (0°,45°) etc., matching the table on p.20). [unclear: exact controls/readout; not rendered in the PDF]
- Prose (red italic "Note:" under the embed): "**Note:** The photons are supposed to get out of the BBO with the same
  angle." (i.e., in the animation the two daughter photons should leave the crystal at the same, symmetric angle — a
  disclaimer about the animation's geometry.)

### [p.4–5] Lab Experiment
Heading (purple serif): "Lab Experiment".
Prose: "Curious about what an optical entanglement setup looks like? Here are a few pictures of our apparatus:"

- Figure [p.5] – Lab photo (colour photograph, full width, rounded corners, with purple pill-shaped overlay labels).
  Scene: a bare stainless optical breadboard (metric hole grid) in a lab corner; white painted brick wall at the top
  left; behind the table a row of black-framed panels/enclosure doors (dark background); a grey multi-outlet power
  strip runs along the back right edge with white mains cables plugged into it and a thick white cable coming in from
  the right. There are no beam tubes or enclosures; the beam path is open. Component arrangement, following the beam
  (labels as printed on the photo, including the site's spelling "Miror" and "Beam spiltter"):
  1. **LASER** (far right, at the table's back-right corner): a black box-shaped laser head on a low mount, labelled
     "LASER"; a white power cable leads into it. Emits toward the left (along the back edge of the table).
  2. **λ/2** (half-wave plate): a 1-inch rotation mount on a post, just left of the laser.
  3. **Beam spiltter** [sic]: a black cylindrical/cube mount (polarizing beam-splitter cube in a black housing) on a
     post/base plate, left of the half-wave plate. The rejected beam goes to a beam dump (not labelled in the photo).
  4. **Lens** (L1): 1-inch lens in a round mount on a post, further left along the back edge.
  5. **Lens** (L2): another 1-inch lens mount further left (the two together form the collimating telescope).
  6. **Miror** (top, back left-centre): a mirror in a kinematic mount on a post near the back wall; a faint violet
     glow (the 405 nm beam) is visible on it. This is the first mirror of the U-turn.
  7. The beam comes forward (toward the viewer) along the left side of the table to **Lens** (L3, foreground left,
     label "Lens") and a second **Miror** (foreground far left, kinematic mount on a post with a base clamp; label
     "Miror" partially cut at the left edge). This second mirror sends the beam to the right, toward the viewer's side
     of the table.
  8. **λ/2** (second half-wave plate): a large 1-inch rotation mount with an engraved degree scale on a post
     (foreground, left-centre).
  9. **Berek** (Berek compensator): a large black cylindrical body (~2 inch diameter) with a tilt/rotation scale, on a
     post with a base plate — the biggest component on the table (foreground, centre-left).
  10. **BBO**: a small square kinematic mount (with a white/silver 1/2-inch aperture) holding the crystal pair, on a
      post, immediately to the right of the Berek (foreground, centre).
  Not visible in this photo: the two output arms (lenses L4/L5, polarizers P1/P2 on motors, detectors D1/D2, beam
  dump) — they would be off to the right of the BBO, outside the frame. There is only one lab photo on this page
  despite "a few pictures".
  Lighting: room lights on; the table top reflects the panels; a faint violet beam spot is seen only on the back mirror.

### [p.6–8] Technical set-up and Equipment
Prose: "Here is a schematic representation of the setup. All equipment is shown, albeit not at scale."

- Figure [p.6] – Schematic (2D, flat vector style on a pale blue-grey rounded rectangle). Beam drawn as a solid red line
  for the pump and as red dashed lines for the down-converted photons. Layout (reading from the top right):
  - Top right: grey box "LASER", beam travels leftward.
  - Purple vertical bar "λ/2" (half-wave plate) just left of the laser.
  - Square "BS" (beam splitter) drawn as a square with a diagonal; below it a black "BD" (beam dump, drawn as a
    black cup/cylinder) receiving the reflected (horizontal) component downward.
  - Two bi-convex lens symbols: "L1 = 10cm" (closer to BS) then "L2 = 2.5cm" (collimating telescope).
  - Top-left: black angled mirror (45°, drawn as a thick black bar) turning the beam downward.
  - On the downward vertical leg: lens "L3 = 25cm" (drawn horizontally, i.e. beam passes through it vertically).
  - Bottom-left: second black angled mirror turning the beam to the right.
  - On the rightward leg: purple bar "λ/2" (second half-wave plate), blue bar "Berek" (Berek compensator), then
    "BBO" drawn as two adjacent cyan rectangles (two thin crystals).
  - From the BBO: the undeflected pump continues right into a black "BD" beam dump; two dashed red lines leave the
    BBO at symmetric angles (approx. ±20° in the drawing): the upper one passes lens "L5 = 50cm" and reaches a
    tilted assembly "P2" (grey square, polarizer) with a green bar "M2" (motor) and a dark grey box "D2" (detector);
    the lower one passes lens "L4 = 50cm" and reaches "P1" / "M1" / "D1" likewise. The polarizer+motor+detector
    assemblies are drawn rotated to face the incoming dashed beam.
  - Legend box (right): "BS : Beam Splitter / BD : Beam Dump / λ/2 : Half-wave plate / Berek : Berek compensator /
    L_ : Plano-convex lens / M_ : Motor".
  - Colour code: half-wave plates purple, Berek blue, BBO cyan, mirrors black, beam dumps black, lenses outlined
    white, detectors dark grey, polarizers light grey, motors green, laser grey.

Prose (p.6–7):

> The setup begins in the top right corner with a laser emitting at 404~nm. Before reaching a polarizing beam splitter,
> the beam passes through a half-wave plate to control its polarization and intensity. The beam splitter transmits only
> vertically polarized light; the horizontal component is directed to a beam dump.
>
> The beam then passes through a pair of collimating lenses, which reduce the beam diameter and ensure it remains
> parallel. A set of two mirrors redirects the beam (a U-turn was necessary due to limited space on the optical
> table). A third lens focuses the beam onto the BBO crystal, ensuring all photon pairs are generated at the same
> location.
>
> Before reaching the BBO, the beam's polarization must be set to 45° with zero relative phase between components.
> This is achieved using a half-wave plate and a *Berek compensator*, an optical device that finely adjusts the phase
> difference between the horizontal and vertical polarization components.
>
> Both output paths (1 and 2) contain a focusing lens and a rotatable polarizer in front of the detector. The
> polarizers are rotated by motorized stages.
>
> The final component (not shown in the diagram) is the coincidence counting system. The detectors are *single-photon
> avalanche diodes* (SPADs). Each detector is coupled to an optical fiber via a collimator and bandpass filter. The
> electronics record the number of photons detected within a specified time window and, crucially, the number of
> *coincidences* — simultaneous detections at both D1 and D2 within a narrow time gate (typically a few nanoseconds).

(Note: the prose says "404~nm" (a LaTeX non-breaking-space artefact) while the equipment table says 405 nm.)

#### Equipment list (p.7–8)
Table (Name column entries are red hyperlinks on the site, presumably to supplier pages):

| Name | Description |
|---|---|
| LASER | Diode laser (405nm) |
| Lenses | L1 is LA1509 (10cm) and L2 is LA1986 (2.5cm); L3 is LA1461 (25cm), all from Thorlabs |
| Berek compensator | New focus, variable wave plate. |
| BBO | 2 thin BBO placed at 90 degrees, from Eskma Optics |
| Double slit | Dimension (200-200-200 μm), made in-house |
| Polarizers | Mounted linear polarizers from Thorlabs |
| Lenses | L4 and L5 are LA?? (50cm), from Thorlabs |
| Motor | Rotation mount bundle (to rotate the polarizers) |
| Detectors | Single photon detection module |

Remarks: the "Double slit" row is clearly copied from the Experiment 2/3 equipment table; no double slit appears in
the schematic, the photo or the text of this page. "LA??" for L4/L5 is literally what the site prints (part number
unknown to the authors; a Thorlabs N-BK7 plano-convex f = 500 mm, 1" lens is LA1908). "Eskma" is the site's spelling
(Eksma Optics). Thorlabs part numbers: LA1509 = f 100 mm, LA1986 = f 125 mm (the site says 2.5 cm, which is
inconsistent with the LA1986 part number; LA1222 is f 25 mm — see Open questions), LA1461 = f 250 mm.

### [p.8–11] Result and analysis
Heading (purple serif): "Result and analysis".

#### Raw data (p.8)
Prose: "You can download all our data here:"
- Download: `data_allAngles.csv` (CSV icon link).
Prose:

> The data file contains five columns. The first two are the polarizer angles, ranging from −90° to 90°. The
> remaining three columns are detector counts: D1 singles, D2 singles, and D1–D2 coincidences. All counts were
> recorded in one-second acquisition windows.

(The CSV itself is not included in the PDF; absolute count values are therefore unknown — see Open questions.)

#### Graphs (p.9–10)
Prose:

> On the left is the data measured in the lab; on the right is the theoretical prediction. The two plots look quite
> different, but the key features remain. When both polarizers are set to the same angle, coincidence counts reach
> a maximum. When the polarizers are rotated 90° relative to each other, the counts drop to nearly zero.
>
> Ideally, this pattern indicates the creation of a *parallel Bell state*: an entangled state in which the two
> photons always share the same polarization. (Bell states are explained in detail in the theory section.)
>
> The experimental plot, however, is less clean than the theory predicts. The pump laser was likely not perfectly
> prepared before generating the entangled pairs, producing an imbalance in the state. The graph clearly shows many
> more vertically polarized pairs than horizontally polarized ones. This imbalance will appear in later experiments
> as well, but at least its origin is now understood.

Sub-heading "**In 3D**"

- Figure [p.9] – Two matplotlib 3D surface plots side by side, both titled "Intensity of photon coincidence",
  "jet"-style rainbow colormap (blue = low, red = high), light grey gridded panes.
  - Left (experimental): x axis "P1 angle (deg)" ticks −75…75 (step 25), y axis "P2 angle (deg)" ticks −75…75,
    z axis "Intensity normalized" 0.2–1.0. The surface is bumpy/noisy. A high red ridge rises toward the back-right
    corner (P1 ≈ +60…+90, P2 ≈ +60…+90, i.e. both polarizers near vertical), reaching 1.0. A second, much lower,
    broad greenish-yellow hump (≈0.4–0.5) sits near the centre/front-left (both polarizers near 0°, i.e. both
    horizontal). Deep blue valleys (near 0) run where the two angles differ by ~90°. The surface has a faceted,
    coarse look (angle step of roughly 10°–15°).
  - Right (theory): same axes but the angle range extends to ±100 (ticks −50, 0, 50, 100), z 0.0–1.0. A smooth
    surface ½cos²(α−β) (normalised to 1): a straight red ridge along the diagonal P1 = P2 and parallel ridges, with
    deep blue troughs along P1 − P2 = ±90°. Looks like a corrugated sheet oriented at 45° to the axes.

Sub-heading "**Same graphs, with a top view**" (p.10)

- Figure [p.10] – The same two datasets as 2D heat maps (top view), titles "Intensity of photon coincidence",
  x axis "P1 angle (deg)" ticks −90, −45, 0, 45, 90; y axis "P2 angle (deg)" ticks −90, −45, 0, 45, 90; rainbow
  colormap (dark blue low → yellow/cream mid → red high), no colour bar.
  - Left (experimental, pixelated, roughly 18×18 cells, i.e. ~10° steps): a strong red/dark-red blob centred at
    about (P1 ≈ +60°, P2 ≈ +60°) extending to the top-right corner (±90° is also "vertical", and the colour map
    wraps there); a weaker warm patch (orange-yellow) at the bottom-left/centre around (P1 ≈ 0 to −20°, P2 ≈ 0
    to −20°) — the horizontal–horizontal maximum, visibly much weaker than the vertical–vertical one; two dark-blue
    minima at about (P1 ≈ −45°, P2 ≈ +45°) and (P1 ≈ +45°, P2 ≈ −45°) (perpendicular polarizers); a faint blue
    streak also near (P1 ≈ −80°, P2 ≈ −10°). Background mostly pale yellow-green (≈0.3–0.5 normalised), i.e.
    there is a sizeable floor of coincidences everywhere.
  - Right (theory): clean diagonal stripes at 45°: red bands along P2 = P1 (and along P2 = P1 ± 180°, which show
    at the corners), dark-blue bands along P2 = P1 ± 90°; between them a smooth gradient red→yellow→green→blue.
    The pattern is a function of (P1 − P2) only.

Prose (p.10–11):

> Let us analyze these graphs. As noted above, there is a significant discrepancy between the theoretical prediction
> and the experimental data, though this does not fundamentally affect the conclusions. The key pattern remains:
> when the polarizer angles are parallel, coincidence counts are high; when perpendicular, they drop to nearly zero.
> The main deviation from theory is an asymmetry — vertical polarization pairs are detected more frequently than
> horizontal ones.
>
> This asymmetry reveals the actual polarization state produced in our setup. Ideally, the photons would be created
> in a balanced Bell state with equal contributions from horizontal and vertical polarizations. The data indicate,
> however, that vertical polarization is favored over horizontal.
>
> The *Berek compensator* is designed to correct exactly this problem by fine-tuning the balance between the
> horizontal and vertical components. With proper adjustment, it should produce a cleaner Bell state. For reasons we
> could not identify, however, the compensation did not work as expected in this experimental run.

### [p.11–20] Theory and equations
Heading (purple serif): "Theory and equations".
Prose: "In this section, we describe quantum entanglement mathematically and apply it to our experiment, where two
entangled photons each pass through a variable polarizer."

#### Entanglement (p.11–13)
Prose:

> Entanglement is one of the most striking features of quantum mechanics. When two particles are entangled, their
> properties are correlated in a way that does not have a classical explanation. Indeed, in 1964, John Bell proved
> that the correlations obtained by measuring entangled particles are stronger than any classical mechanism could
> produce. Experiments have since confirmed Bell's prediction: entanglement is real, and it cannot be explained by
> hidden variables or pre-existing properties. Some tie the surprisingly strong correlations of entangled systems to
> the effect that measurement of one particle may have on the other. The effect is thought to be instantaneous, and
> irrespective of the distance between the particles. This was described by Einstein as a "spooky action at a
> distance".
>
> Using a nonlinear crystal such as BBO, a single high-energy photon from a laser can be converted into two
> lower-energy photons through Spontaneous Parametric Down-Conversion (SPDC). These daughter photons are created with
> entangled polarizations: measuring one immediately reveals the polarization of the other. Crucially, this does not
> enable faster-than-light communication, each individual measurement yields a random result, and the correlations
> only become apparent when results are compared via ordinary (light-speed-limited) communication. In SPDC
> experiments, the two photons are conventionally called:
>
> - The *signal* photon: the one sent through the optical setup under study.
> - The *idler* photon: the partner, typically sent directly to a reference detector.
>
> These names are standard in quantum optics, originating from early parametric amplifier experiments. Because the
> signal and idler are entangled, measuring the idler provides information about the signal, even without directly
> interacting with it. The four maximally entangled two-photon polarization states are called the *Bell states*,
> named after John Bell. They represent the four "perfect" ways in which the polarizations of two photons can be
> correlated or anti-correlated:

Equations (p.13), the four Bell states, exactly as typeset (subscripts 1, 2 label the two photons; ↔ = horizontal,
↕ = vertical):

E1:
$$\ket{\Phi^+} = \frac{1}{\sqrt2}\left(\ket{\leftrightarrow}_1\ket{\leftrightarrow}_2 + \ket{\updownarrow}_1\ket{\updownarrow}_2\right)$$

E2:
$$\ket{\Phi^-} = \frac{1}{\sqrt2}\left(\ket{\leftrightarrow}_1\ket{\leftrightarrow}_2 - \ket{\updownarrow}_1\ket{\updownarrow}_2\right)$$

E3:
$$\ket{\Psi^+} = \frac{1}{\sqrt2}\left(\ket{\leftrightarrow}_1\ket{\updownarrow}_2 + \ket{\updownarrow}_1\ket{\leftrightarrow}_2\right)$$

E4:
$$\ket{\Psi^-} = \frac{1}{\sqrt2}\left(\ket{\leftrightarrow}_1\ket{\updownarrow}_2 - \ket{\updownarrow}_1\ket{\leftrightarrow}_2\right).$$

Prose:

> The first two states (|Φ^±⟩) have *correlated* polarizations: both photons are horizontal, or both are vertical. The
> last two (|Ψ^±⟩) have *anti-correlated* polarizations: if one is horizontal, the other is vertical. The ± sign
> determines the relative phase between the two terms, which affects interference in certain measurements.
>
> Which Bell state is produced depends on the crystal orientation and pump laser preparation. In our setup, the BBO
> alignment produces the correlated state:

E5 (the state produced in this experiment):
$$\ket{\Phi^+} = \frac{1}{\sqrt2}\left(\ket{\leftrightarrow}_1\ket{\leftrightarrow}_2 + \ket{\updownarrow}_1\ket{\updownarrow}_2\right).$$

#### Polarizer with variable angle (p.14–15)
Prose:

> Each photon passes through a polarizer mounted on a motorized rotation stage. Since the polarizer can be set to any
> angle, we denote the angles by Greek letters: α for one polarizer, β for the other.
>
> When a photon encounters a polarizer set to angle α, we can understand what happens by decomposing the photon's
> polarization into two components: one aligned with the polarizer (|α⟩) and one perpendicular to it (|α^⊥⟩).
>
> Any polarization state can be written in this basis. For example, a diagonally polarized photon (45°) encountering
> a polarizer at angle α decomposes as:

E6:
$$\ket{\nearrow\!\!\swarrow} = \cos(\alpha - 45^\circ)\ket{\alpha} + \sin(\alpha - 45^\circ)\ket{\alpha^\perp}$$

(The site writes the diagonal ket as |↗↙⟩.)

Prose: "The polarizer transmits only the component aligned with its axis and blocks the perpendicular component:"

E7:
$$P(\alpha)\ket{\nearrow\!\!\swarrow} = \cos(\alpha - 45^\circ)\ket{\alpha} + \sin(\alpha - 45^\circ)\ket{\text{lost}}$$

Prose: "The transmitted amplitude is cos(α − 45°), so the transmission probability is cos²(α − 45°)."

Prose: "**Verification with a familiar case.** Let us check this formula with an example we have already seen: a
diagonal photon passing through a horizontal polarizer (α = 0°)."

E8:
$$P(0^\circ)\ket{\nearrow\!\!\swarrow} = \cos(45^\circ - 0^\circ)\ket{\leftrightarrow} + \sin(45^\circ - 0^\circ)\ket{\text{lost}} = \cos(45^\circ)\ket{\leftrightarrow} = \frac{1}{\sqrt2}\ket{\leftrightarrow}$$

(Note the site silently drops the |lost⟩ term in the last two equalities; also the sign inside cos/sin is written
(45° − 0°) here vs (α − 45°) in E6/E7 — harmless because cos is even, and sin² is what matters.)

Prose: "The amplitude is 1/√2, so the transmission probability is (1/√2)² = ½."

#### Full approach (p.15–20)
- Figure [p.16] – Schematic (2D, flat vector style on a pale blue-grey rounded rectangle), caption (italic):
  "Schematic of the entanglement experiment." Elements, left to right:
  - Pink/salmon box "LASER" (label pill below it) emitting a thin red line to the right.
  - Dashed vertical grey line labelled "Ψ₀" (below, grey bold) just after the laser.
  - A grey hatched circle (a lens; no label).
  - Two thin adjacent light-blue vertical rectangles labelled "BB" (pill label; the BBO crystal pair) — actually the
    pill reads "BB" [unclear: cut-off "BBO"].
  - Dashed vertical grey line labelled "Ψ₁" right after the BBO.
  - From the BBO two red dashed lines leave: one straight to the right (lower arm) and one going up-right at ~35°
    to a black angled mirror (thick black bar) which reflects it to horizontal (upper arm). (The mirror is a drawing
    convenience to make both arms horizontal; in the real setup there is no mirror in the output arms.)
  - Upper arm: purple hatched circle labelled "α" with a curved rotation arrow above it, pill label "P2" below; then
    a pink/salmon rectangle (detector) with pill label "D2".
  - Lower arm: purple hatched circle "β" with rotation arrow, pill label "P1"; pink detector rectangle "D1".
  - Dashed vertical grey line labelled "Ψ₂" through the polarizers/detectors.
  - Both detectors are wired (thin black lines) to a small rounded box on the far right labelled "coin" (coincidence
    counter, text rotated vertically).
  - Colour code (same family as other pages): laser/detectors salmon-pink, polarizers purple hatched, crystal light
    blue, beam red dashed, state labels grey.

Prose: "Let us now work through the full calculation for two entangled photons, each passing through a polarizer at
some angle."

Prose: "**Step 1. Initial state.** The pump laser produces a diagonally polarized photon:"

E9:
$$\ket{\psi_0} = \ket{\nearrow\!\!\swarrow}$$

Prose: "**Step 2. Entanglement.** After passing through the BBO crystal, the pump photon is converted into a pair of
entangled photons in the correlated Bell state |Φ⁺⟩:"

E10:
$$\ket{\psi_1} = \frac{1}{\sqrt2}\left(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\right)$$

Prose:

> This state is a superposition: both photons are vertical, or both are horizontal, with equal probability. Upon
> measurement, the outcomes are perfectly correlated — if one is found vertical, so is the other.
>
> **Step 3. Polarizers.** Each photon passes through a rotatable polarizer:
>
> - Photon 1 encounters a polarizer at angle β.
> - Photon 2 encounters a polarizer at angle α.
>
> Transmission through a polarizer depends on the cosine of the angle between the photon's polarization and the
> polarizer axis. Vertical polarization is at 90°; horizontal is at 0°. Applying the polarizers:

E11 (three-line derivation, p.18):
$$\ket{\psi_2} = \frac{1}{\sqrt2}\left(P_1(\beta)\ket{\updownarrow}_1\,P_2(\alpha)\ket{\updownarrow}_2 + P_1(\beta)\ket{\leftrightarrow}_1\,P_2(\alpha)\ket{\leftrightarrow}_2\right)$$
$$= \frac{1}{\sqrt2}\left(\cos(\beta - 90^\circ)\ket{\beta}_1\cos(\alpha - 90^\circ)\ket{\alpha}_2 + \cos(\beta - 0^\circ)\ket{\beta}_1\cos(\alpha - 0^\circ)\ket{\alpha}_2\right)$$
$$= \frac{1}{\sqrt2}\left(\sin\beta\sin\alpha + \cos\beta\cos\alpha\right)\ket{\beta}_1\ket{\alpha}_2$$

Prose:

> In the last line, we used cos(θ − 90°) = sin θ. Note that the perpendicular components are blocked by the polarizers
> — they become "lost" photons. The state shown above includes only the photons that pass through both polarizers,
> which is why it is unnormalized.
>
> **Step 4. Coincidence probability.** The probability that both photons pass their respective polarizers is the
> squared magnitude of the amplitude:

E12:
$$P(\alpha,\beta) = \left|\frac{1}{\sqrt2}\left(\sin\beta\sin\alpha + \cos\beta\cos\alpha\right)\right|^2$$

Prose (p.19): "Using the trigonometric identity cos(α − β) = cos α cos β + sin α sin β:"

E13:
$$P(\alpha,\beta) = \left|\frac{1}{\sqrt2}\cos(\alpha - \beta)\right|^2 = \frac{1}{2}\cos^2(\alpha - \beta)$$

Prose:

> **Step 5. Interpretation.** This result has a clear physical meaning:
>
> - **Parallel polarizers** (α = β): The probability is maximized at ½.
> - **Perpendicular polarizers** (α = β + 90°): The probability is zero.
>
> Why does the maximum reach only ½ rather than 1? Recall that the perpendicular components become "lost" photons.
> The Bell state |Φ⁺⟩ contains equal contributions of horizontal and vertical polarization. If both polarizers are
> set to 0° (horizontal), only the |↔↔⟩ component passes — half the pairs are lost. If both are set to 45°, each
> photon has a 50% chance to pass, but the correlations ensure that when one passes, so does the other — again
> yielding 50% coincidences. No polarizer setting achieves 100% transmission for this entangled state.
>
> **Intuitive examples.** The following table shows coincidence probabilities for several angle combinations:

Table (p.20):

| Polarizer angles (α, β) | Angle difference (α − β) | Coincidence probability |
|---|---|---|
| (0°, 0°) | 0° | ½ |
| (0°, 45°) | −45° | ¼ |
| (0°, 90°) | −90° | 0 |
| (45°, 45°) | 0° | ½ |
| (30°, 60°) | −30° | ⅜ |

Prose (p.20):

> The pattern is clear: the closer the polarizers are aligned, the higher the coincidence rate, with a maximum of ½.
> At 90° separation, coincidences vanish entirely. This angular dependence, specifically, the cos²(α − β) form, is a
> hallmark of quantum entanglement and cannot be reproduced by classical correlations (as Bell's theorem
> demonstrates).

(A large purple heading "Similar Experiments" is printed overlapping this paragraph on p.20 — a print artefact of the
next section's heading.)

### [p.21] Similar Experiments / footer
Heading "Similar Experiments" followed by three cards:
- "INTRODUCTION — Quantum for everyone" (thumbnail: the word "OVERVIEW").
- "EXPERIMENT 1 — Polarizers" (thumbnail: the stacked laser→polarizer→detector schematics with Ψ labels).
- "EXPERIMENT 2 — Single and double slit" (thumbnail: laser→slits→screen schematic).
Footer: "Testing Reality © 2018-2026", "Creative commons" with CC BY-SA icons.

## Physics model for simulation

### State space
- Each photon is a polarization qubit. Basis |↔⟩ = horizontal = (1,0), |↕⟩ = vertical = (0,1). A linear
  polarization at angle θ (measured from horizontal, counter-clockwise looking into the beam) is
  |θ⟩ = cos θ |↔⟩ + sin θ |↕⟩; the diagonal state |↗↙⟩ = |45°⟩ = (|↔⟩ + |↕⟩)/√2.
- The pair lives in the 4-dimensional tensor product C² ⊗ C², basis |↔↔⟩, |↔↕⟩, |↕↔⟩, |↕↕⟩ (photon 1 first).
- Per the site, the polarizer "|lost⟩" bookkeeping of Experiment 1 is reused: a third, non-detected channel per
  photon. Implement as projection (unnormalised amplitude) rather than a 3-level system.

### Source (SPDC)
- Pump: single photon from the 405 nm laser, prepared diagonal: |ψ₀⟩ = |↗↙⟩ (E9). (The site says the HWP + Berek
  set it to 45° with zero relative phase.)
- Two thin type-I BBO crystals with optic axes at 90° to each other ("2 thin BBO placed at 90 degrees"): the first
  converts the |↕⟩ pump component into |↔↔⟩ pairs, the second converts |↔⟩ into |↕↕⟩ pairs (standard Kwiat
  two-crystal source). Result, per the site: |ψ₁⟩ = |Φ⁺⟩ = (|↕⟩₁|↕⟩₂ + |↔⟩₁|↔⟩₂)/√2 (E10).
- Daughter photon wavelength: not stated on the page. Energy conservation with a degenerate pair gives
  λ_s = λ_i = 2 × 405 = 810 nm (standard for this kit); propose 810 nm with a ~10 nm bandpass filter in front of
  each fibre collimator (the text mentions "collimator and bandpass filter").
- Emission geometry: the two photons leave on opposite sides of a cone around the pump axis "at symmetric angles";
  the opening half-angle is not stated. Propose ±3° (typical for 405 → 810 nm degenerate type-I BBO at ~3° cone)
  for a true-to-life layout; the site's schematic exaggerates it to ~±20° for readability. The undeflected pump
  goes straight into a beam dump.
- Pair generation rate: not given (coincidences per second unknown; CSV not in PDF). For a game, any rate
  consistent with "counts recorded in one-second acquisition windows" works; propose singles ~10–50 kHz and
  coincidences ~1–3 kHz at parallel polarizers, with accidentals ~10–100 Hz [assumed].

### Polarizers (the operators)
Site convention: photon 1 → polarizer P1 at angle β, photon 2 → polarizer P2 at angle α; horizontal = 0°,
vertical = 90°.
- Single-photon polarizer at angle θ: P(θ)|φ⟩ = cos(θ − φ)|θ⟩ + sin(θ − φ)|lost⟩ (E7 pattern), i.e. transmitted
  amplitude ⟨θ|φ⟩ = cos(θ − φ). As a matrix on (↔,↕): P(θ) = |θ⟩⟨θ| with |θ⟩ = (cos θ, sin θ).
- Two-photon operator: P₁(β) ⊗ P₂(α). Apply to each product term separately (E11):
  P₁(β)|↕⟩₁ = cos(β − 90°)|β⟩₁ = sin β |β⟩₁ ; P₁(β)|↔⟩₁ = cos β |β⟩₁ ; same with α for photon 2.
- Unnormalised post-polarizer state: |ψ₂⟩ = (1/√2)(sin β sin α + cos β cos α)|β⟩₁|α⟩₂ = (1/√2) cos(α − β)|β⟩₁|α⟩₂.

### Predicted probabilities (exact, per the site)
- Coincidence (both pass): P_cc(α, β) = ½ cos²(α − β) (E13). Max ½ at α = β (any absolute angle), 0 at |α − β| = 90°.
- Singles (each photon alone, trace over the partner): P₁(β) = ½ and P₂(α) = ½ for every angle — the site does not
  state this but it follows from the maximally mixed reduced state; useful to show the player that singles are flat
  while coincidences oscillate.
- Other joint outcomes (not on the site, but needed for a full simulator): P(pass, blocked) = ½ sin²(α − β) each;
  P(blocked, blocked) = ½ cos²(α − β). Rows sum to 1.
- Worked values (site table): (0,0)→½, (0,45)→¼, (0,90)→0, (45,45)→½, (30,60)→⅜.
- Normalised theory surface for the plots: cos²(P1 − P2), on a grid P1, P2 ∈ [−90°, 90°] (site's heat map) or
  wider (site's 3D plot shows ±100).

### Non-ideal (lab-matching) model
To reproduce the measured asymmetry ("many more vertically polarized pairs than horizontally polarized ones"), use an
unbalanced state |ψ₁⟩ = a|↔↔⟩ + b e^{iφ}|↕↕⟩ with |a|² + |b|² = 1. Then
P_cc(α,β) = |a cos α cos β + b e^{iφ} sin α sin β|². The site gives no numbers; from the heat map the HH peak is
roughly 40–50 % of the VV peak, so propose |b|² ≈ 0.68, |a|² ≈ 0.32 (ratio ≈ 2.1), φ ≈ 0, plus a constant
accidental/background floor of ~0.25 of the VV peak (the experimental map's background is pale yellow-green, not
blue) [assumed from the figure; replace with a fit to `data_allAngles.csv` when available]. Angle grid: ~10° steps
over −90°…90° (≈ 19 × 19 settings, 1 s each).

### Bell / CHSH
The page invokes Bell's theorem qualitatively only. No CHSH combination, no S value, no inequality bound is printed.
If the game wants to go further: with E(α,β) = cos 2(α − β) for |Φ⁺⟩, the CHSH choice (0°, 45°; 22.5°, 67.5°) gives
S = 2√2 ≈ 2.83 > 2 [not on the site — flag as an extension].

### Geometry / numbers given on the page
- Pump wavelength: 404 nm (prose) / 405 nm (table). Use 405 nm.
- Lenses: L1 f = 10 cm, L2 f = 2.5 cm (telescope, demagnification 4×), L3 f = 25 cm (focus on BBO), L4 = L5 =
  f = 50 cm (one per output arm, focusing onto the detector/fibre collimator).
- Polarizer scan range −90° … +90°; counts in 1 s windows; coincidence gate "a few nanoseconds".
- Not given: distances between components, BBO thickness (propose 2 × 0.5 mm), cone angle, count rates,
  detector efficiency.

## Apparatus list (for Blender)
Dimensions are typical catalogue values; "stated" = named by the site, "assumed" = inferred.

| # | Item | Site description | Approx. real-world size | Mounting | Status |
|---|---|---|---|---|---|
| 1 | Optical breadboard | visible in photo (stainless, metric M6 grid) | ~90 × 60 cm or larger (only part visible), 25 mm hole pitch | on bench | stated (photo) |
| 2 | Diode laser, 405 nm | "Diode laser (405nm)"; black box with white mains cable; emits violet | ~40 × 60 × 100 mm head (e.g. CPS405-type module ~Ø11×50 mm, or boxed module); photo shows a boxed unit ~50 mm tall | low block/base plate at table's back-right corner | stated |
| 3 | Half-wave plate λ/2 (#1, after laser) | "Half-wave plate" purple bar in schematic; 1-inch rotation mount in photo | Ø25.4 mm optic in Ø~50 mm rotation mount with degree scale | post + post holder + base | stated |
| 4 | Polarizing beam splitter cube "BS" | "polarizing beam splitter ... transmits only vertically polarized light"; black housing in photo | 10–20 mm cube in Ø~40 mm black cage/cube mount | post + base | stated |
| 5 | Beam dump "BD" (#1) | receives horizontal component from BS | ~Ø25 × 40 mm black cup | post | stated (schematic only) |
| 6 | Lens L1, Thorlabs LA1509, f = 100 mm | "L1 is LA1509 (10cm)" plano-convex N-BK7 | Ø25.4 mm, in 1" lens mount | post | stated |
| 7 | Lens L2, "LA1986 (2.5cm)" | plano-convex | Ø25.4 mm, 1" lens mount | post | stated (part# inconsistent) |
| 8 | Mirror M (#1, back-left) | "Miror"; 45° turn | Ø25.4 mm dielectric or Al mirror in kinematic mount (~50 × 50 mm) | post | stated |
| 9 | Lens L3, LA1461, f = 250 mm | "L3 is LA1461 (25cm)"; focuses onto BBO | Ø25.4 mm, 1" lens mount | post | stated |
| 10 | Mirror M (#2, front-left) | "Miror"; completes U-turn | same as #8 | post with base clamp | stated |
| 11 | Half-wave plate λ/2 (#2, before Berek) | sets pump to 45°; large rotation mount with engraved scale in photo | Ø25.4 mm optic in ~Ø60 mm rotation mount | post | stated |
| 12 | Berek compensator | "New focus, variable wave plate" (New Focus Model 5540-type) | ~Ø60 × 40 mm black cylinder with tilt knob and two scales, largest item | post + base plate | stated |
| 13 | BBO crystal pair | "2 thin BBO placed at 90 degrees, from Eskma Optics"; two cyan slabs in schematic | 2 × (5 × 5 × 0.5 mm) in a Ø12.7 mm holder inside a square kinematic mount (~40 × 40 mm) | post | stated (thickness assumed) |
| 14 | Beam dump "BD" (#2, pump after BBO) | black cup on axis behind BBO | ~Ø25 × 40 mm | post | stated (schematic only) |
| 15 | Lens L4, f = 500 mm (arm 1) | "L4 ... LA?? (50cm)" | Ø25.4 mm, 1" lens mount | post | stated |
| 16 | Lens L5, f = 500 mm (arm 2) | same | same | post | stated |
| 17 | Polarizer P1 on motor M1 | "Mounted linear polarizers from Thorlabs" in "Rotation mount bundle" (motorized, e.g. PRM1Z8/K10CR1-type) | Ø25.4 mm polarizer in Ø~75 mm motorized rotation stage with cable | post + base | stated |
| 18 | Polarizer P2 on motor M2 | same | same | post + base | stated |
| 19 | Detector D1 (SPAD) | "Single photon detection module"; "coupled to an optical fiber via a collimator and bandpass filter" | fibre collimator Ø~25 × 40 mm on kinematic mount; yellow/orange multimode fibre; SPAD module box ~90 × 60 × 40 mm off-table (e.g. Excelitas SPCM-AQRH) | collimator on post; module on bench | stated (sizes assumed) |
| 20 | Detector D2 (SPAD) | same | same | same | stated |
| 21 | Bandpass filters (×2) | "bandpass filter" before each fibre | Ø25.4 mm, 810 ± 5 nm, in the collimator mount | — | stated (wavelength assumed) |
| 22 | Coincidence counter "coin" | "coincidence counting system ... electronics record ... coincidences within a narrow time gate (a few ns)" | box/FPGA module (~150 × 100 × 50 mm) with BNC/SMA cables to D1, D2 and a laptop | bench | stated (not drawn in schematic; drawn in theory diagram) |
| 23 | Power strip + cables | grey multi-socket strip along back edge, white mains cables | ~400 mm strip | on table | photo |
| 24 | Lab backdrop | white brick wall, black panel/enclosure doors behind the table | — | — | photo |
| 25 | "Double slit (200-200-200 μm)" | in equipment table | — | — | listed but NOT used on this page (copy-paste from Exp. 2) |

Beam-path layout for the 3D scene (not to scale; site gives no distances): laser at back-right → λ/2 → PBS (+BD
sideways) → L1 → L2 → mirror (back-left) → 90° turn toward the front → L3 → mirror (front-left) → 90° turn toward
the right → λ/2 → Berek → BBO → straight-through pump into BD; two down-converted beams fan out at symmetric angles
→ L4 / L5 → motorized polarizers P1 / P2 → fibre collimators (D1 / D2) → fibres to SPAD modules → coincidence
electronics. The pump beam is violet (405 nm) and visible as a faint glow on optics; the 810 nm daughter beams are
invisible (draw them only in "schematic/overlay" mode).

## Teaching notes
Prerequisites, in the order the page needs them:
1. Polarization as a direction + the arrow kets |↔⟩, |↕⟩, |↗↙⟩ (from Experiment 1).
2. Decomposition of a vector onto a rotated orthonormal basis: cos/sin of the angle difference (|θ⟩ basis,
   |α⟩, |α^⊥⟩) — vectors and trig.
3. Amplitude → probability by squaring (Born rule): cos²; the ½ from (1/√2)².
4. The "|lost⟩" bookkeeping for the blocked component (projection, unnormalised states).
5. Tensor products of two qubits: writing |↔⟩₁|↔⟩₂, applying an operator to each factor independently,
   product of amplitudes.
6. Superposition of product states = entanglement; the four Bell states; correlated vs anti-correlated; relative
   phase ±.
7. The trig identity cos(α − β) = cos α cos β + sin α sin β (used to collapse E12 → E13).
8. Interpreting a 2D function of two angles: 3D surface and heat-map reading; recognising that the theory depends
   only on α − β (diagonal stripes).
9. Coincidence counting / time gating; singles vs coincidences; normalisation of data.
10. Bell's theorem (stated, not derived): classical "hidden colour" correlations cannot give cos²(α − β).

Site's pedagogical moves:
- Opens with the blue/red marble analogy and then explicitly rejects it ("misleading — the marbles had definite
  colors all along") to pre-empt the classical-correlation misconception.
- Immediately defuses the "faster than light / change the past" worry with the randomness-of-individual-outcomes
  argument, repeated twice (Abstract and Theory).
- "Try it yourself!" interactive before any math; presets for instructive angle pairs.
- Lab-first ordering: photo → schematic → equipment table → raw data → graphs → only then theory.
- Honest treatment of the imperfect data (asymmetry VV vs HH), with a stated cause (pump preparation, Berek didn't
  work) — a good "science is messy" beat for the game.
- Theory is a step-by-step state evolution Ψ₀ → Ψ₁ → Ψ₂ mirrored by dashed lines in the diagram, exactly as in
  Experiments 1–3.
- "Verification with a familiar case" re-derives the Experiment 1 result (diagonal through horizontal = ½) before
  the two-photon case.
- "Why does the maximum reach only ½?" anticipates the natural question.
- Ends with a worked table of five angle pairs.

## Open questions
- `data_allAngles.csv` is referenced but not included in the PDF; absolute singles/coincidence rates, the angle
  step and the exact VV:HH ratio are unknown. The plots are "normalized" to 1 at the max.
- Pump wavelength given as "404~nm" in prose, "405nm" in the equipment table.
- Lens L2 is given as "LA1986 (2.5cm)": Thorlabs LA1986 is f = 125 mm, not 25 mm (LA1222 would be f = 25 mm).
  Either the part number or the focal length is wrong.
- L4/L5 part number is literally "LA??" on the site.
- The equipment table lists a "Double slit (200-200-200 μm), made in-house" that plays no role on this page.
- The down-converted wavelength (810 nm), BBO thickness, emission cone angle, inter-component distances and
  coincidence window width are not given.
- Only one lab photo is shown although the text says "a few pictures"; the output arms (L4/L5, P1/P2, D1/D2) are
  not photographed.
- The CodeSandbox animation ("react-vazdln-wqy5mw" by vmonette) did not render in the PDF; its controls and presets
  are inferred from the text only. The BBO label pill in the p.16 diagram appears truncated to "BB".
- Polarizer-angle naming is swapped between sections: Abstract/figure use α on P2 and β on P1 (Step 3 says
  "Photon 1 → β, Photon 2 → α"); the results plots use "P1 angle"/"P2 angle". Harmless since P depends on α − β only.
- Whether the pump HWP+PBS "transmits only vertically polarized light" and then the second HWP rotates it to 45° is
  stated; which crystal of the pair converts which component is not (standard Kwiat geometry assumed above).
- No CHSH/Bell inequality numbers anywhere on the page; Bell's theorem is only invoked qualitatively.
- The "Similar Experiments" heading on p.20 is printed on top of the last paragraph (print artefact).
