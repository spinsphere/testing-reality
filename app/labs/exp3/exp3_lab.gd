extends SlitLabBase
## Experiment 3 — Polarized double slit (quantum eraser). 405 nm laser prepared diagonal,
## PA (0°) on slit A, PB (90°) on slit B, rotatable P1 after the slits, scanning D1.

var pa: Optics.Polarizer
var pb: Optics.Polarizer
var p1: Optics.Polarizer


func _init() -> void:
	chapter_id = "exp3"


func build() -> void:
	var laser := place(Optics.Laser.new(405.0, 0.0, "LASER"), -0.54)
	laser.model = "laser_405"
	place(Optics.BeamSplitterCube.new("BS"), -0.44)
	place(Optics.HalfWavePlate.new("λ/2", 22.5), -0.36)
	place(Optics.Lens.new("L1", 500.0), -0.24)
	var m := place(Optics.SlitMask.new("SLIT", 200.0, 400.0), -0.06)
	pa = place(Optics.Polarizer.new("PA", 0.0, {"is": {"path": "A"}}), -0.03, 0.03)
	pb = place(Optics.Polarizer.new("PB", 90.0, {"is": {"path": "B"}}), -0.03, -0.03)
	pa.display_name = "Polarizer on slit A"
	pb.display_name = "Polarizer on slit B"
	place(Optics.Lens.new("L2", 500.0), 0.12)
	p1 = place(Optics.Polarizer.new("P1", 45.0), 0.26)
	p1.display_name = "Third polarizer (eraser)"
	var d := place(Optics.ScanningDetector.new("D1", 3.0), 0.50)
	setup_slit_lab(m, d, 405.0, 0.9)
	set_overlays([
		{"name": "lab: P1 = 45°", "file": "res://data/lab/experiment-3/Data_exp3_-_data_45.csv", "pos_col": 2, "count_col": 3, "window": 2.0, "centre_um": 20000.0},
		{"name": "lab: P1 = −45°", "file": "res://data/lab/experiment-3/Data_exp3_-_data_-45.csv", "pos_col": 2, "count_col": 3, "window": 2.0, "centre_um": 20000.0},
		{"name": "lab: P1 = 0°", "file": "res://data/lab/experiment-3/Data_exp3_-_data_0.csv", "pos_col": 2, "count_col": 3, "window": 2.0, "centre_um": 20000.0},
		{"name": "lab: P1 = 90°", "file": "res://data/lab/experiment-3/Data_exp3_-_data_90.csv", "pos_col": 2, "count_col": 3, "window": 2.0, "centre_um": 20000.0},
	])
	overlay_index = 1
	add_preset("P1 45°", func() -> void: _set_p1(45.0, 1), "Erase which-way information: fringes return.")
	add_preset("P1 −45°", func() -> void: _set_p1(-45.0, 2), "The complementary fringes: maxima and minima swap.")
	add_preset("P1 0°", func() -> void: _set_p1(0.0, 3), "Select photons from slit A only: no fringes.")
	add_preset("P1 90°", func() -> void: _set_p1(90.0, 4), "Select photons from slit B only: no fringes.")
	add_preset("P1 out", func() -> void:
		p1.set_param("enabled", false, false)
		overlay_index = 0, "Which-way information intact: flat envelope at half intensity.")
	camera_rig.set_home(Vector3(0.0, BEAM_HEIGHT, 0.0), 1.35, -30.0, 20.0)


func _set_p1(angle: float, overlay: int) -> void:
	p1.set_param("enabled", true, false)
	p1.set_param("angle", angle, false)
	overlay_index = overlay


func on_rebuilt(snapshots: Array, result: Dictionary) -> void:
	var a := float(p1.get_param("angle"))
	var pred := 0.5 * (1.0 + sin(deg_to_rad(2.0 * a))) if bool(p1.get_param("enabled")) else 0.5
	_summary_rows = [
		["Which-way marking", "PA %d°, PB %d° (%s)" % [int(pa.get_param("angle")), int(pb.get_param("angle")), "orthogonal" if absf(absf(float(pa.get_param("angle")) - float(pb.get_param("angle"))) - 90.0) < 1e-6 else "not orthogonal"]],
		["Predicted fringe visibility", "|sin 2θ| = %.2f" % absf(sin(deg_to_rad(2.0 * a))) if bool(p1.get_param("enabled")) else "0 (no P1)"],
		["Centre intensity / double-slit max", "%.3f" % (pred * 0.5)],
	]
	super(snapshots, result)
