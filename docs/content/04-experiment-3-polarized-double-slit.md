# Experiment 3 : Double slit + Polarizers
Source: `F-Experiment 3 _ Double slit + Polarizers.pdf`; URL printed in the footer: https://testing-reality.webflow.io/experiment-3 ; 23 pages (printed 30/10/2026, 20:51).

Site navigation visible on every page: header "Testing Reality" logo (left), "Experiments" and "About" (right); left-hand "TABLE OF CONTENT": Abstract / Lab Experiments / Result and analysis / Theory and equations / Literature and video. Footer: "Testing Reality © 2018-2026", "Creative commons" (CC BY-SA icons). Pages carry a "Made in Webflow" badge (print artefact, ignored below).

## Page summary
This page combines Experiment 1 (polarizers) and Experiment 2 (single/double slit) into a **quantum eraser**: a diagonally polarized 405 nm laser hits a double slit whose slit A is covered by a horizontal polarizer (PA, 0°) and slit B by a vertical polarizer (PB, 90°); a third, rotatable polarizer P1 sits after the slits in front of the single-photon detector D1. With P1 at 0° or 90° (or absent) the perpendicular slit polarizers "tag" each path with which-way information and the detector sees only a single-slit diffraction envelope (no fringes, half intensity); with P1 at ±45° the tag is erased, both paths are projected onto the same polarization and the double-slit fringes return, the −45° pattern being the exact inverse of the +45° pattern (maxima ↔ minima), the two summing back to the envelope. The site models this by writing each photon state as a product of a polarization ket and a position ket, |ψ⟩ = |↗↙⟩|S⟩, tracking it step by step (Ψ0 … Ψ3) through the apparatus, and showing that orthogonal polarization kets |↔⟩|y⟩ and |↕⟩|y⟩ cannot produce cross terms in |amplitude|², while re-expressing the same state in the diagonal basis lets P1 select a term containing both path phases e^{ika} + e^{ikb}. Four measured scans (P1 = 45°, −45°, 0°, 90°; counts on D1 per second vs actuator position in µm) with theory and fit curves are shown, and the raw CSV data are downloadable.

## Content (in page order)

### p.1 — Title page
- Large label "EXPERIMENT 3" (small caps, grey) above the title "Double slit + Polarizers" (serif, grey, two lines). Nothing else on the page.

### p.2–4 — Abstract

**Figure [p.2] — Schematic: "Experimental setup for the quantum eraser experiment"** (flat 2D schematic, pale blue-grey rounded card background, salmon/red beam lines, lavender accent)
Left to right:
1. **LASER** — salmon/pink rectangle with a small nozzle on the right, label pill "LASER" (red text on pink) underneath.
2. A grey hatched circle (diagonal hatching) immediately after the laser: the diagonal polarizer / half-wave plate that makes the beam diagonally polarized (unlabelled in the figure; the caption says "A diagonally polarized laser").
3. A dashed vertical grey line labelled **Ψ0** (bold grey, at the bottom) — the state just after the source.
4. Two red beam lines fan out from the hatched circle, one up to slit A, one down to slit B.
5. **Double slit**: a thick dark-grey vertical bar broken into three segments (top, middle, bottom), the two gaps being slit A (upper) and slit B (lower).
6. Directly behind each slit a grey circle (polarizer symbol): upper one hatched with **horizontal** lines labelled "0°", pill label **PA** above it; lower one hatched with **vertical** lines labelled "90°", pill label **PB** below it.
7. Dashed lines **Ψ1** (at the slit plane) and **Ψ2** (just after the slit polarizers).
8. The two beams converge towards the detector; between slits and detector sits a **lavender** circle with diagonal hatching labelled "45°", pill label **P1** (lavender) below it, and a curved black arrow above it indicating it is **rotatable**.
9. A vertical axis line labelled **y** (bold) above the detector, and a salmon rectangle (tall, narrow) = screen/detector, pill label **D1** (red text) below it. Dashed line **Ψ3** at the detector plane.
Caption (italic): "Experimental setup for the quantum eraser experiment. A diagonally polarized laser passes through a double slit, where slit A is covered by a horizontal polarizer (PA, 0°) and slit B by a vertical polarizer (PB, 90°). A rotatable third polarizer P1, here set to 45°, is placed after the slits before the detector D1. The labels Ψ0 through Ψ3 indicate the quantum state of the photon at each stage of the setup."

Prose (p.3):
> This experiment combines the previous two: a double-slit setup with polarizers.
>
> More precisely, we cover slit A with a horizontal polarizer and slit B with a vertical polarizer, the two polarizers being perpendicular. A third polarizer, which can be rotated, is placed after the slits so it affects photons from both paths.
>
> Here is what we observe:
>
> - When the third polarizer is set to 0° or 90° (aligned with one of the slit polarizers): **no interference**, the pattern looks like single-slit diffraction.
> - When the third polarizer is set to 45° or -45° (diagonal): **interference returns**, we see the characteristic fringes of a double-slit pattern.
>
> Why does this happen? The perpendicular polarizers on the slits "tag" each path: a horizontally polarized photon must have come from slit A, a vertically polarized one from slit B. This is called **which-way information**. When which-way information is available, even if we do not actually look at it, interference disappears.
>
> The diagonal polarizer erases this tagging. It projects both paths onto the same polarization state, making them indistinguishable again. With no way to tell which slit the photon passed through, interference returns. This is the **quantum eraser** effect.
>
> Why use polarizers instead of, say, placing a detector at one slit? A detector would absorb the photon entirely. Polarizers let most photons through, they interact with the photon just enough to tag it, without destroying it.

Prose (p.4):
> Without spoiling the next experiment, polarizers are not the only way to interact with a photon without absorbing it. We will discover a second method in [Experiment 4](link, red).

**Sub-heading: "Try it yourself!"**
> Here is an animation of Experiment 3. The light coming out of the laser is diagonally polarized. The polarizers can be rotated using the pink handles, and the slit parameters can be adjusted in the control panel. The dark curve shows the maximum diffraction envelope, and the purple curve shows the result of the current setup.

**Embed [p.4] — interactive simulator** (StackBlitz): "react-vazdln-ns7pyb created by vmonette", button "Run this project". The print only shows the StackBlitz phishing-protection interstitial ("This page is shown to protect against phishing attacks… Starting dev server"), so the simulator UI itself is not visible. From the description: a React app; laser with diagonal output polarization; three polarizers (PA, PB, P1) rotatable by dragging pink handles; a control panel for slit parameters (width, separation — by analogy with the Experiment 2 embed); plot with a dark curve = maximal diffraction envelope and a purple curve = pattern for the current polarizer settings.

### p.5 — Lab Experiment

> Curious of what our setup looks like? Here are a few pictures of what we have:

**Figure [p.5] — Lab photo (top-down view of the optical bench)**, with lavender annotation pills and a purple line drawn along the beam path. Photographed from above/at an angle: a stainless-steel optical breadboard (regular grid of M6 tapped holes) with a white wall/panel behind; a power strip and bundles of white/grey/black cables at the back-left; a blue fibre-optic or pneumatic hose coiled at the far left; a small electronics box with a display (green LEDs) and a black box at the back; two **red boxes** at the back-right (electronics/SPCM power or counting modules, cabled with orange and black cables); a brown envelope/cardboard at the top right. Labelled items along the beam (left → right):
1. **LASER** (far left, partially cropped; a small black module on a post, beam heading right).
2. **Beam splitter** (black cube mount on a post immediately after the laser) — labelled above.
3. **Half-wave plate** (black rotation mount just after the beam splitter) — labelled below.
4. **Lens** (first lens, L1, on a post shortly after the half-wave plate) — labelled above.
5. (long free-space gap, ~40% of the bench)
6. **Double slit** (black square holder on an X-Y translation mount, mid-bench) — labelled below; the slit polarizers PA/PB are attached to this holder (not separately labelled).
7. **Lens** (second lens on a post, a short distance after the double slit) — labelled below.
8. **Polarizer P1** (black rotation mount) — labelled above.
9. **Dectection stage** [sic, site spelling] — a motorized translation stage (tall black actuator/stepper on the right, with a vertical post carrying the single slit + fibre coupler) with grey cables, labelled below. Behind it the two red modules (single-photon detection electronics) and a fibre patch cable leading from the stage.
A straight **purple line** is drawn from the laser to the detection stage to indicate the beam path (the beam itself, 405 nm, is not visible in the photo).

### p.6–7 — Technical set-up and Equipment

> Here is a representation of the setup shown in the picture. All of the equipment is displayed, but the scaling is not proportional.

**Figure [p.6] — Setup line diagram** (schematic on pale card; thin red line = beam, left → right):
1. **LASER** — grey rectangle labelled "LASER".
2. **BS** — square cube beam splitter drawn with a diagonal, labelled "BS" below; the reflected beam goes **up** to **BD** (black semicircular beam dump labelled "BD").
3. **λ/2** — tall thin **purple** rectangle labelled "λ/2" (half-wave plate).
4. **L1** — plano-convex lens drawn as a lens outline, labelled "L1 = 50cm" below.
5. **Double slit with PA/PB** — a black vertical bar with two gaps; behind each gap a small light-blue square labelled "PA" (upper) and "PB" (lower).
6. **P1** — light-green/teal square labelled "P1" on a small grey base labelled **M1** (motor; i.e. P1 and/or the following stage sits on a motorized mount).
7. **D1** — dark grey square labelled "D1" (detector).
Legend box (top right): "BS : Beam Splitter / BD : Beam Dump / λ/2 : Half-wave plate / L_ : Plano-convex lens / M_ : Motor".
(Note: the single slit / adjustable slit before the detector that appears in the equipment list is not drawn as a separate element; the second lens from the photo is also not drawn.)

**Equipment list** (table, "Name" entries in red are links to component pages/suppliers):

| Name | Description |
|---|---|
| LASER | Diode laser (405nm) |
| BBO | Two thin BBO crystals of type 1 placed at 90° |
| Double slit | Dimension (200-200-200 μm), made in-house |
| Polarizers | Mounted linear polarizers |
| Lenses | Plano-convex lenses, L1 has f=50cm [LA-1908-B] |
| Single slit | Adjustable slit (placed near 200μm) |
| Detectors | Single photon detection module |

> *Note:* see more component details and link in previous experiment

(The BBO crystals are listed but do not appear in the diagram or in the described beam path for this experiment; they are inherited from the shared equipment list. The lens part number is printed "LA-1908-B" — Thorlabs' f = 500 mm N-BK7 plano-convex lens is LA1908-B, so this is almost certainly a typo for LA1908-B.)

### p.7–9 — Result and analysis

**Raw data** — "The raw data can be downloaded here:" four CSV download links (file icons, red):
- `data_90deg.csv`
- `data_00deg.csv`
- `data_-45deg.csv`
- `data_45deg.csv`

Prose (p.8):
> To recreate a pattern, an actuator was moved along the beam. All data files have four columns. The first two are the angles of the polarizers, but only P1 is used. The third is the distance the actuator has travelled in μm [print artefact: "$\mu m$%\unit{\micro\meter}" — a leaked LaTeX comment].
>
> The last column is the number of counts on D1, the detector. All acquisitions are for a two-second window.

**Graphics** — four plots in a 2×2 grid, headed "At 45°", "At −45°" (top row, p.8) and "At 0°", "At 90°" (bottom row, continued on p.9). All four share the same style (matplotlib): title "Number of counts on D1 per seconds [P1=45]" / "[P1=-45]" / "[P1=0]" / "[P1=90]"; x-axis "Distance on the screen (μm)" from −3000 to 3000 (ticks every 1000); y-axis "Intensity per seconds"; legend: "Theorical curve" [sic] (grey dashed), "Fit of the datas" [sic] (blue solid), "Our datas" [sic] (black dots).

- **Figure [p.8] At 45° (P1=45)**: y from ~1000 to ~8000 counts/s. Black dots form a clear multi-peak interference pattern inside an envelope: a tall central peak at x ≈ 0 (~7700 c/s), a left peak at x ≈ −650 (~6900), a right peak at x ≈ +850 (~5500), a smaller peak at x ≈ +1500 (~2700), a shoulder/weak peak at x ≈ −1300 (~3500) and a background floor ~1300–1500 at the edges. The blue fit follows the dots. The grey dashed theoretical curve is a symmetric double-slit pattern (3 tall central fringes + side fringes) that is noticeably **shifted/narrower** relative to the data — the data's fringe spacing and envelope are offset ("there is actually a phase offset in our polarization setup"). Minima between data peaks do not go to the floor (~3000–4000 c/s), i.e. visibility is partial.
- **Figure [p.8] At −45° (P1=−45)**: y from ~1000 to ~7000. Black dots: two tall peaks at x ≈ −300 (~6600) and x ≈ +400 (~6800) with a deep minimum between them at x ≈ 0 (~3000), smaller peaks at x ≈ −1000 (~4200) and x ≈ +1100 (~4300), floor ~1800–2000. The blue fit matches. Grey dashed theory shows the complementary pattern (minimum at centre). Compared with the 45° plot: where 45° has a maximum (x≈0) this has a minimum, and vice versa — "the inverse" pattern.
- **Figure [p.9] At 0° (P1=0)**: y from ~1000 to ~7000. A single smooth bell-shaped diffraction envelope, peak ~6700 c/s at x ≈ −100, floor ~1300 at the edges, width ~ ±2000 µm to the floor. Blue fit and grey dashed theory are both single-slit envelopes (theory slightly narrower). No fringes.
- **Figure [p.9] At 90° (P1=90)**: y from ~2000 to ~7000. Again a single bell-shaped envelope, noisier dots (scatter ~±400 near the peak), peak ~6400 c/s at x ≈ +600 — i.e. **shifted right** relative to the 0° curve — floor ~2300–2700. Blue fit, grey dashed theory are smooth envelopes. No fringes. (The 0° and 90° centres differ by roughly 500–700 µm on the screen: "This shift represents the spacing between the slits.")

Prose (p.9):
> Let us analyze these graphs. First, at 0 degrees and 90 degrees, there is no interference. By placing polarizer P1 at the same angle as one of the slit polarizers, we know for certain through which slit the photon passed. It behaves like a single-slit experiment. The patterns at 0 and 90 degrees show a slight shift relative to each other. This shift represents the spacing between the slits. Since each slit acts as a single slit, each produces a diffraction pattern centered in front of it.
>
> For the graphs at 45 degrees and -45 degrees, interference is clearly visible, but the two patterns differ. The 45-degree graph has the same shape as the one from Experiment 2, with three large peaks (the pattern is not perfect — there is actually a phase offset in our polarization setup, which will be corrected in the next experiment). Upon closer inspection, the pattern at -45 degrees is the inverse of that at 45 degrees: all maxima become minima and vice versa. Summing both plots recovers the full diffraction envelope. (The same phenomenon occurs with the 0 and 90 degree graphs — adding them yields the same diffraction pattern, though less striking since they already showed diffraction individually.)

### p.9–10 — Theory and equations (section heading overlaps the text in the print)

Prose (p.9–10; the first paragraph is printed **overlapping** another paragraph at the top of p.10, reconstructed from the two interleaved texts):
> Why are the two diagonal plots inverted? There are two explanations. First, [unclear: overlapped text, best reading:] polarizers block a portion of the photons. Perpendicular polarizers block complementary portions, so summing them recovers all the photons.

[unclear: a "second" explanation announced by "There are two explanations" is not visible anywhere on the page; it may be the whole derivation that follows, or lost to the overlap.]

> In the first experiment, we learned how to describe a photon's polarization and how polarizers change it. In the second experiment, we learned how to describe a photon's position, like being at the source, at slit A, or at slit B, and how interference arises from superpositions of paths.
>
> In this experiment, we put those two aspects together. A photon has both:
>
> - A polarization
> - A position in the setup
>
> To write this compactly, we simply list them side by side. For example, the initial state of a diagonal photon located at source S is denoted as follows:

Equation E1 (p.10) — the site's tensor-product notation is simple juxtaposition of kets (polarization ket first, then position ket; no ⊗ symbol is ever written):
$$\ket{\psi} = \ket{\nearrow\!\!\!\swarrow}\ket{S}$$
(written on the site as |↗↙⟩|S⟩ — the diagonal-polarization ket uses the double-headed diagonal arrow glyph ↗↙; anti-diagonal is ↘↖; horizontal ↔; vertical ↕.)

> That is all we need — every state will now be described by polarization *and* position.

### p.10–16 — "The first two polarizers" (sub-section heading, serif bold)

**Figure [p.11] — Schematic "Experimental setup without the third polarizer"**: identical to the p.2 schematic (LASER, hatched diagonal element, Ψ0, double slit with PA 0° horizontal-hatched and PB 90° vertical-hatched circles, Ψ1, Ψ2, y axis, salmon D1 screen, Ψ3) **but with P1 removed**; the two red beams run straight from the slit polarizers to converge on the detector.
Caption (italic): "Experimental setup without the third polarizer. A diagonally polarized laser passes through a double slit with perpendicular polarizers on each slit: a horizontal polarizer (PA, 0°) on slit A and a vertical polarizer (PB, 90°) on slit B. Without a third polarizer, the which-way information encoded by the slit polarizers is preserved, and no interference pattern is observed at the detector D1."

**Step 0. Initial state.** "We start with the photon prepared in a diagonal state at the source:"

Equation E2 (p.12):
$$\ket{\psi_0} = \ket{\nearrow\!\!\!\swarrow}\ket{S}\,.$$

**Step 1. Double slit.** "At the double slit, the photon can go through slit |A⟩ or |B⟩. We ignore photons that hit the wall (|lost⟩) and keep only the ones that pass. The distance from the source to each slit is l, so:"

Equation E3 (p.12):
$$\ket{\psi_1} = \ket{\nearrow\!\!\!\swarrow}\left(\frac{1}{\sqrt{2}}e^{ikl}\left(\ket{A}+\ket{B}\right)\right) = \frac{1}{\sqrt{2}}e^{ikl}\left(\ket{\nearrow\!\!\!\swarrow}\ket{A} + \ket{\nearrow\!\!\!\swarrow}\ket{B}\right).$$

> In the above, all we are doing is distributing |↗↙⟩ to |A⟩ and |B⟩.

**Step 2. Polarization.** "Now comes the crucial step, as each slit has a polarizer. Path |A⟩ has a polarizer P_↔, and path |B⟩ has a polarizer P_↕:"

Equation E4 (p.13), five lines exactly as on the site:
$$\begin{aligned}
\ket{\psi_2} &= \frac{1}{\sqrt{2}}e^{ikl}\left(P_{\leftrightarrow}\ket{\nearrow\!\!\!\swarrow}\ket{A} + P_{\updownarrow}\ket{\nearrow\!\!\!\swarrow}\ket{B}\right)\\
&= \frac{1}{\sqrt{2}}e^{ikl}\left(P_{\leftrightarrow}\left(\frac{\ket{\leftrightarrow}+\ket{\updownarrow}}{\sqrt{2}}\right)\ket{A} + P_{\updownarrow}\left(\frac{\ket{\leftrightarrow}+\ket{\updownarrow}}{\sqrt{2}}\right)\ket{B}\right)\\
&= \frac{1}{\sqrt{2}}e^{ikl}\left(\frac{\ket{\leftrightarrow}+\ket{\mathrm{lost}_{P_A}}}{\sqrt{2}}\ket{A} + \frac{\ket{\mathrm{lost}_{P_B}}+\ket{\updownarrow}}{\sqrt{2}}\ket{B}\right)\\
&= \frac{1}{\sqrt{2}}e^{ikl}\left(\frac{1}{\sqrt{2}}\ket{\leftrightarrow}\ket{A} + \frac{1}{\sqrt{2}}\ket{\updownarrow}\ket{B} + \frac{1}{\sqrt{2}}\ket{\mathrm{lost}_{P_A}} + \frac{1}{\sqrt{2}}\ket{\mathrm{lost}_{P_B}}\right)\\
&= \frac{1}{2}e^{ikl}\left(\ket{\leftrightarrow}\ket{A} + \ket{\updownarrow}\ket{B} + \ket{\mathrm{lost}_{P_A}} + \ket{\mathrm{lost}_{P_B}}\right)
\end{aligned}$$

> In the above algebra, on the second line, we simply express |↗↙⟩ in terms of |↕⟩ and |↔⟩. On the third line we then apply P_↔ and P_↕ to the terms representing |↗↙⟩. Due to the action of polarizers, we lose |↕⟩ for |A⟩ and |↔⟩ for |B⟩ respectively. On lines four and five we simplify and combine the terms to get a cleaner equation.
>
> So after the slits, the surviving photons are either horizontal from |A⟩ or vertical from |B⟩. The terms |lost_PA⟩ and |lost_PB⟩ are just there to account for photons that were lost due to polarization. |lost_PA⟩, for example, describes the photons that tried to go through slit |A⟩ but were blocked by its horizontal polarizer (because their polarization was not aligned). The same applies to |B⟩ in a vertical manner with |lost_PB⟩.

(Note on the site's convention: a polarizer P_↔ acting on |↕⟩ sends it to a "lost" ket rather than to zero, so the total norm is preserved and absorbed photons are explicitly bookkept; the lost kets carry no position label.)

**Step 3. Reaching the detector.** "After the photons pass the slits, they propagate toward the detector. In reality, they can arrive at many points along the vertical axis, but let us focus on one arbitrary position, denoted by |y⟩. The distance from slit |A⟩ to this point is a so the phase factor is e^{ika}, and from slit |B⟩ it is b, so the phase factor is e^{ikb}. In the algebra below, we show how this appears in practice, and factor out |y⟩, which will be useful later on. The "⋯" before and after the terms in the definition of |ψ3⟩ indicates that we are only showing one contribution, as the photons can hit many other places than |y⟩, so there is a whole collection of similar terms. But given we only focus on an arbitrary position |y⟩ here as an example, that is the only one we show."

Equation E5 (p.14):
$$\begin{aligned}
\ket{\psi_3} &= \cdots + \frac{1}{2}e^{ikl}\left(e^{ika}\ket{\leftrightarrow}\ket{y} + e^{ikb}\ket{\updownarrow}\ket{y}\right) + \cdots\\
&= \cdots + \frac{1}{2}e^{ikl}\left(e^{ika}\ket{\leftrightarrow} + e^{ikb}\ket{\updownarrow}\right)\ket{y} + \cdots\\
&= \cdots + \frac{1}{2}e^{ikl}e^{ika}\ket{\leftrightarrow}\ket{y} + \frac{1}{2}e^{ikl}e^{ikb}\ket{\updownarrow}\ket{y} + \cdots
\end{aligned}$$

**Step 4. Calculating the intensity.** "To predict what the detector sees, we calculate the *intensity* at |y⟩. Intensity is the brightness at a spot on the detector, or more technically the likelihood of finding a photon there. Intensity comes from taking the squared magnitude of the total amplitude. Here we have two terms in superposition:"

Equation E6 (p.15) — same as the last line of E5 with under-braces labelling the two coefficients "amplitude A1" (under ½ e^{ikl} e^{ika}) and "amplitude A2" (under ½ e^{ikl} e^{ikb}):
$$\ket{\psi_3} = \cdots + \underbrace{\tfrac{1}{2}e^{ikl}e^{ika}}_{\text{amplitude }A_1}\ket{\leftrightarrow}\ket{y} + \underbrace{\tfrac{1}{2}e^{ikl}e^{ikb}}_{\text{amplitude }A_2}\ket{\updownarrow}\ket{y} + \cdots$$

> To find the intensity, we compute the squared magnitude of each amplitude. But here is the key point: because |↔⟩|y⟩ and |↕⟩|y⟩ are **orthogonal states**, they cannot add up or cancel each other — regardless of their phases. Their contribution to the intensity will invariably be the sum of each term's squared amplitude:

Equation E7 (p.15):
$$\begin{aligned}
I &= |A_1|^2 + |A_2|^2\\
&= \left|\tfrac{1}{2}e^{ikl}e^{ika}\right|^2 + \left|\tfrac{1}{2}e^{ikl}e^{ikb}\right|^2\\
&= \tfrac{1}{4} + \tfrac{1}{4}\\
&= \tfrac{1}{2}
\end{aligned}$$

> This is the mathematical reason why marking the paths with perpendicular polarizers destroys interference: the two terms live in orthogonal states, so they can never combine. We simply get the sum of two independent contributions.
>
> (p.16) So the resulting pattern is simply a flat constant at half the brightness of the ordinary double slit. The reason is that the two polarizations are orthogonal: the kets can no longer factorize in a way that lets the complex exponentials add up or cancel each other.
>
> In equation form, the observed distribution is just the single-slit diffraction envelope scaled down by a factor of 1/2:

Equation E8 (p.16):
$$\mathrm{Pattern} = \frac{1}{2}\times\left(\frac{\sin\alpha}{\alpha}\right)^2$$

> where $\alpha = \dfrac{\pi w \sin\theta}{\lambda}$, with w being the slit width and θ the angle from the center.
>
> This is consistent with the intuition: each slit still produces its own diffraction pattern, but because their polarizations are perpendicular, the detector cannot "add" them coherently. Instead, we only see the sum of two independent single-slit patterns, resulting in half the overall intensity and no interference.

### p.16–22 — "Adding the third polarizer" (sub-section heading)

**Figure [p.17–18] — Three-panel infographic "Step-by-step summary of the quantum eraser effect"** (tall card, three stacked rounded boxes with small arrows/notes between them, serif typography; dark blue for interference curves, grey for envelopes, purple for the −45° curve; yellow = ↔/slit A tag, pink = ↕/slit B tag):

- **Step 1 — Double slit, no polarizers.** Mini-schematic: grey box "S" (source) → dashed pink beams → vertical dark bar with two gaps labelled **A** (upper) and **B** (lower) → grey half-disc "D" (detector). Right: blue multi-fringe curve (≈7 fringes under a sinc² envelope, tallest at centre) labelled "**Interference**". Text: "Both paths identical → can't tell which slit → **fringes**". Formula strip: "|ψ⟩ = 1/√2 e^{ikl} ( |↗↙⟩|A⟩ + |↗↙⟩|B⟩ )   same polarization → can interfere".
- Connector: "↓ add perpendicular polarizers on each slit ↓"
- **Step 2 — Perpendicular polarizers on each slit (no third polarizer).** Same mini-schematic with a small **yellow** rectangle "P↔" on slit A and a **pink** rectangle "P↕" on slit B. Right: a single grey bell curve (with a faint dashed fringe pattern ghosted behind it) labelled "**No interference**  I = ½ × envelope". Text: "Paths are tagged: ↔ = **slit A** (yellow), ↕ = **slit B** (pink) / Could tell which slit → **fringes disappear**". Formula strip: "|ψ⟩ = ½ e^{ikl} ( e^{ika}|↔⟩ + e^{ikb}|↕⟩ )|y⟩   orthogonal → no cross-terms".
- Connector: "↓ add a diagonal polarizer after both slits ↓"
- **Step 3 — Add a third polarizer at 45°** (blue-outlined box). Mini-schematic adds a blue hatched square "P1" between the slits and D. Right: blue fringe curve again, labelled "**Interference is back**  I = ¼(1 + cos)". Text: "Both paths projected onto the **same** polarization / Can't tell which slit anymore → **fringes return**". Formula strip: "Re-express in diagonal basis: |ψ⟩ = 1/(2√2) e^{ikl} [ (e^{ika}+e^{ikb})|↗↙⟩ + (e^{ika}−e^{ikb})|↘↖⟩ ]|y⟩ ;  P1 at 45° selects: (e^{ika}+e^{ikb})|↗↙⟩ → I = ¼(1 + cos k(a−b))". Call-out box: "**Quantum eraser** — The slit polarizers *tagged* each path. The diagonal polarizer *erased* the tag."
- **Going further: 45° and −45° are complementary** (cream box, p.18): blue fringe curve labelled "45°  (e^{ika}+e^{ikb})|↗↙⟩  I = ¼(1+cos)"  **+**  purple fringe curve (maxima where the blue has minima) labelled "−45°  (e^{ika}−e^{ikb})|↘↖⟩  I = ¼(1−cos)"  **=**  grey bell curve labelled "Step 2  |↔⟩ + |↕⟩ orthogonal  I = ½". Bottom line: "¼(1+cos) + ¼(1−cos) = ½ — The two diagonal cases are opposite — maxima ↔ minima. They sum to Step 2."

Caption (italic, p.18–19): "Step-by-step summary of the quantum eraser effect. **Step 1:** A standard double slit with no polarizers produces an interference pattern, as both paths are indistinguishable. **Step 2:** Adding perpendicular polarizers (↔ on slit A, ↕ on slit B) tags each path, destroying interference and yielding a single-slit diffraction envelope at half intensity. **Step 3:** Inserting a diagonal polarizer (P1 at 45°) after the slits projects both paths onto the same polarization state, erasing the which-way information and restoring the interference fringes. The complementary patterns at 45° and −45° are shown to be inverses of each other, summing to recover the Step 2 envelope: ¼(1 + cos) + ¼(1 − cos) = ½."

Prose (p.19):
> We now add a third polarizer P1 after the slits. The result depends entirely on *which basis* we use to express the photon's polarization.

**The state before P1**
> Just before the third polarizer, the photon is in the state:

Equation E9 (p.19):
$$\ket{\psi_3} = \frac{1}{2}e^{ikl}\left(e^{ika}\ket{\leftrightarrow} + e^{ikb}\ket{\updownarrow}\right)\ket{y}$$

> The two polarization states |↔⟩ and |↕⟩ are **orthogonal**. This is why there is no interference: the terms cannot combine.

**Choosing a basis**
> Here is the key insight: *the same state can be written in different bases.*
>
> **In the H/V basis** (horizontal/vertical):

Equation E10 (p.20) — identical to E9:
$$\ket{\psi_3} = \frac{1}{2}e^{ikl}\left(e^{ika}\ket{\leftrightarrow} + e^{ikb}\ket{\updownarrow}\right)\ket{y}$$

> The two terms have different polarizations → orthogonal → no interference.
>
> **In the diagonal basis** (using $\ket{\leftrightarrow} = \frac{1}{\sqrt{2}}(\ket{\nearrow\!\!\!\swarrow} + \ket{\searrow\!\!\!\nwarrow})$ and $\ket{\updownarrow} = \frac{1}{\sqrt{2}}(\ket{\nearrow\!\!\!\swarrow} - \ket{\searrow\!\!\!\nwarrow})$):

Equation E11 (p.20):
$$\ket{\psi_3} = \frac{1}{2\sqrt{2}}e^{ikl}\left[\left(e^{ika}+e^{ikb}\right)\ket{\nearrow\!\!\!\swarrow} + \left(e^{ika}-e^{ikb}\right)\ket{\searrow\!\!\!\nwarrow}\right]\ket{y}$$

> Now each polarization state has *both* phase terms → interference is possible.

**What P1 does**
> The third polarizer **selects one term** from this superposition:

**Table [p.21]**:

| P1 angle | Selects | Intensity | Result |
|---|---|---|---|
| 0° | $e^{ika}\ket{\leftrightarrow}$ | $I = \tfrac{1}{4}$ | no interference |
| 90° | $e^{ikb}\ket{\updownarrow}$ | $I = \tfrac{1}{4}$ | no interference |
| 45° | $(e^{ika}+e^{ikb})\ket{\nearrow\!\!\!\swarrow}$ | $I = \tfrac{1}{4}(1+\cos k\Delta)$ | **interference** |
| −45° | $(e^{ika}-e^{ikb})\ket{\searrow\!\!\!\nwarrow}$ | $I = \tfrac{1}{4}(1-\cos k\Delta)$ | **anti-interference** |

(The 45° row uses the glyph "↗" and the −45° row "↘" in the Selects column — i.e. |↗↙⟩ and |↘↖⟩ printed with single arrowheads; a horizontal rule separates the 0°/90° rows from the ±45° rows.)

> where Δ = a − b is the path difference.

**Why does 45° restore interference?**
> At 0° or 90°, the polarizer selects photons from *one slit only*. We know which path was taken → no interference.
>
> At 45°, the polarizer projects *both* paths onto the *same* final polarization |↗↙⟩. A photon that survives could have come from either slit — we cannot tell. The which-way information has been **erased**.
>
> This is the **quantum eraser** effect.

**Complementary pairs**
> The 45° and −45° patterns are opposite: maxima ↔ minima. Adding them:

Equation E12 (p.22):
$$\frac{1}{4}(1+\cos k\Delta) + \frac{1}{4}(1-\cos k\Delta) = \frac{1}{2}$$

> This recovers exactly the pattern from before adding P1. Same for 0° + 90°:

Equation E13 (p.22):
$$\frac{1}{4} + \frac{1}{4} = \frac{1}{2}$$

### p.22 — "Similar Experiments" (section heading, purple serif — but the text under it is the closing remark of the theory)
> The third polarizer does not create or destroy photons. It **picks a decomposition**: a way of splitting the photons into two complementary groups that always sum to the same total.

(No "Literature and video" content is present on the page despite the TOC entry; no video or reference list appears.)

### p.23 — Footer navigation cards
Three cards: **INTRODUCTION — Quantum for everyone** (card image: the word "OVERVIEW" in bold black), **EXPERIMENT 1 — Polarizers** (thumbnail: four stacked schematic rows of laser → polarizer circles (0°, 45°, 90° …) → detector with Ψ0…Ψ3 labels), **EXPERIMENT 2 — Single and double slit** (thumbnail: laser → slit bar → fanned beams → screen with Ψ labels). Footer: "Testing Reality © 2018-2026" and "Creative commons" with CC / BY / SA icons.

## Physics model for simulation

### State space
- **Polarization qubit**, basis {|↔⟩ (H, 0°), |↕⟩ (V, 90°)}; diagonal basis |↗↙⟩ = (|↔⟩+|↕⟩)/√2 (D, +45°), |↘↖⟩ = (|↔⟩−|↕⟩)/√2 (A, −45°); inverses |↔⟩ = (|↗↙⟩+|↘↖⟩)/√2, |↕⟩ = (|↗↙⟩−|↘↖⟩)/√2. General linear polarizer at angle φ (from horizontal) transmits |φ⟩ = cos φ|↔⟩ + sin φ|↕⟩.
- **Position (path) register**, basis {|S⟩ (source), |A⟩, |B⟩ (slits), |y⟩ (a point on the detector line), |lost⟩ (hit the slit wall)}, plus "loss" sinks |lost_PA⟩, |lost_PB⟩ for photons absorbed by the slit polarizers (and, for P1, a third sink |lost_P1⟩ if the programmer wants to keep unit norm).
- **Combined state** = tensor product, written on the site by juxtaposition: |pol⟩|pos⟩ (polarization first). Implement as a dictionary {(pol, pos): complex amplitude} or as a 2 × N complex matrix. The site never writes ⊗; if the game displays it, use the site's juxtaposed form "|↗↙⟩|A⟩".

### Operators
- **Source / diagonal preparation**: |ψ0⟩ = |↗↙⟩|S⟩ (laser + half-wave plate set so the output is diagonal; the λ/2 in the setup diagram is what makes the polarization diagonal).
- **Propagation source → slits**: |S⟩ → (1/√2) e^{ikl} (|A⟩ + |B⟩), both slits at distance l (the |lost⟩ wall component is dropped and the kept part renormalised; the site "ignores photons that hit the wall"). k = 2π/λ.
- **Slit polarizers** (act only on the polarization factor of the matching path): P_↔ on path A: |↔⟩ → |↔⟩, |↕⟩ → |lost_PA⟩. P_↕ on path B: |↕⟩ → |↕⟩, |↔⟩ → |lost_PB⟩. Generic polarizer at angle φ: P_φ|χ⟩ = ⟨φ|χ⟩ |φ⟩ + (orthogonal remainder) |lost⟩.
- **Propagation slits → detector point y**: |A⟩ → e^{ika}|y⟩, |B⟩ → e^{ikb}|y⟩, where a, b are the distances from slit A / slit B to the point y. Path difference Δ = a − b ≈ d·sin θ ≈ d·y/L for slit separation d, screen distance L, position y.
- **Third polarizer P1 at angle φ1**: projector onto |φ1⟩ in the polarization factor, applied to both paths (it sits after the slits in the common beam). The site's table enumerates φ1 ∈ {0°, 90°, 45°, −45°}.
- **Detector D1**: intensity/probability at y = Σ over orthogonal final kets of |amplitude|² — i.e. I(y) = ‖(⟨y| ⊗ 𝟙_pol)|ψ⟩‖².

### Predicted intensities at a point y (per the site; "1" = the ordinary double-slit peak normalisation, envelope omitted)
Let φ1 be the P1 angle. Amplitudes before P1 (E9): A_H = ½ e^{ikl} e^{ika} on |↔⟩|y⟩, A_V = ½ e^{ikl} e^{ikb} on |↕⟩|y⟩.
- **No P1** (E7): I = |A_H|² + |A_V|² = ¼ + ¼ = ½ (no y-dependence beyond the envelope).
- **P1 at 0°**: I = |A_H|² = ¼. **P1 at 90°**: I = |A_V|² = ¼. (Each selects one slit's photons; the lab data show each as a single-slit envelope centred in front of its own slit, hence the ~0.5 mm relative shift between the 0° and 90° scans.)
- **P1 at 45°**: amplitude = ⟨↗↙|(A_H|↔⟩ + A_V|↕⟩) = (A_H + A_V)/√2 = (1/(2√2)) e^{ikl}(e^{ika}+e^{ikb}) ⇒ I = ¼(1 + cos kΔ).
- **P1 at −45°**: amplitude = (A_H − A_V)/√2 ⇒ I = ¼(1 − cos kΔ).
- **General φ1** (not on the site, but the natural extension the simulator needs for a freely rotatable P1): amplitude = cos φ1 · A_H + sin φ1 · A_V ⇒ I(φ1) = ¼[cos²φ1 + sin²φ1 + 2 sin φ1 cos φ1 cos kΔ] = ¼[1 + sin(2φ1) cos kΔ]. Fringe visibility V = |sin 2φ1|: 0 at 0°/90°, 1 at ±45°, sign flips between +45° and −45°. This reproduces all four table rows and the "pink handle" rotation in the embed.
- **Complementarity** (E12, E13): I(45°) + I(−45°) = ½ = I(0°) + I(90°) = I(no P1).

### Full pattern on the screen (what the plots show)
Multiply the above by the single-slit envelope. With slit width w, slit separation d, wavelength λ, angle θ (sin θ ≈ y/L):
- α = π w sin θ / λ, β = π d sin θ / λ (so kΔ = 2β).
- No P1, or P1 at 0°/90° (E8): I(θ) ∝ ½ · (sin α/α)² [for 0°/90° individually: ¼ · (sin α/α)², each envelope centred on its own slit, i.e. shifted by ±d/2 on the screen].
- P1 at 45°: I(θ) ∝ ¼ (sin α/α)² (1 + cos 2β) = ½ (sin α/α)² cos²β — the ordinary double-slit pattern at half brightness. P1 at −45°: ½ (sin α/α)² sin²β.
- Counts in the lab plots also sit on a background floor of ~1300–2700 counts/s (dark counts + stray light) that should be added as an offset if the game reproduces the measured curves.

### Parameters stated by the site
- Wavelength λ = 405 nm (diode laser). k = 2π/λ ≈ 1.551 × 10⁷ rad/m.
- Double slit "Dimension (200-200-200 μm), made in-house": read as slit width w = 200 µm, gap between slits 200 µm, slit width 200 µm ⇒ centre-to-centre separation d = 400 µm. (Same slit as Experiment 2.)
- Lens L1: plano-convex, f = 50 cm (Thorlabs LA1908-B). The second lens in the photo has no stated focal length.
- Single slit before the detector: adjustable, "placed near 200μm" (width ≈ 200 µm — this is the scanning aperture whose finite width smooths the measured fringes).
- Acquisition: 2-second counting window per point; plots are rescaled to counts per second. Scan range −3000 … +3000 µm on the screen; actuator step not stated (dot spacing in the plots suggests ≈ 50 µm).
- Observed fringe spacing in the 45°/−45° data: adjacent maxima ≈ 700–750 µm apart. Fringe period = λL/d ⇒ with d = 400 µm, λ = 405 nm this gives an effective slit-to-scan-plane distance L ≈ 0.7 m. The site does not state L; a realistic value consistent with the photo (slit mid-bench, detector stage ~70–80 cm downstream) is **L ≈ 0.7 m** (proposed, not stated). Envelope half-width to the floor ≈ 2000 µm, consistent with w ≈ 200 µm at that L (first sinc zero at λL/w ≈ 1.4 mm plus the 200 µm scanning slit and the ~1300 c/s floor).
- The measured 45° pattern has a known **phase offset** ("in our polarization setup, which will be corrected in the next experiment"): the fringes are shifted relative to the theory curve, and visibility is partial (minima at ~40–50% of maxima). A simulator should offer an optional phase δ in cos(kΔ + δ) and a visibility factor V < 1 to reproduce the real data; for the idealised teaching mode use δ = 0, V = 1.
- Data file format (CSV, 4 columns): [angle of polarizer 1, angle of polarizer 2 (unused), actuator position in µm, counts on D1 in 2 s]. Files: data_00deg.csv, data_90deg.csv, data_45deg.csv, data_-45deg.csv (not included in the PDF).

## Apparatus list (for Blender)
All on a stainless optical breadboard (M6 grid, 25 mm pitch; visible area ≈ 1.2 m × 0.6 m — assumed), beam running left → right ~10–12 cm above the table (assumed). The beam is violet (405 nm) and effectively invisible in the photo; the site draws it as a purple line.

| Item | Site description | Stated / assumed | Real-world size & mounting (assumed unless noted) |
|---|---|---|---|
| Diode laser | "Diode laser (405nm)" (LASER) | stated | Compact violet laser module ~ Ø25–40 mm × 100 mm, black, on a post/kinematic mount at the far left; power cable to the back. |
| Beam splitter (BS) | "Beam Splitter" in diagram legend; cube in diagram; "Beam splitter" pill in photo | stated | 1-inch cube beamsplitter in a black cube/platform mount on a post, right after the laser; reflected arm goes sideways into a beam dump. |
| Beam dump (BD) | "Beam Dump" | stated (diagram only) | Small black anodised beam trap ~ 30 × 30 × 50 mm on a post, placed on the reflected arm of BS. |
| Half-wave plate (λ/2) | "Half-wave plate" pill in photo; purple plate in diagram | stated | Ø1" zero-order waveplate in a rotation mount (graduated ring, ~Ø55 mm) on a post, right after BS. Sets the laser polarization to diagonal. |
| Lens L1 | "Plano-convex lenses, L1 has f=50cm [LA-1908-B]" | stated | Ø1" plano-convex lens in a lens mount on a post, just after the λ/2; used to collimate/condition the beam before the slit. |
| Double slit + PA, PB | "Dimension (200-200-200 μm), made in-house"; "Mounted linear polarizers" | stated | Slit on a thin plate held in a square black holder on an XY translation/tilt mount, mid-bench. Two small linear-polarizer films/pieces glued/mounted over the slits at 0° (A) and 90° (B). For the game: slit plate ~25 mm square, slit length several mm. |
| Lens (second) | "Lens" pill in photo (after double slit) | stated in photo only; focal length not given | Ø1" plano-convex lens in a mount on a post a few cm after the slit (assumed to image/condition the pattern onto the scanning plane). |
| Polarizer P1 | "Mounted linear polarizers"; "Polarizer P1" pill; green square in diagram on motor M1 | stated | Ø1" linear polarizer in a (motorised, M1) rotation mount on a post; mounted so its angle can be set to 0/90/±45°. |
| Single slit (scanning) | "Adjustable slit (placed near 200μm)" | stated | Adjustable mechanical slit (two blades, micrometer) on the detection stage, in front of the fibre coupler/detector. |
| Detection stage / actuator | "Dectection stage" pill; "an actuator was moved along the beam" | stated | Motorised linear translation stage (stepper actuator, ~25 mm travel) moving the single slit + fibre collimator transversely (vertical y in the schematic, horizontal across the table in practice); grey control cables. |
| Detector D1 | "Single photon detection module" | stated | SPCM (e.g. Excelitas-style module, ~ 90 × 90 × 30 mm) fed by a multimode fibre from the stage; the two **red boxes** at the back-right of the photo are the detection/counting electronics. |
| BBO crystals | "Two thin BBO crystals of type 1 placed at 90°" | stated in list, absent from diagram/photo path | Not used in this experiment's beam path (inherited list entry); omit from the scene or leave in a drawer. |
| Cabling, power strip, controller boxes | visible in photo | — | Power strip on the back edge; a small black controller box with a green display (stage/laser driver); white/grey/black cable bundles; blue hose at left; brown envelope top-right (set dressing). |

Schematic-style assets (for the 2D/narrated view): salmon laser box, hatched grey polarizer circles with angle text, three-segment dark slit bar, lavender P1 circle with rotate arrow, salmon D1 screen with y axis, dashed Ψ0…Ψ3 state planes.

## Teaching notes
Prerequisites, in the order the page needs them:
1. **Polarization as a 2-D vector / ket** (Experiment 1): H/V basis, diagonal states, polarizer as a projection; Malus-type reasoning via inner products. Needed at Step 2 and in "Choosing a basis".
2. **Position/path kets and superposition** (Experiment 2): |S⟩, |A⟩, |B⟩, |y⟩; propagation phase e^{ikl}; |lost⟩ bookkeeping; amplitude → intensity by |·|².
3. **Complex numbers & phases**: e^{ika}, e^{ikb}, |e^{iφ}| = 1, |e^{ika}+e^{ikb}|² = 2(1+cos kΔ). Needed for E7, E11 and the table.
4. **Tensor product (composite systems)**: introduced informally as "list them side by side" — |↗↙⟩|S⟩; distributivity over sums (E3); operators acting on one factor only (E4). This is the page's main new idea.
5. **Orthogonality kills cross terms**: |A_1|↔⟩|y⟩ + A_2|↕⟩|y⟩|² = |A_1|² + |A_2|² because ⟨↔|↕⟩ = 0 (E7). Pythagoras in Hilbert space.
6. **Change of basis**: the same vector written in H/V or D/A basis (E10 vs E11); a projector (P1) selects one component; which component depends on the basis you measure in.
7. **Diffraction envelope** sinc²(α), α = πw sin θ/λ (E8), and double-slit cos² factor; sum rule I(45°)+I(−45°) = envelope.

Pedagogical moves used by the site:
- Builds on the two previous experiments explicitly ("This experiment combines the previous two").
- States the observation first (bullets: 0°/90° → no interference; ±45° → interference), then "Why does this happen?" in words (which-way information, tagging, erasing), then the maths.
- Explicit contrast: tagging with polarizers vs placing a detector at a slit (which would absorb the photon) — introduces the idea of gentle, non-destructive interaction; teases Experiment 4.
- Step-numbered derivation (Step 0 … Step 4) with a figure marking Ψ0…Ψ3 planes on the apparatus, and a sentence after every algebra block explaining what was done on each line.
- Keeps "lost" terms explicitly to reassure the learner that probability is conserved.
- Under-brace labelling of amplitudes A1, A2 before squaring.
- The "key insight: the same state can be written in different bases" framing; a four-row table summarising what P1 selects.
- Closing conceptual summary: "The third polarizer does not create or destroy photons. It picks a decomposition."
- Honest about imperfections in the data (phase offset to be fixed in Experiment 4), and the complementary-pairs sum rule is checked against data (45° + −45° = envelope; 0° + 90° = envelope).

## Open questions
- p.9–10: the paragraph beginning "Why are the two diagonal plots inverted? There are two explanations. First, …" is printed overlapping the start of the Theory section; the reconstructed continuation ("polarizers block a portion of the photons. Perpendicular polarizers block complementary portions, so summing them recovers all the photons.") is a best reading, and the announced *second* explanation is not identifiable.
- The "Literature and video" and "Similar Experiments" sections carry no content on the printed page (the "Similar Experiments" heading is followed only by the closing theory sentence).
- The equipment list includes BBO crystals that are not in this experiment's optical path; and the setup diagram omits the second lens and the adjustable single slit that appear in the photo/list.
- Lens part number printed "LA-1908-B" (likely Thorlabs LA1908-B, f = 500 mm).
- Slit-to-detector distance L, actuator step size, and the second lens focal length are not given (L ≈ 0.7 m proposed from the measured fringe spacing).
- The data columns description says "the angles of the polarizers, but only P1 is used" — it is unclear whether column 2 is PA/PB or an unused second polarizer channel.
- The "phase offset in our polarization setup" is acknowledged but not quantified; the 45° plot's theory curve is visibly misaligned with the data.
- The StackBlitz embed (react-vazdln-ns7pyb by vmonette) did not render in the print, so the exact simulator controls (slit width/separation ranges, polarizer handle behaviour) are inferred from the description only.
- The site's "Pattern = ½ (sin α/α)²" envelope formula ignores the slight lateral shift between the two single-slit envelopes that the 0°/90° data clearly show; a simulator wanting to match the data should centre each slit's envelope on its own slit.
