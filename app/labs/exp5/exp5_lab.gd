extends EntangledSlitLab
## Experiment 5 — Putting it all together (5.1 bare slit, 5.2 marked slits, 5.3 local eraser).

func _init() -> void:
	super()
	chapter_id = "exp5"


func build() -> void:
	build_entangled_slit(false, false, 0.43)  # 5.1 coincidences: 875 µm fringes → L ≈ 0.43 m
	set_overlays([
		{"name": "5.1 singles", "target": "singles", "file": "res://data/lab/experiment-5/Data4_1_-_Feuille_1.csv", "pos_col": 2, "count_col": 4, "window": 20.0, "centre_um": 18600.0, "average": true},
		{"name": "5.1 coincidences", "target": "coinc", "file": "res://data/lab/experiment-5/Data4_1_-_Feuille_1.csv", "pos_col": 2, "count_col": 6, "window": 20.0, "centre_um": 18600.0, "average": true},
		{"name": "5.2 singles", "target": "singles", "file": "res://data/lab/experiment-5/Data4_2_-_Feuille_1.csv", "pos_col": 2, "count_col": 4, "window": 20.0, "centre_um": 19000.0, "average": true},
		{"name": "5.2 coincidences", "target": "coinc", "file": "res://data/lab/experiment-5/Data4_2_-_Feuille_1.csv", "pos_col": 2, "count_col": 6, "window": 20.0, "centre_um": 19000.0, "average": true},
		{"name": "5.3 singles", "target": "singles", "file": "res://data/lab/experiment-5/Data4_3_-_Feuille_1_(1).csv", "pos_col": 2, "count_col": 4, "window": 20.0, "centre_um": 18450.0, "average": true},
		{"name": "5.3 coincidences", "target": "coinc", "file": "res://data/lab/experiment-5/Data4_3_-_Feuille_1_(1).csv", "pos_col": 2, "count_col": 6, "window": 20.0, "centre_um": 18450.0, "average": true},
	])
	add_preset("5.1 bare slit", func() -> void: _cfg(false, false, 2), "No polarizers: fringes in singles and coincidences.")
	add_preset("5.2 marked slits", func() -> void: _cfg(true, false, 4), "PA, PB on: which-way information → no fringes.")
	add_preset("5.3 + P1 45°", func() -> void: _cfg(true, true, 6), "The local eraser fails: the information lives in the idler.")
	_cfg(false, false, 2)


func _cfg(marked: bool, eraser: bool, overlay: int) -> void:
	pa.set_param("enabled", marked, false)
	pb.set_param("enabled", marked, false)
	p1.set_param("enabled", eraser, false)
	overlay_index = overlay


func on_rebuilt(snapshots: Array, result: Dictionary) -> void:
	_summary_rows = [["Idler", "goes straight to D2 (no polarizer) — its polarization is never measured in a basis that erases which-way information"]]
	super(snapshots, result)
