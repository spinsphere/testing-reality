# Experiment 2: Single slit and Double slit
Source: `E-Experiment 2 _ Double slit.pdf`; URL printed in the footer: https://testing-reality.webflow.io/experiment-2; 22 pages (printed 30/10/2026, page header "Experiment 2 : Double slit").

Site navigation visible on every page: "Testing Reality" logo (top left), "Experiments", "About" (top right), "Made in Webflow" badge (bottom right), footer "Testing Reality © 2018-2026 / Creative commons (CC BY-NC icons)".

Left-hand TABLE OF CONTENT (p.2): Abstract / Lab Experiments / Result and analysis / Theory and equations / Literature and video.

## Page summary
This page moves from the polarization qubit of Experiment 1 to a second quantum degree of freedom, the photon's *path*. It states the double-slit puzzle (single photons arrive as dots, thousands of dots build an interference pattern), answers it with superposition of the two path states |A⟩ and |B⟩, and lets the reader play with an interactive simulator (number of slits N, width w, separation d, wavelength λ). It then shows that the simulation is "not lying" by presenting real lab data: an 808 nm laser diode, half-wave plate + polarizing beam-splitter cube, a 50 cm plano-convex lens, an in-house double-slit mask (200-200-200 µm), and a single-photon counting module scanned across the pattern on a motorized linear actuator. Two measured plots are given (single slit with either slit covered: two offset bell curves; double slit: three main peaks with a theoretical dashed curve overlaid), with raw CSVs downloadable. The theory section explains diffraction via Heisenberg's uncertainty principle, introduces complementarity (|↕⟩ as a superposition of diagonal states), introduces the phase e^{iks}, and derives, in Dirac notation, |ψ₁⟩ = (1/√2)(|A⟩+|B⟩) → amplitudes e^{ika}, e^{ikb} at a screen point |y⟩ → I = I₀(1+cos k(b−a)) → full pattern I(θ) = 2I₀(1+cos(2πd sinθ/λ))(sin α/α)², α = πw sinθ/λ. Punchline: interference comes from how path amplitudes with different phases add, "exactly as the Introduction described for any quantum superposition".

## Content (in page order)

### [p.1] Title page
- Small grey caption "EXPERIMENT 2"; large serif grey title on three lines: "Single slit / and / Double slit".

### [p.2] Abstract (section heading, purple serif "Abstract")

Prose (faithful):

> In Experiment 1, we explored how polarizers transform the polarization state of photons—and saw that quantum mechanics predicts results that defy classical intuition. Now we turn to another quantum degree of freedom: the photon's *path*.
>
> The double-slit experiment is perhaps the most iconic demonstration in quantum mechanics. Here is the puzzle: send photons through two slits, one at a time, and record where each one lands on a detector screen.
>
> Each photon arrives as a single localized dot—clearly particle-like. But after thousands of photons, the collection of recorded dots forms an interference pattern—the kind of pattern we associate with waves. Where does the interference come from, if each photon travels alone?
>
> The answer lies in superposition. Just as a photon's polarization can be a superposition of |↕⟩ and |↔⟩, a photon's path can be a superposition of |A⟩ and |B⟩—passing through both slits simultaneously. The interference pattern emerges from how these path amplitudes combine, exactly as the Introduction described for any quantum superposition.

("Experiment 1" is rendered as a red hyperlink to the Experiment 1 page.)

### [p.3] Try it yourself!  (embedded interactive simulator)

Prose:

> Explore how the interference pattern depends on the geometry. The simulation lets you adjust:
> - Number of slits (N)
> - Slit width (w)
> - Slit separation (d)
> - Wavelength (λ)
>
> Drag the pink dots on the control panel and observe how each parameter affects the pattern. Pay attention to what happens when you cover one slit—the fringes disappear, leaving only the wide envelope.

Embed [p.3]: the rest of page 3 is blank in the print — the interactive simulator (an iframe; the Introduction/Experiment 1 pages use react/codesandbox embeds) did not print. From the text we know its controls: a "control panel" with draggable **pink dots** (sliders) for N (number of slits), w (slit width), d (slit separation), λ (wavelength), and an option to cover one slit. It draws the resulting far-field intensity pattern, presumably I(θ) ∝ (sin α/α)² · [sin(Nβ)/ (N sin β)]² with β = πd sinθ/λ (the N-slit generalisation of E7 below). Title/author of the embed are not visible. [unclear: exact layout, axis ranges and default values of the simulator — not printable.]

### [p.4] Is that real?

Prose:

> The prove you that the animation is not lying, we built the setup in a lab.   [sic — "To prove to you"]

Figure [p.4] — two small side-by-side plots (thumbnails of the plots repeated full-size on p.8–9), captioned in bold grey italics **"Single slit"** (left) and **"Double slit"** (right). See the detailed descriptions under Graphics (p.8–9).

Prose:

> This is the data we got from our lab setup. The left plot has two curves, for either slit covered. In the following section, we will explain what we did in the lab, what the data shows, what the explanation is for all of this and the maths behind the theoretical curves.

### [p.4–5] Lab Experiment (section heading, purple serif "Lab Experiment")

Prose:

> Curious of what an optical setup looks like? Here are some pictures of the double slit and the single slit setup (same setup, we just change the slit).

Figure [p.5] — **Lab photo** (colour photograph, landscape, with five rounded lilac label bubbles in purple bold text overlaid). The photo is taken from the side, at bench height, looking along a line perpendicular to the beam, on a black optical breadboard (regular grid of M6 tapped holes, ~25 mm pitch). Elements, left to right:
- **Background left:** a stack of grey/beige lab electronics boxes; in front of them, a red box with a black front panel and a white label — this is the **single-photon counting module** (SPCM, Excelitas-style red housing), with two **orange fibre patch cables** (FC connectors) plugged into black fibre adapters on its front. Label bubble **"Detector"** sits over this area (lower left). A second black module with an SMA/fibre connector is visible further left.
- **Centre-left:** a black **fibre collimator** package (short black cylinder with the orange fibre entering from the left) held in a black **kinematic mirror-style mount** with two large knurled adjustment knobs (top and bottom). Label bubble **"Collimator"**. The collimator is at the beam end of a horizontal black lens-tube assembly.
- **Centre:** a horizontal black **SM1 lens tube** assembly (~1" diameter, ~10 cm long) carrying the collimator, running left-to-right toward the filter stack. The whole assembly stands on a short black post/post-holder clamped onto a **black motorized linear translation stage** (large black block with a dovetail/rail, standing on the breadboard, with a round black knob/encoder on its left side). Label bubble **"Linear actuator"** at the bottom centre.
- **Centre, vertical:** a thin **orange/gold PCB** standing vertically, edge-on, with a **grey ribbon cable** looping up and out of frame and a small red/blue wire pair at the top. This board carries a small motor; label bubble **"Motor (unused)"** at the top centre. The board sits in the beam path between the collimator and the filter tube, so it is most plausibly the mount of the **in-house double-slit mask** (assumed — not stated).
- **Centre-right:** a second, longer black lens-tube assembly with several **stacked Thorlabs filter rings**; the engraved labels read "REFLECTIVE FILTER ND06A", "ND04A" (neutral-density filters) and "THORLABS VA100" (Thorlabs VA100 is an adjustable mechanical slit with micrometer drive). Label bubble **"Filters"**. A **micrometer head** (silver barrel with knurled thimble) sticks up vertically at the top right of this stack — consistent with the VA100 adjustable slit ("Adjustable slit (placed near 200 µm)" in the equipment table). This tube is held by a black ring clamp on a tall ½" stainless post + post holder with a clamping fork on the breadboard.
- **Right:** white equipment box in the background; black and beige cables lying on the table; a silver cable-tie / slotted bar.
- Overall colour palette: black anodised optomechanics, stainless posts, orange fibres, grey ribbon cable, black breadboard.

### [p.5–7] Technical set-up and Equipment

Prose:

> The diagram below represents the double-slit setup shown in the previous pictures. While all key components are included, the scaling is not to size.

Figure [p.6] — **Schematic of the optical setup** (clean 2D line diagram on a pale blue-grey rounded panel, same style as Experiment 1's diagrams). Elements left to right along a thin **red horizontal beam line**:
1. **LASER** — grey rectangle with a small grey nozzle on its right, labelled "LASER" inside.
2. **BS** — a square drawn with a diagonal line (cube polarizing beam splitter), label "BS" below. A short red line goes **upward** from the cube's centre to:
3. **BD** — a small black semicircular/dome shape above the BS, labelled "BD" (beam dump) — the rejected polarization is dumped.
4. **λ/2** — a tall thin **purple/magenta vertical bar** immediately right of the BS, labelled "λ/2" above (half-wave plate). *Note: in the diagram the λ/2 is drawn after the BS, whereas the prose says the beam "first passes through a half-wave plate and a beam splitter".*
5. **L1** — a biconvex lens outline (vertical lens shape, black outline), labelled "L1 = 50cm" below.
6. **Slit** — a vertical black dashed bar (three black dashes with gaps = the slits in the mask), unlabelled.
7. **D1** — a dark grey square with a small nozzle on its left, labelled "D1" (detector); the beam ends on it.
- A boxed legend at top right: "BS : Beam Splitter / BD : Beam Dump / λ/2 : Half-wave plate / L_ : Plano-convex lens".

Prose (p.6–7):

> We use a laser with a wavelength of 808 nm as the light source. The beam first passes through a half-wave plate and a beam splitter, which together ensure that its polarization is diagonal—an important detail for certain interference effects.
>
> The beam is then focused by a lens onto the double slit (or single slit), after which it continues toward the detector.
>
> Our detector is a single-photon counting module mounted on a motorized linear translation stage, allowing it to scan across the interference pattern and build up a full spatial intensity profile over time. In front of the detector, we place a set of optical filters, including long-pass filters, to prevent saturation and reduce background noise. These detectors are extremely sensitive and can handle a maximum of about 250,000 photons per second—meaning even ambient light must be carefully controlled.
>
> For the single-slit measurements, we used the same double-slit mask with one of the slits covered, allowing us to isolate the contribution of each slit individually. A dedicated single slit could also be used, but covering one slit allows for direct comparison under otherwise identical conditions. Our approach allows us to observe the contribution of each individual slit and clearly visualize the spacing between them in the resulting graph.

Table [p.7] — **Equipment list** (heading "Equipment list" overlaps the prose in the print). Names in red are hyperlinks (LASER, Half-wave plate, Beam splitter, Lens, Single slit, Detectors); "Double slit" is plain text (made in-house, no link).

| Name | Description |
|---|---|
| LASER | Laser diode (808nm) |
| Half-wave plate | Zero-Order Half-Wave plate [WPH05M-808] |
| Beam splitter | 30 mm Mounted Polarizing Beamsplitting Cube |
| Lens | Plano-convex lenses, L1 has f=50cm [LA-1908-B] |
| Double slit | Dimension (200-200-200 μm), made in-house |
| Single slit | Adjustable slit (placed near 200μm) |
| Detectors | Single photon detection module |

### [p.7–10] Result and analysis (section heading, purple serif)

#### Raw data [p.8]

> You can download all our data here:

Links/downloads (three file-download buttons with red "download file" icons):
- `SingleSlit_left.csv`
- `SingleSlit_right.csv`
- `DoubleSlit.csv`

> The files have 3 columns. The first one is the distance travelled by the actuator in μm. The second column is the number of counts seen by the detector, in a range of 2 seconds. The last column is the same number of counts, but per seconds.

(So: column 1 = actuator position [µm]; column 2 = counts in a 2 s window; column 3 = counts per second = column 2 / 2.)

#### Graphics [p.8–9]

**Single slit** — Figure [p.8] (matplotlib-style plot, white background, black frame):
- Title: "Number of counts on D1 per seconds [single slit]".
- x axis: "Distance on the screen (µm)", range −2500 … +2500, ticks −2000, −1000, 0, 1000, 2000.
- y axis: "Intensity per seconds", ticks 500, 1000, 1500, 2000 (counts/s); range ≈ 150 … 2300.
- Legend (top right): blue line "Right slit"; black dots "Our datas"; red line "Left slit".
- Content: two smooth bell-shaped curves (fits) and the measured points (black dots, ~70 per curve, spaced ~75 µm).
  - **Red ("Left slit")**: peak ≈ 2230 counts/s at x ≈ −750 µm; wider; left shoulder starts higher (≈ 300 at −2500).
  - **Blue ("Right slit")**: peak ≈ 2230 counts/s at x ≈ −575 µm; narrower; ≈ 200 at −2500.
  - Both decay to a flat background ≈ 200 counts/s by x ≈ +1300 µm and stay flat to +2500.
  - Full width at half maximum (above background) ≈ 1800–1900 µm for either curve. The two curves cross at ≈ +100 µm on the right flank and are offset horizontally by ~175 µm (quoted by the site) on the left flank.
  - The curves look Gaussian-like (no visible secondary side lobes of a sinc²: background noise hides them).

**Double slit** — Figure [p.9] (same style):
- Title: "Number of counts on D1 per seconds [double slit]".
- x axis: "Distance on the screen (µm)", range −3000 … +3000, ticks every 1000.
- y axis: "Intensity per seconds", ticks 2000, 4000, 6000, 8000; range ≈ 400 … 9000.
- Legend (top left): grey dashed "Theorical curve" [sic]; blue line "Fit of the datas"; black dots "Our datas".
- Content: **three main peaks**.
  - Central peak: ≈ 8700 counts/s at x ≈ +50 µm (data and blue fit).
  - Left side peak: ≈ 3900 counts/s at x ≈ −950 µm. Right side peak: ≈ 3650 counts/s at x ≈ +1050 µm.
  - Minima between peaks: ≈ 1800 at x ≈ −550 µm and ≈ 1850 (data dips to ≈ 1750) at x ≈ +650 µm. The measured minima do **not** go to zero.
  - Outside ±1800 µm the data falls to a flat background ≈ 550 counts/s (blue fit ≈ 650 flat).
  - Peak-to-peak spacing of the fringes ≈ 1000 µm.
  - **Grey dashed theoretical curve** (E7 with the lab parameters, scaled so its central peak ≈ 8800 at x = 0): side peaks ≈ 4400 at x ≈ ±900 µm (higher than measured), minima touching ≈ 700–800 (its baseline) at x ≈ ±500 and ±1500 µm, then zero of the envelope near ±2000 µm, and small secondary bumps (≈ 1000–1300) re-emerging at |x| ≈ 2500–3000 µm — the second diffraction lobe, which the measurement does not show above background. The theory curve is slightly narrower per fringe than the data.

Prose (p.9–10):

> In the first plot, two curves are displayed–each corresponding to the intensity with one of the slits covered.
>
> In the second plot, we can clearly distinguish three main peaks, indicating the presence of interference. The number and size of the peaks are determined by the geometry of the double slit—depending on the slit width and spacing, you might observe three, four, five, or more peaks. To anticipate the number and structure of the peaks, you can refer to the interactive animation provided at the beginning of the experiment.
>
> Typically, the central peak is the most intense, and the adjacent peaks should have roughly equal intensity. If they do not, it may indicate that the slits are not perfectly aligned perpendicular to the incoming beam. The horizontal distance between the two individual curves is approximately 175 μm, which corresponds closely to the actual slit separation of about 200 μm.
>
> As a final check, we compare the experimental data with theoretical predictions using the equations from the theory section. The theoretical curve, shown as a gray dashed line, matches the general pattern, although we observe slight deviations in intensity and width. These discrepancies can be attributed to minor misalignments in lens placement or imperfections in the linear actuator's motion.

### [p.10–20] Theory and equations (section heading, purple serif)

#### Conceptual Overview [p.10–11]

> A first surprising effect to be explained is that when coming through a narrow slit, the beam of photons does not get narrow. Quite the opposite: it widens up. This phenomenon is called diffraction.
>
> The easiest way to understand, at a high level, why a particle diffracts when it passes through a slit is by invoking Heisenberg's uncertainty principle. Here's what the principle says:
>
> - A particle's position and momentum cannot both be precisely defined at the same time.
> - The more precisely position is constrained, the more uncertain momentum becomes, and vice versa.

**Why Does This Matter for a Slit?** (sub-heading)

> When a photon passes through a slit of a certain width, we know its position along the vertical axis (the slit fixes it within that range). This means that the uncertainty in its vertical momentum must increase, following Heisenberg's uncertainty principle.
>
> That uncertainty in momentum translates into a spread of possible directions the photon can take once it has passed the slit. Instead of traveling in a perfectly straight line, its sideways momentum has a significant spread. So instead of having one exact momentum value pointing straight ahead, the photon now has many possible sideways momentum values, each value tied to a certain probability. The result is that many possible shifted directions are realized, with different probabilities, forming what we observe as a diffraction pattern.
>
> To put it simply:
> - Narrow slit → small uncertainty in position → large uncertainty in momentum → wide diffraction pattern.
> - Wide slit → large uncertainty in position → small uncertainty in momentum → narrow diffraction pattern.
>
> The mathematical form of this diffraction pattern is:

Equation E1 [p.11]:
$$ D = \left(\frac{\sin\alpha}{\alpha}\right)^{2}, \quad \text{with } \alpha = \frac{\pi w \sin\theta}{\lambda} $$

> This formula will reappear throughout subsequent experiments.

#### Other Uncertainties [p.12]

> Heisenberg's uncertainty principle is very general, it doesn't just apply to position and momentum, but also to other pairs of quantum properties. More broadly, this is called quantum complementarity.
>
> Take polarization, for example. A photon can be in the state |↕⟩, for instance. If we then measure it along the vertical-horizontal axes, we will get a definite outcome: it will appear vertical.
>
> But what if we measure it along the diagonal (|↗↙⟩ and |↘↖⟩) axes? In that case the outcome is no longer certain. We can in fact write the |↕⟩ state as a superposition of the diagonal states:

Equation E2 [p.12]:
$$ \ket{\updownarrow} = \frac{\ket{\nearrow\!\!\swarrow} - \ket{\searrow\!\!\nwarrow}}{\sqrt{2}}, $$

> What the above equation means is that if we test the |↕⟩ state with a diagonal polarizer, it has a 50 percent chance of coming out one way, and a 50 percent chance of coming out the other way. The core idea here is that no photon can be perfectly defined in both descriptions, meaning vertical *and* diagonal at the same time.

#### Phase and Interference [p.12–14]

> We have seen that when a system is in superposition, its state is expressed as a sum of many other states, each of which is multiplied by an amplitude. These amplitudes correspond to a complex number, and so it can be decomposed into a modulus and a phase.
>
> We can think of a phase as a point rotating on a circle. Mathematically, it's represented by a complex exponential:

Equation E3 [p.13]:
$$ \text{phase} = e^{iks} $$

> In the above equation, i is the imaginary number, k = 2π/λ is the wave number, and s is the distance the photon has traveled.
>
> Using Dirac notation, we can describe the photon's journey mathematically. At the source, the state is |ψ₀⟩ = |S⟩. After passing through the double slit, the photon is in a superposition of both paths:

Equation E4 [p.13]:
$$ \ket{\psi_1} = \frac{1}{\sqrt{2}}\left(\ket{A} + \ket{B}\right) $$

> Here, the factor 1/√2 ensures normalization. As each path accumulates phase based on distance traveled, interference emerges. The full derivation appears in the Mathematical Derivation section below.

#### Key Formulas [p.14–15]

> The equation that describes the diffraction pattern of a photon passing through a single slit is:

Equation E1 (repeated) [p.14]:
$$ D = \left(\frac{\sin\alpha}{\alpha}\right)^{2}, \quad \text{with } \alpha = \frac{\pi w \sin\theta}{\lambda} $$

> Here, w represents the width of the slit, θ is the angle between a point on the screen and the center of the slit, and λ is the wavelength of the photons. On the right, we can see an example of a diffraction pattern.

Figure [p.15] — **Single-slit diffraction plot** (matplotlib, black line on white, full-width):
- x axis: "Distance on the screen (µm)", range −0.03 … +0.03, ticks every 0.01. [Note: the axis label says µm but the numbers are clearly in metres/ arbitrary units — a sinc² with first zeros at ±0.01 and secondary lobes at ±0.015 and ±0.025.]
- y axis: "Intensity normalized", 0.0 … 1.0, ticks every 0.2.
- Curve: (sin α/α)² shape — central maximum 1.0 at 0, zeros at ±0.01, ±0.02, ±0.03; side lobes peaking ≈ 0.047 at ±0.014 and ≈ 0.017 at ±0.024.
- Caption (italic): "Single-slit diffraction pattern: normalized intensity as a function of position on the screen, showing the characteristic central maximum and smaller side lobes."

#### Mathematical Derivation [p.15–20]

> In this experiment, the polarization of the photon does not matter, we only track its position. The photon starts at the source in the state:

Equation E5 [p.16]:
$$ \ket{\psi_0} = \ket{S}. $$

> As the photon propagates toward the slits, its wavefunction overlaps with both slits, as well as the opaque parts of the mask (the area between/around the slits, which blocks or absorbs photons). Some photons hit the mask and are absorbed (lost), while others pass through slit A or slit B. Let A_pass represent the amplitude of a photon that successfully passes through a slit, and A_lost the amplitude of a photon that is absorbed.

Equation E6 [p.16]:
$$ \ket{\psi_1} = A_{\text{pass}}\frac{1}{\sqrt{2}}\left(e^{ikl}\ket{A} + e^{ikl}\ket{B}\right) + A_{\text{lost}}\ket{\text{lost}} $$

> Since we cannot easily predict the number of lost photons and because they do not contribute to the interference pattern, we drop the |lost⟩ term. The state becomes:

Equation E6' [p.16]:
$$ \ket{\psi_1} = \frac{1}{\sqrt{2}}\,e^{ikl}\left(\ket{A} + \ket{B}\right) $$

> The photon then propagates to the detection screen. Consider a specific point on the screen, |y⟩. If |y⟩ is at the center, the distances from A and B are equal. If |y⟩ is above or below the center, the path lengths differ. Let "a" be the distance from slit A to |y⟩, and "b" the distance from slit B to |y⟩. At that position, the amplitudes from both slits combine:

**Path difference geometry** (sub-heading, p.17)

> For a screen at distance L from slits separated by d, the path difference in the small-angle regime (y ≪ L) is:

Equation E7 [p.17]:
$$ b - a \approx \frac{d\cdot y}{L} = d\sin\theta, $$

> where θ is the angle from the optical axis. We use this approximation throughout.

Figure [p.17, left] — **"Schematic of the double-slit geometry."** (small grey line drawing, caption in italics). Left to right: a grey rectangular **source S** (box with small nozzle) at vertical dashed line **1**; a thick dark-grey vertical bar (the mask) at dashed line **2** with two black dots **A** (upper) and **B** (lower) marking the slits; a dark-grey half-disc **detector D₀** at dashed line **3** with a black dot **X** on the axis where the beam arrives. Dotted lines: S→A and S→B both labelled *l* (italic), A→X labelled *a*, B→X labelled *b*. Numbers 1, 2, 3 (light grey) beneath the dashed planes mark source plane / slit plane / detector plane. [This diagram's labels match E6/E8: equal length l to each slit, a and b from the slits to the detection point.]

Figure [p.17, right] — a faint lilac line plot (illustrative, partly washed out): a wide bell-shaped envelope (peak 2.0 at 0) filled with rapid interference fringes; x axis from −4 to 4, y ticks 0.5, 1.0, 1.5, 2.0. Grey text beside it: "I_0 = diffraction" and "I_0 = I_left+ I_right" (this reads as a note that the envelope I₀ is the single-slit diffraction, equal to the sum of the left- and right-slit intensities). [unclear: this looks like an unfinished annotation left on the site.]

Figure [p.18] — **"Path geometry for the double-slit experiment."** (full-width colour diagram on a pale blue-grey panel, same pink/red style as the setup diagrams). Elements left to right:
- **LASER**: pink/salmon rectangle with a small nozzle, pink label pill "LASER" below.
- Two **red rays** leave the laser nozzle to the two slits; each is labelled **ℓ** (script ell) — equal lengths.
- **Mask**: three black vertical bars (top, middle, bottom) with two gaps = slits; the upper slit is A, the lower is B (not lettered in this drawing).
- From each slit a **red ray** goes to the detector point **y** (black dot at the lower right, on the detector face): upper slit → y labelled **a**, lower slit → y labelled **b**.
- Faint **pink rays** from each slit go to a second point **y′** (grey dot higher on the detector face), labelled **a′** and **b′** — illustrating "the full state includes contributions at every screen position".
- **Detector D**: tall pink/salmon rectangle at the right (the screen), with a dotted vertical line through it and a pink label pill "D" below.

> As the photon propagates from each slit to position y, each path acquires a phase proportional to the distance traveled:

Equation E8 [p.18]:
$$ \ket{A} \rightarrow e^{ika}\ket{y}, \qquad \ket{B} \rightarrow e^{ikb}\ket{y}. $$

> The full state now includes contributions at every screen position. Focusing on a single position y:

Equation E9 [p.19]:
$$ \begin{aligned} \ket{\psi_2} &= \cdots + \frac{1}{\sqrt{2}}\,e^{ikl}\left(e^{ika}\ket{y} + e^{ikb}\ket{y}\right) + \cdots \\ &= \cdots + \frac{1}{\sqrt{2}}\,e^{ikl}\left(e^{ika} + e^{ikb}\right)\ket{y} + \cdots \end{aligned} $$

> (The "⋯" indicates similar terms for other positions y′ on the screen.)
>
> To compute the probability of detecting a photon at |y⟩, we square the coefficient in front of |y⟩. We define I₀ as the *peak intensity* at the center of the screen (θ = 0), before any angular dependence is applied. With this definition, the interference term becomes:

Equation E10 [p.19]:
$$ I_{\text{interference}} = I_0\left(1 + \cos\!\big(k(b-a)\big)\right) $$

> This term oscillates between 0 (destructive interference, when b − a = (n + ½)λ) and 2I₀ (constructive interference, when b − a = nλ).
>
> Finally, the interference term must be combined with the *single-slit diffraction envelope*. Each slit has finite width w, which causes the light to spread according to:

Equation E11 [p.20]:
$$ D(\theta) = \left(\frac{\sin\alpha}{\alpha}\right)^{2}, \quad \text{where } \alpha = \frac{\pi w \sin\theta}{\lambda} $$

> The complete intensity pattern combines both effects—interference fringes modulated by the diffraction envelope:

Equation E12 [p.20]:
$$ I(\theta) = 2I_0\left(1 + \cos\!\left(\frac{2\pi d \sin\theta}{\lambda}\right)\right)\left(\frac{\sin\alpha}{\alpha}\right)^{2} $$

> Here:
> - I₀ is the intensity from a *single slit* at θ = 0. With both slits open and constructive interference, the maximum intensity is 4I₀, because intensity scales as amplitude squared (doubling amplitude quadruples intensity).
> - d is the slit separation (center to center)
> - w is the width of each slit
> - The term (1 + cos(⋯)) creates the interference fringes (ranges from 0 to 2)
> - The term (sin α/α)² is the diffraction envelope
>
> Note: We replaced the path difference (b − a) with its geometric equivalent d sin θ, valid in the far-field regime.

(In the print, the "Literature and video" heading and its intro sentence overlap this bullet list — print artefact.)

### [p.20–21] Literature and video (section heading, purple serif)

> If you want to see the three polarizer paradox from your own eyes, here are some Youtube videos we found to be accurate and insightful!   [sic — sentence copied from Experiment 1; the videos are about the double slit]

Embeds [p.21] — two YouTube embeds side by side (greyed-out thumbnails with the red YouTube play button, "Watch on" footer, share/clock icons):
1. **"Why reality changes when you look"** — channel: **The Royal Institution**.
2. **"Young's interference experiment wi…"** (title cut off; presumably "…with single photons" or similar) — channel: **HAMAMATSU PHOTONICS**.

Figure [p.21] — a graphing-calculator-style plot (grid background, Desmos-like): a **red** smooth envelope (sinc²-like bell, peak 1 at x = 0, falling to ~0 by |x| ≈ 2.5, x axis −4 … 4, y axis −1 … 1) and a **blue** rapidly oscillating curve filling the envelope (double-slit fringes: ~9 fringes between −2 and 2, touching the red envelope at their maxima and touching 0 at minima). Caption (italic): "Comparison of the single-slit diffraction envelope with the full double-slit pattern."

### [p.21–22] Similar Experiments (section heading) / Overview footer

Three cards:
- **INTRODUCTION — "Quantum for everyone"** (card shows the word "OVERVIEW" in big black text).
- **EXPERIMENT 1 — "Polarizers"** (card: four stacked schematic rows LASER → hatched grey disc → purple polarizers labelled 90°, 45, 0° with pills P1/P2/P3 → D1; column labels Ψ₀, Ψ₁, Ψ₂, Ψ₃).
- **EXPERIMENT 2 — "Single and double slit"** (card: two rows; top row LASER → hatched disc → black dashed mask → D1 straight through; bottom row LASER → hatched disc → two red rays through the mask converging on D1; column labels Ψ₀, Ψ₁ Ψ₂, Ψ₃).

Footer: "Testing Reality © 2018-2026" and "Creative commons" with CC / BY / NC icons.

## Physics model for simulation

### States
- **Path degree of freedom only.** The site states explicitly that polarization is ignored on this page ("the polarization of the photon does not matter, we only track its position"). Model the photon as a path state in a basis that grows along the journey:
  - Source: {|S⟩}. |ψ₀⟩ = |S⟩. (E5)
  - After the mask: {|A⟩, |B⟩, |lost⟩} — a path qubit |A⟩/|B⟩ plus a loss/absorption state. (E6)
  - At the screen: a continuum (or fine grid) of screen positions {|y⟩}; each |y⟩ receives a contribution from both slits. (E8, E9)
- Site notation to reuse verbatim in the game: |S⟩, |A⟩, |B⟩, |lost⟩, |y⟩, |y′⟩, A_pass, A_lost, ψ₀, ψ₁, ψ₂, l (source-to-slit distance, equal for both slits), a, b (slit-to-screen distances), k = 2π/λ, I₀, D(θ), α, w, d, L, θ.
- Polarization aside (E2): |↕⟩ = (|↗↙⟩ − |↘↖⟩)/√2 — used only to illustrate complementarity (P = ½ for each diagonal outcome).

### Operators / steps
1. **Mask (slits):** |S⟩ → A_pass (1/√2)(e^{ikl}|A⟩ + e^{ikl}|B⟩) + A_lost |lost⟩. Then renormalize onto the pass subspace: |ψ₁⟩ = (1/√2) e^{ikl}(|A⟩+|B⟩). The common phase e^{ikl} is global and drops out of all probabilities. A_pass and A_lost are not given numerically; |A_pass|² + |A_lost|² = 1 (assumed). For a game, treat the fraction of "lost" photons as the ratio of open slit area to beam area (not stated; see Open questions).
2. **Free propagation slit → screen:** |A⟩ → e^{ika}|y⟩, |B⟩ → e^{ikb}|y⟩ with a, b the geometric distances (E8).
3. **Detection at y:** amplitude c(y) = (1/√2) e^{ikl}(e^{ika} + e^{ikb}); probability ∝ |c(y)|² = ½|e^{ika}+e^{ikb}|² = 1 + cos(k(b−a)). (E10, with I₀ as the single-slit peak intensity.)
4. **Path difference:** b − a ≈ d·y/L = d sin θ, θ = angle from optical axis, y ≪ L (E7).
5. **Finite slit width:** multiply by the single-slit envelope D(θ) = (sin α/α)², α = πw sinθ/λ (E1/E11).

### Predicted intensities
- **Single slit (one slit covered), width w:**
  $$ I_{1}(\theta) = I_0 \left(\frac{\sin\alpha}{\alpha}\right)^2, \qquad \alpha = \frac{\pi w \sin\theta}{\lambda}, \quad \sin\theta \approx y/L. $$
  First zeros at sin θ = ±λ/w; central lobe full width 2λL/w; FWHM ≈ 0.886 λL/w.
- **Double slit, width w, centre-to-centre separation d (E12):**
  $$ I(\theta) = 2 I_0 \left(1 + \cos\frac{2\pi d \sin\theta}{\lambda}\right)\left(\frac{\sin\alpha}{\alpha}\right)^2 $$
  Max 4I₀ at θ = 0; fringe maxima at d sin θ = nλ (period on the screen Δy = λL/d); fringe zeros at d sin θ = (n+½)λ; envelope zeros at w sin θ = mλ. Missing orders when d/w is an integer (n = m·d/w).
- **N slits (for the simulator):** I_N(θ) = I₀ (sin α/α)² [sin(Nβ)/sin β]², β = πd sinθ/λ (N = 2 reduces to E12 since [sin 2β / sin β]² = 4cos²β = 2(1+cos 2β)). Not written on the site but implied by the "Number of slits (N)" control.
- **"Cover one slit" behaviour (p.3):** fringes disappear, only the envelope remains.

### Lab numbers to match
| Parameter | Value | Status |
|---|---|---|
| Wavelength λ | 808 nm (laser diode) | stated |
| Double-slit mask | "200-200-200 µm", made in-house | stated (ambiguous: read as slit 200 µm / gap 200 µm / slit 200 µm) |
| Slit width w | 200 µm | stated (from the mask spec and "Adjustable slit (placed near 200 µm)") |
| Slit separation d | site says "about 200 µm" (p.9) — but if the mask is 200 µm slit / 200 µm bar / 200 µm slit then **centre-to-centre d = 400 µm** and the edge-to-edge gap = 200 µm | ambiguous, see below |
| Lens L1 | plano-convex f = 50 cm (Thorlabs LA1908-B), placed before the slit, "focuses the beam onto the double slit" | stated |
| Slit-to-detector distance L | not stated | missing — proposed 50 cm (see justification) |
| Detector scan range | ±2500 µm (single), ±3000 µm (double), step ≈ 75 µm, 2 s dwell per point | read off the plots / CSV description |
| Detector max rate | ~250,000 counts/s; long-pass + ND filters (ND04A, ND06A visible) in front | stated / seen in photo |
| Measured single-slit peak | ≈ 2200 counts/s above a ≈ 200 counts/s background; FWHM ≈ 1.8–1.9 mm; peaks at −750 µm (left slit) and −575 µm (right slit), offset ≈ 175 µm | read off the plot |
| Measured double-slit | central ≈ 8700 counts/s at ≈ +50 µm; side peaks ≈ 3900 (−950 µm) and ≈ 3650 (+1050 µm); minima ≈ 1800 (not zero); fringe spacing ≈ 1.0 mm; background ≈ 550 | read off the plot |
| Ratio central double / single peak | 8700/2200 ≈ 4 → matches the site's "4I₀" claim | derived |

**Consistency check / proposed missing parameters.** Fringe period Δy = λL/d. Observed Δy ≈ 1000 µm with λ = 808 nm:
- With d = 400 µm (centre to centre, 200-200-200 mask) → L ≈ 0.50 m. This equals the lens focal length (50 cm), and with w = 200 µm the single-slit central lobe FWHM ≈ 0.886·λL/w ≈ 1.79 mm, matching the measured ≈ 1.8–1.9 mm, and the envelope zero at λL/w ≈ 2.02 mm coincides with the second-order fringe (d = 2w → the n = ±2 orders are missing), which is exactly why only **three** main peaks are seen and why the theory curve on p.9 goes to zero near ±2000 µm.
- With d = 200 µm → L ≈ 0.25 m, but then the envelope FWHM would be ≈ 0.9 mm, half the measured width.
- **Recommendation for the simulation:** λ = 808 nm, w = 200 µm, d = 400 µm (centre-to-centre), effective propagation distance L = 0.50 m (detector in/near the focal region of the f = 50 cm lens, so the Fraunhofer pattern appears with scale λf), background ≈ 200–600 counts/s, dwell 2 s. Reproduce the site's gray dashed curve as 2I₀(1+cos(2πd y/(λL)))·sinc²(πw y/(λL)) + background with I₀ ≈ 2200 counts/s. The quoted "slit separation of about 200 µm" should then be read as the *gap between the slits* (bar width), and the 175 µm shift between the two single-slit curves as the residual geometric offset of the two slits (not a far-field effect).
- Beam preparation: HWP + PBS set the polarization to diagonal ("important for certain interference effects" — relevant to later quantum-eraser experiments, not to this page's model).

### Derivation steps to animate (in the site's order)
1. |ψ₀⟩ = |S⟩.
2. Mask: |ψ₁⟩ = A_pass (1/√2)(e^{ikl}|A⟩ + e^{ikl}|B⟩) + A_lost|lost⟩ → drop |lost⟩.
3. Propagate: |A⟩→e^{ika}|y⟩, |B⟩→e^{ikb}|y⟩ → |ψ₂⟩ = ⋯ + (1/√2)e^{ikl}(e^{ika}+e^{ikb})|y⟩ + ⋯.
4. Square the coefficient: I_interference = I₀(1+cos k(b−a)) ∈ [0, 2I₀].
5. b − a ≈ d sin θ; multiply by D(θ) → E12, max 4I₀.

## Apparatus list (for Blender)

| Item | Site description | Approx. real-world dimensions | Mounting | Status |
|---|---|---|---|---|
| Laser diode, 808 nm (near-IR, invisible to the eye — depict beam as dark red/faint) | "Laser diode (808nm)"; drawn as grey box "LASER" | fibre-coupled or free-space diode module ~ 40×40×100 mm; or a pigtailed butterfly diode in a mount with the beam delivered by an orange single-mode fibre and the **fibre collimator** seen in the photo (black cylinder Ø ~ 12 mm, 30 mm long) | collimator in a kinematic mount (two knurled knobs) on a post/post-holder on a short riser | stated (laser), collimator seen in photo |
| Half-wave plate (zero-order, 808 nm) | "Zero-Order Half-Wave plate [WPH05M-808]"; drawn as purple vertical bar "λ/2" | Thorlabs WPH05M-808: Ø 1" mounted plate (Ø 25.4 mm, ~6 mm thick) | in a rotation mount (Ø 1" rotation mount with engraved degree scale) on post | plate stated; rotation mount assumed |
| Polarizing beam-splitter cube | "30 mm Mounted Polarizing Beamsplitting Cube"; drawn as square with diagonal, label "BS" | 30 mm cube in a cage-cube/mount (~ 40×40×40 mm block) | on a post / kinematic platform; secondary port faces up (towards BD in the diagram) or sideways | stated |
| Beam dump "BD" | drawn as black dome above the BS | small black cylindrical/ conical beam block ~ 20 mm | on a post | stated in diagram only |
| Plano-convex lens L1, f = 50 cm | "Plano-convex lenses, L1 has f=50cm [LA-1908-B]"; drawn as lens outline "L1 = 50cm" | Thorlabs LA1908-B: Ø 1" (25.4 mm), B-coating (650–1050 nm) | lens in a Ø 1" lens mount on a post | stated |
| Double-slit mask | "Dimension (200-200-200 μm), made in-house" — two slits ~ 200 µm wide separated by a 200 µm bar; drawn as a vertical black dashed bar | small opaque plate (e.g. metal foil / PCB-etched mask) ~ 10–25 mm, slit height a few mm; in the photo plausibly the vertical gold/orange PCB with ribbon cable and an **unused motor** (labelled "Motor (unused)") | on a post in the beam; the PCB stands vertically | dimensions stated; identification with the PCB assumed |
| Single slit (adjustable) | "Adjustable slit (placed near 200μm)" — photo shows "THORLABS VA100" engraving and a micrometer head | Thorlabs VA100: Ø 1"-threaded adjustable slit, 0–6 mm opening, micrometer drive (~ 50 mm wide × 35 mm tall + 30 mm micrometer) | in the lens-tube stack, held by a ring clamp on a tall ½" post + post holder + clamping fork | stated; the site says the single-slit *data* were actually taken by covering one slit of the double-slit mask |
| Optical filters: long-pass filters + ND filters | "set of optical filters, including long-pass filters" — photo shows Thorlabs reflective ND filters ND04A, ND06A (Ø 1", in SM1 lens tube) | Ø 25 mm filters in SM1 lens tube (Ø 30 mm, 50–100 mm long) | lens tube in front of the detector/collimator, in the same tube stack, ring-clamped on a post | stated + seen |
| Single-photon counting module (SPCM) "D1" | "Single photon detection module"; max ≈ 250 000 counts/s; drawn as dark grey box with nozzle | red Excelitas-style SPCM box ~ 90×60×35 mm with black front panel and fibre input (FC) ; the light is collected by the fibre collimator on the moving stage and sent through orange fibre to the module | module sits on the bench at the back; collection collimator on the **motorized linear translation stage** | stated + seen |
| Motorized linear translation stage ("Linear actuator") | "motorized linear translation stage"; scans ±2.5–3 mm in ~75 µm steps, 2 s dwell | black stage block ~ 100×100×40 mm with a round knob/encoder on the side; travel ≥ 6 mm (realistically 25 mm) | bolted to the breadboard; carries the post with the collimator/filter tube | stated + seen |
| Optical breadboard | seen in photo | black aluminium breadboard, M6 holes on 25 mm grid | — | seen |
| Lab electronics (background) | grey/beige instrument boxes, white box | ~ 2–3 rack-style boxes, 20–30 cm wide | on the bench behind the setup | seen |
| Cables | orange single-mode fibre patch cables (FC), grey ribbon cable to the (unused) motor, black/beige coax cables | — | — | seen |
| Posts / post holders / clamping forks | — | ½" stainless posts (50–75 mm), black post holders, clamping forks | — | seen |

## Teaching notes

Order in which ideas are needed:
1. **Review from Experiment 1 / Introduction:** kets as states, superposition with amplitudes, probability = |amplitude|², 1/√2 normalization. The page explicitly refers back ("exactly as the Introduction described for any quantum superposition").
2. **Particle vs wave puzzle** (pedagogical "paradox" framing): single dots, but a fringe pattern after many photons. "Where does the interference come from, if each photon travels alone?" → answer: superposition of path states |A⟩ + |B⟩.
3. **Interactive exploration before theory**: the N, w, d, λ simulator with pink draggable dots; the key observation "cover one slit → fringes vanish, envelope remains".
4. **"Is that real?" move**: show the lab data immediately after the simulator to establish credibility, then explain.
5. **Heisenberg uncertainty (qualitative)**: position-momentum trade-off → narrow slit = wide diffraction. Only inequalities/arrows, no formula; then the sinc² formula is simply stated.
6. **Complementarity generalised**: the polarization example |↕⟩ = (|↗↙⟩ − |↘↖⟩)/√2, 50/50 outcomes — ties back to Experiment 1's bases. (Needs: change of basis, square of 1/√2.)
7. **Complex numbers as phases**: amplitude = modulus × phase, phase = e^{iks} as "a point rotating on a circle"; k = 2π/λ; s = distance. (Needs: Euler's formula, unit circle, the idea that a global phase does not matter.)
8. **Dirac-notation journey**: |S⟩ → (|A⟩+|B⟩)/√2 → e^{ika}|y⟩, e^{ikb}|y⟩. Needs: linearity (each ket evolves independently), collecting coefficients of |y⟩.
9. **Squaring a sum of two phases**: |e^{ika}+e^{ikb}|² = 2 + 2cos(k(b−a)) → constructive (nλ) vs destructive ((n+½)λ). Needs: |z|² = z z*, cos from Euler.
10. **Small-angle geometry**: b − a ≈ d y/L = d sin θ (similar triangles; "far-field regime"). Needs: trig, small-angle approximation.
11. **Multiplying envelope × fringes**: final E12, and the counting of peaks (3, 4, 5…) as a function of d/w. Needs: product of functions, zeros of sinc.
12. **Intensity scaling**: 2 slits → amplitude ×2 → intensity ×4 (4I₀), and a sanity check against the data (8700 ≈ 4 × 2200).
13. **Reading real data**: counts/s, background, fits vs theory, misalignment explanations (unequal side peaks → slits not perpendicular to the beam; width deviations → lens placement / actuator imperfections).

Site's own pedagogical moves: puzzle-first framing; simulator before derivation; "Is that real?" lab-reality check; explicit "we drop the |lost⟩ term" honesty about absorbed photons; "⋯" for the other screen positions; bullet-list glossary after the final formula; the note that D = (sin α/α)² "will reappear throughout subsequent experiments".

## Open questions
- **Slit separation d is ambiguous.** The equipment table says the in-house double slit is "200-200-200 µm" (naturally: slit/bar/slit, so centre-to-centre d = 400 µm), while the text says "the actual slit separation of about 200 µm" and the single-slit curves are offset by ≈ 175 µm. Fringe spacing analysis (≈ 1 mm fringes at 808 nm) fits d = 400 µm with L ≈ 50 cm, or d = 200 µm with L ≈ 25 cm; the envelope width favours d = 400 µm / L = 50 cm. Needs confirmation.
- **Slit-to-detector distance L is never stated**; the lens f = 50 cm is before the slit. Proposed L_eff = 0.50 m.
- The optical diagram (p.6) draws the λ/2 plate **after** the PBS, whereas the prose says "half-wave plate and a beam splitter" in that order. Which is physically first is unclear (for a diagonal output after a PBS, the HWP must come after the PBS; before the PBS it would only set the split ratio).
- The simulator on p.3 (iframe) did not print: no view of its layout, default values, or title/author.
- p.15 plot: x-axis labelled "Distance on the screen (µm)" but ticks run −0.03…0.03 — units are inconsistent (looks like metres or arbitrary units).
- p.17 right-hand figure: faint washed-out plot with the stray text "I_0 = diffraction / I_0 = I_left+ I_right" — appears to be an unfinished annotation.
- "Literature and video" intro sentence talks about the "three polarizer paradox" (copied from Experiment 1).
- Second video title is cut off: "Young's interference experiment wi…" (HAMAMATSU PHOTONICS).
- The CSV files (SingleSlit_left.csv, SingleSlit_right.csv, DoubleSlit.csv) are not in the PDF; all numbers above are read off the plots (±5 %). Not found in the repo either.
- A_pass / A_lost are symbolic only; no transmission fraction is given.
- "Filters" in the photo show ND filters (ND04A, ND06A); the text mentions long-pass filters — both are presumably in the tube stack.
- Whether the vertical PCB with the "Motor (unused)" is the double-slit mask holder is an inference from its position, not stated.
