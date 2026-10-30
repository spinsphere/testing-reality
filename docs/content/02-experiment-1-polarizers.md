# Experiment 1: Polarizers and the three-polarizer paradox
Source: `D-Experiment 1 _ Polarizers.pdf`; URL in footer: https://testing-reality.webflow.io/experiment-1 ; 30 pages (printed 30/10/2026, 20:49).

Site header on every page: "Testing Reality" logo (left), nav links "Experiments" / "About" (right). Footer: "Made in Webflow" badge, URL, page N/30. Page 30 carries the site footer "Testing Reality © 2018-2026 — Creative commons (CC BY NC icons)". All of that is print chrome and is omitted below.

## Page summary
This is the first of the site's experiments. It introduces polarization as a quantum property of a single photon (a 2-dimensional state vector with basis |↔⟩, |↕⟩, plus the diagonal states |↗↙⟩ and |↘↖⟩), and introduces the polarizer as a *linear operator* that either passes a photon (projecting its state onto the polarizer axis) or sends it to a bookkeeping state |lost⟩. The experiment is the classic "three-polarizer paradox": a horizontal polarizer followed by a vertical polarizer blocks everything (0%), but inserting a third polarizer at 45° *between* them lets 12.5% of the light through. The site shows the lab measurement (single-photon counting on a 405 nm diode-laser beam prepared at 45°: 1159 counts/s with no polarizer, 616 with one at 0°, 439 with two crossed, 564 with three), then derives the predictions 100% / 50% / 0% / 12.5% step by step with kets, the |lost⟩ trick, and the change of basis |↔⟩ = (|↗↙⟩ + |↘↖⟩)/√2. The punchline: a polarizer does not merely filter, it *changes the state* (rotates the polarization), and intensities follow from the Born rule applied only at the end.

## Content (in page order)

The left-hand "TABLE OF CONTENT" (page 2) lists: **Abstract · Lab Experiments · Result and analysis · Theory and equations · Literature and video**. The actual on-page headings are slightly different and are used below.

---

### [p.1] Title block
- Kicker: "EXPERIMENT 1"
- Title (large serif, grey): "Polarizers and the three-polarizer paradox"

---

### [p.2–7] Abstract

**Heading (purple serif): "Abstract"**

Prose [p.2]:
> This first experiment is called the three-polarizer paradox. It's not a true paradox—quantum mechanics predicts the result exactly—but the outcome is surprising enough to challenge our classical intuition. Place two polarizers at 90° to each other: no light passes. Now insert a third polarizer at 45° between them: suddenly 12.5% of the light passes through. How can adding a filter *increase* transmission? To resolve the paradox, we will apply the ideas covered in the Introduction—states as kets, evolution via linear operators, and the Born rule for measurement outcomes—to a concrete physical property, the polarization of light.

("Introduction" is a red hyperlink to the Introduction page.)

**Sub-heading: "What are polarizers?"** [p.2]

> As light propagates, its electric field oscillates perpendicular to the direction of travel. The axis of this oscillation is the light's *polarization*. A photon can be polarized vertically, horizontally, or at any angle in between.
>
> In the language of quantum mechanics, polarization is a quantum property described by a state vector. Two natural basis states are:

Equation E1 [p.3] (inline, two kets side by side):
$$\ket{\updownarrow}\ \text{(vertical)}\qquad\text{and}\qquad \ket{\leftrightarrow}\ \text{(horizontal)}$$

> These states are orthogonal—a detector can distinguish them with certainty. But a photon can also exist in a superposition, such as the diagonal polarization:

Equation E2 [p.3]:
$$\ket{\nearrow\!\!\!\swarrow} = \frac{1}{\sqrt2}\ket{\leftrightarrow} + \frac{1}{\sqrt2}\ket{\updownarrow}$$
(Site notation: the diagonal ket is written with a double-headed diagonal arrow |↗↙⟩; written below as |↗↙⟩.)

> This is exactly the kind of linear combination we studied in the Introduction.

**Figure [p.4] — "Three examples of natural basis states."**
Style: flat 2D vector diagram on a very light blue-grey rounded card. Three arrows from a common origin at bottom-left:
- Vertical arrow, purple (#6A4FD8-ish), pointing straight up, labelled "|↕⟩" in purple at its tip.
- Diagonal arrow, black/dark navy, at exactly 45°, labelled "|↗⟩" (single-headed up-right arrow inside the ket) in black.
- Horizontal arrow, red-orange (#F04E3E-ish), pointing right, labelled "|↔⟩" in red at its tip.
All three arrows have the same length (unit vectors). No axes, no grid, no tick marks. Caption below in italics: "Three examples of natural basis states."
Colour convention established here and reused throughout the site's schematics: **vertical = purple, horizontal = red/orange, diagonal = black**.

**Sub-heading: "What are Polarizers?"** [p.5] (repeated heading, capital P this time)

> A polarizer is an optical device that transmits light polarized along its axis and blocks light polarized perpendicular to it. Mathematically, a polarizer acts as a *linear operator* on the photon's quantum state—much like the transformation R₄₅ from the Introduction, but with a key difference: polarizers can *lose* photons.
>
> The transmission probability follows from the amplitudes:
> - If the photon's polarization is aligned with the polarizer (e.g., both horizontal), it passes with probability 1.
> - If perpendicular (one vertical, one horizontal), it passes with probability 0.
> - At 45° misalignment, the probability is cos²(45°) = ½.
>
> Crucially, the photon that emerges is now polarized along the polarizer's axis—the polarizer has *changed* the quantum state, not merely filtered it.

Equation E3 (inline in the bullet): $$\cos^2(45^\circ) = \tfrac12$$

**Sub-heading: "Try it yourself!"** [p.5–6]

**Embed [p.5–6] — interactive simulator (CodeSandbox).** Header bar reads "react-vazdln-h798ez created by vmonette" with a "Run this project" button; the iframe body itself printed blank (only a scrollbar is visible on p.5). Description text under it:

> Explore how light behaves under different polarizer configurations. The simulation starts with a diagonally polarized laser beam (45°). Use the control panel to add polarizers and drag the pink dot to adjust their orientation. The percentage on the right shows how much light reaches the detector relative to the original beam: 100% means nothing is blocked, 0% means complete darkness.

So the simulator: a React app (CodeSandbox id `react-vazdln-h798ez`, author `vmonette`); controls = "add polarizer" buttons in a control panel, a draggable pink dot per polarizer to set its angle; output = a percentage of transmitted light at the detector, relative to the 45°-polarized source beam.

**Sub-heading (serif): The three polarizer "paradox"** [p.6]

> Here is the puzzle:
> - Place a horizontal polarizer followed by a vertical polarizer. Result: **0% transmission**. Their axes are 90° apart, so the second blocks everything from the first.
> - Now insert a 45° polarizer *between* them. Result: **12.5% transmission**.
>
> Adding a third filter lets light through. This defies classical intuition—more obstacles should mean less transmission, not more. Are we somehow creating photons?
>
> We'll derive the 12.5% result exactly in the Quantum Predictions for the 3-Polarizers Paradox, using the operator formalism. The resolution lies in how polarizers transform quantum states—but first, let's confirm this effect is real. For more on the 3-polarizer paradox, have a look at this brief video:

("Quantum Predictions for the 3-Polarizers Paradox" is a red in-page link to the section of that name.)

**Embed [p.7] — YouTube video.** Title "3 Polarizing Filters", channel "UMD Physics Videos!" (University of Maryland physics demo). Standard YouTube thumbnail frame with red play button and "Watch on [YouTube]" link; the thumbnail image itself printed blank/white.

---

### [p.8–9] In the laboratory

**Figure [p.8] — summary schematic above the results table** (site's "setup" column art; light blue-grey card). Three (visible) horizontal rows, each a left-to-right beam line:
- Row 1: `LASER` (pink/salmon rounded rectangle with a small nozzle on its right side, label "LASER" in a pink pill below) → grey hatched circle (the 45° preparation element: diagonal grey hatching, no label) → long red beam line → `D1` (tall pink rectangle, label "D1" in pink pill). Result printed at far right in large grey bold: **100%**.
- Row 2: LASER → grey hatched circle → purple circle with **horizontal** hatching labelled "0°" inside and "P1" in a lilac pill below → beam → D1. Result: **50%**.
- Row 3: LASER → grey hatched circle → purple circle "0°" (horizontal hatching, "P1") → beam → purple circle with **vertical** hatching labelled "90°" ("P2") → D1. Result: **0%**.
- Dashed vertical grey lines mark the planes: after the preparation element, after P1, after P2, and before D1.
- A **fourth row** (3 polarizers → 12.5%) is clearly part of the same graphic: its labels "LASER", "P1", "P2", "P3", "D1" and the state markers "Ψ0 Ψ1 Ψ2 Ψ3" bleed through the table header on p.8, but the row itself is hidden under the table in the print. The same 4-row graphic appears as the Experiment-1 card thumbnail on p.30 (see below), where it is fully visible.

Hatching convention for polarizer icons: horizontal lines = 0° (horizontal) polarizer; vertical lines = 90° (vertical) polarizer; diagonal lines = 45° polarizer. Preparation element = grey circle with diagonal hatching (the 45° filter at the laser).

**Heading (serif): "In the laboratory"** [p.8]

> We set up the experiment in a laboratory and measured the light intensity at the detector. The gist of the data is represented in the below table, which displays how the transmitted light intensity changes depending on the number and orientation of the polarizers.
>
> This table was made using the data we collected in the lab. The column "lab result'' is the number of photons detected in the center of the beam (which gives the highest number of photons). The intensity is a comparison with the initial beam. We always considered the initial beam (with no optical devices) to be 100%.

**Table [p.8] — lab results vs theory** (verified on a 220-dpi render; the print has body text overlapping the rows but every value is legible):

| Setup | Lab results: number of photons per second | Lab results: relative % | Theoretical results: relative % |
|---|---|---|---|
| No polarizers | 1159 | 100% | 100% |
| 1 polarizer (45°) | 1159 | 100% | 100% |
| 1 polarizer (22.5°) | 884 | 67.1% | ~85% |
| 1 polarizer (0°) | 616 | 35.1% | 50% |
| 1 polarizer (−45°) | 322 | 0% | 0% |
| 2 polarizers | 439 | 14.0% | 0% |
| 3 polarizers | 564 | 28.9% | 12.5% |

Column headers as printed: "Setup" | "Lab results" (spanning "Number of photons per seconds" and "Relative %") | "Theoretical results" ("Relative %").

Check of the site's normalisation (relative % = (N − 322)/(1159 − 322)): 884 → 67.1% ✓; 616 → 35.1% ✓; 439 → 14.0% ✓; 564 → 28.9% ✓. So the "relative %" column is background-subtracted with 322 counts/s treated as the dark/background level and 1159 as 100%.

**Italic note [p.9]** (printed on top of the next paragraph; reconstructed from the text layer; the identical note is repeated on p.17):

> *Note: The percentage on the lab results are calculated by removing the background noise (of 322 photons) and comparing to the maximum value (1159 photons). Because the data is taken from a different setup, it is very hard to compare them together. A small reflection of a polarizer or a different background can results in big change. That is why the data doesn't really fit the theoretical results.*

Prose [p.9]:

> The first line is the result with nothing in the way of the laser. The next four values are measured with 1 polarizer, placed at different angles compared to the initial beam. We see the number of photons change for all four angles. Because the incident beam is at 45 degrees, all the photons pass.
>
> We consider this value to be 100%. At −45 degrees, no photon should be able to pass. But, we can still detect some photons, which can come from different sources in the lab, any light coming from an instrument or misread on the detector. We place its relative value at 0%.

---

### [p.9–11] Lab Experiment

**Heading (purple serif): "Lab Experiment"** [p.9]

> Curious of what an entanglement optical setup looks like? Here is a few picture of what we have:

(Sic — the sentence says "entanglement" although this is the polarizer experiment; the wording is probably copied from the entanglement page.)

**Figure [p.10, upper] — lab photograph** (colour photo, landscape, taken from above/behind the laser end looking down the optical table toward the detector; the beam runs from top-left to bottom-right of the photo). Elements with their purple label pills, in beam order:
1. **"Laser"** — at the far end (top of photo), a small black cylindrical/boxy module on a post, with white and blue cables; behind it a black electronics box (driver) and a tall black vertical plate (optical post/enclosure) at the back edge of the table.
2. **"Beam splitter"** — immediately after the laser: a black cube mount on a post (the polarizing beam-splitter cube; the beam-dump port is not visible).
3. **"Lens"** — a lens in a round black mount on a post (lens L1).
4. **"P1"** — a polarizer in a large round black rotation mount (graduated ring) on a post.
5. **"P2"** — a second identical rotation mount with polarizer, on a post.
6. **"Lens"** — second lens (blue-coated, in a round mount) on a post.
7. **"P3"** — third polarizer; in the photo it is a lens-tube-style mount on a red circuit board / red adapter plate, on a black post holder (the pill "P3" sits beside it).
8. **"Detector"** — at the near end (bottom-right): a red PCB module (single-photon detection module) in a black housing on a post, with a grey ribbon cable, a black BNC/coax lead, and white USB-style cables; next to it a small silver cylindrical component.
Environment: a steel optical breadboard with a regular grid of M6 tapped holes, black background on the left (dark lab wall/curtain), white wall on the right; cables (white, black) lie loose on the table.

**Figure [p.10, lower] — schematic "Technical set-up"** (hand-drawn-style line schematic, white background, red beam line). Left to right:
- `LASER` (grey rectangle, label inside) → red beam →
- `BS` (square drawn with a diagonal line = cube beam splitter; label "BS" below). A red line goes **up** from the cube to a small black trapezoid labelled `BD` (beam dump) — the rejected polarization exits the top port and is dumped.
- `λ/2` — a thin tall **magenta/purple** vertical bar (half-wave plate), label "λ/2" above.
- Lens — a biconvex lens outline, label below "**L1 = 50cm**" (focal length 50 cm).
- `P1`, `P2`, `P3` — three identical light-blue/teal rectangles (polarizers), labels inside.
- `D1` — dark grey square with a small nozzle on its left (detector), label inside.
- A partially cut-off caption box above the schematic reads "L_ : Plano convex lens" (truncated in print; [unclear: exact text]).

**Heading (serif): "Technical set-up and Equipment"** [p.10]

> Here is the representation of the setup you see in the picture. All of the equipment is shown, but the scaling is not representative.

Prose [p.11]:

> On the left side, the laser emits a beam of photons. We then place a polarizing beam splitter to rotate the polarization of the beam at 45 degrees. Depending of the orientation of the beam splitter, you might not get 45 degrees, so you can add a half-wave plate to rotate it in the orientation you want: 45 degrees for us. Then, a set of lenses can be use to concentrate the beam in the detector. The beam is now set to pass through all the polarizers we want. We tested with 0, 1, 2 and 3 polarizers. Finally, on the right-side, the detector is placed at the center of the beam.

**Sub-heading (serif): "Equipment list"** [p.11]

**Table [p.11]** (the "Name" cells are red hyperlinks, presumably to vendor pages):

| Name | Description |
|---|---|
| LASER | Diode laser (405nm) |
| Polarizers | Mounted linear polarizers |
| Lenses | Plano-convex lenses kit |
| Beam splitter | A cube polarizing beam splitter |
| Detectors | Single photon detection module |

Italic note [p.11]:

> *Note: for this experiment, we use high quality equipment, because it will be needed for the future experiment. This experiment could be very easy and cheap to realise for classes or at home. Any laser in visible light will work, any polarizers would do and no detector are needed if you don't want to measure the number of photon. A white paper would be enough to see the different intensity.*

---

### [p.12] Result and analysis

**Heading (purple serif): "Result and analysis"**

**Sub-heading (serif): "Raw data"**

> You can download all our data here:

Downloads (three CSV download chips, each with a red file icon):
- `Data_1polarizer.csv`
- `Data_2polarizer.csv`
- `Data_3polarizer.csv`

> The pattern is created by moving the detector one side of the laser beam, to the other. At each step of the detetor, we count the number of photons captured in the time allowed (generally 1 or 2 seconds).
>
> All of the acquisition can be found in those csv. They all have 3 columns: the position of the detector, the angle of the polarizers and the number of photons detected.

(So each CSV is a transverse scan of the detector across the beam: columns = detector position, polarizer angle(s), photon count. The table on p.8 uses the peak = beam-centre count.)

---

### [p.12–16] More Quantum Theory: Photons (the site's "Theory and equations" section)

**Heading (purple serif): "More Quantum Theory: Photons"** [p.12]

> Quantum mechanics describes what happens to individual photons when they pass through an optical set-up like the one described above.
>
> The key property of photons to be described here is the polarization of photon.

**Sub-heading (serif): "Completing the Polarization Basis"** [p.13]

> Earlier we introduced the horizontal and vertical polarization states, |↔⟩ and |↕⟩, and the diagonal state |↗↙⟩. To complete our toolkit, we introduce the \emph{anti-diagonal} polarization:

(The raw LaTeX `\emph{...}` is printed literally on the site — a rendering bug, twice on p.13–14.)

Equation E4 [p.13]:
$$\ket{\nwarrow\!\!\!\searrow} = \frac{1}{\sqrt2}\left(\ket{\leftrightarrow} - \ket{\updownarrow}\right).$$
(Site notation |↘↖⟩ for the anti-diagonal ket.)

> The states |↗↙⟩ and |↘↖⟩ form an alternative orthogonal basis—just as valid as {|↔⟩, |↕⟩}. We will need this basis in Part~3 when computing the action of a diagonal polarizer.

(The literal "Part~3" tilde is printed on the site.)

**Sub-heading (serif): "Evolution: Polarizers"** [p.13]

> The quantum state of the photon evolves when light passes through a polarizer. A horizontal polarizer, denoted as P↔, allows horizontally polarized photons to pass through, and it absorbs or reflects the vertically polarized photons. When the polarizer absorbs or reflects a photon, the photon is basically lost. Thus, the evolution of a photon passing through a horizontal polarizer is as follows:

Equation E5 [p.13]:
$$P_{\leftrightarrow}\ket{\leftrightarrow} = \ket{\leftrightarrow} \qquad\text{and}\qquad P_{\leftrightarrow}\ket{\updownarrow} = \ket{\text{lost}}.$$

> In other words, when the evolution operator P↔ acts on the state, it returns the state |↔⟩; and when it acts on the state |↕⟩, it returns |lost⟩.

Prose [p.14]:

> The term~|lost⟩ does not represent a polarization state, but rather the state of the photon's availability. It indicates that the photon won't interact with our detector because it has been absorbed or reflected by the polarizer.
>
> We keep track of these lost photons by defining a state called |lost⟩. This maintains a complete mathematical description and keeps the overall state normalized. We bear in mind, however, that a photon in the |lost⟩ state will not be used in any further calculations: the photon has effectively been \emph{lost}.
>
> Similarly, a vertical polarizer applied to a vertically polarized photon lets it through, or mathematically, P↕|↕⟩ = |↕⟩. And a vertical polarizer applied to a horizontally polarized photon gets it lost, P↕|↔⟩ = |lost⟩.

Equation E6 [p.14] (inline):
$$P_{\updownarrow}\ket{\updownarrow} = \ket{\updownarrow}, \qquad P_{\updownarrow}\ket{\leftrightarrow} = \ket{\text{lost}}.$$

**Figure [p.15] — "Effects of horizontal and vertical slits."** (illustration on a light blue-grey card; drawn in the style of a classic textbook picture of a polarizer as a slotted plate). Two scenes, stacked, each with the wave travelling from lower-left to upper-right along a faint dotted grey axis:
- **Top scene:** an incoming wave drawn as two superimposed sinusoids — one **red** oscillating in the horizontal plane and one **purple/magenta** oscillating in the vertical plane (i.e. unpolarized / both components). It hits a square black-outlined plate containing a **horizontal slot** (a thin wide black rectangle). After the plate only the **red horizontal** sinusoid continues (the purple vertical component is removed). → Horizontal polarizer passes horizontal polarization.
- **Bottom scene:** the same red+purple incoming wave hits a square plate with a **vertical slot** (thin tall black rectangle). After the plate only the **purple vertical** sinusoid continues. → Vertical polarizer passes vertical polarization.
Caption (italic): "Effects of horizontal and vertical slits." (The site calls the polarizer axis a "slit" here — the slotted-plate analogy.)

Prose [p.15]:

> We have carefully specified what happens to horizontally and vertically polarized photons when they go through filters.
>
> But what happens to a diagonally polarized photon, like |↗↙⟩, when it passes through a horizontal filter?

Prose [p.16]:

> Recalling the evolution of quantum states in the Introduction, we use the linearity property of the evolution operator P↔:

Equation E7 [p.16]:
$$\begin{aligned}
P_{\leftrightarrow}\ket{\nearrow\!\!\!\swarrow} &= P_{\leftrightarrow}\,\frac{1}{\sqrt2}\left(\ket{\leftrightarrow}+\ket{\updownarrow}\right)\\
&= \frac{1}{\sqrt2}\left(P_{\leftrightarrow}\ket{\leftrightarrow} + P_{\leftrightarrow}\ket{\updownarrow}\right)\\
&= \frac{1}{\sqrt2}\left(\ket{\leftrightarrow} + \ket{\text{lost}}\right).
\end{aligned}$$

**Sub-heading (serif): "Measurement: Beam Intensity"** [p.16]

> If this is the quantum state of the photon that reaches the detector, we can calculate the probability that the photon hits the detector. It's the probability that the photon is not lost, or in other words, it's the probability that a measurement of {|↔⟩, |lost⟩} returns |↔⟩. This probability is given by the square of the amplitude pertaining to the component~|↔⟩ in the expression above.

Equation E8 [p.16]:
$$\text{Probability of detection} = \left(\frac{1}{\sqrt2}\right)^2 = \frac12.$$

> The intensity of a beam of light is proportional to the number of photons in that beam: the more photons, the more intense the light is.
>
> If we send a beam of light, composed of multiple photons, and if each photon has a 50% chance of passing through, then the intensity of the outgoing beam shall be half that of the incoming beam. [continues p.17]
>
> In general, the intensity of the measured beam (I) is equal to the probability of measuring a single photon multiplied by the intensity of the incoming beam:

Equation E9 [p.17]:
$$I = \text{Prob}\cdot I_0\,.$$

---

### [p.17–29] Quantum Predictions for the 3-Polarizers Paradox

**Heading (purple serif): "Quantum Predictions for the 3-Polarizers Paradox"** [p.17] (printed overlapping the end of the previous section).

> We are now equipped to compute what quantum theory predicts in various scenarios. In four parts, we will study the optical set up with no polarizer, one, two and then three polarizers.

(The italic *Note: The percentage on the lab results…* paragraph from p.9 is printed a second time here, overlapping the "Part 0" text; same wording as above.)

**Sub-heading (serif): "Part 0: No Polarizer"** [p.17]

> Let us consider first the simplest scenario, where a prepared photon propagates freely to the detector without encountering any polarizers. (In fact, because we wanted to prepare diagonally polarized photons, we inserted a diagonal filter right at the laser; but this simply amounts to a laser that emits diagonaly polarized photon.) See the below figure.

**Figure [p.18] — "A diagonally prepared photon, no polarizers and a detector."** Light blue-grey card. Left to right: `LASER` (pink rounded rectangle with nozzle, pink pill label "LASER") → grey circle with diagonal hatching (the diagonal preparation filter, unlabelled) → a dashed vertical grey line labelled **Ψ₀** below (large grey bold "Ψ" with subscript 0) → long thin red beam line → `D1` (tall pink rectangle, pill label "D1"). Nothing else on the line.

Prose [p.18]:

> After the photon exits the laser (and the diagonal polarizer), it is prepared in a diagonal state of polarization:

Equation E10 [p.18]:
$$\ket{\psi_0} = \ket{\nearrow\!\!\!\swarrow}\,.$$

> No polarizer affects the photon, so it propagates freely to the right end of the optical table. [p.19:] Since no component of its quantum state is lost, it will be detected regardless of its polarization state.
>
> The measured intensity is, therefore, the whole of the incoming intensity:

Equation E11 [p.19]:
$$I = 100\%\cdot I_0\,.$$

**Sub-heading (serif): "Part 1: One Horizontal Polarizer"** [p.19]

> In this scenario, we have added a horizontal polarizer between the locations of preparation and detection, see the below figure. This scenario corresponds to what we have studied in the previous section.
>
> The initial state is given by

**Figure [p.20] — one-polarizer schematic.** Same card style. Left to right: `LASER` + grey diagonal-hatched preparation circle → dashed line, **Ψ₀** → purple circle with **horizontal hatching**, text "0°" inside, lilac pill "P1" below → dashed line, **Ψ₁** → long red beam → detector: tall pink rectangle with "Ψ₁" printed inside it, pill "D1" below.
Caption (italic): "A diagonally prepared photon passes through a horizontal polarizer before being detected. We denote the prepared state by |ψ₀⟩, which can be interpreted as the state at some time t₀, and we denote the state after the horizontal polarizer by |ψ₁⟩, the state at time t₁."

Equation E12 [p.20]:
$$\ket{\psi_0} = \ket{\nearrow\!\!\!\swarrow}$$

> The state |ψ₁⟩ can be computed by applying the horizontal polarizer, P↔, as we did before:

Equation E13 [p.21]:
$$\begin{aligned}
\ket{\psi_1} &= P_{\leftrightarrow}\ket{\psi_0}\\
&= P_{\leftrightarrow}\ket{\nearrow\!\!\!\swarrow}\\
&= P_{\leftrightarrow}\,\frac{1}{\sqrt2}\left(\ket{\leftrightarrow}+\ket{\updownarrow}\right)\\
&= \frac{1}{\sqrt2}\ket{\leftrightarrow} + \frac{1}{\sqrt2}\ket{\text{lost}}\,.
\end{aligned}$$

> The intensity at the detector is, as we have seen previously,

Equation E14 [p.21]:
$$\begin{aligned}
I &= \left(\frac{1}{\sqrt2}\right)^2\cdot I_0\\
&= 50\%\cdot I_0\,.
\end{aligned}$$

**Sub-heading (serif): "Part 2: Two Polarizers, Horizontal \& Vertical"** [p.21] (literal "\&" printed on the site)

**Figure [p.22] — two-polarizer schematic.** `LASER` + grey diagonal-hatched circle → dashed line **Ψ₀** → purple circle, horizontal hatching, "0°", pill "P1" → dashed line **Ψ₁** → long red beam → purple circle, **vertical** hatching, "90°", pill "P2" → dashed line **Ψ₂** → detector (pink rectangle with "Ψ₂" inside, pill "D1").
Caption (italic): "The optical set-up here consists of the preparation, a horizontal polarizer, a vertical polarizer and a detector."

> We now consider the insertion of a vertical polarizer as depicted in the above figure.
>
> Again, the initial state is given by |ψ₀⟩ = |↗↙⟩.
>
> Applying the first (horizontal) polarizer, we obtain

Equation E15 [p.23]:
$$\begin{aligned}
\ket{\psi_1} &= P_{\leftrightarrow}\ket{\psi_0}\\
&= \frac{1}{\sqrt2}\ket{\leftrightarrow} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\,,
\end{aligned}$$

> where |lost_{P1}⟩ denotes a state for the photon where it has been lost at the first polarizer.
>
> Applying the second (vertical) polarizer, we find

Equation E16 [p.23]:
$$\begin{aligned}
\ket{\psi_2} &= P_{\updownarrow}\ket{\psi_1}\\
&= P_{\updownarrow}\left(\frac{1}{\sqrt2}\ket{\leftrightarrow} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\right)\\
&= \frac{1}{\sqrt2}P_{\updownarrow}\ket{\leftrightarrow} + \frac{1}{\sqrt2}P_{\updownarrow}\ket{\text{lost}_{P_1}}\\
&= \frac{1}{\sqrt2}\ket{\text{lost}_{P_2}} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\,.
\end{aligned}$$

> The probability of measuring a non-lost photon is 0. Therefore, the intensity at the detector is

Equation E17 [p.24]:
$$\begin{aligned}
I &= (0)^2\cdot I_0\\
&= 0\%\,.
\end{aligned}$$

**Sub-heading (serif): "Part 3: Three Polarizers, Horizontal, 45° & Vertical"** [p.24]

**Figure [p.24] — "The three-polarizer set-up."** `LASER` + grey diagonal-hatched circle → dashed line **Ψ₀** → purple circle, horizontal hatching, "0°", pill "P1" → dashed **Ψ₁** → purple circle with **diagonal** hatching and large "45" inside (no degree sign, no pill label — [unclear: a "P2" pill may be hidden]) → dashed **Ψ₂** → purple circle, vertical hatching, "90°", pill "P2" → dashed **Ψ₃** → detector (pink rectangle with "Ψ₃" inside, pill "D1").
Note the label inconsistency: in this figure the vertical polarizer is labelled P2 while the text calls the 45° element the second polarizer (P2) and the vertical one the third (P3, |lost_{P3}⟩). In the p.8/p.30 four-row graphic the three are labelled P1, P2, P3 in beam order.

> We now consider the final optical set-up, where a polarizer oriented at 45° is inserted between the horizontal and vertical polarizers. See the above figure.

**Figure [p.25] — "Reconstructing |↔⟩ from |↗↙⟩ and |↘↖⟩."** Black-on-white hand-drawn-style vector diagram (looks like a scanned/whiteboard image, slightly blurry). A right-angled triangle made of three arrows:
- Arrow 1 from bottom-left corner up-right at 45° to the apex, labelled "|↗↙⟩" (underlined) to its left.
- Arrow 2 from the apex down-right at −45° to the bottom-right corner, labelled "|↘↖⟩" (underlined) to its right.
- Arrow 3 along the base from bottom-left to bottom-right (horizontal), unlabelled = the resultant.
- A small square drawn at the apex marks the 90° angle between the two diagonal vectors.
Below the triangle, a large hand-written-style equation:
$$\ket{\leftrightarrow} = \frac{\ket{\nearrow\!\!\!\swarrow} + \ket{\nwarrow\!\!\!\searrow}}{\sqrt2}$$
Caption (italic): "Reconstructing |↔⟩ from |↗↙⟩ and |↘↖⟩."

Prose [p.26]:

> As we have seen before, the initial state~|ψ₀⟩ = |↗↙⟩ evolves into |ψ₁⟩ = (1/√2)|↔⟩ + (1/√2)|lost_{P1}⟩.
>
> Then, between time t₁ and t₂, a diagonal polarizer is applied:

Equation E18 [p.26]:
$$\begin{aligned}
\ket{\psi_2} &= P_{\nearrow\!\!\!\swarrow}\ket{\psi_1}\\
&= P_{\nearrow\!\!\!\swarrow}\left(\frac{1}{\sqrt2}\ket{\leftrightarrow} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\right)\\
&= \frac{1}{\sqrt2}P_{\nearrow\!\!\!\swarrow}\ket{\leftrightarrow} + \frac{1}{\sqrt2}P_{\nearrow\!\!\!\swarrow}\ket{\text{lost}_{P_1}}\,.
\end{aligned}$$

> How do we carry on with this calculation? The second term is easy to compute: P↗↙ applied to a previously lost photon keeps the photon lost, so P↗↙|lost_{P1}⟩ = |lost_{P1}⟩. But how do we compute P↗↙|↔⟩? The key is to express the state |↔⟩ in terms of the vectors |↗↙⟩ and |↘↖⟩. Consider what happens when we sum |↗↙⟩ and |↘↖⟩:

Equation E19 [p.27] (laid out as a column addition with a rule under the second line):
$$\begin{aligned}
\ket{\nearrow\!\!\!\swarrow} &= \tfrac{1}{\sqrt2}\ket{\leftrightarrow} + \tfrac{1}{\sqrt2}\ket{\updownarrow}\\
+\ \ket{\nwarrow\!\!\!\searrow} &= \tfrac{1}{\sqrt2}\ket{\leftrightarrow} - \tfrac{1}{\sqrt2}\ket{\updownarrow}\\
\hline
\ket{\nearrow\!\!\!\swarrow} + \ket{\nwarrow\!\!\!\searrow} &= \tfrac{2}{\sqrt2}\ket{\leftrightarrow}
\end{aligned}$$

> The resulting state is not normalized, but by multiplying each side of the above equation by 1/√2, we obtain

Equation E20 [p.27]:
$$\ket{\leftrightarrow} = \frac{\ket{\nearrow\!\!\!\swarrow} + \ket{\nwarrow\!\!\!\searrow}}{\sqrt2}\,.$$

> By the same logic, subtracting the diagonal states gives the vertical state:

Equation E21 [p.28]:
$$\ket{\updownarrow} = \frac{\ket{\nearrow\!\!\!\swarrow} - \ket{\nwarrow\!\!\!\searrow}}{\sqrt2}\,.$$

> Applying P↗↙ to |↗↙⟩ leaves it as |↗↙⟩, while applying P↗↙ to |↘↖⟩ makes the photon |lost⟩. Therefore, going back to equation to our previous equation for |ψ₂⟩ we have,

Equation E22 [p.28]:
$$\begin{aligned}
\ket{\psi_2} &= \frac{1}{\sqrt2}P_{\nearrow\!\!\!\swarrow}\ket{\leftrightarrow} + \frac{1}{\sqrt2}P_{\nearrow\!\!\!\swarrow}\ket{\text{lost}_{P_1}}\\
&= \frac{1}{\sqrt2}P_{\nearrow\!\!\!\swarrow}\left(\frac{1}{\sqrt2}\ket{\nearrow\!\!\!\swarrow} + \frac{1}{\sqrt2}\ket{\nwarrow\!\!\!\searrow}\right) + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\\
&= \frac{1}{\sqrt2}\left(\frac{1}{\sqrt2}P_{\nearrow\!\!\!\swarrow}\ket{\nearrow\!\!\!\swarrow} + \frac{1}{\sqrt2}P_{\nearrow\!\!\!\swarrow}\ket{\nwarrow\!\!\!\searrow}\right) + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\\
&= \frac{1}{\sqrt2}\left(\frac{1}{\sqrt2}\ket{\nearrow\!\!\!\swarrow} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_2}}\right) + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\\
&= \frac12\ket{\nearrow\!\!\!\swarrow} + \frac12\ket{\text{lost}_{P_2}} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\,.
\end{aligned}$$
(The site's 3rd and 4th lines carry a stray extra closing parenthesis after |lost_{P1}⟩ — a typo on the site.)

> We then apply the third polarizer, P↕:

Equation E23 [p.29]:
$$\begin{aligned}
\ket{\psi_3} &= P_{\updownarrow}\ket{\psi_2}\\
&= \frac12 P_{\updownarrow}\ket{\nearrow\!\!\!\swarrow} + \frac12\ket{\text{lost}_{P_2}} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\\
&= \frac12\left(\frac{1}{\sqrt2}\ket{\updownarrow} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_3}}\right) + \frac12\ket{\text{lost}_{P_2}} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\\
&= \frac{1}{2\sqrt2}\ket{\updownarrow} + \frac{1}{2\sqrt2}\ket{\text{lost}_{P_3}} + \frac12\ket{\text{lost}_{P_2}} + \frac{1}{\sqrt2}\ket{\text{lost}_{P_1}}\,.
\end{aligned}$$

> The intensity at the detector is, therefore,

Equation E24 [p.29] (printed partly overlapped by the video embeds; the fraction "1/√2" bleeding vertically between the two video cards is this equation's 1/(2√2)):
$$\begin{aligned}
I &= \left(\frac{1}{2\sqrt2}\right)^2\cdot I_0\\
&= 0.125\cdot I_0\\
&= 12.5\%\cdot I_0\,.
\end{aligned}$$

Prose [p.29]:

> The "paradox" in this optical setup is the following: classically, inserting an additional filter should only make transmission less likely, not more. Yet here, adding a third polarizer—placed between two polarizers that completely block the light—allows some light to pass through.

Prose [p.30]:

> The analysis resolves this puzzle. A polarizer does more than simply block or transmit light: it changes the polarization state of the photons that pass through it. As a result, the outgoing light is effectively rotated. In quantum mechanics, this behavior is described using the notion of states and their evolution, followed—only at the end—by a measurement rule that connects these states to observed intensities.

**Table [p.30] — summary of products and results** (present in the PDF text layer; in the print it is hidden behind the "Similar Experiments" cards, so it is reconstructed from the text layer; four rows, two Product/Results column pairs):

| Product | Results | Product | Results |
|---|---|---|---|
| P↕\|↕⟩ | \|↕⟩ | P↕\|↔⟩ | \|lost⟩ |
| P↔\|↔⟩ | \|↔⟩ | P↔\|↕⟩ | \|lost⟩ |
| P↔\|↗↙⟩ | (1/√2)\|↔⟩ + (1/√2)\|lost⟩ | P↕\|↗↙⟩ | (1/√2)\|↕⟩ + (1/√2)\|lost⟩ |
| P↔\|↘↖⟩ | (1/√2)\|↔⟩ + (1/√2)\|lost⟩ | P↕\|↘↖⟩ | (1/√2)\|↕⟩ + (1/√2)\|lost⟩ |

In LaTeX:
$$\begin{aligned}
P_{\updownarrow}\ket{\updownarrow} &= \ket{\updownarrow}, & P_{\updownarrow}\ket{\leftrightarrow} &= \ket{\text{lost}},\\
P_{\leftrightarrow}\ket{\leftrightarrow} &= \ket{\leftrightarrow}, & P_{\leftrightarrow}\ket{\updownarrow} &= \ket{\text{lost}},\\
P_{\leftrightarrow}\ket{\nearrow\!\!\!\swarrow} &= \tfrac{1}{\sqrt2}\ket{\leftrightarrow} + \tfrac{1}{\sqrt2}\ket{\text{lost}}, & P_{\updownarrow}\ket{\nearrow\!\!\!\swarrow} &= \tfrac{1}{\sqrt2}\ket{\updownarrow} + \tfrac{1}{\sqrt2}\ket{\text{lost}},\\
P_{\leftrightarrow}\ket{\nwarrow\!\!\!\searrow} &= \tfrac{1}{\sqrt2}\ket{\leftrightarrow} + \tfrac{1}{\sqrt2}\ket{\text{lost}}, & P_{\updownarrow}\ket{\nwarrow\!\!\!\searrow} &= \tfrac{1}{\sqrt2}\ket{\updownarrow} + \tfrac{1}{\sqrt2}\ket{\text{lost}}.
\end{aligned}$$
(Strictly the last row should carry a minus sign on the |lost⟩ term for P↕|↘↖⟩ — the site writes "+" in all four; the sign does not affect any intensity.)

---

### [p.29] Literature and video

**Heading (serif): "Literature and video"** [p.29] (printed on top of the ψ₃ derivation)

> If you want to see the three polarizer paradox from your own eyes, here are some Youtube videos we found to be accurate and insightful!

**Embeds [p.29] — two YouTube video cards side by side** (thumbnails printed blank, only title bars and "Watch on" links visible):
1. "Three polarizing filters: a simple de…" (title truncated; probably "…a simple demonstration") by **Orion Lawlor**.
2. "3 Polarizing Filters" by **UMD Physics Videos!** (same video as on p.7).

---

### [p.30] Similar Experiments (site footer cards)

**Heading (purple serif): "Similar Experiments"** — three navigation cards:
1. **INTRODUCTION — "Quantum for everyone"**: thumbnail = the word "OVERVIEW" in black bold on a light card.
2. **EXPERIMENT 1 — "Polarizers"**: thumbnail = the four-row polarizer schematic. Rows top to bottom: (a) LASER → grey hatched circle → D1; (b) LASER → grey circle → purple polarizer "90°" P1 → D1; (c) LASER → grey circle → P1 "90°" → P2 "0°" → D1; (d) LASER → grey circle → P1 "90°" → P2 "45" (diagonal hatching) → P3 "0°" → D1; dashed state planes labelled Ψ₀, Ψ₁, Ψ₂, Ψ₃ along the bottom. **Note the thumbnail uses the opposite angle convention (first polarizer 90°, last 0°) to the in-page figures (first 0°, last 90°)** — physically equivalent.
3. **EXPERIMENT 2 — "Single and double slit"**: thumbnail = two rows: LASER → grey circle → a thick black vertical bar (slit plate, dashed) → D1; second row the same with two red rays diverging from the preparation point and reconverging on the detector; planes Ψ₀, Ψ₁ Ψ₂, Ψ₃.

Footer: "Testing Reality © 2018-2026", "Creative commons" with CC / BY / NC icons.

---

## Physics model for simulation

### State space
- One photon, one qubit of polarization, extended by bookkeeping "lost" channels. Working basis: H = |↔⟩ (horizontal, 0°), V = |↕⟩ (vertical, 90°).
- Diagonal basis: D = |↗↙⟩ = (H + V)/√2 (45°), A = |↘↖⟩ = (H − V)/√2 (−45°, anti-diagonal).
- Inverse relations (E20, E21): H = (D + A)/√2, V = (D − A)/√2.
- General linear polarization at angle θ from horizontal: |θ⟩ = cos θ |↔⟩ + sin θ |↕⟩. (Not written on the site but implied by the cos²(45°) statement and the 22.5° data row.)
- |lost⟩ (optionally tagged |lost_{P1}⟩, |lost_{P2}⟩, |lost_{P3}⟩ to remember which polarizer absorbed the photon). Lost states are orthogonal to all polarization states and to each other; any polarizer maps |lost_k⟩ → |lost_k⟩.

### Operators
Polarizer at angle α, site-style (polarization part + lost part), acting on the span{H, V, lost…}:
- P_α |α⟩ = |α⟩, P_α |α+90°⟩ = |lost⟩, P_α |lost_k⟩ = |lost_k⟩, extended by linearity.
- Equivalent "projector" form on the 2-D polarization subspace: P_α = |α⟩⟨α|; the amplitude that reaches |lost⟩ is ⟨α+90°|ψ⟩ (so norm is conserved: |⟨α|ψ⟩|² + |⟨α⊥|ψ⟩|² = ‖ψ‖²).
- Site-named operators: P↔ = P_0°, P↕ = P_90°, P↗↙ = P_45°.
- Half-wave plate (lab only, not in the ket derivation): rotates linear polarization by 2φ where φ is the fast-axis angle; used to set the beam to exactly 45° after the PBS.
- Polarizing beam splitter cube (lab only): transmits one linear polarization (H, say) and reflects the orthogonal one to the beam dump "BD"; combined with the λ/2 plate it prepares the pure 45° state |ψ₀⟩ = |↗↙⟩.

### Measurement / intensity rule
- Detector counts the photon iff it is not lost: Prob(detect) = Σ |amplitude on polarization kets|² = 1 − Σ_k |amplitude on lost_k|².
- Beam intensity I = Prob · I₀ (E9). With I₀ ↔ 1159 counts/s in the lab.
- Single-photon counting: for a game, sample Bernoulli(Prob) per photon or Poisson(rate · Prob · dt) per frame.

### Predicted intensities (every configuration on the page)
Source always |ψ₀⟩ = |↗↙⟩ (45°).

| Configuration | State at detector | Prob | Site theory % |
|---|---|---|---|
| no polarizer | \|↗↙⟩ | 1 | 100% |
| one polarizer at 45° | \|↗↙⟩ | cos²(0°) = 1 | 100% |
| one polarizer at 22.5° | cos(22.5°)\|22.5°⟩ + … | cos²(22.5°) = 0.8536 | ~85% |
| one polarizer at 0° (P↔) | (1/√2)\|↔⟩ + (1/√2)\|lost⟩ | ½ | 50% |
| one polarizer at −45° | \|lost⟩ | cos²(90°) = 0 | 0% |
| P↔ then P↕ | (1/√2)\|lost₂⟩ + (1/√2)\|lost₁⟩ | 0 | 0% |
| P↔, P↗↙, P↕ | (1/(2√2))\|↕⟩ + (1/(2√2))\|lost₃⟩ + ½\|lost₂⟩ + (1/√2)\|lost₁⟩ | (1/(2√2))² = 1/8 | 12.5% |

General n-polarizer chain, source at θ₀, polarizer angles θ₁…θ_n: Prob = Π_{k=1}^{n} cos²(θ_k − θ_{k−1}) (Malus's law chained; the site never names Malus but the kets reproduce it). E.g. 45° → 0° → 45° → 90°: ½ · ½ · ½ = ⅛.

For the on-page simulator ("drag the pink dot"): with polarizer angles set by the user, display 100 · Π cos²(Δθ_k) %, starting from the 45° source.

### Lab numbers to match
- Raw peak counts (counts per second at beam centre): none 1159; 45° 1159; 22.5° 884; 0° 616; −45° 322; two crossed (0°, 90°) 439; three (0°, 45°, 90°) 564.
- Site normalisation: relative % = (N − 322)/(1159 − 322) × 100, i.e. background = 322 counts/s (the −45° "fully blocked" row), full scale = 1159 counts/s.
- Resulting lab % vs theory: 22.5°: 67.1 vs ~85; 0°: 35.1 vs 50; two: 14.0 vs 0; three: 28.9 vs 12.5. The site explicitly says the lab data "doesn't really fit the theoretical results" because the rows come from different set-ups, stray reflections, and varying background. A faithful "lab mode" in the game could add a Poisson background of ~322 counts/s plus an imperfect-polarizer extinction (an extinction ratio of roughly 1:7 would give the 14% leakage of the crossed pair — a proposed value, not from the site).
- Integration time: "generally 1 or 2 seconds" per detector position; the CSVs are transverse scans (detector position, polarizer angle, counts).

### Parameters the site gives / leaves out
- Wavelength: 405 nm (stated). Lens L1 focal length: 50 cm (stated on the schematic). Everything else (distances between elements, beam diameter, polarizer extinction ratio, detector efficiency, dark count) is not given.
- Proposed values (assumed): element spacing ~10–15 cm on a 60×90 cm breadboard; beam diameter ~2 mm; polarizer extinction ratio 1000:1 for "ideal mode"; detector dark count ~100/s (the measured 322/s includes stray room light).

## Apparatus list (for Blender)

| Item | Site description | Stated / assumed | Approx. real-world size | Mounting (from the photo / assumed) |
|---|---|---|---|---|
| Diode laser, 405 nm (violet) | "Diode laser (405nm)" | stated | compact module ~ Ø20–30 mm × 60–100 mm, or a boxed laser head ~ 40×40×100 mm | on a post + post holder at far end of table; driver box (black, with cables) behind it (seen in photo) |
| Polarizing beam splitter cube "BS" | "A cube polarizing beam splitter" | stated | 10 mm or 20 mm cube in a black cube/platform mount | post-mounted, immediately after the laser; rejected port goes up/sideways to a beam dump |
| Beam dump "BD" | only in schematic (black trapezoid) | stated (schematic only) | small black absorber ~ 25×25×40 mm | assumed post-mounted at the BS side port |
| Half-wave plate "λ/2" | "half-wave plate to rotate it in the orientation you want: 45 degrees" | stated (schematic + text; not labelled in the photo) | Ø25.4 mm waveplate in a rotation mount | assumed in a graduated rotation mount on a post |
| Lens L1, f = 50 cm | "Plano-convex lenses kit"; "L1 = 50cm" | stated | Ø25.4 mm plano-convex, in a Ø1" lens mount | post-mounted, after the λ/2 plate ("Lens" label in photo) |
| Second lens | second "Lens" label in the photo (between P2 and P3) | stated (photo only; focal length not given) | Ø25.4 mm plano-convex (assumed f ≈ 50–100 mm, to focus onto the detector) | post-mounted round black mount, blue AR-coated glass visible |
| Polarizers P1, P2, P3 | "Mounted linear polarizers" | stated | Ø25.4 mm film/glass linear polarizers in Ø2" graduated rotation mounts (black, 360° scale) | each in a rotation mount on a post/post holder; P3 appears in a lens-tube style mount on a red adapter plate |
| Detector D1 | "Single photon detection module" | stated | red PCB ~ 50×50 mm in a black housing with a Ø1" entrance aperture / tube, ribbon + coax + USB cables | post-mounted at beam centre, near end of table; translatable across the beam for the CSV scans (translation stage assumed) |
| Optical breadboard | visible in photo | stated (photo) | steel, M6 holes on 25 mm grid; roughly 600 × 900 mm shown | on a table; black curtain/wall on one side, white wall on the other |
| Cables | white USB/power, black BNC, grey ribbon, blue laser cable | stated (photo) | — | lying loose on the table |
| Optional (text): white paper screen | "A white paper would be enough to see the different intensity" | stated as alternative to the detector | A4 sheet | hand-held / clipped |

Schematic-icon style (for the 2D Godot layer): laser = salmon rounded rectangle with nozzle; preparation filter = grey circle with diagonal hatching; polarizer = purple-outlined circle, hatched along its transmission axis (horizontal / diagonal / vertical), angle text inside ("0°", "45", "90°"), lilac pill label ("P1"…); detector = tall salmon rectangle with the state label (Ψ₁…) inside and pill "D1"; beam = thin red line; state planes = dashed grey verticals labelled Ψ₀…Ψ₃ in large grey bold.

## Teaching notes

Prerequisites, in the order the page needs them:
1. **Light as a transverse oscillation; polarization = the oscillation axis** (p.2) — the p.15 slotted-plate picture is the analogy (polarizer as a "slit" that lets one oscillation direction through).
2. **2-D vectors and unit vectors** (p.4 figure): |↔⟩ and |↕⟩ as perpendicular unit arrows; |↗↙⟩ as the 45° unit arrow.
3. **Linear combination / superposition and normalisation**: |↗↙⟩ = (|↔⟩+|↕⟩)/√2 — why 1/√2 (Pythagoras: (1/√2)² + (1/√2)² = 1).
4. **Orthogonality and "distinguishable with certainty"** (p.3).
5. **Trigonometry**: cos²(45°) = ½ (p.5); needed again for the 22.5° row (~85%).
6. **Linear operators and linearity** (p.13, p.16): define P by its action on the basis, then extend by linearity — the whole derivation is "apply the operator term by term".
7. **The |lost⟩ bookkeeping state**: keeps the state normalised and makes "absorbed" an explicit outcome instead of a non-unitary shrink (p.13–14). Tagging lost₁, lost₂, lost₃ (p.23 onward) teaches that distinct outcomes add in probability, not amplitude.
8. **Born rule**: probability = |amplitude|² of the surviving component; intensity = probability × I₀ (p.16–17). Counting photons links probability to measured intensity.
9. **Change of basis**: |↔⟩ = (|↗↙⟩+|↘↖⟩)/√2, |↕⟩ = (|↗↙⟩−|↘↖⟩)/√2 (p.25–28; the triangle picture is the geometric proof via vector addition, with the right angle marked at the apex to show D ⊥ A).
10. **Chaining operators in time**: ψ₀ → ψ₁ → ψ₂ → ψ₃ labelled by times t₀…t₃ and by dashed planes on the schematics.

Pedagogical moves the site makes:
- "Paradox" framing: state the surprising fact up front (0% → 12.5%), promise a derivation, confirm experimentally first ("let's confirm this effect is real"), then derive.
- Builds in four Parts of increasing complexity (0, 1, 2, 3 polarizers), each with its own schematic, caption, state labels Ψ_k and a boxed final intensity.
- Repeats the computation pattern verbatim each Part so the learner sees the same three steps (expand in basis → apply operator term by term → read off amplitude).
- Honest treatment of lab data: shows that raw numbers disagree with theory and explains why (background, different set-ups, reflections).
- Ends with the conceptual moral: a polarizer *rotates* the state; measurement is applied only at the end.
- Offers a cheap at-home version (any visible laser + any polarizers + white paper).

## Open questions
- **Lab table vs figure labelling**: the in-page Part-3 figure (p.24) labels the vertical polarizer "P2" and gives the 45° polarizer no pill label, whereas the text uses lost_{P1}, lost_{P2} (45°), lost_{P3} (vertical) and the p.8/p.30 graphic uses P1, P2, P3 in beam order. Recommend P1 = 0°, P2 = 45°, P3 = 90° for the game.
- **Angle convention**: p.30 thumbnail shows the chain as 90° → 45 → 0° while all in-page figures show 0° → 45 → 90°. Physically identical; pick one.
- **Hidden content on p.8**: the fourth row (3 polarizers, 12.5%) of the summary graphic is covered by the results table in the print; its labels bleed through. Visible on the p.30 thumbnail instead.
- **Hidden content on p.30**: the 4×2 "Product / Results" summary table exists only in the text layer (covered by the Similar-Experiments cards). Reconstructed from text; the site writes "+" for P↕|↘↖⟩ where "−" would be exact.
- **Truncated caption on p.10**: a box above the schematic reads "L_ : Plano convex lens" — cut off in print; presumably "L1: Plano convex lens".
- **Lab data mismatch** (acknowledged by the site): two crossed polarizers give 14% (should be 0%), three give 28.9% (should be 12.5%), 0° gives 35% (should be 50%). Do not "fix" these; present as measured, or use the theory column for the idealised simulation.
- **"1 polarizer (45°) = 1159 = 100%"** is identical to the no-polarizer row; probably the same measurement reused as the reference.
- The p.9 sentence "Curious of what an entanglement optical setup looks like?" is a copy-paste from the entanglement page.
- The simulator iframe (CodeSandbox `react-vazdln-h798ez` by vmonette) and both video thumbnails printed blank; control details beyond the description paragraph are unknown. Video 1's full title is truncated ("Three polarizing filters: a simple de…", Orion Lawlor).
- The CSV downloads (Data_1polarizer.csv, Data_2polarizer.csv, Data_3polarizer.csv) are not in this repo; column semantics are known (detector position, polarizer angle, photon count) but units and ranges are not.
- Not given anywhere: inter-element distances, beam diameter, second lens focal length, polarizer extinction ratio, detector model/efficiency, the exact λ/2 and PBS orientation. Values proposed above are assumptions.
- Rendering artefacts on the site itself (not transcription errors): literal "\emph{anti-diagonal}", "\emph{lost}", "Part~3", "state~|ψ₀⟩", "term~|lost⟩", "component~|↔⟩", "Horizontal \& Vertical"; stray ")" in two lines of E22.
