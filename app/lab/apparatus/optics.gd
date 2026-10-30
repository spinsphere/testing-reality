## Concrete optical elements built on [Apparatus]. One small class per element so labs can
## compose them; all angles are degrees from horizontal as on the site.
class_name Optics


class Laser extends Apparatus:
	## Prepares the photon: sets the polarization property and (optionally) the path property.
	var wavelength_nm := 405.0
	var polarization_deg := 45.0
	var power_photons_per_s := 1159.0

	func _init(p_wavelength: float = 405.0, p_pol: float = 45.0, p_label: String = "LASER") -> void:
		label = p_label
		display_name = "Diode laser (%d nm)" % int(p_wavelength)
		model = "laser_module"
		wavelength_nm = p_wavelength
		polarization_deg = p_pol
		description = "A laser diode. Its light is prepared with a definite polarization before it reaches the first element."
		add_param("polarization", {"label": "Prepared polarization", "type": "float", "min": -90.0, "max": 90.0, "step": 0.5, "unit": "°", "value": p_pol,
			"help": "The polarization angle of the photons leaving the preparation stage (0° = horizontal ↔, 90° = vertical ↕, 45° = diagonal ↗↙)."})

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		sys.add_property(ctx["pol"], ctx["live"])
		sys.set_linear_polarization(ctx["pol"], ctx["live"], float(get_param("polarization")))

	func summary() -> String:
		return "%s · %d nm" % [label, int(wavelength_nm)]


class Polarizer extends Apparatus:
	## A linear polarizer in a rotation mount. Blocked light goes to `lost@<label>`.
	var when: Dictionary = {}  # optional predicate (e.g. only on path A)

	func _init(p_label: String = "P1", p_angle: float = 0.0, p_when: Dictionary = {}) -> void:
		label = p_label
		display_name = "Linear polarizer %s" % p_label
		model = "polarizer_rotation_mount"
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
		model_root.position.y = 0.0 if bool(get_param("enabled")) else 0.06
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
		model = "lens_mount"
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

	func _init(p_label: String = "D1") -> void:
		label = p_label
		display_name = "Single-photon detector"
		model = "spcm_detector"
		description = "A single-photon counting module. Every photon that is not lost on the way produces a click; the click rate is the beam intensity."

	func is_detector() -> bool:
		return true

	func apply(sys: QuagmireSystem, ctx: Dictionary) -> void:
		last_probability = sys.probability({"alive": PackedStringArray([ctx["pol"]])})

	func summary() -> String:
		return "%s · %d %%" % [label, roundi(last_probability * 100.0)]
