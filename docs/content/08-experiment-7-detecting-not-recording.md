# Experiment 7: Detecting, but not recording
Source: `J-Experiment 7 _ Detecting but not recording.pdf`; URL printed in the footer: https://testing-reality.webflow.io/experiment-7 ; 15 pages (printed 30/10/2026, 20:52). Browser tab title: "Experiment 7 : Detecting but not recording".

## Page summary
This page is a "what if" appendix to the delayed-choice quantum-eraser experiment (Experiment 5, and by extension Experiment 6). The author takes the full eraser apparatus (BBO entangled-pair source, double slit with orthogonal polarizers PA = 0° and PB = 90°, eraser polarizer P1 = 45° before the signal detector D1, idler polarizer P2 = 90° before the idler detector D2, coincidence counter) and deliberately breaks the idler arm in two ways: (1) a physical wall placed on the idler ("upper", "path 2") beam after P2 and before D2, and (2) D2 left in place but electrically unplugged from the coincidence counter. In both cases the D1 singles show only the single-slit diffraction envelope (no fringes), and the coincidence channel is zero (near-zero with the wall, because of stray light/dark counts; exactly zero when unplugged). The theory section repeats the Experiment 5 state calculation to Step 6 and shows that, because the idler polarizations |↕⟩₂ and |↔⟩₂ are orthogonal, the two path terms add in intensity, giving I(y) = 1/4 + 1/4 = 1/2 = constant (no interference). The punchline: interference appears only in the coincidence subset and only when the idler is measured in an erasing (diagonal) basis; blocking or ignoring the idler does not destroy which-path information (it is still encoded in the absorbed photon / the environment), it only removes our ability to post-select. A six-question FAQ addresses "someone else looks at D2", "a fly or camera looks at the idler", the wall's position, delaying the idler by years, faster-than-light signalling, and retrocausality; the answers are consistently that observation/consciousness plays no role and that nothing at D1 is "changed" after the fact.

## Content (in page order)

### [p.1] Hero / title block
- Small-caps label "EXPERIMENT 7" (grey), then large serif title in two lines: "Detecting, but" / "not recording" (light grey). Site nav: "Testing Reality" logo left, "Experiments" and "About" right. Footer URL https://testing-reality.webflow.io/experiment-7, "1/15".
- No image on the title page.

### [p.2] TABLE OF CONTENT (left sidebar)
The sidebar lists:
- Abstract
- Lab Experiments
- Result and analysis
- Theory and equations

(Note: although "Lab Experiments" is listed in the TOC, there is no separate "Lab Experiments" section body on the printed page: after the Abstract the page goes straight to "Result and analysis". There are no lab photos on this page; the only setup figures are the two schematics on p.5 and p.6. There is also no "Literature and video" section.)

### [p.2-3] Abstract
Prose (faithful):

> This experiment pushes the delayed-choice quantum eraser further by testing common "what if" scenarios. While exploring forums and FAQs, we encountered many questions people ask about the experiment:
>
> - What if we block one of the paths?
> - What if a fly looks at the beam instead of me?
> - What if the detector is unplugged?
>
> The underlying question is: *what really counts as a detection?* If someone else observes D₂ but I don't, do we see the same results? If a fly or a wall "detects" the photon, what happens?
>
> The answer has two parts: first, to see interference, we must record coincidences between D₁ and D₂. Second, the idler measurement must be performed in a basis that allows the wavefunction terms to recombine (e.g., diagonal polarization). Blocking the idler or leaving D₂ unplugged satisfies neither condition. Furthermore, which-path information cannot be destroyed—it may change form (e.g., if a photon is absorbed by a wall), but the correlation with the signal path remains encoded in the environment.
>
> In this section, we test two scenarios:
>
> - **Wall on path 2:** A physical barrier blocks the idler photon before D₂.
> - **D₂ unplugged:** The idler photon reaches the detector, but no signal is recorded.
>
> We conclude with a FAQ addressing additional "what if" questions.

Operational meaning of "detecting but not recording" (as the site defines it):
- Scenario A ("Wall on path 2"): the idler photon is *absorbed by a passive object* (a black beam block) placed on the idler arm, i.e. it is "detected" by the wall in the sense that it interacts irreversibly with matter, but nothing records the outcome and D2 never fires.
- Scenario B ("D2 unplugged"): the idler photon *does* reach the single-photon detector D2 and D2 does whatever it physically does, but D2's output cable is disconnected from the coincidence electronics, so no electrical signal is recorded and the coincidence logic can never trigger. D1 is still recorded as singles.
- In both cases the signal arm (double slit, PA/PB, P1 at 45°, D1 on its translation actuator) is left exactly as in the eraser configuration of Experiment 5.

### [p.4] Result and analysis

#### Raw data
Prose: "Data files:" followed by two download buttons (red PDF/file icons):
- `data_wall.csv`
- `data_unplugged.csv`

> Each file contains 7 columns:
> - Polarizer angle P₁
> - Polarizer angle P₂
> - Actuator position (μm)
> - Sweep number
> - Counts at D₁ (signal path)
> - Counts at D₂ (idler path)
> - Coincidences between D₁ and D₂
>
> At each actuator position, we recorded multiple samples to compute an average and standard deviation. We performed several sweeps to further reduce noise.

Table (column layout of each CSV as stated):

| Col | Name | Unit / meaning |
|---|---|---|
| 1 | Polarizer angle P1 | degrees (eraser polarizer before D1; 45° in the plots) |
| 2 | Polarizer angle P2 | degrees (idler polarizer before D2; 90° in the plots) |
| 3 | Actuator position | μm (D1 transverse position on the "screen") |
| 4 | Sweep number | integer |
| 5 | Counts at D1 | counts (signal path) |
| 6 | Counts at D2 | counts (idler path) |
| 7 | Coincidences D1-D2 | counts |

(The site does not state the integration time per sample, the number of samples per position or the number of sweeps. Plot titles say "per seconds", so rates are per second.)

### [p.5] Graphics — "With a wall on the upper path"

Figure [p.5, top] — schematic of the apparatus with a wall on the idler path (flat vector style, light blue-grey rounded background, red dashed beam lines, labels in small rounded pills). Elements left to right:
1. **LASER** — salmon/red rounded rectangle with a short stub (the emitter) on its right side, label pill "LASER" below. A solid red line leaves it to the right.
2. **A hatched grey disc** (unlabelled) on the pump beam between the laser and the crystal — drawn in the same style as the polarizers (grey circle with diagonal hatching). It carries no angle and no label; in the sister experiments this element is the pump-beam element in front of the BBO (filter/half-wave plate/polarizer for the pump). Mark as [unclear: unlabelled pump-beam optic].
3. **BB** — two thin vertical light-blue rectangles side by side (the stacked BBO crystal pair), label pill "BB" (blue) below. From the right face of the crystal the beam fans out as red dashed lines: one line going up-right (idler, "path 2", "upper path") and two lines going right/slightly down (signal, "path 1") toward the two slits.
4. **Mirror** on the idler arm — a short, thick black bar tilted ~45° at the top of the diagram; the idler dashed line reflects off it and then runs horizontally to the right along the top of the figure.
5. **Double slit** — a tall thin black vertical bar broken into three segments (two gaps = slits A (upper) and B (lower)), positioned on the dashed vertical line Ψ2.
6. **PA** — hatched grey disc labelled "0°" immediately right of the upper slit, with pill "PA" above it (horizontal hatching).
7. **PB** — hatched grey disc labelled "90°" immediately right of the lower slit, with pill "PB" below it (vertical hatching).
8. **P1** — larger hatched grey disc labelled "45°" (diagonal hatching) on the signal arm, pill "P1" below, on the Ψ4 line. The two signal dashed lines from the slits converge through P1 toward D1.
9. **P2** — hatched disc in violet/purple labelled "90°" (vertical hatching) on the idler arm, pill "P2" (violet) below, also on the Ψ4 line.
10. **WALL** — a thick black vertical bar immediately to the right of P2 on the idler arm, just before the Ψ5-6 line. The idler dashed line stops at the wall; no dashed line continues to D2. (This bar is the only difference from the p.6 schematic.)
11. **D2** — salmon/red rounded rectangle at the top right (on Ψ7), pill "D2" below. Nothing reaches it.
12. **D1** — salmon/red rounded rectangle at the right on the signal arm (on Ψ7), pill "D1" below; both signal dashed lines terminate on its face.
13. **coin** — a small rounded pill labelled "coin" (rotated 90°) to the right of the detectors, joined by thin black wires to both D1 and D2 (the coincidence counter). Both wires are drawn, i.e. D2 is still cabled in the wall scenario.
- State labels along the bottom under dashed vertical reference lines: Ψ0 (just after laser), Ψ1 (just after BB), Ψ2 (at the slits), Ψ3 (just after PA/PB), Ψ4 (at P1/P2), Ψ5-6 (just after P1/P2, where the wall sits), Ψ7 (at the detectors). These correspond to Experiment 5's state numbering.

Figure [p.5, middle-left] — plot "Number of counts on D1 per seconds [P2 = 90deg]".
- x axis: "Distance on the screen (μm)", range −2000 to +2000 (ticks −2000, −1000, 0, 1000, 2000).
- y axis: "Intensity per seconds", ticks 170, 175, 180, 185, 190, 195, 200.
- Legend: "Theorical curve" (grey dashed), "Fit of the datas" (blue solid), "Our datas" (black dots).
- Data: a single broad bell-shaped hump (single-slit diffraction envelope), from ≈178 counts/s at −2000 μm, rising to a peak of ≈200-201 counts/s at ≈ +100 to +200 μm, falling to ≈168 counts/s at +2000 μm. The data are slightly asymmetric (higher plateau on the left than on the right). No fringes at all. The blue fit follows the dots closely; the grey theoretical curve is a narrower/more symmetric envelope that peaks ≈202 near +150 μm and dips to ≈167 at both edges, i.e. the measured envelope is wider than theory, especially on the left.
- Roughly 80 data points spanning the range (≈50 μm step).

Figure [p.5, middle-right] — plot "Number of coincidences (D1-D2) per seconds [P2 = 90deg]".
- x axis: "Distance on the screen (μm)", −2000 to 2000 (ticks every 500).
- y axis: "Intensity per seconds", 0.0000 to 0.0035 (ticks every 0.0005).
- Legend as above. Theoretical curve and fit both lie flat on 0.
- Data: the overwhelming majority of points are exactly 0.0000; a scattering of ≈25 points sit at exactly ≈0.00167 /s and ≈6 points at exactly ≈0.00335 /s. The quantisation into levels of 1/600 and 2/600 counts per second strongly suggests one or two accidental coincidence counts over an integration window of ≈600 s per point (or equivalently 1 count per 10-minute bin) — this is the "small residual count" the author attributes to stray light and dark counts. [inferred from the plot; the site does not state the integration time]

Caption (italic, faithful):
> Results with a wall blocking the idler path. Left: singles at D₁. Right: coincidences (nearly zero). Note: The wall's position does not affect the results—it could be placed immediately after the BBO or 22 km away, as long as it intercepts the idler before D₂.

Sub-heading at the bottom of p.5: "With D2 unplugged" (its figures are on p.6).

### [p.6] Graphics — "With D2 unplugged" (continued)

Figure [p.6, top] — schematic identical to the p.5 schematic except:
- There is **no wall** on the idler arm; the idler dashed line continues from P2 (90°, violet) all the way to D2.
- The **coincidence wiring** differs: only D1 is wired to the "coin" pill. D2 has **no wire** to the coincidence counter (the cable is drawn as absent — "unplugged"). The "coin" pill sits above-right of D1, with a single black wire from D1.
- All other elements (LASER, unlabelled pump optic, BB, 45° mirror, double slit at Ψ2, PA 0°, PB 90°, P1 45°, P2 90°, D1, D2, Ψ0…Ψ7 labels) are the same.

Figure [p.6, middle-left] — plot "Number of counts on D1 per seconds [P2 = 90deg]" (unplugged run).
- Same axes; y ticks 175…210.
- Data: single-slit envelope from ≈183 counts/s at −2000 μm, peak ≈209 counts/s at ≈0 μm (slightly left of centre), down to ≈176 counts/s at +2000 μm. Again no fringes; data slightly wider than the grey theoretical envelope (which peaks ≈211 at 0 and reaches ≈176 at the edges). Blue fit tracks the dots.

Figure [p.6, middle-right] — plot "Number of coincidences (D1-D2) per seconds [P2 = 90deg]" (unplugged run).
- y axis from −0.04 to +0.04 (auto-scaled around zero).
- Every data point is exactly 0.00 across the whole −2000…+2000 μm range; the fit and theory lines coincide with the data at zero. A perfectly flat row of dots.

Prose (faithful):
> **Singles at D₁:** In both scenarios, the D₁ singles show only diffraction—no interference fringes. This matches all previous experiments: the signal path alone never reveals interference because which-path information is encoded in the idler.
>
> Coincidences:
>
> - **Wall:** Near-zero coincidences. The small residual count is experimental noise (stray light, dark counts).
> - **Unplugged:** Exactly zero coincidences. No electrical signal means no coincidence logic trigger.

### [p.7] (continued)
> The key result: without coincidence counting, interference cannot be recovered.

### [p.7-11] Theory and equations

#### Why No Interference?
> The mathematics follows directly from Experiment 5. ("Experiment 5" is a red hyperlink.)

**Step 1. Initial entangled state.**
> The BBO produces the Bell state:

E1:
$$
\ket{\Phi^{+}} = \frac{1}{\sqrt{2}}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big).
$$
(Site notation: |↕⟩ vertical, |↔⟩ horizontal; subscript 1 = signal photon, 2 = idler photon.)

**Step 2. Signal photon at the double slit.**
> The signal photon enters a spatial superposition:

E2 (the left edge of the equation is clipped in the print; it reads |ψ₁⟩ =):
$$
\ket{\psi_1} = \frac{1}{\sqrt{2}}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big)\otimes\frac{1}{\sqrt{2}}\Big(\ket{A}_1 + \ket{B}_1\Big)\otimes\ket{S}_2 .
$$
(|A⟩₁, |B⟩₁ = signal photon path through slit A / slit B; |S⟩₂ = the idler's spatial mode, "the second path".)

**Step 3. Polarizer filtering at the slits.**
> Vertical polarizer at slit A transmits |↕⟩₁; horizontal polarizer at slit B transmits |↔⟩₁. After filtering:

E3:
$$
\ket{\psi_2} = \frac{1}{2}\Big(\ket{\updownarrow}_1\ket{\updownarrow}_2\ket{A}_1 + \ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\ket{B}_1\Big)\otimes\ket{S}_2 + \ket{\mathrm{lost}} .
$$
> The |lost⟩ term represents blocked photons; we drop it in subsequent steps.

(Note: in the schematic PA is drawn as "0°" and PB as "90°". The text says the polarizer at slit A is *vertical* and at slit B is *horizontal*; so the site's "0°" on PA corresponds to its |↕⟩ convention here. The site is not consistent about whether 0° means vertical or horizontal across pages — flag for the simulation: what matters is only that PA ⟂ PB and that PA passes the component correlated with |↕⟩₂. See Open questions.)

**Step 4. Propagation to D₁.**
> Photons from slits A and B travel distances a and b:

E4 (left edge clipped in the print; reads |ψ₃⟩ = ⋯ + … + ⋯):
$$
\ket{\psi_3} = \cdots + \frac{1}{2}\Big(e^{ika}\ket{\updownarrow}_1\ket{\updownarrow}_2 + e^{ikb}\ket{\leftrightarrow}_1\ket{\leftrightarrow}_2\Big)\otimes\ket{y}_1\otimes\ket{D}_2 + \cdots
$$
(|y⟩₁ = signal photon at transverse position y on the D1 "screen"; |D⟩₂ = idler photon at/heading for D2; k = 2π/λ; a, b = path lengths from slit A, slit B to the point y. The "⋯" indicate the other y positions / the dropped terms.)

**Step 5. Idler photon is lost.**
> In both scenarios (wall or unplugged detector), the idler photon provides no usable information. However, the which-path information still exists:
> - |↕⟩₂ ⇒ signal came through slit A
> - |↔⟩₂ ⇒ signal came through slit B
>
> The idler's polarization state is correlated with the signal's path, whether or not we measure it.

**Step 6. Detection intensity at D₁.**
> To find the intensity at D₁, we must account for both idler states. The idler polarizations |↕⟩₂ and |↔⟩₂ are orthogonal—they cannot combine. Each term contributes its own intensity independently:

E5:
$$
I(y) \propto \Big|\tfrac{1}{2}e^{ika}\Big|^2 + \Big|\tfrac{1}{2}e^{ikb}\Big|^2 = \frac{1}{4} + \frac{1}{4} = \frac{1}{2}.
$$

> The intensity is independent of position y:

E6 (boxed on the site):
$$
\boxed{\,I(y) = \text{constant (no interference)}\,}
$$

> The pattern at D₁ is the sum of two single-slit diffraction envelopes—no fringes.

**Interpretation.**
> The which-path information is encoded in the idler photon's polarization. Blocking or ignoring the idler does not erase this information—it merely prevents us from accessing it. Since the information exists (in the absorbed photon, in the environment, etc.), interference cannot appear. To recover interference, we would need to:
> - Detect the idler photon
> - Measure it in a basis that erases which-path information (e.g., diagonal)
> - Post-select coincidences based on that measurement
>
> None of these are possible when the idler is blocked or the detector is unplugged.

### [p.11-13] Frequently Asked Questions

**Q1: What if someone else looks at D₂ but I don't?**
> A: The results at D₁ are unchanged—you see only diffraction. To observe interference, *you* must record coincidences. If another person has the D₂ data and you have the D₁ data, you could later combine them to find interference in the coincidence subset. But looking at D₁ alone will never show fringes.

**Q2: What if a fly or a camera observes the idler?**
> A: Any interaction that could, in principle, reveal which-path information counts as a "measurement." A fly's eye, a camera sensor, or even air molecules scattering the photon—all constitute measurements. The key is whether the which-path information becomes encoded in the environment. If it does, interference is lost at D1 (unless you can somehow access and erase that information).

**Q3: Does the wall's position matter?**
> A: No. The wall can be 1 cm or 1 km from the BBO. As long as it blocks the idler before reaching D₂, the result is the same: no coincidences, no interference. This reinforces that the effect is not about timing—it's about whether coincidence data can be collected.

**Q4: What if I delay the idler path by years?**
> A: Even with an extremely long delay (using fiber optic storage, for example), the physics is unchanged. When you eventually detect the idler and compute coincidences, you will find interference if you measured in the erasing basis (±45°), or no interference if you measured in the which-path basis (0°/90°). The "delayed choice" aspect works regardless of the delay length.

**Q5: Can I use this to send information faster than light?**
> A: No. The D₁ singles *never* show interference—they always show diffraction. Only the coincidence subset reveals fringes, and computing coincidences requires classical communication between D₁ and D₂ (which is limited to light speed). There is no way to use this experiment for faster-than-light signaling.

**Q6: Does blocking the idler "change" what already happened at D₁?**
> A: No. The D₁ detection is unaffected by what happens to the idler. The signal photon's behavior at D₁ is fixed the moment it's detected. What changes is our ability to *sort* the D₁ data into interference and non-interference subsets—and that sorting requires the idler data, which we don't have if it's blocked.

### [p.13-14] Conclusion
> These "what if" experiments confirm the core principle: **interference appears only in coincidences, and only when which-path information is erased.**
>
> Blocking the idler or unplugging the detector doesn't change the physics—it simply removes our ability to perform the coincidence measurement that reveals interference. The which-path information still exists; we just can't access or erase it.

The site's position on observation / consciousness / collapse, stated in its own terms:
- "What counts as a detection" is answered physically: any interaction that encodes which-path information in the environment (wall, fly's eye, camera sensor, air molecules) is a measurement. A conscious observer is neither necessary nor relevant.
- Nothing "collapses" differently depending on who looks: D1 singles are *always* a diffraction envelope in every configuration of Experiments 5-7. Interference is a property of the coincidence-filtered subset, which is a classical post-selection step requiring both data streams.
- No retrocausality: the D1 record is fixed at detection; choices on the idler arm (even years later) change only how the D1 record can be sorted.
- No FTL signalling, because the sorting requires classical communication.

### [p.14] Similar Experiments
Section heading "Similar Experiments" (violet serif), with the cards on p.15.

### [p.15] Cards + footer
Three link cards (thumbnail + label + title):
- "OVERVIEW" thumbnail (bold black word on light card) → "INTRODUCTION — Quantum for everyone".
- Thumbnail: a schematic with four horizontal rows (laser → hatched discs → detector, with Ψ labels) → "EXPERIMENT 1 — Polarizers".
- Thumbnail: a schematic with laser, slit bar, two fanned beams, detector (Ψ labels) → "EXPERIMENT 2 — Single and double slit".
Footer: "Testing Reality © 2018-2026", "Creative commons" with CC BY-NC icons (cc, person, dollar-struck). "Made in Webflow" badge is a print artefact on every page.

## Physics model for simulation

### State space
- Two photons: signal (1) and idler (2).
- Each has a polarization qubit in the basis {|↕⟩, |↔⟩} (site's vertical/horizontal arrows). Diagonal basis: |↗↙⟩ = (|↕⟩+|↔⟩)/√2, |↘↖⟩ = (|↕⟩−|↔⟩)/√2 (used implicitly by the "±45°" erasing basis in Q4 and by P1 = 45°).
- Signal path qubit {|A⟩₁, |B⟩₁} (slit A upper, slit B lower), later mapped to a continuous screen coordinate |y⟩₁.
- Idler spatial mode |S⟩₂ → |D⟩₂ (one mode; it becomes |wall⟩ / |absorbed⟩ in scenario A, and |D2 fired, unrecorded⟩ in scenario B — in both cases a state orthogonal to "recorded in the coincidence logic").
- Loss/absorption sink |lost⟩ for photons stopped by PA/PB/P1/P2 (dropped after normalisation bookkeeping).

### Operators
- BBO (type-I stacked pair, as drawn "BB"): produces |Φ⁺⟩ = (|↕↕⟩ + |↔↔⟩)/√2 (E1).
- Double slit: |A⟩₁ + |B⟩₁ over √2 (E2), followed by slit polarizers: projector P_↕ on |A⟩ branch, P_↔ on |B⟩ branch (E3). Result: path ⟷ polarization are perfectly correlated for the signal, and hence path ⟷ idler polarization are perfectly correlated (which-path info "copied" into the idler).
- Propagation: multiply branch A by e^{ika}, branch B by e^{ikb}, a and b path lengths to y (E4). For a double slit with separation d and slit-screen distance L: b − a ≈ d·y/L.
- Eraser polarizer P1 at angle θ₁ before D1 (45° in all runs here): projector onto |θ₁⟩₁ = cosθ₁|↕⟩ + sinθ₁|↔⟩ (angle measured from the site's |↕⟩ axis — see Open questions on 0°/90° convention).
- Idler polarizer P2 at angle θ₂ before D2 (90° in all runs here): projector onto |θ₂⟩₂.
- Detectors: D1 counts singles as a function of y; D2 counts singles; the "coin" box forms the AND of D1 and D2 within a coincidence window.

### Predicted intensities
General (Experiment 5 formula, with P1 = θ₁, P2 = θ₂ both present and D2 recorded):
- Singles at D1 (trace over idler): I₁(y) ∝ ½·E(y) where E(y) is the single-slit envelope — never any fringes, whatever θ₁, θ₂.
- Coincidences: C(y) ∝ |cosθ₁cosθ₂ e^{ika} + sinθ₁sinθ₂ e^{ikb}|² · E(y). With θ₁ = 45°, θ₂ = ±45°: C(y) ∝ ½[1 ± cos(k(b−a))]·E(y) → fringes (the eraser). With θ₁ = 45°, θ₂ = 90° (the "which-path basis" used on this page): C(y) ∝ ½·E(y), flat.

This page, scenario A (wall after P2, D2 still wired): idler mode is absorbed; the idler never reaches D2:
- I₁(y) ∝ |½e^{ika}|² + |½e^{ikb}|² = ¼ + ¼ = ½ (E5, E6), times the envelope E(y): a single-slit diffraction hump, no fringes.
- C(y) = 0 ideally; measured C(y) = accidental/dark coincidences only (quantised at ≈0.0017 and ≈0.0033 per second in the plot, i.e. 1-2 events per bin).
- D2 singles: ≈ dark-count rate only (not plotted; present in column 6 of data_wall.csv).

Scenario B (no wall, D2 unplugged from the coincidence counter):
- I₁(y): identical form, measured peak ≈209 counts/s, edges ≈176-183 counts/s.
- C(y) = 0 exactly, by construction of the electronics.
- D2 singles: D2 still detects photons physically, but no signal is recorded (column 6 of data_unplugged.csv is presumably 0 / absent — [unclear: not stated]).

Implementation hint: model the "wall" as a measurement of the idler in the {|↕⟩₂,|↔⟩₂} basis whose outcome is written to an inaccessible environment register, and the "unplug" as the same measurement with the result discarded. In both cases the reduced density matrix of the signal is ρ₁ = ½(|A,↕⟩⟨A,↕| + |B,↔⟩⟨B,↔|), a mixture, whose y-distribution is ½E_A(y) + ½E_B(y) with no cross term. This is exactly E5.

### Lab numbers to match (from the plots on this page)
| Quantity | Wall run | Unplugged run |
|---|---|---|
| P1 | 45° (schematic) | 45° (schematic) |
| P2 | 90° (plot title "P2 = 90deg") | 90° |
| D1 scan range | −2000 … +2000 μm | −2000 … +2000 μm |
| D1 singles at −2000 μm | ≈178 /s | ≈183 /s |
| D1 singles peak | ≈200-201 /s at ≈ +150 μm | ≈209 /s at ≈ 0 μm |
| D1 singles at +2000 μm | ≈168 /s | ≈176 /s |
| Envelope FWHM (from plot) | ≈2.6-2.8 mm | ≈2.6-2.8 mm |
| Coincidences | 0 with sparse 0.0017 / 0.0033 /s outliers | exactly 0 |
| Number of positions | ≈80 | ≈80 |

### Parameters the site leaves out on this page (propose values)
- Pump wavelength and BBO type: not stated here. Propose 405 nm diode pump, type-I stacked BBO producing degenerate 810 nm pairs (standard for this kind of tabletop SPDC eraser; matches the project's "405 nm violet laser" note). The signal/idler wavelength λ = 810 nm sets k = 2π/λ.
- Slit width w and separation d: not stated. Propose w = 100 μm, d = 250 μm — typical commercial double-slit slides for photon-counting demos; gives an envelope width consistent with the ≈2.7 mm FWHM seen if the slit-to-D1 distance is L ≈ 0.4-0.5 m (single-slit envelope half-width ≈ λL/w ≈ 810e-9·0.45/100e-6 ≈ 3.6 mm to first zero).
- Distance L slits→D1 and D1 aperture/fiber size: not stated. Propose L = 0.45 m and a 100 μm pinhole/fiber in front of D1 (the fine envelope needs a small collection aperture).
- Integration time per sample and number of sweeps: not stated. The coincidence quantisation (1/600 per s) suggests ≈600 s total per position (e.g. 6 sweeps × 100 s, or 10 samples × 60 s). Propose 1 s samples × ≈600 accumulated.
- Coincidence window: not stated; propose 5-10 ns.
- Wall position: explicitly irrelevant ("1 cm or 1 km", "22 km away"); in the schematic it is immediately after P2.

## Apparatus list (for Blender)
No photographs on this page; all items are from the two schematics (p.5, p.6) and from the text. Items marked "stated" appear/are named on this page; "assumed" are inferred from the sister experiments (5/6) or from standard practice.

| # | Item | Site description / label | Approx. real-world size | Mounting | Status |
|---|---|---|---|---|---|
| 1 | Pump laser | "LASER" (salmon box with emitter stub) | Diode laser module, ≈ 100 × 40 × 40 mm (405 nm, violet beam per project notes) | On a post/clamp or a laser mount on the breadboard | stated (laser); wavelength assumed |
| 2 | Pump-beam optic | Unlabelled hatched disc between laser and BB | Ø25 mm round optic (half-wave plate or polarizer/filter for the pump) | Rotation mount on a post | stated as drawn, identity unclear |
| 3 | BBO crystal pair | "BB" — two thin vertical blue plates | Two 5 × 5 × 0.5 mm BBO plates stacked, in a ≈ Ø25 mm holder | Kinematic/rotation mount on post | stated |
| 4 | Idler steering mirror | Thick black tilted bar at 45° on the upper path | Ø25 mm broadband (NIR) mirror | Kinematic mirror mount on post | stated (drawn) |
| 5 | Double slit | Tall black bar with two gaps at Ψ2, slits A (upper) and B (lower) | Slide ≈ 25 × 75 mm; slits ~0.1 mm wide, ~0.25 mm apart (assumed) | Slide holder on post, possibly on a translation stage | stated (slit); dimensions assumed |
| 6 | Slit polarizer PA | Hatched disc "0°" at slit A, label "PA" | Small film polarizer piece covering slit A (a few mm), or Ø12.7 mm polarizer | Fixed to the slit mask / small rotation mount | stated |
| 7 | Slit polarizer PB | Hatched disc "90°" at slit B, label "PB" | As PA, orthogonal | As PA | stated |
| 8 | Eraser polarizer P1 | Hatched disc "45°", label "P1", on the signal arm before D1 | Ø25 mm linear polarizer (NIR) | Rotation mount with degree scale, on post | stated |
| 9 | Idler polarizer P2 | Violet hatched disc "90°", label "P2", on the idler arm | Ø25 mm linear polarizer | Rotation mount with degree scale, on post | stated |
| 10 | Wall / beam block | Thick black vertical bar after P2 (scenario A only) | Black anodised beam block or black card, ≈ 50 × 50 mm | Post or flag holder | stated |
| 11 | Signal detector D1 | Salmon box "D1" at Ψ7 | Single-photon detection module (e.g. SPCM, ≈ 90 × 50 × 30 mm) with a fiber/pinhole collection head | On a motorised linear translation actuator (the "actuator position (μm)" column; ±2 mm travel used) | stated (D1, actuator); module type assumed |
| 12 | Idler detector D2 | Salmon box "D2" at Ψ7 on the upper path | Same SPCM type | Fixed on post | stated |
| 13 | Coincidence counter | Pill "coin" wired to D1 and D2 (p.5) or to D1 only (p.6) | Counter/FPGA box, ≈ 150 × 100 × 50 mm, with BNC/SMA cables | On the bench next to the detectors | stated |
| 14 | Cables | Black lines D1→coin, D2→coin; D2's cable removed in the unplugged run | Coax cables ≈ 1 m | – | stated |
| 15 | Optical breadboard / enclosure | Not shown | ≈ 600 × 900 mm breadboard, black enclosure (single-photon work needs darkness) | – | assumed |

Layout notes for the 3D reconstruction: the pump axis runs left→right; the BBO sits ≈ 10-15 cm after the laser; the idler leaves the crystal at a small upward angle (≈3°) and is folded by the 45° mirror to run parallel to the signal arm about 10-15 cm above it; P2 sits level with P1; D2 sits level with D1 at the right edge; the double slit is ≈ 10-20 cm after the BBO and D1 ≈ 40-50 cm after the slits. Keep the "Ψ" reference planes as invisible helper objects: Ψ0 after the laser, Ψ1 after the BBO, Ψ2 at the slit, Ψ3 right after PA/PB, Ψ4 at P1/P2, Ψ5-6 right after P1/P2, Ψ7 at the detectors.

## Teaching notes
Concepts the page assumes, in the order needed:
1. The Experiment 5 setup and its result (eraser gives fringes only in coincidences with P2 at ±45°). This page assumes the reader has that result in hand; the game should gate Experiment 7 behind Experiment 5.
2. Two-photon product states and tensor products (|↕⟩₁|↕⟩₂, ⊗ with spatial kets).
3. Entanglement / Bell state |Φ⁺⟩ and the idea of perfect polarization correlation.
4. Projectors (polarizer as a filter that keeps one component and sends the other to |lost⟩).
5. Phase factors e^{ika}, e^{ikb} and why their *cross term* is the interference; the complex modulus squared.
6. Orthogonality: terms tagged with orthogonal idler states (|↕⟩₂ vs |↔⟩₂) add in intensity, not in amplitude (E5). This is the single key computation of the page — an opportunity to teach "incoherent sum vs coherent sum" visually.
7. Mixed states / reduced density matrix (implicit): "we must account for both idler states" = tracing over the idler.
8. Post-selection: interference lives in a *subset* of D1 clicks chosen using D2 data; without D2 data no subset can be formed.
9. Decoherence framing: which-path information "changes form" (absorbed by a wall, scattered by air) but stays encoded in the environment; a fly's eye is as good as a detector.
10. No-signalling and no-retrocausality arguments (Q5, Q6).

The site's own pedagogical moves:
- Starts from real forum/FAQ questions ("what if a fly looks?"), i.e. it meets the popular "consciousness causes collapse" framing head-on and answers it operationally.
- Two minimal-change experiments (add a wall; pull a cable) that each remove exactly one ingredient of the eraser, with the raw CSVs offered.
- Repeats the Experiment 5 derivation step by step and stops at the one line that differs (Step 5-6), then boxes the conclusion.
- The "22 km away" / "1 cm or 1 km" / "delay by years" exaggerations drive home that the effect is not about timing or distance.
- The FAQ is a good source of in-game dialogue beats: NPC asks "what if my friend reads D2?", "what if I unplug it?", the player predicts, then runs the scan and sees a flat coincidence row.

Game-scene suggestions: let the player (a) place the beam block anywhere along the idler arm and (b) unplug D2's cable; both produce the same D1 envelope and an empty coincidence histogram. Then let them re-plug and rotate P2 to 45° to recover fringes in coincidences (link back to Experiment 5).

## Open questions
- Polarizer angle convention: the schematic labels PA = 0°, PB = 90°, P2 = 90°, but the text says "vertical polarizer at slit A transmits |↕⟩₁" and the idler basis check in Q4 calls 0°/90° the "which-path basis". Whether 0° means vertical or horizontal on this site is not fixed on this page; only the relative orthogonality matters for the model. Cross-check with Experiment 5's page.
- The unlabelled hatched disc between the laser and the BBO is not described anywhere on this page (pump filter? half-wave plate? polarizer?). Check Experiments 5/6 for its identity.
- Equations E2 and E4 are clipped at the left margin in the PDF print (the "|ψ₁⟩" and "|ψ₃⟩" labels are cut); reconstructed from the layout text and the surrounding steps.
- Integration time per sample, number of samples per position, number of sweeps, coincidence window, pump wavelength, slit geometry and slit-to-D1 distance are not given on this page. The coincidence quantisation at ≈1/600 s⁻¹ suggests ≈600 s total per position.
- The TOC lists "Lab Experiments" but no section with that heading exists in the print; there are no lab photographs on this page at all (both setup figures are schematics).
- Column 6 (counts at D2) in `data_unplugged.csv`: not stated whether it is recorded as zero, as the physical D2 singles, or omitted.
- The right-hand coincidence plot for the wall run has a theoretical curve drawn at exactly 0 (not a small dark-count level) — the "theory" for the blocked case is simply "no coincidences".
- "22 km away" in the caption versus "1 cm or 1 km" in Q3: both are rhetorical; no actual long-distance run was performed.
