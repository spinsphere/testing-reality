extends EntangledSlitLab
## Experiment 7 — Detecting, but not recording: a wall on the idler, or D2 unplugged.

var _unplugged := false


func _init() -> void:
	super()
	chapter_id = "exp7"


func build() -> void:
	build_entangled_slit(true, true)
	set_overlays([
		{"name": "wall: singles", "target": "singles", "file": "res://data/lab/experiment-7/6.1_wall_-_Feuille_1_(2).csv", "pos_col": 2, "count_col": 4, "window": 20.0, "centre_um": 18600.0, "average": true},
		{"name": "wall: coincidences", "target": "coinc", "file": "res://data/lab/experiment-7/6.1_wall_-_Feuille_1_(2).csv", "pos_col": 2, "count_col": 6, "window": 20.0, "centre_um": 18600.0, "average": true},
		{"name": "unplugged: singles", "target": "singles", "file": "res://data/lab/experiment-7/6.2_unplugged_-_Feuille_1_(1).csv", "pos_col": 2, "count_col": 4, "window": 20.0, "centre_um": 18600.0, "average": true},
		{"name": "unplugged: coincidences", "target": "coinc", "file": "res://data/lab/experiment-7/6.2_unplugged_-_Feuille_1_(1).csv", "pos_col": 2, "count_col": 6, "window": 20.0, "centre_um": 18600.0, "average": true},
	])
	d2.add_param("plugged", {"label": "D2 cable connected", "type": "bool", "value": true, "help": "Unplug D2 from the coincidence counter: no electrical signal, so no coincidences can be formed."})
	pa.set_param("enabled", true, false)
	pb.set_param("enabled", true, false)
	p2.set_param("angle", 90.0, false)
	add_preset("Eraser working", func() -> void: _cfg(false, true, 45.0, 0), "Reference: P2 at 45°, wall out, D2 plugged — fringes in coincidences.")
	add_preset("Wall on idler", func() -> void: _cfg(true, true, 90.0, 2), "The idler is absorbed before D2: no coincidences at all.")
	add_preset("D2 unplugged", func() -> void: _cfg(false, false, 90.0, 4), "The idler reaches D2 but nothing is recorded.")
	_cfg(true, true, 90.0, 2)


func _cfg(wall_in: bool, plugged: bool, p2_angle: float, overlay: int) -> void:
	wall.set_param("enabled", wall_in, false)
	d2.set_param("plugged", plugged, false)
	p2.set_param("angle", p2_angle, false)
	overlay_index = overlay


func _finish(sys: QuagmireSystem, ctx: Dictionary) -> Dictionary:
	var out := super(sys, ctx)
	if not bool(d2.get_param("plugged")) and out.has("coincidence"):
		# no electrical signal: the coincidence logic never triggers
		var zeros := QuagmireSystem.new()
		zeros.add_property("x", PackedStringArray(["0"]))
		var geom: QuagmireScreen = out["geometry"]
		zeros.add_property("path", PackedStringArray(["S", "A", "B"]))
		var empty: QuagmireProfile = zeros.screen_profile("path", geom, out["ys"], {"is": {"path": "A"}})
		if empty != null:
			out["coincidence"] = empty
	return out


func on_rebuilt(snapshots: Array, result: Dictionary) -> void:
	_summary_rows = [
		["Wall", "in (idler absorbed)" if bool(wall.get_param("enabled")) else "out"],
		["D2", "plugged" if bool(d2.get_param("plugged")) else "unplugged — zero coincidences by construction"],
		["Which-way information", "still exists (in the idler, the wall, the environment); it just cannot be used for sorting"],
	]
	super(snapshots, result)
