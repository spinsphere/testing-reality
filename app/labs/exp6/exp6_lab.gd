extends EntangledSlitLab
## Experiment 6 — Delayed-choice quantum eraser: P2 on the idler chooses the basis.

func _init() -> void:
	super()
	chapter_id = "exp6"


func build() -> void:
	build_entangled_slit(true, false, 0.32)  # P2 ±45° coincidences: 600–660 µm fringes → L ≈ 0.32 m
	var d1 := [3, 6, 9, 12, 15]
	var cc := [5, 8, 11, 14, 17]
	set_overlays([
		{"name": "P2 45° coincidences", "target": "coinc", "file": "res://data/lab/experiment-6/Data_45degre.csv", "pos_col": 2, "count_cols": cc, "window": 20.0, "centre_um": 18300.0, "average": true},
		{"name": "P2 45° singles", "target": "singles", "file": "res://data/lab/experiment-6/Data_45degre.csv", "pos_col": 2, "count_cols": d1, "window": 20.0, "centre_um": 18300.0, "average": true},
		{"name": "P2 −45° coincidences", "target": "coinc", "file": "res://data/lab/experiment-6/Data_135deg.csv", "pos_col": 2, "count_cols": cc, "window": 20.0, "centre_um": 18450.0, "average": true},
		{"name": "P2 0° coincidences", "target": "coinc", "file": "res://data/lab/experiment-6/Data_0deg.csv", "pos_col": 2, "count_cols": cc, "window": 20.0, "centre_um": 18450.0, "average": true},
		{"name": "P2 90° coincidences", "target": "coinc", "file": "res://data/lab/experiment-6/Data_90deg.csv", "pos_col": 2, "count_cols": cc, "window": 20.0, "centre_um": 18450.0, "average": true},
		{"name": "P2 0° singles", "target": "singles", "file": "res://data/lab/experiment-6/Data_0deg.csv", "pos_col": 2, "count_cols": d1, "window": 20.0, "centre_um": 18450.0, "average": true},
	])
	add_preset("P2 45°", func() -> void: _p2(45.0, 1), "Erasing basis: fringes appear in coincidences.")
	add_preset("P2 −45°", func() -> void: _p2(-45.0, 3), "The complementary fringes.")
	add_preset("P2 0°", func() -> void: _p2(0.0, 4), "Which-way basis: idler reveals slit A → no fringes.")
	add_preset("P2 90°", func() -> void: _p2(90.0, 5), "Which-way basis: slit B → no fringes.")
	pa.set_param("enabled", true, false)
	pb.set_param("enabled", true, false)
	_p2(45.0, 1)


func _p2(angle: float, overlay: int) -> void:
	p2.set_param("enabled", true, false)
	p2.set_param("angle", angle, false)
	overlay_index = overlay


func on_rebuilt(snapshots: Array, result: Dictionary) -> void:
	var g := float(p2.get_param("angle"))
	_summary_rows = [
		["Coincidence law", "I ∝ 1 + sin(2γ) cos kΔ,  γ = %d° → sin 2γ = %.2f" % [roundi(g), sin(deg_to_rad(2.0 * g))]],
		["Delayed choice", "P2 may be set after D1 has already clicked; the sorted record changes, the D1 singles never do"],
	]
	super(snapshots, result)
