extends LabBase
## Experiment 1 — Polarizers and the three-polarizer paradox.
## LASER → (BS + λ/2 preparation, fixed) → L1 → P1 → P2 → P3 → D1.

const I0 := 1159.0  # photons/s with no polarizer, from the site's lab table

var p1: Optics.Polarizer
var p2: Optics.Polarizer
var p3: Optics.Polarizer
var detector: Optics.Detector
var laser: Optics.Laser
var _meter: ProgressBar
var _counts := {"detected": 0, "lost": 0}
var _count_label: Label


func _init() -> void:
	chapter_id = "exp1"


func build() -> void:
	laser = place(Optics.Laser.new(405.0, 45.0, "LASER", I0), -0.52)
	place(Optics.Lens.new("L1", 500.0), -0.33)
	p1 = place(Optics.Polarizer.new("P1", 0.0), -0.14)
	p2 = place(Optics.Polarizer.new("P2", 45.0), 0.05)
	p3 = place(Optics.Polarizer.new("P3", 90.0), 0.24)
	detector = place(Optics.Detector.new("D1"), 0.48)
	p2.set_param("enabled", false, false)
	p3.set_param("enabled", false, false)

	add_preset("No polarizer", func() -> void: _configure(false, 0, false, 45, false, 90),
		"Only the diagonal preparation: 100 % reaches the detector.")
	add_preset("One (0°)", func() -> void: _configure(true, 0, false, 45, false, 90),
		"A horizontal polarizer: half the diagonal light passes.")
	add_preset("Two (0°, 90°)", func() -> void: _configure(true, 0, false, 45, true, 90),
		"Crossed polarizers: nothing passes.")
	add_preset("Three (0°, 45°, 90°)", func() -> void: _configure(true, 0, true, 45, true, 90),
		"Insert a 45° polarizer between the crossed pair: 12.5 % passes!")

	controller.ctx["wavelength"] = 405.0
	camera_rig.set_home(Vector3(0.0, BEAM_HEIGHT, 0.0), 1.45, -24.0, 22.0)


func _configure(e1: bool, a1: float, e2: bool, a2: float, e3: bool, a3: float) -> void:
	p1.set_param("enabled", e1, false)
	p1.set_param("angle", a1, false)
	p2.set_param("enabled", e2, false)
	p2.set_param("angle", a2, false)
	p3.set_param("enabled", e3, false)
	p3.set_param("angle", a3, false)
	_counts = {"detected": 0, "lost": 0}


func on_rebuilt(_snapshots: Array, _result: Dictionary) -> void:
	clear_results()
	var p := detector.last_probability
	add_result_row("Transmission to D1", "%.1f %%" % (p * 100.0), Palette.ACCENT_SOFT)
	add_result_row("Predicted count rate", "%d photons / s" % roundi(p * controller.rate_scale()))
	var n_active := 0
	for pol in [p1, p2, p3]:
		if bool(pol.get_param("enabled")):
			n_active += 1
	var lab := _lab_reference(n_active)
	if lab != "":
		add_result_row("Measured in the lab", lab, Palette.TEXT_DIM)
	_meter = ProgressBar.new()
	_meter.max_value = 1.0
	_meter.value = p
	_meter.show_percentage = false
	_meter.custom_minimum_size = Vector2(0, 10)
	add_result_control(_meter)
	# Malus's law for the selected polarizer, as a product of cos² factors
	var expl := _explain()
	if expl != "":
		var r := BlockFactory.rich_text(expl)
		r.add_theme_color_override("default_color", Palette.TEXT_DIM)
		add_result_control(r)
	_count_label = Label.new()
	_count_label.theme_type_variation = "Mono"
	_count_label.text = "photon mode: press Space to fire single photons"
	add_result_control(_count_label)
	_refresh_counts()


func _lab_reference(n_active: int) -> String:
	# From the site's table (background-subtracted, relative to 1159/s)
	match n_active:
		0:
			return "1159 /s  (100 %)"
		1:
			var a := float(p1.get_param("angle")) if bool(p1.get_param("enabled")) else 0.0
			if is_equal_approx(a, 0.0):
				return "616 /s  (35 % raw, ≈50 % after background)"
			if is_equal_approx(a, 22.5):
				return "884 /s  (67 % raw, ≈85 % after background)"
			if is_equal_approx(a, 45.0):
				return "1159 /s  (100 %)"
			if is_equal_approx(a, -45.0):
				return "322 /s  (0 % after background)"
			return ""
		2:
			return "439 /s  (≈0 % after background)"
		3:
			return "564 /s  (≈12.5 % after background — 28.9 % raw)"
	return ""


func _explain() -> String:
	var parts: PackedStringArray = []
	var prev := float(laser.get_param("polarization"))
	var total := 1.0
	for pol in [p1, p2, p3]:
		if not bool(pol.get_param("enabled")):
			continue
		var a := float(pol.get_param("angle"))
		var f := pow(cos(deg_to_rad(a - prev)), 2.0)
		parts.append("cos²(%s° − %s°) = %.3f" % [_deg(a), _deg(prev), f])
		total *= f
		prev = a
	if parts.is_empty():
		return "No polarizer: every photon reaches the detector."
	return "Each polarizer keeps cos²(angle difference) of the light that reaches it, and leaves it polarized along its own axis:\n" + "  ×  ".join(parts) + "  =  [b]%.3f[/b]" % total


func _deg(v: float) -> String:
	return ("%d" % roundi(v)) if is_equal_approx(v, roundf(v)) else ("%.1f" % v)


func _photon_arrived(_photon: Dictionary, index: int) -> void:
	if controller.components[index].is_detector():
		_counts["detected"] += 1
	else:
		_counts["lost"] += 1
	_refresh_counts()


func _refresh_counts() -> void:
	if _count_label == null or not is_instance_valid(_count_label):
		return
	var total: int = _counts["detected"] + _counts["lost"]
	if total == 0:
		_count_label.text = "photon mode: press Space to fire single photons"
	else:
		_count_label.text = "single photons: %d detected / %d sent  (%.1f %%)" % [_counts["detected"], total, 100.0 * _counts["detected"] / total]
