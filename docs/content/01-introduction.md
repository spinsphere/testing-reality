# Introduction: The quantum formalism: learn the basics for everyone
Source: `A-Introduction New.pdf`; URL printed in the footer: https://testing-reality.webflow.io/introduction ; 18 pages (printed 30/10/2026 20:38, browser tab title "Introduction New").

Note on the duplicate export: `C-Quantum formalism.pdf` is the same page printed ten minutes later (20:48). Its text, figures and page count are identical to A; only the print timestamp in the running header differs (pdftotext diff shows nothing else). The site's "Quantum formalism" link therefore resolves to this same Introduction page; C is not transcribed separately.

Site chrome on every page (stripped below): nav bar "Testing Reality" / "Experiments" / "About"; "Made in Webflow" badge; footer on the last page "Testing Reality © 2018-2026" and "Creative commons" with CC / BY / NC icons.

## Page summary
This page is the site's self-contained primer on the quantum formalism, aimed at readers with "only minimal mathematical background": "for now, you only need vectors in 2 dimensions". It proceeds in two passes. First, "The Quantum Apple" teaches the three moves of quantum mechanics by analogy: a state is a superposition of definite states (|red⟩, |eaten⟩) with numerical amplitudes; evolution acts on each component separately and in superposition (red → rotten gradually, eaten stays eaten); measurement returns one definite outcome with probability equal to the squared amplitude (2/3 rotten, 1/3 eaten). Second, "The Mathematical Arena" makes this precise: a ket is a unit-length vector, distinguishable states are orthogonal, superpositions α|A⟩+β|B⟩ are valid states iff |α|²+|β|²=1 (verified for |φ3⟩ = ½|A⟩+(√3/2)|B⟩ with Pythagoras), transformations are linear and length-preserving (worked example: a "45° rotation" R45 that maps |φ1⟩ back to |A⟩, with the |B⟩ terms cancelling, which is introduced as the algebraic face of constructive/destructive interference), and measurement in the {|A⟩,|B⟩} basis yields |A⟩ with frequency |α|² and |B⟩ with |β|². The punchline is that superposition, evolution and probabilistic measurement are all just unit vectors, linear maps and squared projections in a plane.

## Content (in page order)

### [p.1] Title block
- Kicker (grey uppercase): INTRODUCTION
- Title (large grey serif): **The quantum formalism: learn the basics for everyone**

### [p.2] Left sidebar "TABLE OF CONTENT"
Listed entries: Abstract / Lab Experiments / Result and analysis / Theory and equations / Literature and video. This is the site's generic experiment-page template; on this page only "Abstract" corresponds to an actual heading. The real headings are: Abstract; The Quantum Apple (Description, Evolution, Gradual Evolution, Measurement); The Mathematical Arena (Describing Quantum Systems, Evolving Quantum Systems, Measuring Quantum Systems); Similar Experiments. See Open questions.

### [p.2] Abstract
- Heading (purple-blue serif): **Abstract**
- Prose: "Here, we explain how quantum mechanics works: the mathematical objects it uses, the predictions it makes, and how those predictions are tested experimentally."
- Prose: "Rather than beginning with rigorous formalism, we start in the middle — by offering simple statements that capture the core ideas. The downside of simplicity is that it can be inaccurate, but as you move through the website, we'll gradually refine and deepen the presentation."
- Prose: "The upshot is that you can begin understanding quantum theory with only minimal mathematical background. For now, you only need vectors in 2 dimensions."

### [p.3] The Quantum Apple
- Heading (purple-blue serif): **The Quantum Apple**
- Prose: "As is customary in physics, systems are described by their states. As the system evolves in time, the state evolves too, providing us with a state for each moment. Think of it like a movie: each frame shows the state of a particular scene at a specific instant. As the film runs, the frames change, and we see how the story evolves over time. The same applies to states in physics."
- Prose: "For instance, an apple may be in the state "red", or "eaten". These are its *classical states* — definite properties that describe the system and which we can measure. Consider the fridge of someone who enjoys red apples. The red apple may evolve to the state "eaten", while the "eaten" apple remains "eaten"."

#### [p.3-4] Description
- Sub-heading (black serif): **Description**
- Prose: "In quantum mechanics, systems are still described by states — but now they are quantum states."
- Prose: "A quantum apple can also be in one of two definite states: |red⟩, |eaten⟩ (don't worry about this special notation for now). But unlike a classical apple, a quantum apple doesn't have to be in just one of these states. It can be in a *superposition* of being red and being eaten — a kind of combination of two equally real states. For example, the apple might be in the state:"
- Equation E1 [p.4]:
$$\ket{\Psi_0} = \sqrt{\tfrac{2}{3}}\,\ket{\mathrm{red}} + \tfrac{1}{\sqrt{3}}\,\ket{\mathrm{eaten}}\,.$$
- Prose: "The letter Ψ ('Psi') is often used to denote the quantum state. We could have called it "A", "Some-Incredible-Name", or anything else. It's simply a convention to call it Ψ, no need to overthink it. The subscript "0" serves to label the state at an initial time (t = 0), it helps us see this is the initial state we're talking about. As we can see, Ψ, a quantum state, is made out of other states (|red⟩ and |eaten⟩)."
- Prose: "The numbers √(2/3) and 1/√3 are called *amplitudes*. We will cover them in more detail later, but in the meantime, we can think of them as indications of how much of each state we're adding into the "mix" that is Ψ, and as a result, how likely we are to find it. Sort of like weights for ingredients in a recipe." (Print artefact: stray "~" characters appear around the inline fractions on the site; removed.)

#### [p.4-5] Evolution
- Sub-heading: **Evolution**
- Prose: "Between time 0 and time 1, our quantum apple may evolve in the following way: the red apple rots, while the eaten apple remains eaten. Simple as that! Mathematically:"
- Equation E2 [p.5]:
$$\ket{\mathrm{red}} \mapsto \ket{\mathrm{rotten}}$$
$$\ket{\mathrm{eaten}} \mapsto \ket{\mathrm{eaten}}$$
- Prose: "Therefore the quantum state of the apple at time 1 would be:"
- Equation E3 [p.5]:
$$\ket{\Psi_1} = \sqrt{\tfrac{2}{3}}\,\ket{\mathrm{rotten}} + \tfrac{1}{\sqrt{3}}\,\ket{\mathrm{eaten}}\,.$$

#### [p.5-6] Gradual Evolution
- Sub-heading: **Gradual Evolution**
- Prose: "Let's now make this more interesting. When it starts rotting, the red apple won't rot all at once. It will be a gradual process over time. At first, the apple is mostly red, with just a tiny chance of being rotten. But as time moves forward, the "red" part shrinks while the "rotten" part grows."
- Prose: "So instead of the apple flipping from red → rotten in one step, it gradually shifts, like this:"
  - "At t = 0: all red, no rotten yet."
  - "At t = 0.25: mostly red, a little rotten."
  - "At t = 0.75: almost all rotten, barely red."
  - "At t = 1: fully rotten"
- Prose: "But in the meantime, the "eaten" part, however, stays exactly as it was. So for example, the state could evolve step by step like this:"
- Equation E4 [p.6] (four aligned lines, each prefixed by a text label):
$$\text{At } t=0:\quad \ket{\Psi_0} = \sqrt{\tfrac{2}{3}}\ket{\mathrm{red}} + \tfrac{1}{\sqrt{3}}\ket{\mathrm{eaten}}$$
$$\text{At } t=0.25:\quad \ket{\Psi_{0.25}} = \tfrac{1}{\sqrt{2}}\ket{\mathrm{red}} + \tfrac{1}{\sqrt{6}}\ket{\mathrm{rotten}} + \tfrac{1}{\sqrt{3}}\ket{\mathrm{eaten}}$$
$$\text{At } t=0.75:\quad \ket{\Psi_{0.75}} = \tfrac{1}{\sqrt{6}}\ket{\mathrm{red}} + \tfrac{1}{\sqrt{2}}\ket{\mathrm{rotten}} + \tfrac{1}{\sqrt{3}}\ket{\mathrm{eaten}}$$
$$\text{At } t=1:\quad \ket{\Psi_1} = \sqrt{\tfrac{2}{3}}\ket{\mathrm{rotten}} + \tfrac{1}{\sqrt{3}}\ket{\mathrm{eaten}}$$
  (Check: every line is normalized: 1/2+1/6+1/3 = 1 and 1/6+1/2+1/3 = 1. The eaten amplitude 1/√3 is constant throughout; the red/rotten pair shares the remaining weight 2/3.)
- Prose: "This is a simple model of how amplitudes can flow continuously between states. True physical processes, like radioactive decay, have a similar evolution. In a decay, a particle doesn't just suddenly vanish, it gradually shifts from one state into another, with the mixture of states changing step by step."
- Prose: "Changes in quantum states are gradual, like the apple that smoothly flows from one state into another, via a superposition. As we are often interested in the state at some key moments, for instance at times 0 and 1, the gradual change accumulates into a discrete change."

#### [p.7] Classical vs quantum evolution
- Prose: "This is a major difference with the classical picture, where our classical apple was described by *either* of the states "red", or "eaten". It was therefore evolving according to *either*"
- Equation E5 [p.7] (set in upright quoted text, not kets, to stress it is classical):
$$\text{"red"} \mapsto \text{"rotten"} \quad\text{or}\quad \text{"eaten"} \mapsto \text{"eaten"}\,.$$
- Prose: "On the other hand, our quantum apple is initially in a *superposition* of |red⟩, and |eaten⟩."
- Prose: "Therefore, between time 0 and time 1, the evolution of |red⟩ ↦ |rotten⟩, and |eaten⟩ ↦ |eaten⟩ happens in superposition."

#### [p.7-8] Measurement
- Sub-heading: **Measurement**
- Prose: "After time 1, suppose that we want to measure our quantum apple in order to determine if it is rotten or eaten. What should we expect?"
- Prose: "This is like opening Schrödinger's famous box with the cat inside, which is either alive or dead. Before we open the box, the apple's state includes both "rotten" and "eaten" at once. But when we check, we only observe one of the two outcomes: either a rotten apple, or an eaten apple."
- Prose: "The measurement device (our eyes, or any detector) will register one definite result. Quantum mechanics doesn't let us predict which one we will see, it only gives us probabilities. To find these probabilities, we simply square the amplitudes of the given states."
- Equation E6 [p.8] (two bullet lines with inline math):
  - "The outcome "rotten" will be recorded with probability" $$\left(\sqrt{\tfrac{2}{3}}\right)^{2} = \tfrac{2}{3};$$
  - "The outcome "eaten" will be recorded with probability" $$\left(\tfrac{1}{\sqrt{3}}\right)^{2} = \tfrac{1}{3};$$
- Prose: "This is just like Schrödinger's cat: the description includes multiple possibilities at once (the states in superposition), but our experience of opening the box always returns just one clear outcome."

- Figure [p.8] "A state is a vector of length 1." Style: flat, marker-like hand-drawn vector art on a pale blue-grey rounded panel (~2:1). Elements: one horizontal red-orange arrow pointing right, drawn slightly left of centre, with the bold red-orange label "|A⟩" immediately right of the arrowhead (the ket bars and angle bracket are drawn in the same rounded bold sans as the letter). Above the arrow, spanning exactly its length, a thin grey dimension line with short end ticks and the bold grey numeral "1" centred above it. No axes, no grid. Caption (italic, under the panel): "A state is a vector of length 1."

- Figure [p.9] "Distinguishable states are orthogonal kets." Same style and panel. Two arrows from a common origin at lower-left-centre: a purple arrow pointing straight up labelled "|B⟩" (purple, bold, placed at the tip, slightly right) and a red-orange arrow pointing right labelled "|A⟩" (red-orange, at the tip, below-right). Both arrows have the same length (unit). They form a right angle; no right-angle marker is drawn. Caption: "Distinguishable states are orthogonal kets."

### [p.10] The Mathematical Arena
- Heading (purple-blue serif): **The Mathematical Arena**
- Prose: "The quantum apple is a good teaser to get a generic idea of quantum mechanics. The superposition of states, the evolution that also happens in superposition, and the seemingly probabilistic measurement has already been expressed."
- Prose: "But in order to dive deeper into quantum mechanics, we must be able to go into the more mathematically precise descriptions of quantum systems, and for that, understand the various tools that are used. What even is a ket, "| ⟩"? And why are we allowed to add them like we did the description of |Ψ0⟩? What about the amplitudes... can they be any number?"
- Prose: "In this section, we address those questions by giving further details on what the mathematical objects are that are involved in quantum mechanics."

#### [p.10-13] Describing Quantum Systems
- Sub-heading: **Describing Quantum Systems**
- Prose: "Quantum states are represented by vectors of unit length, namely, of length equal to 1. This is what a *ket* is: a vector of unit length. Commonly, we write inside the ket a convenient label representing the state, such as |red⟩ for the color red or |A⟩ for a property labeled by A."
- Prose: "Two states, like |A⟩ and |B⟩ are *distinguishable* if it is possible to tell them apart with certainty, in which case they are then *orthogonal*. One can imagine orthogonality as two perpendicular arrows in 2D."

- Figure [p.11] "The states |φ1⟩, |φ2⟩ and |φ3⟩". Same panel style. From one origin (left-centre of the panel): red-orange arrow right = |A⟩ (label at tip, below-right); purple arrow up = |B⟩ (label at tip, above-right); and three black arrows of the same unit length with open "angle" arrowheads: |φ1⟩ at +45° (up-right, bisecting A and B), |φ3⟩ at +60° (steeper than φ1, closer to B), |φ2⟩ at −45° (down-right, mirror image of φ1 below the A axis). Labels "|φ1⟩", "|φ2⟩", "|φ3⟩" in bold black at the arrow tips, subscripts as small digits. Caption (italic): "The states |φ1⟩, |φ2⟩ and |φ3⟩ defined in the below equations. They arise from superposing |A⟩ and |B⟩."

- Prose [p.12]: "The superposition principle states that combinations of distinguishable states also form a valid quantum state, so long as the newly formed vector is also of unit length."
- Prose: "Thus, if |A⟩ and |B⟩ are valid orthogonal states, then by the superposition principle, all of the following states are also valid states:"
- Equation E7 [p.12]:
$$\ket{\phi_1} = \tfrac{1}{\sqrt{2}}\ket{A} + \tfrac{1}{\sqrt{2}}\ket{B}$$
$$\ket{\phi_2} = \tfrac{1}{\sqrt{2}}\ket{A} - \tfrac{1}{\sqrt{2}}\ket{B}$$
$$\ket{\phi_3} = \tfrac{1}{2}\ket{A} + \tfrac{\sqrt{3}}{2}\ket{B}\,.$$
- Prose: "Let us verify that |φ3⟩ is a vector of length one (also called a valid state, or a normalized state)."
- Prose: "Geometrically, the length of |φ3⟩ can be computed from the lengths of the horizontal and vertical projections. The horizontal projection, or the projection onto |A⟩, has length 1/2; and the vertical projection onto |B⟩, has length √3/2."
- Prose: "Using Pythagoras's theorem, we find that the length of |φ3⟩ is"
- Equation E8 [p.13]:
$$\sqrt{\left(\tfrac{1}{2}\right)^{2} + \left(\tfrac{\sqrt{3}}{2}\right)^{2}} = \sqrt{\tfrac{1}{4} + \tfrac{3}{4}} = \sqrt{1} = 1\,.$$
- Prose [p.13]: "Algebraically, we took the amplitudes, 1/2 and √3/2, squared them, and summed them to obtain 1. More generally, any state of the form α|A⟩ + β|B⟩ is a valid state, so long as the numbers α and β satisfy |α|² + |β|² = 1. In general, α and β can be *complex numbers* — not just real numbers like 1/√2. The notation |α|² means the squared magnitude (modulus) of α."
- Equation E9 (inline, normalization condition):
$$\alpha\ket{A} + \beta\ket{B} \text{ is valid iff } |\alpha|^{2} + |\beta|^{2} = 1 .$$
- Prose: "For real numbers, this is just the square; for complex numbers, it accounts for both real and imaginary parts. We will encounter complex amplitudes in later experiments, where they encode *phase* information that determines interference patterns."
- Prose: "The process of multiplying |A⟩ by α, multiplying |B⟩ by β, and adding them together is called *taking a linear combination* of |A⟩ and |B⟩."
- Prose: "The *superposition principle of quantum mechanics* tells us that linear combinations of valid states yield other valid states — as long as the normalization condition, |α|² + |β|² = 1, is satisfied."
  (Print/site artefact: on the live page the words "complex numbers", "phase", "taking a linear combination" and later "combination", "other" appear wrapped in raw LaTeX macros "\textit{...}", "\emph{...}", "{...}" that the site's renderer did not process. Transcribed here as the intended italics.)

#### [p.13-17] Evolving Quantum Systems
- Sub-heading [p.13 bottom]: **Evolving Quantum Systems**
- Prose [p.14]: "One of the central questions of quantum mechanics is how states change over time. A quantum system is described by a state vector, say |A⟩, for example. Over time, or through an interaction of some kind (measurement, rotation, etc.), the system's state evolves."
- Prose: "A strict rule of quantum theory is that when a physical transformation is applied to a valid state, meaning a state of unit length, the resulting state after the physical transformation must also be a valid state. This is important as length in this context relates to probabilities, and the probabilities must always add up to 1. Let's take an example."
- Prose: "Suppose we have two states, |A⟩ and |B⟩. Let's assume these states are orthogonal (like "up" and "down" directions, for example). Let's now imagine that the system can transform |A⟩ into another state |φ2⟩, and |B⟩ into |φ1⟩, as follows:"

- Figure [p.15] "Computing the length of |φ3⟩." Same panel style, larger. Origin at lower-left-centre. Red-orange arrow right = |A⟩ (label at tip, below-right, large). Purple arrow up = |B⟩ (label above, large). Black arrow |φ3⟩ at 60° from the A axis, same length as A and B. A grey dashed vertical line drops from the tip of |φ3⟩ to the A axis, labelled to its right in grey "√3 / 2" (stacked fraction). Along the A axis, from the origin to the foot of that dashed line, a grey dotted/dashed segment overlays the red arrow, labelled below in grey "1 / 2" (stacked fraction). This is the right-triangle construction for E8. Caption (italic): "Computing the length of |φ3⟩."

- Equation E10 [p.16] (set on one line; in the print the left-most "R4" of the first term and the final "B⟩" of the second term are clipped by the page margin, i.e. the equation is wider than the column; reconstructed from the surrounding prose):
$$R_{45}\ket{A} = \ket{\phi_2} = \tfrac{1}{\sqrt{2}}\ket{A} - \tfrac{1}{\sqrt{2}}\ket{B} \qquad\text{and}\qquad R_{45}\ket{B} = \ket{\phi_1} = \tfrac{1}{\sqrt{2}}\ket{A} + \tfrac{1}{\sqrt{2}}\ket{B}\,.$$
- Prose: "We called this transformation R45 for reasons we will clarify later, but intuitively it can be thought of as a kind of 45° rotation in a two-dimensional space. So far so good. But how does it act on *other* quantum states, meaning states other than |A⟩ or |B⟩?"
- Prose: "Quantum transformations are *linear*. Linearity in this context means if it is known how R45 affects a certain set of states (|A⟩ and |B⟩, for example), it is also known how it applies to any *combination* of those states. This may seem unimportant, or even trivial, but it's not, because quantum states are often in a superposition of different states. Linearity is very useful in those situations."
- Prose: "Let's compute how R45 acts on the state |φ1⟩ to illustrate this. We previously defined |φ1⟩ as |φ1⟩ = (1/√2)|A⟩ + (1/√2)|B⟩. Let's now apply R45 and use linearity:"
- Equation E11 [p.16]:
$$R_{45}\ket{\phi_1} = R_{45}\left(\tfrac{1}{\sqrt{2}}\ket{A} + \tfrac{1}{\sqrt{2}}\ket{B}\right) = \tfrac{1}{\sqrt{2}}R_{45}\ket{A} + \tfrac{1}{\sqrt{2}}R_{45}\ket{B}\,.$$
- Prose [p.17]: "Think of R45 as an *operator* that we apply to states. We can now substitute (|A⟩ and |B⟩ with the transformation equations of R45." (The unmatched "(" is on the site.)
- Equation E12 [p.17]:
$$= \tfrac{1}{\sqrt{2}}\left(\tfrac{1}{\sqrt{2}}\ket{A} - \tfrac{1}{\sqrt{2}}\ket{B}\right) + \tfrac{1}{\sqrt{2}}\left(\tfrac{1}{\sqrt{2}}\ket{A} + \tfrac{1}{\sqrt{2}}\ket{B}\right).$$
- Prose: "After simplifying, we find |A⟩ as the answer:"
- Equation E13 [p.17]:
$$= \tfrac{1}{2}\ket{A} - \tfrac{1}{2}\ket{B} + \tfrac{1}{2}\ket{A} + \tfrac{1}{2}\ket{B} = \ket{A}\,.$$
- (Site artefact: directly beneath E13 the page repeats E12 verbatim a second time. This is a duplicated equation block on the site, not new content.)
- Prose: "So to summarize, using linearity, we were able to find that" $$R_{45}\ket{\phi_1} = \ket{A}\,.$$ (E14)
- Prose: "The simplification that occurs in the above equation is an example of *constructive* and *destructive* interference. The contributions involving |A⟩ added together, resulting in constructive interference, while the contributions involving |B⟩ canceled each other out, showing a case of destructive interference. This is how interference manifests itself algebraically."

#### [p.17-18] Measuring Quantum Systems
- Sub-heading [p.17 bottom]: **Measuring Quantum Systems** (in the print the large purple "Similar Experiments" footer heading is overprinted on top of this sub-heading; both are real headings.)
- Prose [p.18]: "Taking our two orthogonal |A⟩ and |B⟩ states again, these represent two distinct outcomes that can be obtained when performing a measurement on the system. So if the system is in state |A⟩, it will return that result, and similarly if it's in |B⟩." (Site has stray "(" before each ket.)
- Prose: "But what if the system is in a superposition of these two states? Take the following system, where |Ψ⟩ is normalized such that |α|² + |β|² = 1:"
- Equation E15 [p.18]:
$$\ket{\Psi} = \alpha\ket{A} + \beta\ket{B}\,.$$
- Prose: "With the above system, if we apply a measurement, we get one of the two outcomes, either |A⟩ or |B⟩. We can't predict which of those outcomes we will get, but if we were to theoretically perform the measurement over and over again, the number of times we get |A⟩ and |B⟩ relative to the number of measurements will align with |α|² and |β|² respectively."

### [p.17-18] Similar Experiments (footer card row)
- Heading (purple-blue serif): **Similar Experiments**
- Three link cards, identical in style to the Home page grid (see 00-home.md for the thumbnail vocabulary):
  - INTRODUCTION — "Quantum for everyone" (thumbnail: the word OVERVIEW; i.e. this page itself).
  - EXPERIMENT 1 — "Polarizers" (thumbnail: four stacked laser → polarizer rows, P1 90°, P2 0°/45, P3 0°, D1, planes Ψ0-Ψ3).
  - EXPERIMENT 2 — "Single and double slit" (thumbnail: single-slit row and double-slit diamond row to D1, planes Ψ0, Ψ1 Ψ2, Ψ3).
- Links/downloads: no CSV, video, or embedded simulator on this page.

## Physics model for simulation
This page defines no optical apparatus; what it defines is the state-vector toolkit every later experiment uses. A programmer should implement the following.

### 1. State space
- Real 2-D (and, for the apple, 3-D) column vectors of unit Euclidean length. Basis kets are orthonormal: ⟨A|A⟩ = ⟨B|B⟩ = 1, ⟨A|B⟩ = 0. In this page every amplitude is real; the page warns that later pages use complex amplitudes (phase), so store amplitudes as complex from the start.
- Apple basis (3-D): |red⟩ = (1,0,0), |rotten⟩ = (0,1,0), |eaten⟩ = (0,0,1).
- Generic qubit basis (2-D): |A⟩ = (1,0), |B⟩ = (0,1). Named superpositions:
  - |φ1⟩ = (1/√2, 1/√2) (angle +45° from A),
  - |φ2⟩ = (1/√2, −1/√2) (angle −45°),
  - |φ3⟩ = (1/2, √3/2) (angle +60°).
- Validity check (normalization): |α|² + |β|² = 1 (E9). For drawing: a valid state is any arrow of length 1 from the origin; its angle θ from the A axis gives α = cos θ, β = sin θ.

### 2. Evolution
- Any physical transformation is a linear map that preserves unit length (a unitary; for real 2-D vectors, a rotation or reflection). Apply it to basis kets and extend by linearity (E11-E13).
- Apple evolution U (time 0 → 1): |red⟩ ↦ |rotten⟩, |eaten⟩ ↦ |eaten⟩ (E2). Result: |Ψ1⟩ = √(2/3)|rotten⟩ + (1/√3)|eaten⟩ (E3).
- Gradual apple evolution U(t): keep the eaten amplitude fixed at 1/√3 and rotate the (red, rotten) pair by an angle θ(t): red amplitude = √(2/3)·cos θ(t), rotten amplitude = √(2/3)·sin θ(t). The site's sample points correspond to θ(0)=0°, θ(0.25)=30° (cos 30° · √(2/3) = 1/√2, sin 30° · √(2/3) = 1/√6 ✓), θ(0.75)=60°, θ(1)=90°. Note these are not linear in t (linear would give 22.5° and 67.5° at t=0.25 and 0.75); the site only says "mostly red" / "almost all rotten". For animation, θ(t) = 90°·t is proposed (smooth, matches the end points, within a few percent of the site's intermediate amplitudes); if the exact site numbers must be hit at t = 0.25 and 0.75, use a lookup/ease curve through (0,0°), (0.25,30°), (0.75,60°), (1,90°).
- R45 operator, defined by E10: R45|A⟩ = |φ2⟩, R45|B⟩ = |φ1⟩. Matrix in the (A,B) basis (columns = images of basis vectors):
$$R_{45} = \begin{pmatrix} \tfrac{1}{\sqrt{2}} & \tfrac{1}{\sqrt{2}} \\ -\tfrac{1}{\sqrt{2}} & \tfrac{1}{\sqrt{2}} \end{pmatrix}$$
  Determinant = 1, so it is a proper rotation; geometrically it rotates vectors by −45° (clockwise), which is why R45|φ1⟩ (at +45°) lands on |A⟩ (at 0°) (E14). Also R45|φ2⟩ = −|B⟩ and R45|φ3⟩ = (cos 15°, sin 15°) ≈ (0.966, 0.259). The site itself only says "a kind of 45° rotation" and promises to clarify the name later; the game should show the arrow rotating clockwise by 45° for visual consistency with E10.
- Interference bookkeeping (for the narration): when expanding R45|φ1⟩, the |A⟩ coefficients ½ + ½ add (constructive) and the |B⟩ coefficients −½ + ½ cancel (destructive).

### 3. Measurement
- Measuring in the {|A⟩, |B⟩} basis: outcome A with probability |α|², outcome B with |β|² (E15 and the final paragraph). For the apple at t = 1 in the {rotten, eaten} basis: P(rotten) = 2/3, P(eaten) = 1/3 (E6). (At intermediate times, measuring in {red, rotten, eaten} gives P(red) = (2/3)cos²θ, P(rotten) = (2/3)sin²θ, P(eaten) = 1/3; e.g. t = 0.25: 1/2, 1/6, 1/3.)
- Implementation: draw a uniform random number r ∈ [0,1); return A if r < |α|², else B; after the outcome, the state is the corresponding basis ket (the page says only that "one definite result" is registered; it does not state the post-measurement state explicitly, but the Schrödinger's-cat framing implies it).
- Frequencies: a repeated-measurement counter should converge to |α|² and |β|² (the page phrases it as relative frequencies over many trials; the game can show a tally bar).

### 4. Lab numbers
None on this page (purely theoretical). No wavelengths, slit widths, or distances are given.

## Apparatus list (for Blender)
No physical apparatus appears on this page. The only pictorial elements are the four 2-D vector diagrams (pp. 8, 9, 11, 15) and the three "Similar Experiments" thumbnails, which are the Home page thumbnails (Introduction / Experiment 1 / Experiment 2) and are inventoried in 00-home.md. Items that a game scene might stage for the apple analogy (fridge, red apple, rotten apple, eaten apple core, Schrödinger's box with a cat) are the site's verbal analogies only ("assumed" if modelled).

If the vector diagrams are rebuilt as in-game 2-D art, match the site: pale blue-grey panel (#F4F6FB-like) with rounded corners; |A⟩ red-orange (#E8533A-like) horizontal arrow; |B⟩ purple (#7B4FE0-like) vertical arrow; |φn⟩ black arrows with open angle-shaped heads; grey dashed projection lines and grey stacked fractions; labels in a bold rounded sans with the ket bars drawn as glyphs; italic grey captions beneath the panel.

## Teaching notes
Order in which the page needs each idea (teach just-in-time):
1. States and time evolution as "frames of a movie" (classical intuition; no maths).
2. Classical definite states ("red", "eaten") vs a quantum superposition written with kets and numerical weights; the Ψ naming convention and the subscript as a time label.
3. Amplitudes as "weights for ingredients in a recipe"; the specific numbers √(2/3), 1/√3 (square roots and fractions).
4. Evolution rules applied component-wise (|red⟩ ↦ |rotten⟩, |eaten⟩ ↦ |eaten⟩), then "in superposition"; gradual evolution as continuous flow of amplitude (analogy: radioactive decay), with a three-term state and the realisation that each line still sums squares to 1.
5. Measurement: one definite outcome; probability = amplitude squared (Schrödinger's cat analogy, used twice).
6. Vectors in 2-D as arrows; length of a vector; the unit length requirement (figure p.8).
7. Orthogonality = perpendicular arrows = distinguishable states (figure p.9).
8. Linear combinations / superposition principle; the family φ1, φ2, φ3 (figure p.11); signs of amplitudes (φ2 has a minus).
9. Projections and Pythagoras's theorem to verify unit length (figure p.15, E8); generalisation |α|²+|β|²=1.
10. Complex numbers (mentioned only: modulus squared, phase, interference later). The game can defer this to Experiment 2/3.
11. Linear operators: define on a basis, extend by linearity; R45 as a 45° rotation; worked substitution (E10-E14).
12. Constructive vs destructive interference as the cancellation of like terms in that algebra (prepares the slit experiments).
13. Measurement in a basis of a general superposition α|A⟩+β|B⟩: frequencies |α|², |β|².

The site's pedagogical moves: start "in the middle" with simple possibly-inaccurate statements and refine later; everyday analogy (apple in a fridge) before abstraction; repeated Schrödinger's-cat framing for measurement; explicit reassurance ("don't worry about this special notation for now", "no need to overthink it"); every claim backed by a fully worked numerical example (2/3 and 1/3; the length of φ3; R45|φ1⟩); geometry (arrows, projections) and algebra (squares summing to 1) presented side by side; forward references ("we will clarify later", "later experiments") to motivate the next pages.

## Open questions
- Sidebar TABLE OF CONTENT (Abstract / Lab Experiments / Result and analysis / Theory and equations / Literature and video) does not match the page's actual headings; only "Abstract" exists. It appears to be the shared page template.
- E10 is clipped at both margins in the print (shows "5|A⟩ = |φ2⟩ = ..." and "... + (1/√2)|E"). Reconstructed as R45|A⟩ and ...|B⟩ from the prose; verify on the live site.
- E12 is printed twice (once before and once after E13); assumed to be a site duplication, not a distinct step.
- Raw LaTeX macros (\textit{...}, \emph{...}, {other}) are visible in the live text on p.13 and p.16; transcribed as italics.
- The site never says which direction R45 rotates; the definition in E10 implies a clockwise (−45°) rotation in the A-right/B-up picture. It says the name "R45" will be clarified later (presumably in Experiment 1, where it will correspond to a 45° polarizer / basis change).
- The gradual-evolution sample amplitudes correspond to θ = 30°, 60° at t = 0.25, 0.75, not to a linear-in-time rotation; the site gives no formula.
- Post-measurement state is not stated explicitly.
- "Quantum formalism" (file C) is the same page as this one (A); no separate content.
