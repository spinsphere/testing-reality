## Concrete optical elements built on [Apparatus]. One small class per element so labs can
## compose them; all angles are degrees from horizontal as on the site.
class_name Optics


class Laser extends Apparatus:
	## Prepares the photon: sets the polarization property and (optionally) the path property.
	## `on` is the shutter; `power` the photon rate the source delivers (photons / s), which every
	## count rate in the lab scales with.
	var wavelength_nm := 405.0
	var polarization_deg := 45.0
	var power_photons_per_s := 1159.0

	func _init(p_wavelength: float = 405.0, p_pol: float = 45.0, p_label: String = "LASER", p_power: float = 1159.0) -> void:
		label = p_label
		display_name = "Diode laser (%d nm)" % int(p_wavelength)
		model = "laser_405"
		wavelength_nm = p_wavelength
		polarization_deg = p_pol
		power_photons_per_s = p_power
		description = "A laser diode. Its light is prepared with a definite polarization before it reaches the first element. Close the shutter to stop the experiment; the power sets how many photons per second go down the beam."
		add_param("on", {"label": "Shutter open", "type": "bool", "value": true,
			"help": "Close the shutter to stop the beam: no photons, no counts. Every other setting is kept."})
		add_param("power", {"label": "Power", "type": "float", "min": 50.0, "max": 5000.0, "step": 10.0, "unit": " photons/s", "value": p_power,
			"help": "Photons per second leaving the preparation stage. All predicted rates and the live counts scale with it."})
		add_param("polarization", {"label": "Prepared polarization", "type": "float", "min": -90.0, "max": 90.0, "step": 0.5, "unit": "°", "value": p_pol,
			"help": "The polarization angle of the photons leaving the preparation stage (0° = horizontal ↔, 90° = vertical ↕, 45° = diagonal ↗↙)."})

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		sys.add_property(ctx["pol"], ctx["live"])
		sys.set_linear_polarization(ctx["pol"], ctx["live"], float(get_param("polarization")))

	func is_on() -> bool:
		return bool(get_param("on"))

	func summary() -> String:
		if not is_on():
			return "%s · shutter closed" % label
		return "%s · %d nm · %d /s" % [label, int(wavelength_nm), roundi(float(get_param("power")))]


class Polarizer extends Apparatus:
	## A linear polarizer in a rotation mount. Blocked light goes to `lost@<label>`.
	var when: Dictionary = {}  # optional predicate (e.g. only on path A)

	## Sideways slide (metres, along the table's z) that represents "taken out of the beam":
	## a rotation mount is lifted off its post and set down beside the beam; a film glued on
	## the slit mask is moved to the side of the plate.
	var out_offset := 0.09

	func _init(p_label: String = "P1", p_angle: float = 0.0, p_when: Dictionary = {}, p_model: String = "polarizer_rotation_mount") -> void:
		label = p_label
		display_name = "Linear polarizer %s" % p_label
		model = p_model
		if p_model == "polarizer_film":
			out_offset = 0.02
			display_name = "Polarizer film %s" % p_label
		when = p_when
		description = "Transmits the component of the light polarized along its axis and absorbs the perpendicular component. Rotate it with the slider."
		add_param("angle", {"label": "Axis angle", "type": "float", "min": -90.0, "max": 90.0, "step": 0.5, "unit": "°", "value": p_angle,
			"help": "0° transmits horizontal ↔, 90° transmits vertical ↕, ±45° the diagonals."})
		add_param("enabled", {"label": "In the beam", "type": "bool", "value": true, "help": "Lift the polarizer out of the beam to remove it from the experiment."})

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		if not bool(get_param("enabled")):
			return
		sys.polarizer(ctx["pol"], ctx["live"], float(get_param("angle")), "lost@%s" % label, when)

	func summary() -> String:
		if not bool(get_param("enabled")):
			return "%s · out" % label
		return "%s · %s°" % [label, _fmt(float(get_param("angle")))]

	func refresh_visual() -> void:
		super()
		var rotor := _find_rotor()
		if rotor:
			rotor.rotation_degrees.x = -float(get_param("angle"))
		# out of the beam = set down beside it on the table (never floating above it)
		model_root.position = Vector3(0.0, 0.0, 0.0 if bool(get_param("enabled")) else out_offset)
		model_root.visible = true

	func _find_rotor() -> Node3D:
		return model_root.find_child("Rotor", true, false) as Node3D

	static func _fmt(v: float) -> String:
		return ("%d" % roundi(v)) if is_equal_approx(v, roundf(v)) else ("%.1f" % v)


class HalfWavePlate extends Apparatus:
	func _init(p_label: String = "λ/2", p_angle: float = 22.5) -> void:
		label = p_label
		display_name = "Half-wave plate"
		model = "half_wave_plate"
		description = "A birefringent plate that rotates linear polarization: light at angle θ to its fast axis comes out at −θ (so the plate at 22.5° turns horizontal into diagonal). It does not absorb light."
		add_param("angle", {"label": "Fast-axis angle", "type": "float", "min": -90.0, "max": 90.0, "step": 0.5, "unit": "°", "value": p_angle})

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		sys.half_wave_plate(ctx["pol"], ctx["live"], float(get_param("angle")))

	func summary() -> String:
		return "%s · %.1f°" % [label, float(get_param("angle"))]

	func refresh_visual() -> void:
		super()
		var rotor := model_root.find_child("Rotor", true, false) as Node3D
		if rotor:
			rotor.rotation_degrees.x = -float(get_param("angle"))


class Lens extends Apparatus:
	var focal_mm := 500.0

	func _init(p_label: String = "L1", p_focal_mm: float = 500.0) -> void:
		label = p_label
		display_name = "Plano-convex lens"
		model = "lens_mount_f500"
		focal_mm = p_focal_mm
		description = "Focuses or collimates the beam. It does not change the quantum state we track here; it only keeps the photons on the detector."

	func summary() -> String:
		return "%s · f = %d mm" % [label, int(focal_mm)]


class BeamSplitterCube extends Apparatus:
	## Polarizing beam splitter used in the preparation stage (transmits H, reflects V).
	func _init(p_label: String = "BS") -> void:
		label = p_label
		display_name = "Polarizing beam-splitter cube"
		model = "pbs_cube"
		description = "A cube that transmits horizontally polarized light and reflects vertically polarized light into a beam dump. Together with the half-wave plate it prepares a clean polarization."

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		# Preparation stage: keep the transmitted (horizontal) part as the beam.
		sys.polarizer(ctx["pol"], ctx["live"], 0.0, "lost@%s" % label, {})

	func summary() -> String:
		return label


class Detector extends Apparatus:
	## Single-photon counting module. Reports the probability that a photon arrives.
	var last_probability := 0.0
	## Extra properties that must also be "alive" for a click (e.g. the idler path, which a wall
	## can send to a sink).
	var extra_alive := PackedStringArray()

	func _init(p_label: String = "D1") -> void:
		label = p_label
		display_name = "Single-photon detector"
		model = "spcm_detector"
		description = "A single-photon counting module. Every photon that is not lost on the way produces a click; the click rate is the beam intensity."

	func is_detector() -> bool:
		return true

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		var props := PackedStringArray([ctx["pol"]])
		props.append_array(extra_alive)
		last_probability = sys.probability({"alive": props})

	func summary() -> String:
		return "%s · %d %%" % [label, roundi(last_probability * 100.0)]


class SlitMask extends Apparatus:
	## The in-house double slit. Creates the path property: |S⟩ → (|A⟩ + |B⟩)/√2.
	## Mode "double" opens both slits; "A only" / "B only" cover one slit.
	const MODES := ["double", "A only", "B only"]

	func _init(p_label: String = "SLIT", p_width_um: float = 200.0, p_sep_um: float = 400.0) -> void:
		label = p_label
		display_name = "Double slit mask"
		model = "double_slit_mask"
		description = "Two parallel slits cut in an opaque plate (made in-house). A photon that passes is in a superposition of 'through slit A' and 'through slit B'. Cover one slit to see a single-slit pattern."
		add_param("mode", {"label": "Open slits", "type": "enum", "options": MODES, "value": "double", "help": "Cover one slit to compare single-slit diffraction with the double-slit pattern."})
		add_param("width", {"label": "Slit width w", "type": "float", "min": 50.0, "max": 400.0, "step": 10.0, "unit": " µm", "value": p_width_um, "help": "Narrower slits spread the light more (wider envelope)."})
		add_param("separation", {"label": "Slit separation d", "type": "float", "min": 150.0, "max": 1000.0, "step": 10.0, "unit": " µm", "value": p_sep_um, "help": "Centre-to-centre distance. Larger d → closer fringes (spacing λL/d)."})

	func open_slits() -> PackedStringArray:
		match str(get_param("mode")):
			"A only":
				return PackedStringArray(["A"])
			"B only":
				return PackedStringArray(["B"])
		return PackedStringArray(["A", "B"])

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		sys.add_property(ctx["path"], PackedStringArray(["S"]))
		var slits := open_slits()
		sys.slits(ctx["path"], "S", slits, 1.0, 0.0, "")
		# make sure both labels exist so the screen geometry resolves
		sys.add_label(ctx["path"], "A")
		sys.add_label(ctx["path"], "B")

	func summary() -> String:
		return "%s · w %d µm · d %d µm · %s" % [label, int(get_param("width")), int(get_param("separation")), str(get_param("mode"))]

	func refresh_visual() -> void:
		super()
		var cover := model_root.find_child("Cover", true, false) as Node3D
		if cover:
			match str(get_param("mode")):
				"A only":
					cover.visible = true
					cover.position.z = -0.0004
				"B only":
					cover.visible = true
					cover.position.z = 0.0004
				_:
					cover.visible = false


class ScanningDetector extends Apparatus:
	## Single-photon detector on a motorised linear stage, with a narrow slit in front.
	## The lab computes the full scan profile; `position_mm` is where the detector sits now.
	var last_rate := 0.0

	func _init(p_label: String = "D1", p_half_range_mm: float = 3.0) -> void:
		label = p_label
		display_name = "Scanning single-photon detector"
		model = "spcm_detector"
		description = "A single-photon counting module behind a 200 µm slit, carried by a motorised stage that steps across the beam. Counting at each step builds up the pattern."
		add_param("position", {"label": "Detector position", "type": "float", "min": -p_half_range_mm, "max": p_half_range_mm, "step": 0.05, "unit": " mm", "value": 0.0, "help": "Move the detector across the pattern; the count rate follows the curve."})
		add_param("slit", {"label": "Detector slit", "type": "float", "min": 50.0, "max": 500.0, "step": 10.0, "unit": " µm", "value": 200.0, "help": "A wider slit collects more light but blurs fine fringes."})
		add_param("range", {"label": "Scan half-range", "type": "float", "min": 1.0, "max": 6.0, "step": 0.5, "unit": " mm", "value": p_half_range_mm})
		add_param("distance", {"label": "Effective slit → detector distance L", "type": "float", "min": 0.2, "max": 2.0, "step": 0.05, "unit": " m", "value": 0.5, "help": "With a lens between the slits and the detector, L is the focal length (the far-field pattern forms in the focal plane)."})

	func is_detector() -> bool:
		return true

	func summary() -> String:
		return "%s · %.2f mm · %d /s" % [label, float(get_param("position")), roundi(last_rate)]

	func refresh_visual() -> void:
		super()
		model_root.position.z = float(get_param("position")) / 1000.0 * 40.0  # exaggerated ×40 so motion is visible


class SPDCSource extends Apparatus:
	## Two thin type-I BBO crystals at 90°: converts a pump photon into a polarization-
	## entangled pair (signal "pol1", idler "pol2"). |↔⟩_pump → |↕⟩|↕⟩, |↕⟩_pump → e^{iφ}|↔⟩|↔⟩.
	func _init(p_label: String = "BBO") -> void:
		label = p_label
		display_name = "BBO crystal pair (SPDC source)"
		model = "bbo_crystal"
		description = "Two thin beta-barium-borate crystals glued with their axes at 90°. Very rarely, a 405 nm pump photon splits into two 810 nm photons whose polarizations are entangled: both vertical or both horizontal, with the amplitudes set by the pump polarization."
		add_param("phase", {"label": "Relative phase φ", "type": "float", "min": -180.0, "max": 180.0, "step": 5.0, "unit": "°", "value": 0.0, "help": "The phase between the |↕↕⟩ and |↔↔⟩ parts. The Berek compensator before the crystal is used to set it to zero (|Φ⁺⟩)."})
		add_param("pairs", {"label": "Detected pair rate", "type": "float", "min": 50.0, "max": 5000.0, "step": 50.0, "unit": " pairs/s", "value": 1500.0,
			"help": "Photon pairs per second that reach the detectors when nothing blocks them. A real source makes many more singles than pairs (most partners miss the detectors); here both are counted per pair so the ratios are exact."})

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		sys.spdc(ctx["pol"], ctx["live"], "pol1", "pol2", ctx["live"], float(get_param("phase")))
		sys.add_property("idler_path", PackedStringArray(["D2"]))
		set_meta("wavelength_after", 810.0)

	func summary() -> String:
		return "%s · φ = %d°" % [label, int(get_param("phase"))]


class Berek extends Apparatus:
	## Variable retarder: fine-tunes the phase between ↔ and ↕ of the pump.
	func _init(p_label: String = "Berek") -> void:
		label = p_label
		display_name = "Berek compensator"
		model = "berek_compensator"
		description = "A tiltable crystal plate acting as a variable wave plate. Tilting it changes the phase delay between the horizontal and vertical components of the pump, which fixes the sign and phase of the entangled state."
		add_param("retardance", {"label": "Retardance δ", "type": "float", "min": 0.0, "max": 360.0, "step": 5.0, "unit": "°", "value": 0.0})
		add_param("axis", {"label": "Axis angle", "type": "float", "min": -90.0, "max": 90.0, "step": 1.0, "unit": "°", "value": 0.0})

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		sys.retarder(ctx["pol"], ctx["live"], float(get_param("axis")), float(get_param("retardance")))

	func summary() -> String:
		return "%s · δ = %d°" % [label, int(get_param("retardance"))]


class Mirror extends Apparatus:
	func _init(p_label: String = "M1", p_yaw: float = 45.0) -> void:
		label = p_label
		display_name = "Mirror in kinematic mount"
		model = "mirror_kinematic"
		rotation_degrees.y = p_yaw
		description = "A dielectric mirror on a two-axis kinematic mount; it only folds the beam to fit the table."

	func summary() -> String:
		return label


class BeamDump extends Apparatus:
	func _init(p_label: String = "BD") -> void:
		label = p_label
		display_name = "Beam dump"
		model = "beam_dump"
		description = "Absorbs the unwanted reflected beam from the polarizing beam splitter."

	func summary() -> String:
		return label


class CoincidenceCounter extends Apparatus:
	## Counting electronics beside the table: its display shows the live acquisition.
	var counts: Dictionary = {}

	func _init(p_label: String = "CC") -> void:
		label = p_label
		display_name = "Coincidence counter"
		model = "coincidence_counter"
		description = "The detectors' pulses come here. Each channel is counted, and two pulses arriving within a 10 ns window are counted as a coincidence: both photons of one pair were detected. Press Run in the COUNTING panel to start an acquisition."

	func set_counts(p_counts: Dictionary) -> void:
		counts = p_counts
		refresh_visual()

	func summary() -> String:
		if counts.is_empty():
			return "%s · idle" % label
		var parts: PackedStringArray = []
		for k in counts:
			parts.append("%s %d" % [k, int(counts[k])])
		return "%s\n%s" % [label, "   ".join(parts)]


class Wall extends Apparatus:
	## A removable black wall on the idler arm (Experiment 7).
	func _init(p_label: String = "WALL") -> void:
		label = p_label
		display_name = "Black wall (beam block)"
		model = "beam_dump"
		description = "An opaque screen that absorbs the idler photon before it can reach D2. It can be anywhere on the idler path — 1 cm or 22 km from the crystal."
		add_param("enabled", {"label": "Wall in the beam", "type": "bool", "value": false})

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		if bool(get_param("enabled")):
			sys.relabel("idler_path", "D2", "wall", {})
			sys.mark_sink("idler_path", "wall")

	func summary() -> String:
		return "%s · %s" % [label, "in" if bool(get_param("enabled")) else "out"]

	func refresh_visual() -> void:
		super()
		# the wall is slid aside, not conjured away
		model_root.position = Vector3(0.0, 0.0, 0.0 if bool(get_param("enabled")) else 0.09)
