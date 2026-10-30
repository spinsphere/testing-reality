# Experiment 6: Delayed Choice Quantum Eraser
Source: `I-Experiment 6 _ delayed choice quantum eraser.pdf`; URL printed in the footer: https://testing-reality.webflow.io/experiment-6 ; 19 pages (printed 30/10/2026, 20:52).

## Page summary
This page presents the Testing Reality group's own version of the delayed-choice quantum eraser, built on polarization-entangled photon pairs from a BBO crystal (Bell state |Φ+⟩). The "signal" photon (path 1) goes through a double slit whose two slits are covered by orthogonal polarizers (P_A = 0°, P_B = 90°), then through an "eraser" polarizer P_1 at 45°, a 500 mm lens, and a 200 μm slit on a scanning detector D_1. The "idler" photon (path 2) goes through a 500 mm lens and a single rotatable polarizer P_2 at angle γ to a stationary detector D_2. The punchline: the D_1 singles never show interference (only a diffraction envelope) whatever P_2 does, but the D_1–D_2 coincidences show fringes when P_2 = +45°, anti-fringes when P_2 = −45°, and only (slit-centred) diffraction when P_2 = 0° or 90°. The site derives the coincidence law I(γ) ∝ 1 + sin(2γ) cos[k(a − b)], presents four measured data sets (CSV files + plots), and argues that although the choice of P_2 can be made after the signal is detected, "the past isn't changed — the correlation was always there, waiting to be revealed."

## Content (in page order)

### [p.1] Title page
- Small caps label: "EXPERIMENT 6"
- Large serif title in grey: "Delayed Choice Quantum Eraser"
- Site header: "Testing Reality" logo (left), nav links "Experiments", "About" (right). Footer: "Made in Webflow" badge.

### [p.2] Left-hand TABLE OF CONTENT
The sidebar lists the page's sections in this order:
1. Abstract
2. Lab Experiments
3. Result and analysis
4. Theory and equations
5. Literature and video

### Abstract [p.2–3]

Prose (faithful):

> This experiment is the delayed-choice quantum eraser.
>
> The experiment was first performed in 1998 and repeated in Brazil in 2008 with a slightly different setup (see the Literature section), more similar to ours. On one path, a double slit produces interference for non-entangled photons. With entangled photons, detector D_1 alone never shows interference, even though the photons pass through the double slit. This is the purple curve in the animation.
>
> However, when we examine coincidences between D_1 and D_2, the results depend on the polarizer angles. By rotating the idler polarizer P_2, we can make interference fringes appear or disappear in the coincidence data. This is the pink curve in the animation.
>
> At first glance, it may appear that a measurement made in the present can alter one made in the past.
>
> The key insight is that the which-path information is encoded in the idler photon. Measuring the idler at 0° or 90° preserves this information, yielding no interference. Measuring at ±45° erases the information, and interference reappears in the coincidences.

Note for the game: "purple curve" = D_1 singles (always diffraction-only); "pink curve" = D_1–D_2 coincidences (fringes or not depending on P_2). These colour conventions come from the embedded animation.

#### "Try it yourself!" [p.3]
> Use the animation to explore the experiment:

Embed [p.3]: a StackBlitz embed, project name "react-vazdln-scmwpz created by vmonette", with a "Run this project" button and the StackBlitz anti-phishing notice ("This page is shown to protect against phishing attacks..."), "Starting dev server". The animation itself did not render in the print, so its controls are not visible. From the abstract we know it draws two curves: a purple curve (D_1 singles, diffraction only) and a pink curve (coincidences) whose fringes appear/disappear as the user rotates the idler polarizer P_2. [unclear: exact controls; presumably a P_2 angle slider as in the other Testing Reality simulators by the same author "vmonette".]

### Lab Experiment [p.3–6]

> Curious about what an entanglement optical setup looks like? Here are photos of our apparatus:

Figure [p.4] — Lab photo (colour photograph, landscape, with purple callout labels and arrows). Scene: a black anodized optical breadboard/table with a regular grid of tapped holes, lab shelving and blue plastic bins in the background, a white lab notebook with a yellow highlighter and a black cloth at the right. The photographed assembly is the **D_1 detection head on the signal path**, seen from the side/front. Elements visible, roughly left to right / front to back:
- Far left: a 1-inch black lens/mirror mount on a post with a red-capped thumbscrew (unlabelled; probably a lens mount — assumed L4 or a spare mount).
- An orange optical fibre (FC-connected, orange jacket) coming in from the left and plugged into the fibre collimator at the centre.
- Centre: a black Thorlabs cage/rotation assembly. Label **"Collimator"** (purple pill, arrow pointing to the cylindrical fibre collimator package marked "THORLABS CP33"-style cage plate). Label **"Rotation motor (unused)"** pointing to a red circuit board (a stepper/rotation motor PCB with a grey ribbon cable) attached to a Thorlabs motorised rotation mount on the same axis — annotated as not used in this experiment.
- Label **"Long pass filter"** pointing to a black mounted filter (one-inch, in a Thorlabs mount with engraved part number, looks like "FELH0..." — [unclear]) immediately in front of the collimator, i.e. the bandpass/long-pass filter that rejects the 405 nm pump.
- Label **"Single slit"** pointing to a black adjustable slit assembly (Thorlabs-style adjustable mechanical slit with a micrometer knob on top) at the very front of the stack: this is the 200 μm slit that scans the pattern.
- The whole head sits on a tall black post and post holder with thumbscrews, which in turn sits on a black translation stage; the label **"Linear actuator"** points to a brass/gold-coloured motorised actuator body at the bottom front (a motorised linear actuator with a grey ribbon cable). The stage carries the whole detector head across the beam.
- Mounting: cage plates (Thorlabs CP33 visible), 1/2-inch posts, post holders, a kinematic/pitch-yaw style adjuster block with two knurled knobs, clamps to the breadboard.
- No caption text under the photo other than the introductory sentence above.

#### Technical set-up and Equipment [p.4–6]

> The below image shows a schematic of the apparatus. All components are shown, but not to scale.

Figure [p.5] — Schematic of the full apparatus (flat 2D drawing on a pale blue-grey panel, red lines for beams, black dashes for mirrors). Reading it along the beam:

Pump preparation (top row, right to left — same as Experiment 4):
1. **LASER** (grey box, far right of the top row), beam exits to the left as a solid red line.
2. **λ/2** half-wave plate (tall thin purple rectangle, labelled "λ/2").
3. **BS** beam splitter (square with diagonal, labelled "BS"); the reflected beam goes down into a **BD** beam dump (black curved block labelled "BD").
4. **L1 = 10cm** plano-convex lens (lens outline).
5. **L2 = 2.5cm** plano-convex lens (lens outline). L1 and L2 form a telescope.
6. Top-left: a 45° **mirror** (thick black diagonal bar) sends the beam downward.
7. On the vertical leg: **L3 = 25cm** lens (drawn horizontally in the vertical beam).
8. Bottom-left: a second 45° **mirror** turns the beam to travel rightwards along the bottom row.
9. **λ/2** half-wave plate (purple rectangle, labelled "λ/2").
10. **Berek** compensator (blue rectangle, labelled "Berek").
11. **BBO** (two adjacent light-cyan rectangles, labelled "BBO") — two thin type-I crystals at 90°.
12. The undeflected pump continues straight to a **BD** beam dump (black curved block).

Down-converted pairs (dashed red lines leaving the BBO at ± a small angle — about ±15° on the drawing — upward-right = signal, downward-right = idler):

Signal path (upper dashed line, path 1):
- **Double slit** drawn as two small light-blue squares with black bars at their entrance, labelled **PA** and **PB** — the polarizers covering slit A and slit B (the slit mask is the black bar in front of them).
- **L4 = 50cm** lens (lens outline).
- **P1** polarizer (light-blue tilted rectangle, labelled "P1").
- A black bar (the 200 μm single slit) in front of **D1** (dark grey box labelled "D1"), which sits on a lighter grey square plate with a grey double-headed arrow underneath, indicating that D1 translates perpendicular to the beam (the linear actuator).

Idler path (lower dashed line, path 2):
- **L5 = 50cm** lens (lens outline).
- **P2** polarizer (light-blue tilted rectangle, labelled "P2").
- **D2** (dark grey box labelled "D2"), stationary.

Legend box (top right, black border):
- BS : Beam Splitter
- BD : Beam Dump
- λ/2 : Half-wave plate
- Berek : Berek compensator
- L_ : Plano-convex lens

Style: clean vector schematic, red beams, purple wave plates, blue Berek, cyan BBO, light-blue polarizers, dark grey detectors. Not to scale.

Prose after the schematic [p.5]:

> The BBO crystal produces photon pairs in the Bell state:

Equation E1 [p.5]:
$$
\ket{\Phi^{+}} = \frac{1}{\sqrt{2}}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big).
$$

> **Signal path (path 1):** A double slit (b = 200 μm slit width, d = 400 μm separation) with polarizers P_A = 0° and P_B = 90° covering each slit. A 500 mm focal length lens is placed midway between the slits and detector (500 mm from each). A third polarizer P_1 at 45° acts as the eraser. Detector D_1 is mounted on a linear actuator with a 200 μm slit in front.
>
> **Idler path (path 2):** A 500 mm lens (500 mm from the detector) and a rotatable polarizer P_2.
>
> **Detection system:** Single-photon detectors coupled to optical fibers. Each fiber input requires a collimator and bandpass filter. The detectors count photons over a fixed integration time. We scan D_1 across the beam to reconstruct the spatial pattern. D_2 remains stationary since the idler beam has no spatial structure.
>
> Components before the BBO (beam preparation optics) are described in Experiment 4. [link: "Experiment 4"]

#### Equipment list [p.6]

Table (names in the first column are red links on the site, except "Double slit"):

| Name | Description |
|---|---|
| LASER | Diode laser (405nm) |
| BBO | Two thin BBO crystals of type 1 placed at 90° |
| Double slit | Dimension (200-200-200 μm), made in-house |
| Polarizers | Mounted linear polarizers |
| Lenses | Plano-convex lenses, L4 and L5 are LA?? (50cm) |
| Single slit | Adjustable slit (placed near 200μm) |
| Detectors | Single photon detection module |

> *Note: the components placed before the BBO are listed and explained in Experiment 4* [link]

("LA??" is literally what the site prints — an unfinished Thorlabs part number for the 500 mm plano-convex lenses; see Open questions.)

### Result and analysis [p.7–10]

#### Raw data [p.7]

> Data files for each P_2 configuration:

Links/downloads (four file tiles with a red file icon):
- `data_90deg.csv`
- `data_00deg.csv`
- `data_-45deg.csv`
- `data_45deg.csv`

> To reconstruct each pattern, we scanned the actuator across the beam. At each position, we recorded multiple samples to compute an average and standard deviation. We performed several sweeps to further reduce noise. Each file contains 7 columns:
>
> - Polarizer angle 1 (fixed in this experiment)
> - Polarizer angle 2 (fixed in this experiment)
> - Actuator position (μm)
> - Sweep number
> - Counts at D_1 (signal path)
> - Counts at D_2 (idler path)
> - Coincidences between D_1 and D_2

#### Graphics [p.8–10]

Eight plots arranged as four rows (one per P_2 angle) × two columns (left: D_1 singles, right: D_1–D_2 coincidences). All plots share the same style: matplotlib-like, white background, black box frame; x-axis "Distance on the screen (μm)" from about −2200 to +2200 (ticks −2000, −1000, 0, 1000, 2000); y-axis "Intensity per seconds"; legend top-left with three entries: "Theorical curve" (light grey dashed), "Fit of the datas" (blue/indigo solid), "Our datas" (black dots). About 70–80 data points per curve.

**At 45°** [p.8]
- Figure left: title "Number of counts on D1 per seconds [P2 = 45deg]". y from 330 to ~371. A single broad bell (sinc²-type diffraction envelope) peaked ~369 at x ≈ 0; data ≈ 331 at ±2000 μm. Fit and theory nearly coincide; the theory curve is slightly wider on the left.
- Figure right: title "Number of coincidences (D1-D2) per seconds [P2 = 45deg]". y from 0.2 to ~0.75. Data show a **central fringe peak ≈ 0.60 at x ≈ 0**, two side peaks ≈ 0.42 at x ≈ −900 μm and ≈ 0.48 at x ≈ +850 μm, minima ≈ 0.37 between them, falling to ≈ 0.25 at the edges. The fit (blue) reproduces three visible maxima with reduced visibility; the theory curve (grey dashed) shows full-visibility fringes: maximum ≈ 0.75 at 0, zeros near ±500 μm and ±1500 μm, side maxima ≈ 0.45 at ±1000 μm. Fringe period on the screen ≈ 1000 μm.

**At −45°** [p.9 top]
- Figure left: "Number of counts on D1 per seconds [P2 = -45deg]". y 330–371. Same bell as at 45°, peak ≈ 369 near x ≈ −100 μm.
- Figure right: "Number of coincidences (D1-D2) per seconds [P2 = -45deg]". y 0.15–0.55. Data show **two peaks ≈ 0.40 at x ≈ −450 μm and x ≈ +400 μm with a central dip ≈ 0.31 at x = 0** — exactly the complementary (anti-fringe) pattern of the 45° plot; outer shoulders ≈ 0.28 at ±1200 μm; ≈ 0.17 at the edges. Theory: full-contrast anti-fringes with maxima ≈ 0.47 at −450 μm and ≈ 0.55 at +400 μm, zero at x = 0 (≈ 0.16 baseline), secondary maxima ≈ 0.26 at ±1300 μm.

**At 0°** [p.9 bottom]
- Figure left: "Number of counts on D1 per seconds [P2 = 0deg]". y 170–202. Single bell, peak ≈ 201 at x ≈ −200 μm; ≈ 170 at +2000 μm. (Lower absolute rate than the ±45° runs — different session.)
- Figure right: "Number of coincidences (D1-D2) per seconds [P2 = 0deg]". y 0.05–0.28. **No fringes**: a single broad hump peaked ≈ 0.25 at x ≈ −400 μm (shifted to the left of centre), ≈ 0.10 at −2000 μm and ≈ 0.06 at +2000 μm. Fit and theory coincide.

**At 90°** [p.10 top]
- Figure left: "Number of counts on D1 per seconds [P2 = 90deg]". y 165–202. Same single bell as at 0°, peak ≈ 201 at x ≈ −200 μm.
- Figure right: "Number of coincidences (D1-D2) per seconds [P2 = 90deg]". y 0.07–0.40. **No fringes**: single hump peaked ≈ 0.33 at x ≈ 0 to +100 μm (shifted to the right relative to the 0° curve), ≈ 0.09 at both edges; data scatter is larger (one outlier ≈ 0.37 at x ≈ +200).

Prose [p.10]:

> **Singles (left column):** All four curves are identical (within experimental error). The D_1 singles show only diffraction, regardless of P_2. This confirms that no local measurement at D_1 can reveal interference.
>
> **Coincidences (right column):**
> - P_2 = ±45°: Clear interference fringes. The two patterns are complementary (peaks and troughs swap).
> - P_2 = 0° or 90°: No interference, only diffraction. The two curves are slightly shifted because each selects photons from a different slit. The diffraction maxima are centered on each slit.
>
> This is the quantum eraser effect: interference appears only in coincidences, and only when P_2 is set to erase which-path information.

(Print artefact: the big heading "Theory and equations" is printed overlapping the "P_2 = ±45°" bullet on p.10; it belongs to the next section.)

### Theory and equations [p.10–17]

#### Conceptual Overview [p.11–12]

> The BBO crystal generates entangled photon pairs in the Bell state:

Equation E1 repeated [p.11]:
$$
\ket{\Phi^{+}} = \frac{1}{\sqrt{2}}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big).
$$

> The photons travel along two paths:
>
> **Signal path:** A double slit where each slit is covered by a polarizer (P_A = 0°, P_B = 90°). This encodes which-path information in the polarization. A third polarizer P_1 at 45° projects both polarizations onto the diagonal basis.
>
> **Idler path:** A single rotatable polarizer P_2 at angle γ. The key physics:
>
> - After the slit polarizers, measuring the idler's polarization reveals which slit the signal passed through (vertical ⇒ slit A, horizontal ⇒ slit B).
> - If P_2 = 0° or 90°, it selects one polarization, preserving which-path information. Coincidences show only diffraction.
> - If P_2 = ±45°, it projects onto the diagonal basis, erasing which-path information. Coincidences show interference.
> - Singles at D_1 never show interference, regardless of P_2. The which-path information exists in the idler, even if we choose not to access it.
>
> The "delayed choice" aspect: the idler can be measured *after* the signal is detected. The choice of P_2 angle determines whether interference appears in the coincidence record, even though the signal detection already occurred.

#### Mathematics [p.12–14]

Heading "Mathematics" [p.12], then a full-page infographic [p.13–14] captioned *"Delayed-choice quantum eraser setup."*

Figure [p.13–14] — Infographic (a tall, hand-designed poster with rounded panels, serif typography, pastel colours; a faint grey watermark line at its bottom edge reads approximately "DRAFT LAYOUT FOR VALÉRIE" [unclear]). Panels from top to bottom:

1. **Panel "Delayed-Choice Quantum Eraser Setup"** — a minimal left-to-right schematic: grey box **BBO** at left; two dotted lines diverge to the right. Upper line = "signal": a black vertical bar with two gaps (the double slit), a small yellow circle labelled "0°" on the upper slit and a pink circle labelled "90°" on the lower slit (the slit polarizers P_A, P_B), then a blue rounded rectangle **P1** marked "45°", then a red box **D1**. Lower line = "idler": continues further right, through a green rounded rectangle **P2** marked "γ", to a red box **D2**. Both detectors feed a pink box "coinc" (coincidence counter) at the far right. Note the drawing places P2 physically *further from the BBO than D1*, i.e. the idler is drawn as the longer arm. Text under it:
   > The idler polarizer **P2** can be set *after* the signal reaches D1.
   > Its angle γ determines whether interference appears in the **coincidences**.

2. **Panel "D1 Singles: Always the same (no interference)"** — a plot of a single smooth grey bell curve (no fringes). Text at right:
   > Looking at D1 alone, you **never** see interference — just diffraction.
   > The which-way info is in the idler, even if we don't look at it.

3. **Panel (green border) "The Key: P2 chooses the basis"** — two sub-boxes:
   - Left: "In the H/V basis (P2 = 0° or 90°)": "|↕⟩₂ from slit A, |↔⟩₂ from slit B" / "orthogonal → can distinguish → no interference" / "P2 = 0° selects slit A photons only" / "P2 = 90° selects slit B photons only".
   - Right (green text): "In the diagonal basis (P2 = ±45°)": "|↗↙⟩₂ ← both slits contribute" / "|↘↖⟩₂ ← both slits contribute" / "can't distinguish → interference!" / "P2 = 45° mixes both paths → fringes" / "P2 = −45° mixes both paths → anti-fringes".

4. **Panel "Coincidence patterns for each P2 angle"** — four cards:
   - Grey header "WE KNOW: slit A", "P2 = 0°" (yellow): a single grey bell; caption "I ∝ 1 (no cos)".
   - Grey header "WE KNOW: slit B", "P2 = 90°" (pink): a single grey bell; caption "I ∝ 1 (no cos)".
   - Green header "WE DON'T KNOW", "P2 = 45°" (green): a blue fringe pattern inside a bell envelope (bright central fringe, ~5 visible fringes); caption "I ∝ 1 + cos".
   - Green header "WE DON'T KNOW", "P2 = −45°" (purple): a purple anti-fringe pattern (central minimum, two main peaks); caption "I ∝ 1 − cos".
   Summary box (light blue):
   > **45°** and **−45°** are complementary (maxima ↔ minima).
   > **0°** and **90°** are shifted copies (centered on each slit).
   > All pairs sum to the same envelope. P2 **picks a decomposition**.

5. **Panel (beige/orange border) "The "Delayed Choice""**:
   > P2 can be set **after** the signal photon reaches D1.
   > Yet it determines whether interference appears in the coincidence record.
   > *The past isn't changed — the correlation was always there, waiting to be revealed.*

Caption under the infographic: *Delayed-choice quantum eraser setup.*

Prose [p.14]:

> The delayed-choice quantum eraser follows the same logic as Experiment 3 [link], but with entangled photons. The idler polarizer P_2 plays the role that P_1 played before: it chooses which basis to use, and that choice determines whether interference appears.

##### The state after the slit polarizers [p.14–15]

> The BBO produces entangled pairs. After the signal passes through the double slit (with P_A = 0° on slit A, P_B = 90° on slit B) and the eraser polarizer P_1 at 45°, the state is:

Equation E2 [p.15]:
$$
\ket{\psi} = \frac{1}{2\sqrt{2}}\Big(e^{ika}\ket{\nearrow\swarrow}_1\ket{\updownarrow}_2 + e^{ikb}\ket{\nearrow\swarrow}_1\ket{\leftrightarrow}_2\Big)\ket{y}_1\ket{D}_2
$$

(Notation: |↗↙⟩ = diagonal (+45°) polarization; e^{ika}, e^{ikb} = propagation phases from slit A / slit B to the screen point; |y⟩₁ = the signal's transverse position (screen coordinate); |D⟩₂ = the idler's spatial mode at detector D_2. The subscript 1 = signal, 2 = idler.)

> The signal polarization is now diagonal for both paths — P_1 has done its job. But the **idler polarizations are still orthogonal**: |↕⟩₂ vs |↔⟩₂.
>
> This is why D_1 alone sees no interference: the two paths are still distinguishable via the idler.

##### Choosing a basis [p.15–16]

> Here is the key insight: *the idler polarizer P_2 chooses which basis to express the idler in.*
>
> **In the H/V basis (P_2 = 0° or 90°):** The idler states |↕⟩₂ and |↔⟩₂ are orthogonal → the two terms cannot combine → no interference.
>
> Setting P_2 = 0° selects only |↕⟩₂ photons (from slit A). Setting P_2 = 90° selects only |↔⟩₂ photons (from slit B). Either way, we know which slit.
>
> **In the diagonal basis (P_2 = ±45°):** We can rewrite the idler states as:

Equation E3 [p.15]:
$$
\ket{\updownarrow}_2 = \frac{1}{\sqrt{2}}\Big(\ket{\nearrow\swarrow}_2 + \ket{\searrow\nwarrow}_2\Big), \qquad
\ket{\leftrightarrow}_2 = \frac{1}{\sqrt{2}}\Big(\ket{\nearrow\swarrow}_2 - \ket{\searrow\nwarrow}_2\Big)
$$

> Now both paths contribute to |↗↙⟩₂ and both contribute to |↘↖⟩₂. When P_2 selects one diagonal component, it mixes amplitudes from *both* slits → interference is possible.

##### What P_2 does [p.16]

> The idler polarizer projects onto angle γ. The coincidence intensity is:

Equation E4 [p.16]:
$$
I(\gamma) \propto 1 + \sin(2\gamma)\,\cos\!\big[k(a-b)\big]
$$

Table [p.16]:

| P_2 angle | Selects idler | sin(2γ) | Result |
|---|---|---|---|
| 0° | \|↕⟩₂ (slit A only) | 0 | no interference |
| 90° | \|↔⟩₂ (slit B only) | 0 | no interference |
| 45° | \|↗↙⟩₂ (both slits) | +1 | **interference** |
| −45° | \|↘↖⟩₂ (both slits) | −1 | **anti-interference** |

(The table has a horizontal rule separating the 0°/90° pair from the ±45° pair.)

##### Why does ±45° restore interference? [p.16–17]

> At 0° or 90°, the polarizer selects idler photons from *one slit only*. The coincidence record contains only single-slit photons → no interference.
>
> At 45°, the polarizer accepts idler photons from *both* slits with equal amplitude. A coincidence event could have come from either path — we cannot tell. The which-way information has been **erased**, and interference reappears.
>
> This is the delayed-choice quantum eraser: the choice of P_2 can be made *after* the signal is detected, yet it determines whether interference appears in the coincidence record.

##### Complementary pairs [p.17]

> The 45° and −45° patterns are opposite (maxima ↔ minima). The 0° and 90° patterns are shifted copies of each other (centered on each slit).
>
> In all cases, summing the complementary pair recovers the same diffraction envelope. The idler polarizer does not create or destroy photons — it picks a **decomposition**.

##### Why no interference in singles? [p.17]

> The D_1 singles count all signal photons, regardless of what happens to the idler. This is equivalent to averaging over all possible P_2 angles:

Equation E5 [p.17]:
$$
\int_0^{2\pi} \sin(2\gamma)\, d\gamma = 0
$$

> The interference terms cancel. Only by selecting a specific idler outcome (via coincidences) can interference appear.

### Litterature and video [p.17–18]
(Site spelling: "Litterature and video". In the print this heading and its paragraphs overlap the "Complementary pairs" / "Why no interference in singles?" text of the Theory section; de-interleaved here.)

> If you want to check out some papers that did the same experiment, here are the two best resources we have found:

Links [p.17] — two paper thumbnails (first page of each PDF):
1. **"A Delayed Choice Quantum Eraser"** — Yoon-Ho Kim, R. Yu, S.P. Kulik, and Y.H. Shih, Department of Physics, University of Maryland, Baltimore County, Baltimore, MD 21250; Marlan O. Scully, Department of Physics, Texas A&M University, College Station, TX 77842. (The 1998/2000 experiment mentioned in the abstract: Phys. Rev. Lett. 84, 1 (2000).)
2. **"A double-slit quantum eraser"** — S. P. Walborn, M. O. Terra Cunha, S. Pádua, and C. H. Monken, Departamento de Física / Departamento de Matemática, Universidade Federal de Minas Gerais, Caixa Postal 702, Belo Horizonte, MG 30123-970, Brazil, (February 1, 2008). (The "Brazil" experiment with slit polarizers, Phys. Rev. A 65, 033818 (2002); the site cites the arXiv date.)

> If you want a more interactive resource, here are some Youtube videos we found to be accurate and insightful.

Embed [p.18] — YouTube embed: **"The Delayed Choice Quantum Eraser"** by **Sabine Hossenfelder** (player chrome visible: share icon, watch-later icon, "Watch on" YouTube). Only one video is visible in the print.

### Similar Experiments [p.18–19]
Heading "Similar Experiments" followed by three cards:
- **INTRODUCTION — Quantum for everyone** (card image: "OVERVIEW" in large black letters).
- **EXPERIMENT 1 — Polarizers** (card image: four rows of laser → polarizer circles → detector schematics with Ψ_0, Ψ_1, Ψ_2, Ψ_3 labels).
- **EXPERIMENT 2 — Single and double slit** (card image: laser → slit → screen schematics with Ψ_0, Ψ_1, Ψ_2, Ψ_3).

Footer [p.19]: "Testing Reality © 2018-2026" and "Creative commons" with CC BY-NC icons.

## Physics model for simulation

### Hilbert space
- Photon 1 (signal): polarization qubit {|↕⟩ (V, 0°), |↔⟩ (H, 90°)} ⊗ path qubit {|A⟩, |B⟩} ⊗ transverse position |y⟩ on the screen.
- Photon 2 (idler): polarization qubit {|↕⟩₂, |↔⟩₂} ⊗ a single spatial mode |D⟩₂ (no spatial structure; D_2 is stationary).
- Site angle convention: 0° = vertical |↕⟩, 90° = horizontal |↔⟩; +45° = |↗↙⟩ = (|↕⟩+|↔⟩)/√2; −45° = |↘↖⟩ = (|↕⟩−|↔⟩)/√2 (from E3). Polarizer at angle γ transmits |γ⟩ = cos γ |↕⟩ + sin γ |↔⟩.

### Source
BBO (two type-I crystals at 90°, pumped at 405 nm) emits the Bell state E1: |Φ+⟩ = (|↕⟩₁|↕⟩₂ + |↔⟩₁|↔⟩₂)/√2. Signal and idler leave at symmetric angles (≈ ±3° in reality; drawn ≈ ±15°).

### Operators, in order along the signal path
1. Double slit with slit polarizers: slit A (width b) carries projector P_A = |↕⟩⟨↕| (0°), slit B carries P_B = |↔⟩⟨↔| (90°). Acting on |Φ+⟩ and keeping the path label:
   |ψ₁⟩ = (1/√2)( |A⟩|↕⟩₁|↕⟩₂ + |B⟩|↔⟩₁|↔⟩₂ ).
   The path and the idler polarization are now perfectly correlated: idler V ⇒ slit A, idler H ⇒ slit B.
2. Propagation to the screen point y: path A acquires phase e^{ika}, path B e^{ikb}, where a, b are the optical lengths from slit A / slit B to y (k = 2π/λ). With the lens at 2f–2f (500 mm each side) the pattern is the Fraunhofer pattern of the double slit.
3. Eraser polarizer P_1 at 45°: projector |↗↙⟩⟨↗↙|. ⟨↗↙|↕⟩ = ⟨↗↙|↔⟩ = 1/√2, giving the extra 1/2 and E2:
   |ψ⟩ = (1/(2√2)) ( e^{ika} |↗↙⟩₁|↕⟩₂ + e^{ikb} |↗↙⟩₁|↔⟩₂ ) |y⟩₁|D⟩₂.
   P_1 removes the polarization tag on the signal but the idler still carries it.
4. 200 μm slit on D_1 at position y (actuator), integrate counts.

### Idler path
Polarizer P_2 at angle γ (projector |γ⟩⟨γ|, |γ⟩ = cos γ|↕⟩₂ + sin γ|↔⟩₂), then D_2.

### Predicted rates
- Coincidence amplitude for the joint outcome (D_1 at y, D_2 behind P_2 = γ):
  A(y, γ) = (1/(2√2)) ( e^{ika} cos γ + e^{ikb} sin γ ).
- Coincidence rate (site's E4, with the envelope made explicit):
  R_c(y, γ) ∝ |A|² = (1/8) [ cos²γ + sin²γ + 2 sin γ cos γ cos k(a−b) ] = (1/8) [ 1 + sin(2γ) cos k(a−b) ].
  Multiply by the single-slit diffraction envelope sinc²(π b y / (λ f)) (and, per slit, by a per-slit envelope centred on that slit's image when the magnification is 1 — see next bullet).
- Fraunhofer form with the lens: the phase difference is k(a−b) = 2π d y / (λ f) (f = 500 mm). Hence
  R_c(y, γ) ∝ sinc²(π b y/(λ f)) · [1 + sin(2γ) cos(2π d y/(λ f))].
  - γ = +45°: 1 + cos(…) → fringes, bright centre. (Measured: peaks at 0, ≈ ±900 μm.)
  - γ = −45°: 1 − cos(…) → anti-fringes, dark centre. (Measured: peaks at ≈ ±450 μm, dip at 0.)
  - γ = 0°: envelope only, from slit A (the site: "centred on slit A", observed hump shifted ≈ −400 μm).
  - γ = 90°: envelope only, from slit B (observed hump near 0/+100 μm). The ±200 μm shift expected from a 2f–2f imaging geometry (magnification −1, slits at ±d/2 = ±200 μm) is of the right order as the observed relative shift of ≈ 400–500 μm between the 0° and 90° humps.
  - Sum rule: R_c(y, 45°) + R_c(y, −45°) = R_c(y, 0°) + R_c(y, 90°) ∝ 2·envelope — "All pairs sum to the same envelope."
- Singles at D_1 (trace over the idler, equivalently average E4 over γ; E5): R_1(y) ∝ sinc²(π b y/(λ f)) × const — never any fringes, independent of γ. If the simulation uses the per-slit shifted envelopes, singles = sum of the two shifted humps.
- Singles at D_2: constant (no spatial structure); with P_2 at any angle, half the idlers pass (cos²γ + sin²γ)/2 = 1/2 of the source rate.
- Visibility: theory 100 %; the measured 45° fit has visibility roughly (0.60−0.37)/(0.60+0.37) ≈ 0.24 at the centre; the site's plots label the full-visibility curve "Theorical curve" and the reduced-visibility one "Fit of the datas". A game simulator should expose a visibility parameter V (default ≈ 0.3–0.5 for "lab-realistic", 1.0 for "ideal"): R_c ∝ env · [1 + V sin(2γ) cos(…)].

### Parameters given by the site
- Pump: diode laser 405 nm.
- Double slit: b = 200 μm slit width, d = 400 μm centre-to-centre separation ("200-200-200 μm" = slit, gap, slit), made in-house.
- Slit polarizers: P_A = 0°, P_B = 90°. Eraser P_1 = 45°. Idler P_2 = γ ∈ {0°, 90°, +45°, −45°} in the data.
- Lenses: L4 = L5 = 500 mm plano-convex; L4 midway between slits and D_1 (500 mm each side, i.e. 2f–2f); L5 500 mm from D_2.
- D_1 scanning slit: adjustable slit "placed near 200 μm", on a motorised linear actuator; scan range ≈ −2200 … +2200 μm, step ≈ 50–60 μm (≈ 75 points per sweep).
- Detection: single-photon detection modules, fibre-coupled, each with a collimator and a bandpass (long-pass in the photo) filter; fixed integration time per point; multiple samples per point; several sweeps averaged.
- Measured rates (read off the plots): D_1 singles ≈ 330–370 counts/s (±45° runs), ≈ 165–200 counts/s (0°/90° runs); coincidences 0.05–0.75 counts/s.
- Pump optics (from Experiment 4): λ/2, BS + beam dump, L1 = 10 cm, L2 = 2.5 cm (telescope), two mirrors, L3 = 25 cm, λ/2, Berek compensator, BBO, beam dump.

### Parameters NOT given (proposed values)
- Down-converted wavelength λ: not stated on this page. Use 810 nm (degenerate SPDC of a 405 nm pump) — standard and consistent with the observed fringe period λf/d = 0.81 μm × 500 mm / 400 μm ≈ 1.0 mm (observed ≈ 0.9–1.0 mm) and envelope first zero λf/b ≈ 2.0 mm (observed edges at ±2 mm).
- Coincidence window: not stated; propose 5–10 ns (typical for SPCM-based counters).
- Integration time per point: not stated; propose 1 s (rates are given "per seconds").
- Slit–BBO distance and the actual fibre/cable lengths: not stated (see Open questions). The "delayed" claim is made conceptually, not with a quoted delay.
- SPDC opening angle: not stated; propose 3° half-angle (type-I BBO at 405 nm), and ≈ 60 cm from BBO to the double slit so the two arms fit on a 1.2 m breadboard.

## Apparatus list (for Blender)

Items marked (stated) appear in the site's text/diagram; (photo) are visible only in the lab photo; (assumed) are inferred.

Pump preparation (shared with Experiment 4, drawn in the schematic):
1. Diode laser, 405 nm (stated). Compact violet laser head, ≈ 40 × 40 × 100 mm, on a post/clamp (assumed). Beam colour violet.
2. Half-wave plate λ/2 #1 (stated) — 1-inch wave plate in a rotation mount, ≈ 50 mm dia × 15 mm, on a post (assumed).
3. Cube beam splitter BS (stated) — 1-inch cube (25.4 mm) on a kinematic platform mount; a beam dump BD on its reflected port (black anodised cone/bucket, ≈ 30 × 30 × 50 mm) (assumed dims).
4. Plano-convex lens L1 = 10 cm focal length (stated); 1-inch lens in a lens mount on a post (assumed).
5. Plano-convex lens L2 = 2.5 cm (stated); same mounting. L1/L2 = beam telescope.
6. Mirror #1, 45°, in a kinematic mirror mount (stated as mirror; mount assumed), 1-inch.
7. Plano-convex lens L3 = 25 cm (stated).
8. Mirror #2, 45°, kinematic mount.
9. Half-wave plate λ/2 #2 (stated), rotation mount.
10. Berek compensator (stated) — a tiltable/rotatable plate in a compact mount, ≈ 50 mm dia (assumed dims).
11. BBO: "Two thin BBO crystals of type 1 placed at 90°" (stated) — a ≈ 5 × 5 × 1 mm crystal pair in a small mount, in a rotation/tilt mount on a post (assumed).
12. Beam dump BD for the undeflected pump (stated), black.

Signal arm (path 1):
13. Double slit, in-house, 200-200-200 μm (stated); a thin plate/foil in a 1-inch holder (assumed), with
14. Polarizer P_A at 0° and polarizer P_B at 90°, one covering each slit (stated). In practice two small polarizer films glued over the slits (assumed); the schematic draws them as two separate squares labelled PA/PB.
15. Plano-convex lens L4, f = 500 mm, "LA??" Thorlabs (stated, part number truncated), 1-inch in a lens mount, 500 mm from the slits and 500 mm from D_1 (stated).
16. Polarizer P_1 at 45° — "mounted linear polarizer" (stated), in a rotation mount (assumed).
17. Adjustable single slit, set near 200 μm, with micrometer (stated; photo).
18. Long-pass filter in a 1-inch mount (photo; text says "bandpass filter").
19. Fibre collimator (photo; stated "collimator"), Thorlabs cage plate CP33 visible, orange FC fibre patch cord.
20. Motorised rotation mount with red PCB and ribbon cable — "Rotation motor (unused)" (photo).
21. Motorised linear actuator / translation stage carrying the whole D_1 head, gold/brass actuator body, grey ribbon cable (stated "linear actuator"; photo).
22. Single-photon detection module D_1 (stated), fibre-coupled — the module itself is off-screen; model as a black box (≈ 90 × 60 × 40 mm) with an FC fibre input and BNC output (assumed).
23. Posts, post holders, pitch/yaw adjuster block, cage plates, clamps (photo).

Idler arm (path 2):
24. Plano-convex lens L5, f = 500 mm (stated), 500 mm from D_2.
25. Polarizer P_2, rotatable (stated) — linear polarizer in a (manual or motorised) rotation mount; the data files list "Polarizer angle 2" so a calibrated rotation mount is implied.
26. Collimator + bandpass filter + fibre (stated "each fiber input requires a collimator and bandpass filter").
27. Single-photon detection module D_2 (stated), stationary.

Electronics / environment:
28. Coincidence counter ("coinc" box in the infographic) (stated in infographic; assumed hardware: an FPGA/counter box).
29. Computer logging 7-column CSVs (implied by the data section).
30. Black optical breadboard with M6 hole grid, lab shelving, blue bins, notebook (photo, background dressing).

## Teaching notes

Concepts assumed, in the order the page needs them:
1. Linear polarization states as vectors; polarizer as a projector; Malus-type overlaps ⟨↗↙|↕⟩ = 1/√2 (needed to go from E1 to E2 and for E3).
2. Change of basis: writing |↕⟩, |↔⟩ in the diagonal basis (E3) — the whole argument hinges on "P_2 chooses the basis".
3. Double-slit interference and single-slit diffraction (from Experiment 2): path phases e^{ika}, e^{ikb}, the cos k(a−b) cross term, the sinc² envelope, Fraunhofer geometry with a lens (fringe period λf/d).
4. Tensor products of two photons, entanglement, the Bell state |Φ+⟩ (from Experiment 4): correlations between the idler's polarization and the signal's path.
5. Complex amplitudes and |amplitude|² → probability; adding amplitudes vs adding probabilities ("orthogonal → the two terms cannot combine"). Derivation of E4: |cos γ e^{ika} + sin γ e^{ikb}|² = 1 + sin 2γ cos k(a−b).
6. Partial trace / marginal: averaging E4 over γ gives E5 (∫ sin 2γ dγ = 0) — why singles never interfere; also the "sum rule" that complementary pairs add to the same envelope.
7. Coincidence counting as post-selection: interference lives in the joint record, not in either detector alone.
8. Causality framing: timing ("the choice of P_2 can be made after the signal is detected") versus the resolution ("the past isn't changed — the correlation was always there, waiting to be revealed"; "P_2 picks a decomposition"; "the idler polarizer does not create or destroy photons").

Site's pedagogical moves:
- Opens with the paradox hook ("it may appear that a measurement made in the present can alter one made in the past") and immediately gives the resolution (which-path info lives in the idler).
- Links back explicitly: same logic as Experiment 3 (the non-entangled quantum eraser where P_1 chose the basis), but now P_2 on the other photon plays P_1's role; beam preparation = Experiment 4.
- Interactive animation first (purple singles curve vs pink coincidence curve), then the lab photo and schematic, then raw CSVs so the learner can re-plot, then the theory.
- Infographic uses "WE KNOW: slit A / slit B" vs "WE DON'T KNOW" cards to make the which-path criterion visual, and labels each card with its intensity law (1, 1, 1 + cos, 1 − cos).
- The four-row table (angle → selected idler state → sin 2γ → result) is the single most game-ready summary; a scene can expose a P_2 dial and show sin 2γ and the resulting pink curve live.
- Ends on complementarity ("complementary pairs") and the marginal argument ("why no interference in singles?").

## Open questions
- **Delay/path lengths:** the task asked for which photon is delayed and the fibre/path delays. The site does not state any delay, fibre length or arm-length difference. The only geometric numbers are the lens placements (L4 500 mm from slits and 500 mm from D_1; L5 500 mm from D_2). The infographic draws P_2 further from the BBO than D_1 and says "P2 can be set after the signal reaches D1"; the prose says "the idler can be measured after the signal is detected". Whether the lab arm was actually made longer (and by how much) is not documented. Recommend the 3D scene make the idler arm visibly longer (e.g. extra 1 m via a fibre loop) and flag it as a staging choice.
- Down-converted wavelength is not given on this page (presumably 810 nm, from Experiment 4).
- "LA??" in the lens description is an unfinished Thorlabs part number (likely an LA1xxx 500 mm lens); the site itself left it incomplete.
- The equipment list calls the detector-side filter a "bandpass filter" while the photo labels it "Long pass filter".
- The site says the four singles curves are "identical (within experimental error)", but the absolute rates differ by ≈ 2× between the ±45° runs (330–370 /s) and the 0°/90° runs (165–200 /s); shapes are identical, so the statement is about shape. Note also that the singles should not depend on P_2 at all — the difference indicates separate measurement sessions / laser power.
- The two P_2 = 0°/90° coincidence humps are shifted relative to each other by ≈ 400–500 μm; the text says "centred on each slit" (expected ±200 μm for unit magnification). Minor discrepancy, within the plotted scatter.
- The StackBlitz animation did not render in the PDF; its controls/colours are inferred from the abstract (purple = singles, pink = coincidences).
- Only one YouTube video (Sabine Hossenfelder) is visible although the text says "some Youtube videos".
- The infographic carries a faint watermark that reads approximately "DRAFT LAYOUT FOR VALÉRIE" [unclear] — the infographic appears to be a draft layout.
- Print artefacts: the "Theory and equations" and "Litterature and video" headings are printed on top of neighbouring paragraphs (p.10, p.17); de-interleaved above as best as possible. Equation E2's subscript placement (|y⟩₁|D⟩₂) was read from the 130-dpi render.
