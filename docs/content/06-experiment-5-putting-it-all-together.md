# Experiment 5 : Putting it all together
Source: "H-Experiment 5 _ putting it all together.pdf"; URL printed in the footer: https://testing-reality.webflow.io/experiment-5 ; 25 pages (printed 30/10/2026, 20:52).

Site header nav on every page: "Testing Reality" logo (left), "Experiments", "About" (right). Footer on every page: "Made in Webflow" badge, URL, page number.

## Page summary
This page takes the polarization-entangled photon-pair source of Experiment 4 (405 nm pump, two thin BBO crystals, Bell state |Φ+⟩) and sends the *signal* photon through the double slit of Experiments 2/3 while the *idler* photon flies straight to detector D2. Detector D1 is scanned across the signal-side pattern on a linear actuator; both singles (D1 alone) and D1–D2 coincidences (10 ns window) are recorded. Three configurations are built up one component at a time: 5.1 bare double slit (clear interference in both singles and coincidences), 5.2 a vertical polarizer P_A (0°) on slit A and a horizontal polarizer P_B (90°) on slit B (interference vanishes; only the sum of two single-slit diffraction envelopes remains, and count rates halve), and 5.3 an extra 45° polarizer P1 after the slits on the signal path (surprisingly, interference does *not* come back, unlike Experiment 3). The punchline: with entangled pairs the which-path tag is copied into the idler's polarization; because the two idler states |↕⟩₂ and |↔⟩₂ are orthogonal, the two path amplitudes can never recombine, and no operation on the signal path alone can erase that information. The page ends by announcing the fix (measure the idler in the diagonal basis and post-select), i.e. the quantum eraser of Experiment 6.

## Content (in page order)

The left-hand "TABLE OF CONTENT" (p.2) lists: Abstract / Lab Experiments / Result and analysis / Theory and equations. (The actual theory section on the page is titled "Mathematics and equations".)

### [p.1] Title page
- Small caps kicker: "EXPERIMENT 5"
- Large serif title: "Putting it all together"

### [p.2–3] Abstract

Prose (p.2):

> This section presents experiments 5.1–5.3, which set up the puzzle that the quantum eraser will resolve in experiment 6. Starting from the entanglement setup of experiment 4, we add a double slit and polarizers on the signal path. The detector D₁ is mounted on a linear actuator to scan the diffraction and interference patterns.
>
> This section presents one of the most counterintuitive aspects of entanglement. If we reproduce the same experiment as experiment 3 (double slit with polarizers), but using entangled photon pairs instead of single photons, the results change completely.
>
> We proceed step by step, adding one component at a time to observe how each affects the final pattern. For details on the entanglement source and BBO crystal, refer to experiment 4. The development is split into three parts:
>
> - **5.1**: Double slit only. We observe interference.
> - **5.2**: Orthogonal polarizers on each slit. Interference disappears due to which-path information.
> - **5.3**: A third polarizer at 45°. Surprisingly, interference does *not* return.

Prose (p.3):

> The key puzzle: in Experiment 3, the third polarizer restored interference by erasing which-path information. With entangled photons, it fails. The which-path information is no longer stored in the signal photon's polarization. Instead, it is encoded in the *idler* photon. No local operation on the signal path can erase it.
> Try the animation first, then examine the results below.

("Experiment 3" and later "Experiment 4" are rendered as orange/red hyperlinks to the sibling pages.)

Embed [p.3]: a StackBlitz embed, "react-vazdln-kpdd3a created by vmonette", with a "Run this project" button. In the PDF print it shows only StackBlitz's phishing-protection interstitial ("This page is shown to protect against phishing attacks. If this link was sent to you by someone who you don't know please proceed with caution or contact us. If you'd like to remove this from your StackBlitz preview URLs, please upgrade your membership plan.") and the status "Starting dev server". The animation itself is NOT visible in the print. From context it is an interactive React animation of the 5.1–5.3 setups (same family as the simulators on the other experiment pages). [unclear: controls and visuals of the animation]

### [p.4] Lab Experiments — Exp 5.1 : Adding the double slit

Prose:

> We start with the same setup as in Experiment 4, but remove the two polarizers in front of the detectors (they were only needed to verify the polarization state). Detector D₁ is mounted on a linear actuator to scan the full pattern.

Figure [p.4] — schematic, "Setup for Experiment 5.1: double slit with entangled photons and no polarizers."
Flat, pastel, 2-D schematic on a very light blue-grey rounded panel. Left to right:
- **LASER**: salmon/pink rectangle with a small triangular nozzle on its right, label pill "LASER" (pink pill, red text) below it.
- A thin solid red beam line goes right.
- An **unlabelled grey hatched disc** (diagonal hatching) on the beam — same symbol the site uses right after the laser in the Exp 1 and Exp 2 cards; it represents the beam-conditioning optics (interpretation: the lens/wave-plate/PBS stage of Exp 4 collapsed into one symbol). [unclear: exact meaning]
- **BB**: two thin light-blue vertical rectangles side by side (the two thin BBO crystals placed at 90°), label pill "BB" (light-blue pill, blue text) below.
- From the right face of BB, **red dashed lines** (photon pairs) fan out:
  - Upper ray goes up-right to a **mirror** drawn as a short thick black tilted bar (about 30° from horizontal), then runs horizontally right to **D2**.
  - Lower pair of rays goes right to the **double slit**, drawn as a thick black vertical bar broken by two small gaps (three black segments: top, middle, bottom). One ray enters the upper gap (slit A), one the lower gap (slit B).
  - From each slit a red dashed line converges on **D1** (so slit → D1 forms a narrow diamond with the BB → slit rays).
- **D2** (top right) and **D1** (right, on the beam axis): salmon rectangles (taller than wide), label pills "D2" / "D1" below each.
- A thin black bracket joins D1 and D2 on the far right to a small rotated pill labelled **"coin"** (coincidence counter).
- Vertical grey dashed reference lines with Greek labels under them: **Ψ₀** (just after the laser), **Ψ₁** (just after BB), **Ψ₂** (at the double slit), **Ψ₃** (at the detectors).
- No polarizers anywhere in this diagram.

### [p.5] Graphics — "No polarizers"

Figure [p.5] — **lab photo**, labelled with a lilac pill "Double slit" (purple text) in the top-left corner.
- Close-up photograph of the home-made double slit. A square transparent acrylic plate (approx. 25–30 mm side) held by four stainless hex-head bolts/standoffs at its corners (top-left and bottom-left bolts seen head-on, top-right and bottom-right seen from the side, the bottom-right with a nut).
- Behind the clear plate, a thin metallic foil/shim with a **stadium-shaped (oval) aperture**; inside the aperture two extremely fine parallel vertical lines are visible — the two slits (200 µm wide, 200 µm apart per the Exp 2/4 equipment list).
- The plate sits on top of a black cylindrical mount (a Thorlabs-style post holder / rotation mount with a blue dot) on an optical breadboard with the regular M6 hole grid visible in the blurred background.
- Black mounting clamps/bases out of focus at bottom-left and right; white wall in the background; shallow depth of field.
- Below the photo: heading "Graphics" (serif) and sub-heading "No polarizers" (bold sans), introducing the two plots on p.6.

### [p.6] Results for 5.1 (two plots) + Raw data

Figure [p.6, left] — plot, title "Number of counts on D1 per seconds [No polarizer]".
- x axis: "Distance on the screen (µm)", range about −2200 to +2200, ticks −2000, −1000, 0, 1000, 2000.
- y axis: "Intensity per seconds", ticks 200, 250, 300, 350, 400.
- Legend: "Theorical curve" (grey dashed), "Fit of the datas" (blue solid), "Our datas" (black dots).
- Data: a clear three-lobe interference pattern. Central maximum ≈ 410 counts/s at y = 0; two side maxima ≈ 275 counts/s at y ≈ ±900 µm; minima between them ≈ 265 counts/s at y ≈ ±500 µm; baseline/background ≈ 180 counts/s at |y| ≥ 2000 µm. Roughly 70 data points, very smooth.
- Theoretical curve (dashed grey): sharper fringes with much deeper minima — maxima at 0 (≈ 425) and ±900 µm (≈ 285), minima touching the baseline (≈ 180) at ≈ ±450 µm and ≈ ±1350 µm, i.e. fringe spacing ≈ 900 µm under a single-slit envelope. The measured fringe visibility is clearly lower than the ideal.

Figure [p.6, right] — plot, title "Number of coincidences (D1-D2) per seconds [No polarizer]".
- Same x axis; y axis "Intensity per seconds", ticks 0–8.
- Same shape as the singles: central peak ≈ 7.7 coincidences/s at y = 0, side peaks ≈ 3.6 at ±900 µm, minima ≈ 3.2 at ≈ ±550 µm, background ≈ 0.3 at |y| ≥ 2000 µm. Dashed theoretical curve peaks at ≈ 8, with minima near 0.3 at ±450 µm and ±1350 µm.

Prose (p.6; print overlaps "Raw data" with the result paragraph — reconstructed order):

> Both graphs show a clear interference pattern. The right graph has fewer counts because it records only coincidences: events where D₁ and D₂ both detect a photon within a 10 ns window.
>
> As expected, a double slit produces interference.

**Raw data** — "The data is available here:" download link **data5_1.csv** (red file icon).

> This file contains 6 columns:
> - Polarizer angle 1 (not applicable here)
> - Polarizer angle 2 (not applicable here)
> - Actuator position
> - Sweep number
> - Counts at D₁
> - Counts at D₂
> - Coincidences between D₁ and D₂
>
> All counts are recorded over 20-second windows.

(Note: the site says "6 columns" but lists 7 items.)

### [p.7] Exp 5.2 : Covering the slit with polarizers

Prose:

> We place a vertical polarizer (P_A at 0°) in front of slit A and a horizontal polarizer (P_B at 90°) in front of slit B. This encodes which-path information in the polarization.

Figure [p.7] — schematic, caption (printed at top of p.8): "Setup for Experiment 5.2: double slit with orthogonal polarizers and entangled photons."
Identical to the 5.1 schematic with two additions immediately to the right of the double slit:
- **PA**: a grey disc with **horizontal hatching**, text "0°" inside, label pill "PA" above it, sitting on the ray from the upper slit (slit A).
- **PB**: a grey disc with **vertical hatching**, text "90°" inside, label pill "PB" below it, on the ray from the lower slit (slit B).
- The rays from PA and PB converge on D1; the upper mirror → D2 path is unchanged (no polarizer on the idler).
- Reference lines: **Ψ₀** (after laser), **Ψ₁** (after BB), **Ψ₂** (at the slit), **Ψ₃** (just after PA/PB), **Ψ₄** (at the detectors).
- Polarizer angle convention (from the text): 0° = vertical transmission axis, 90° = horizontal.

### [p.8] Results for 5.2 (two plots)

Figure [p.8, left] — plot, title "Number of counts on D1 per seconds [PA + PB]".
- x: "Distance on the screen (µm)", −2200…+2200. y: "Intensity per seconds", ticks 220…320.
- Data: a single smooth bell-shaped curve, no fringes. Peak ≈ 322 counts/s at y ≈ −100 µm; falls to ≈ 222 at −2200 µm and ≈ 207 at +2200 µm (slightly asymmetric; small shoulder near −1500 µm). Fit (blue) follows the data; theoretical dashed curve is a slightly narrower bell with the same peak, baseline ≈ 208.

Figure [p.8, right] — plot, title "Number of coincidences (D1-D2) per seconds [PA + PB]".
- y ticks 0.2…1.0. Data: noisy bell, peak ≈ 1.0 coincidences/s at y ≈ 0 (scatter up to 1.05), edges ≈ 0.15–0.25 at ±2000 µm. Theoretical dashed curve peaks ≈ 1.03.

Prose:

> Interference has disappeared. As in Experiment~3, orthogonal polarizers on each slit make the paths distinguishable, destroying interference. We observe only diffraction (the sum of two single-slit patterns).
>
> The count rate also drops significantly because each polarizer blocks half the photons.

**Raw data** — "You can download the data here:" download link **data5_2.csv** (p.9).

### [p.9] Raw data (cont.) + Exp 5.3 heading

> Column format is identical to Exp 5.1.
> All counts are recorded over 20-second windows.

Heading: **Exp 5.3 : Adding a third polarizer**

> We now add a third polarizer at 45° after the double slit, just as we did in Experiment 3.

### [p.10] 5.3 schematic + Results

Figure [p.10] — schematic, caption: "Setup for Experiment 5.3: double slit with orthogonal polarizers, a third polarizer, and entangled photons." (Same drawing as p.21; the print on p.10 is partly covered by the "Results" heading and the plots.)
Same as the 5.2 schematic plus:
- **P1**: a grey disc with **diagonal hatching**, text "45°" inside, label pill "P1" below, placed on the signal path between PA/PB and D1 where the two slit rays have nearly merged. P1 sits only on the D1 (signal) path; the idler path (mirror → D2) still has no polarizer.
- Reference lines: **Ψ₀**, **Ψ₁**, **Ψ₂** (slit), **Ψ₃** (after PA/PB), **Ψ₄** (at P1), **Ψ₅** (after P1), **Ψ₆** (detectors).

Figure [p.10, left] — plot, title "Number of counts on D1 per seconds [PA + PB + P1]".
- y ticks 175…200. Data: a broad bell, no fringes, peak ≈ 199 counts/s at y ≈ +450 µm; ≈ 180 at −2000 µm, ≈ 175–178 at +2000 µm. The pattern is shifted to positive y compared with 5.1/5.2. Noisier than before (scatter ≈ ±1.5). Theoretical dashed curve: bell peaking ≈ 199 at ≈ +400 µm, baseline ≈ 175.

Figure [p.10, right] — plot, title "Number of coincidences (D1-D2) per seconds [PA + PB + P1]".
- y ticks 0.15…0.35. Data: noisy bell, peak ≈ 0.34–0.37 coincidences/s at y ≈ +500 µm, edges ≈ 0.15 at ±2000 µm. Theoretical dashed curve peaks ≈ 0.35.

Prose:

> This result is surprising. In Experiment 3 (with non-entangled photons), the 45° polarizer restored interference by erasing which-path information. Here, with entangled photons, interference does *not* return.
>
> By "losing interference", we mean that each slit acts as an independent single slit. The observed pattern is the sum of two diffraction envelopes, with no oscillating fringes.

### [p.11] Raw data for 5.3

"You can download the data here:" download link **data5_3.csv**.

> Column format is identical to previous experiments. The first two columns (polarizer angles) can be ignored for P₂. All counts are recorded over 20-second windows.

[unclear: "P₂" — there is no P2 in this experiment; probably meant "can be ignored" or refers to the (absent) polarizer on the D2 path.]

### [p.11–16] Mathematics and equations — Experiment 5.1: No Polarizers

Figure [p.12]: the 5.1 schematic repeated (identical to p.4), caption "Setup for Experiment 5.1: double slit with entangled photons and no polarizers."

> In this experiment, entangled photon pairs pass through a double slit with no polarizers. We track both polarization and position.

**Step 1. Initial entangled state.**

> The BBO crystal produces polarization-entangled pairs in the Bell state |Φ⁺⟩. Using subscript 1 for the signal photon and 2 for the idler:

E1:
$$\ket{\Phi^+} = \frac{1}{\sqrt{2}}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big).$$

> The signal photon travels toward the double slit. The idler travels directly to detector D₂.

**Step 2. Signal photon at the double slit.**

> The signal photon can pass through slit A or slit B, entering a spatial superposition. The full state (polarization ⊗ signal position ⊗ idler position) is:

E2:
$$\ket{\psi_1} = \frac{1}{\sqrt{2}}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big) \otimes \frac{1}{\sqrt{2}}\Big(\ket{A}_1 + \ket{B}_1\Big) \otimes \ket{S}_2 .$$

> Here |A⟩₁ and |B⟩₁ denote the signal photon's position at slit A or B, and |S⟩₂ is the idler's position (traveling toward D₂). The symbol ⊗ just means "and", we're combining polarization and position into one complete description.

**Step 3. Propagation to detectors.**

> The signal photon propagates from each slit to position y on the detection screen. The path lengths differ: distance a from slit A, distance b from slit B. Each path acquires a phase factor:

E3:
$$\ket{A}_1 \rightarrow e^{ika}\ket{y}_1, \qquad \ket{B}_1 \rightarrow e^{ikb}\ket{y}_1 .$$

> The idler propagates distance m to detector D₂:

E4:
$$\ket{S}_2 \rightarrow e^{ikm}\ket{D}_2 .$$

> After the propagation on the screen, the full state is decomposed as a sum of various terms at different locations. Making explicit one such location, the state becomes:

E5:
$$\ket{\psi_2} = \cdots + \frac{1}{2}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big) \otimes \Big(e^{ika} + e^{ikb}\Big)\ket{y}_1 \otimes e^{ikm}\ket{D}_2 + \cdots .$$

**Step 4. Detection probability at D₁.**

> To find the probability of detecting the signal photon at position y, we compute the squared amplitude. The key observation: both polarization terms (|↕↕⟩ and |↔↔⟩) have *identical* spatial amplitudes. The polarization does not encode any which-path information.
>
> The path lengths a and b depend on the detection position y. Using the path-difference geometry from experiment 2:

E6:
$$a - b \approx \frac{d\cdot y}{L}.$$

> The spatial amplitude is:

E7:
$$\mathcal{A}(y) = \frac{1}{\sqrt{2}}\Big(e^{ika(y)} + e^{ikb(y)}\Big).$$

> The intensity (proportional to the squared amplitude) is:

E8:
$$I(y) \propto |\mathcal{A}(y)|^2 = \frac{1}{2}\big|e^{ika} + e^{ikb}\big|^2 = \frac{1}{2}\Big(2 + 2\cos\big(k(a-b)\big)\Big) = 1 + \cos\Big(\frac{2\pi d y}{\lambda L}\Big).$$

> This is the standard double-slit interference pattern:

E9 (boxed on the site):
$$\boxed{\,I(y) \propto 1 + \cos\Big(\frac{2\pi d y}{\lambda L}\Big)\,}$$

> The intensity oscillates between 0 (destructive interference) and a maximum of 2 (constructive interference), with fringe spacing Δy = λL/d. We omit the single-slit diffraction envelope here for clarity.

**Interpretation.**

> Without polarizers at the slits, the paths remain indistinguishable. Both polarization components (|↕↕⟩ and |↔↔⟩) traverse both slits with identical amplitudes. The entanglement does not destroy interference because no which-path information is encoded anywhere.
>
> This matches our experimental observation: clear interference fringes in both singles and coincidences.

### [p.16–21] Experiment 5.2: Adding Polarizers

Figure [p.16]: the 5.2 schematic repeated (identical to p.7), caption "Setup for Experiment 5.2: double slit with orthogonal polarizers and entangled photons."

> We place a vertical polarizer (0°) in front of slit A and a horizontal polarizer (90°) in front of slit B. This encodes which-path information in the polarization.

**Step 1. Initial entangled state.** "As before, the BBO produces the Bell state:" (E1 repeated)

$$\ket{\Phi^+} = \frac{1}{\sqrt{2}}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big).$$

> Before the polarizers, the signal photon is in a spatial superposition of both slits: (E2 repeated)

$$\ket{\psi_1} = \frac{1}{\sqrt{2}}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big) \otimes \frac{1}{\sqrt{2}}\Big(\ket{A}_1 + \ket{B}_1\Big) \otimes \ket{S}_2 .$$

**Step 2. Polarizer filtering.**

> The polarizers act as filters, not state assigners. Each polarizer transmits only the matching polarization component:
> - Vertical polarizer at A: transmits |↕⟩₁, blocks |↔⟩₁
> - Horizontal polarizer at B: transmits |↔⟩₁, blocks |↕⟩₁
>
> Expanding the state before filtering:

E10:
$$\ket{\psi_1} = \frac{1}{2}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2\ket{A}_1 + \ket{\updownarrow}_1\ket{\updownarrow}_2\ket{B}_1 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\ket{A}_1 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\ket{B}_1\Big) \otimes \ket{S}_2 .$$

> After filtering, the blocked components are absorbed:

E11:
$$\ket{\psi_2} = \frac{1}{2}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2\ket{A}_1 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\ket{B}_1\Big)\otimes\ket{S}_2 + \frac{1}{2}\Big(\ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\ket{A}_1 + \ket{\updownarrow}_1\ket{\updownarrow}_2\ket{B}_1\Big)\otimes\ket{\mathrm{lost}} .$$

> The |lost⟩ term represents photons blocked by the polarizers—half the total. Since these do not reach the detector, we drop them from subsequent analysis:

E12:
$$\ket{\psi_2} \rightarrow \frac{1}{2}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2\ket{A}_1 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\ket{B}_1\Big)\otimes\ket{S}_2 .$$

**Step 3. The key insight: which-path information.**

> Look carefully at the surviving state. The polarization is now perfectly correlated with the slit:
> - |↕⟩₁|↕⟩₂|A⟩₁: signal is vertical, idler is vertical, path is slit A
> - |↔⟩₁|↔⟩₂|B⟩₁: signal is horizontal, idler is horizontal, path is slit B
>
> The idler photon's polarization now reveals which slit the signal photon passed through:

E13:
$$\text{Idler } \ket{\updownarrow}_2 \Rightarrow \text{signal went through } A, \qquad \text{Idler } \ket{\leftrightarrow}_2 \Rightarrow \text{signal went through } B.$$

> This is which-path information, encoded in the entangled partner.

**Step 4. Propagation to detector.**

> The signal photon propagates to position y on the screen, with path lengths a (from slit A) and b (from slit B):

E14:
$$\ket{\psi_3} = \cdots + \frac{1}{2}\Big(e^{ika}\ket{\updownarrow}_1\ket{\updownarrow}_2 + e^{ikb}\ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big)\otimes\ket{y}_1\otimes\ket{D}_2 + \cdots$$

**Step 5. Detection intensity.**

> To find the intensity at position y, we compute the squared amplitude. The key observation: the two terms correspond to orthogonal polarization states of the idler (|↕⟩₂ vs. |↔⟩₂).
>
> Orthogonal states cannot combine—they remain distinct contributions that add independently. This means the phases e^{ika} and e^{ikb} never add or cancel. Each term contributes its own intensity:

E15:
$$I(y) \propto \Big|\frac{1}{2}e^{ika}\Big|^2 + \Big|\frac{1}{2}e^{ikb}\Big|^2 = \frac{1}{4} + \frac{1}{4} = \frac{1}{2}.$$

> The intensity is independent of position y:

E16 (boxed):
$$\boxed{\,I(y) = \text{constant (no interference)}\,}$$

> There are no oscillating fringes. The observed pattern is the sum of two single-slit diffraction envelopes.

**Interpretation.**

> The polarizers have tagged each path with a distinct polarization, and because the photons are entangled, this tagging is mirrored in the idler:

E17:
$$\text{Path } A:\; \ket{\updownarrow}_1\ket{\updownarrow}_2 \qquad\qquad \text{Path } B:\; \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2$$

> The idler states |↕⟩₂ and |↔⟩₂ are orthogonal, so these two terms in the wavefunction cannot recombine. The phases e^{ika} and e^{ikb} contribute independently, they never add constructively or cancel destructively. This is the physical origin of the lost interference.
>
> Compare to experiment 3 (non-entangled photons): there, the which-path information was stored only in the signal photon's polarization, and a 45° polarizer could erase it. Here, the distinguishing property is in the *idler*, beyond our reach on the signal path.

### [p.21–25] Experiment 5.3: Adding a Third Polarizer

Figure [p.21]: the 5.3 schematic (full, unobstructed version of the p.10 drawing), caption "Setup for Experiment 5.3: double slit with orthogonal polarizers, a third polarizer, and entangled photons." Elements: LASER → hatched disc → BB → (mirror → D2) and (double slit → PA 0° on slit A / PB 90° on slit B → P1 45° → D1); D1 & D2 → "coin". Ψ₀…Ψ₆ as listed above.

> We now add a 45° polarizer after the double slit, just as we did in Experiment~3. With non-entangled photons, this restored interference. Will it work here?

**Step 1. State after the slit polarizers.**

> From Exp 5.2, after the orthogonal polarizers at the slits and propagation to position y:

E18:
$$\ket{\psi_1} = \cdots + \frac{1}{2}\Big(e^{ika}\ket{\updownarrow}_1\ket{\updownarrow}_2 + e^{ikb}\ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big)\otimes\ket{y}_1\otimes\ket{D}_2 + \cdots$$

> The signal polarization is correlated with the path, and this correlation is mirrored in the idler.

**Step 2. Applying the 45° polarizer.**

> The 45° (diagonal) polarizer projects both |↕⟩ and |↔⟩ onto |↗↙⟩, each with amplitude 1/√2:

E19:
$$\ket{\updownarrow} \rightarrow \frac{1}{\sqrt{2}}\ket{\nearrow\!\!\swarrow}, \qquad \ket{\leftrightarrow} \rightarrow \frac{1}{\sqrt{2}}\ket{\nearrow\!\!\swarrow}.$$

> After the polarizer, the signal photon's polarization is |↗↙⟩₁ for both paths. The state becomes:

E20:
$$\ket{\psi_2} = \cdots + \frac{1}{2\sqrt{2}}\Big(e^{ika}\ket{\nearrow\!\!\swarrow}_1\ket{\updownarrow}_2 + e^{ikb}\ket{\nearrow\!\!\swarrow}_1\ket{\leftrightarrow}_2\Big)\otimes\ket{y}_1\otimes\ket{D}_2 + \cdots$$

**Step 3. Why interference still fails.**

> At first glance, the signal photon now has the same polarization |↗↙⟩₁ regardless of which slit it passed through. In Experiment 3, this was enough to restore interference.
>
> But look at the full state. The two amplitudes are:

E21:
$$\text{Path } A:\; e^{ika}\ket{\nearrow\!\!\swarrow}_1\ket{\updownarrow}_2 \qquad\qquad \text{Path } B:\; e^{ikb}\ket{\nearrow\!\!\swarrow}_1\ket{\leftrightarrow}_2$$

> The signal polarizations are now identical. But the **idler polarizations are still orthogonal**: |↕⟩₂ and |↔⟩₂ are perpendicular states that cannot combine.

**Step 4. Computing the detection intensity.**

> For interference to occur, the two path amplitudes must be indistinguishable in *every* degree of freedom. Here, they differ in the idler's polarization.
>
> Because the idler states are orthogonal, the two terms contribute independently to the intensity. The phases e^{ika} and e^{ikb} never add or cancel—each term contributes its own intensity separately:

E22:
$$I(y) \propto \Big|\frac{1}{2\sqrt{2}}e^{ika}\Big|^2 + \Big|\frac{1}{2\sqrt{2}}e^{ikb}\Big|^2 = \frac{1}{8} + \frac{1}{8} = \frac{1}{4}.$$

> The cross-terms that would produce interference (containing e^{i(ka−kb)} and e^{−i(ka−kb)}) vanish because they multiply orthogonal idler states.

E23 (boxed):
$$\boxed{\,I(y) = \text{constant (no interference)}\,}$$

**Interpretation.**

> The 45° polarizer erased the which-path information from the *signal* photon. But the information still exists in the *idler* photon:
> - Idler is |↕⟩₂ ⇒ signal came through slit A
> - Idler is |↔⟩₂ ⇒ signal came through slit B
>
> No operation on the signal path alone can erase information stored in the idler. The which-path information has been "exported" to the entangled partner, where it remains intact.
>
> This is the fundamental difference from Experiment 3: with non-entangled photons, all which-path information was local to the signal photon, so a local polarizer could erase it. With entangled photons, the information is also encoded in a remote system.

**What would restore interference?**

> To recover interference, we would need to erase the which-path information from the idler as well. This can be done by measuring the idler in the diagonal basis and post-selecting on the result. This is the quantum eraser protocol, explored in the next experiment.

### [p.25] Similar Experiments (cards) + footer
Three link cards (the print overlaps them with the last paragraphs):
- "OVERVIEW" card → INTRODUCTION — "Quantum for everyone"
- Card with four stacked laser → polarizer(s) → D1 rows (90°, 0°, 45 configurations) → EXPERIMENT 1 — "Polarizers"
- Card with single-slit and double-slit rows → EXPERIMENT 2 — "Single and double slit"
Footer: "Testing Reality © 2018-2026", "Creative commons" with CC / BY / NC icons.

### Links/downloads on this page
- data5_1.csv (Exp 5.1), data5_2.csv (Exp 5.2), data5_3.csv (Exp 5.3). All share the same column format: polarizer angle 1, polarizer angle 2, actuator position, sweep number, counts at D1, counts at D2, D1–D2 coincidences; 20-second acquisition windows; plots are shown per second.
- Hyperlinks to Experiment 3 and Experiment 4 pages.
- StackBlitz project react-vazdln-kpdd3a (vmonette).

## Physics model for simulation

### Hilbert space
- Signal photon (1): polarization qubit {|↕⟩₁ (vertical, polarizer angle 0°), |↔⟩₁ (horizontal, 90°)} ⊗ path qubit {|A⟩₁, |B⟩₁} → after propagation a continuum |y⟩₁ (screen coordinate).
- Idler photon (2): polarization qubit {|↕⟩₂, |↔⟩₂} ⊗ trivial path |S⟩₂ → e^{ikm}|D⟩₂ (one detector, no slit).
- Diagonal basis: |↗↙⟩ = (|↕⟩ + |↔⟩)/√2 (site's symbol for the 45° state); its orthogonal partner |↘↖⟩ = (|↕⟩ − |↔⟩)/√2 is not used on this page but is needed for Experiment 6.
- Angle convention: 0° = vertical, 90° = horizontal, 45° = diagonal (|↗↙⟩). A polarizer at angle θ transmits |θ⟩ = cos θ |↕⟩ + sin θ |↔⟩.
- Loss sink |lost⟩ (orthogonal to everything) for photons absorbed by a polarizer; coincidence/singles rates are computed from the surviving (unnormalised) branch.

### Initial state (from the BBO, Experiment 4)
|Φ⁺⟩ = (|↕⟩₁|↕⟩₂ + |↔⟩₁|↔⟩₂)/√2, then ⊗ (|A⟩₁+|B⟩₁)/√2 ⊗ |S⟩₂ (E2). Experiment 4 notes the real source is not perfectly balanced between ↕↕ and ↔↔ (Berek compensation did not work as expected); the page here assumes the ideal state.

### Operators (apply in order along the signal path)
1. Double slit: |pol⟩₁ ⊗ (|A⟩₁+|B⟩₁)/√2 (equal amplitudes).
2. Slit polarizers (5.2, 5.3): projector P_A = |↕⟩⟨↕|₁ ⊗ |A⟩⟨A|₁ on slit A, P_B = |↔⟩⟨↔|₁ ⊗ |B⟩⟨B|₁ on slit B; blocked components go to |lost⟩ (E11). Survival probability 1/2.
3. Propagation: |A⟩₁ → e^{ika(y)}|y⟩₁, |B⟩₁ → e^{ikb(y)}|y⟩₁, with k = 2π/λ and a − b ≈ d·y/L (E6). Idler: |S⟩₂ → e^{ikm}|D⟩₂ (global phase, irrelevant).
4. Third polarizer P1 at 45° (5.3): projector |↗↙⟩⟨↗↙|₁ on the signal polarization; each of |↕⟩, |↔⟩ → (1/√2)|↗↙⟩ (E19). Survival probability 1/2 again.
5. Detection: D1 at y registers the signal regardless of polarization (no polarizer at D1); D2 registers the idler regardless of polarization. Therefore the rate at y is the squared norm summed (traced) over the idler polarization basis: I(y) = Σ_{j∈{↕,↔}} |⟨y, j|ψ⟩|².

### Predicted patterns (fringe term only; multiply by the envelope below)
| Config | Surviving amplitude at y | I(y) (site's normalisation) | Fringes? | Relative level |
|---|---|---|---|---|
| 5.1 no polarizers | ½(|↕↕⟩+|↔↔⟩)(e^{ika}+e^{ikb}) | 1 + cos(2πdy/λL), range 0…2 | YES | 1 (ref.) |
| 5.2 P_A=0°, P_B=90° | ½(e^{ika}|↕↕⟩ + e^{ikb}|↔↔⟩) | ¼ + ¼ = ½ (flat) | NO | ½ |
| 5.3 + P1=45° on signal | (1/2√2)|↗↙⟩₁(e^{ika}|↕⟩₂ + e^{ikb}|↔⟩₂) | ⅛ + ⅛ = ¼ (flat) | NO | ¼ |

Singles at D1 and D1–D2 coincidences have the same y-dependence in every configuration (the idler is detected without any polarization selection), so the game only needs one shape per configuration plus different count scales.

Cross-term rule (the one idea to implement generically): interference between the two path amplitudes exists only if the *full* two-photon states multiplying e^{ika} and e^{ikb} overlap. Visibility V = |⟨χ_A|χ_B⟩| where |χ_A⟩, |χ_B⟩ are the (polarization ⊗ idler) states attached to the two paths. 5.1: χ_A = χ_B → V = 1. 5.2: ⟨↕↕|↔↔⟩ = 0 → V = 0. 5.3: ⟨↗↙,↕|↗↙,↔⟩ = 1·0 = 0 → V = 0. Experiment 3 (no entanglement) is the same calculation with the idler factor absent: ⟨↗↙|↗↙⟩ = 1 → V = 1 after the 45° polarizer.

### Beyond the page (needed for the game's "what would fix it" moment, consistent with the final paragraph)
If an additional polarizer P2 at angle θ (from vertical) is put in front of D2 (as in Experiment 6):
- 5.2 + P2(θ): coincidence amplitude ½(e^{ika} cos θ |↕⟩₁ + e^{ikb} sin θ |↔⟩₁) → I_c = ¼(cos²θ + sin²θ) = ¼, still no fringes for any θ (signal polarizations still orthogonal).
- 5.3 + P2(θ): amplitude (1/2√2)|↗↙⟩₁(e^{ika} cos θ + e^{ikb} sin θ) → I_c(y) = ⅛[1 + sin 2θ · cos(2πdy/λL)]. θ = 45°: full fringes; θ = −45° (135°): anti-fringes; θ = 0° or 90°: flat ⅛. Singles at D1 stay flat (¼) whatever θ; only the coincidences recover fringes. This is the quantum-eraser result the page announces for Experiment 6.

### Envelope and lab numbers
- Each slit also contributes a single-slit diffraction envelope (the site "omits it for clarity" in the derivation but the data and the "theoretical curve" include it). Far-field form: I(y) = E(y)·[1 + V cos(2πdy/λL)] with E(y) = sinc²(π w y/(λL)), w = slit width. 5.2 and 5.3 are "the sum of two single-slit diffraction envelopes", i.e. I ∝ E(y) (same envelope for both slits in the Fraunhofer limit).
- Parameters stated elsewhere on the site (not on this page): pump laser 405 nm (Exp 4 equipment list, text says "404~nm"); double slit "200-200-200 µm, made in-house" (slit width 200 µm, gap 200 µm; Exp 2 quotes "slit separation about 200 µm" and a measured 175 µm); coincidence window 10 ns (this page); acquisition 20 s per actuator position; counts plotted per second.
- Not stated: the down-converted wavelength λ and the slit–detector distance L. Proposed: λ = 810 nm (degenerate SPDC of 405 nm; Exp 2 used an 808 nm laser to mimic exactly this); from the measured fringe spacing Δy ≈ 900 µm and d = 200 µm (centre-to-centre) → L = Δy·d/λ ≈ 0.22 m (if d = 400 µm centre-to-centre the same fringe spacing gives L ≈ 0.44 m; L4/L5 are f = 50 cm lenses, so the "screen" is likely an image plane — treat L as an effective distance tuned to Δy ≈ 900 µm).
- Measured fringe visibility in 5.1 (above background ≈ 180/s): singles (410−265)/(410+265−2·180) ≈ 0.45; the ideal curve has V = 1. Use V ≈ 0.5 for a "lab-realistic" look, V = 1 for the "theory" overlay.
- Count scales to match (per second, from the plots): 5.1 singles 180 → 410 (peak), coincidences 0.3 → 7.7; 5.2 singles 208 → 322, coincidences 0.15 → 1.0; 5.3 singles 175 → 199, coincidences 0.15 → 0.35. Pattern centres: 5.1 at y ≈ 0, 5.2 at ≈ −100 µm, 5.3 at ≈ +450 µm (alignment shift after inserting P1). Scan range ±2000 µm (singles data extend to ±2200 µm).
- Observed peak-coincidence ratios 5.2/5.1 ≈ 0.11 and 5.3/5.2 ≈ 0.3 are lower than the ideal ½ and ½ because (i) the ideal ½ refers to total flux, while the central *peak* of an interference pattern is 2× the envelope, giving ¼ at y = 0, and (ii) real film polarizers transmit < 100 % of the matching polarization. For the simulator, use transmission ≈ 0.8 per polarizer on top of the ideal projection.

## Apparatus list (for Blender)

Source side (stated on the Experiment 4 page; this page says "same setup as in Experiment 4"):
| Item | Site description | Approx. size | Mounting | Status |
|---|---|---|---|---|
| Pump laser | Diode laser (405 nm), violet; text also says "404~nm" | 40×40×100 mm module | post + kinematic/laser mount | stated (Exp 4) |
| Half-wave plate | sets polarization/intensity before PBS, and 45° before BBO | Ø25 mm in rotation mount | rotation mount on post | stated (Exp 4) |
| Polarizing beam splitter + beam dump | cube PBS transmitting vertical; horizontal → beam dump | 20–25 mm cube | kinematic platform | stated (Exp 4) |
| Lenses L1, L2, L3 | Thorlabs LA1509 (f = 10 cm), LA1986 (f = 2.5 cm), LA1461 (f = 25 cm) — collimation pair + focusing lens on BBO | Ø25 mm | lens mounts on posts | stated (Exp 4) |
| Two mirrors | U-turn of the beam for space | Ø25 mm | kinematic mirror mounts | stated (Exp 4) |
| Berek compensator | New Focus variable wave plate | ~50 mm housing | post | stated (Exp 4) |
| BBO | 2 thin BBO crystals placed at 90°, Eksma Optics; drawn as "BB" (two light-blue plates) | ~5×5×0.5 mm each in Ø25 mm holder | rotation mount on post | stated |
| Pump filter/beam block after BBO | not shown on this page | — | — | assumed |

Signal path (this page):
| Item | Site description | Approx. size | Mounting | Status |
|---|---|---|---|---|
| Double slit | "Dimension (200-200-200 µm), made in-house"; photo: clear square plate with 4 corner hex bolts over a metal foil with a stadium aperture containing two fine vertical slits | plate ~25–30 mm square | black cylindrical mount with blue dot (Thorlabs rotation/post mount) on breadboard | stated + photo |
| P_A (0°, vertical) | mounted linear polarizer (Thorlabs) covering slit A | Ø25 mm (half covering one slit) | rotation mount | stated |
| P_B (90°, horizontal) | mounted linear polarizer covering slit B | Ø25 mm | rotation mount | stated |
| P1 (45°) | third polarizer after the double slit on the signal path (5.3 only) | Ø25 mm | motorized rotation mount ("rotation mount bundle", Exp 4) | stated |
| Lens L4 | Thorlabs f = 50 cm, in path 1 before the detector | Ø25 mm | lens mount | stated (Exp 4) |
| D1 | single photon detection module (SPAD) via fiber collimator + bandpass filter; "mounted on a linear actuator to scan the full pattern" | collimator Ø12 mm; SPAD box 90×60×30 mm | motorized linear actuator/translation stage, travel ≥ 4.4 mm | stated |

Idler path:
| Item | Site description | Approx. size | Mounting | Status |
|---|---|---|---|---|
| Mirror | black tilted bar in the schematic redirecting the idler to D2 | Ø25 mm | kinematic mirror mount | stated (schematic) |
| Lens L5 | Thorlabs f = 50 cm, in path 2 | Ø25 mm | lens mount | stated (Exp 4) |
| D2 | single photon detection module, fixed; no polarizer in front of it in 5.1–5.3 | as D1 | fixed post | stated |

Electronics:
| Item | Site description | Status |
|---|---|---|
| Coincidence counter ("coin" in the schematic) | counts D1, D2 singles and D1–D2 coincidences within a 10 ns window; 20 s acquisitions | stated |
| Actuator controller / PC | drives D1's linear stage and logs "actuator position" and "sweep number" | implied |
| Optical breadboard | M6 hole grid visible in the photo; black clamps/bases | photo |

Schematic colour/style guide (for the 2-D overlay): laser and detectors salmon (#F8C8BC-ish) with pink label pills and red text; BBO light blue with blue pill; polarizers grey hatched discs (horizontal hatch = 0°, vertical hatch = 90°, diagonal hatch = 45°) with grey pills "PA", "PB", "P1"; double slit and mirror solid black; photon paths red dashed; wavefunction reference lines grey dashed with bold grey Ψ_n labels; panel background very light blue-grey; headings in indigo serif ("Exp 5.1 : …").

## Teaching notes

Prerequisites in the order they are needed:
1. Linear polarization states as vectors: |↕⟩, |↔⟩, and the diagonal |↗↙⟩ = (|↕⟩+|↔⟩)/√2; polarizer as a projector (Malus's law cos²θ) — from Experiment 1.
2. Double-slit interference: path difference a − b ≈ dy/L, phase e^{ika}, |e^{ika}+e^{ikb}|² = 2 + 2cos(k(a−b)), fringe spacing λL/d; single-slit envelope — from Experiment 2.
3. Which-path tagging by orthogonal polarizers and erasure by a 45° polarizer — from Experiment 3 (the page constantly contrasts with it).
4. Entangled Bell state |Φ⁺⟩ and the meaning of subscripts 1 (signal) and 2 (idler); coincidence counting — from Experiment 4.
5. Tensor product ⊗ as "and": the page explicitly says "The symbol ⊗ just means 'and'". States with three factors (polarization ⊗ signal position ⊗ idler position).
6. Complex amplitudes, modulus squared, and the key rule: amplitudes attached to orthogonal states add in intensity, not in amplitude (cross-terms vanish because ⟨↕|↔⟩ = 0). This is the whole punchline, stated three times (Step 5 of 5.2, Step 4 of 5.3, Interpretation).
7. Non-unitary filtering: the |lost⟩ sink and dropping the blocked half; normalisation factors ½, 1/2√2 and the resulting ½ and ¼ levels.
8. Partial trace in disguise: "detector D1 does not look at the idler" ⇒ sum intensities over idler basis states.

Site's pedagogical moves:
- "Puzzle" framing: the page is written as the setup of a mystery that Experiment 6 resolves; it repeatedly says "Surprisingly", "Will it work here?", "At first glance…".
- Step-by-step incrementalism ("adding one component at a time") with the same four/five numbered steps per sub-experiment (initial state → slit superposition → filtering → propagation → intensity → interpretation), and the same Ψ_n reference-plane labelling in the schematics as on the other pages.
- Explicit contrast table-in-prose with Experiment 3 at every stage.
- Boxed final results (E9, E16, E23) as the "take-away" per sub-experiment.
- "Polarizers act as filters, not state assigners" — a deliberate correction of a common misconception.
- The "exported information" metaphor: which-path information "exported" to the entangled partner, "beyond our reach on the signal path".
- Ends with the hook "What would restore interference?" → measure the idler in the diagonal basis and post-select (Experiment 6).

## Open questions
- The StackBlitz animation (react-vazdln-kpdd3a by vmonette) is not rendered in the PDF; its controls and visuals are unknown.
- "This file contains 6 columns" but 7 columns are listed (polarizer angle 1, polarizer angle 2, actuator position, sweep number, D1, D2, coincidences). Verify against data5_1.csv.
- p.11: "The first two columns (polarizer angles) can be ignored for P₂" — "P₂" is undefined on this page (there is no polarizer on D2). Probably a leftover from a page where P2 existed; meaning likely "can be ignored".
- Units of "Actuator position" in the CSV (µm?) and the mapping to "Distance on the screen (µm)" are not stated; whether the plots are averaged over several "sweeps" is not stated.
- Down-converted wavelength (presumably 810 nm) and slit-to-detector distance L (or imaging lens arrangement) are never given; fringe spacing ≈ 900 µm must be matched by tuning L.
- Slit geometry "200-200-200 µm" is ambiguous (centre-to-centre separation 200 µm vs 400 µm); Experiment 2 says "actual slit separation of about 200 µm".
- The measured drop in coincidences from 5.1 to 5.2 (≈ 8×) is much larger than the stated "each polarizer blocks half the photons"; the page does not comment on it.
- The 5.3 pattern is shifted ≈ +450 µm relative to 5.1/5.2; no explanation on the page (likely realignment after inserting P1).
- The unlabelled grey hatched disc after the laser in the schematics is never explained on this page.
- The caption "Setup for Experiment 5.2 …" is printed at the top of p.8, above "Results", and the 5.3 schematic on p.10 is partly hidden behind the "Results" heading and plots — print artefacts, not missing content.
- Text uses "Experiment~3" (LaTeX non-breaking-space artefact) twice; transcribed as written.
