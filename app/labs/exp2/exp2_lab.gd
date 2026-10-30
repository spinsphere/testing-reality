extends SlitLabBase
## Experiment 2 — Single and double slit. 808 nm laser (infrared, invisible to the eye),
## λ/2 + PBS preparation, lens, slit mask, scanning detector.

func _init() -> void:
	chapter_id = "exp2"


func build() -> void:
	var laser := place(Optics.Laser.new(808.0, 0.0, "LASER"), -0.54)
	laser.model = "laser_808"
	place(Optics.BeamSplitterCube.new("BS"), -0.44)
	place(Optics.HalfWavePlate.new("λ/2", 22.5), -0.34)
	place(Optics.Lens.new("L1", 500.0), -0.20)
	var m := place(Optics.SlitMask.new("SLIT", 200.0, 400.0), -0.02)
	var d := place(Optics.ScanningDetector.new("D1", 3.0), 0.50)
	setup_slit_lab(m, d, 808.0, 0.5)
	set_overlays([
		{"name": "double slit", "file": "res://data/lab/experiment-2/double_slit_-_calib_123_(1).csv", "pos_col": 0, "count_col": 2, "window": 1.0, "centre_um": 20500.0},
		{"name": "left slit only", "file": "res://data/lab/experiment-2/Single_slit_-_left_slit.csv", "pos_col": 0, "count_col": 2, "window": 1.0, "centre_um": 20000.0},
		{"name": "right slit only", "file": "res://data/lab/experiment-2/Single_slit_-_right_slit.csv", "pos_col": 0, "count_col": 2, "window": 1.0, "centre_um": 20000.0},
	])
	overlay_index = 1
	add_preset("Double slit", func() -> void:
		m.set_param("mode", "double", false)
		overlay_index = 1, "Both slits open: interference fringes under the diffraction envelope.")
	add_preset("Slit A only", func() -> void:
		m.set_param("mode", "A only", false)
		overlay_index = 2, "Cover slit B: only the single-slit envelope remains, centred on slit A.")
	add_preset("Slit B only", func() -> void:
		m.set_param("mode", "B only", false)
		overlay_index = 3, "Cover slit A: the envelope shifts by the slit separation.")
	camera_rig.set_home(Vector3(0.05, BEAM_HEIGHT, 0.0), 1.3, -30.0, 20.0)


func on_rebuilt(snapshots: Array, result: Dictionary) -> void:
	var d_um := float(mask.get_param("separation"))
	var spacing_mm := wavelength_nm * 1e-9 * distance_m / (d_um * 1e-6) * 1000.0
	var w_um := float(mask.get_param("width"))
	var env_zero_mm := wavelength_nm * 1e-9 * distance_m / (w_um * 1e-6) * 1000.0
	_summary_rows = [
		["Fringe spacing λL/d", "%.2f mm" % spacing_mm],
		["First envelope zero λL/w", "±%.2f mm" % env_zero_mm],
		["Light", "808 nm — infrared, invisible to the eye (shown dark red)"],
	]
	super(snapshots, result)
