extends SceneTree
## Headless smoke test for the teaching widgets:
##   godot --headless --path app -s tests/smoke_widgets.gd
## Instantiates every widget with its defaults and with the guide's params, adds it to the
## tree, waits two frames, exercises configure() again, and reports OK / FAILED.

const CASES := {
	"vector_playground": [{}, {"labels": ["A", "B"], "angle": 60, "mode": "projection", "show_probabilities": true}, {"mode": "basis_change", "labels": ["↔", "↕"], "angle": 20}, {"mode": "superposition", "angle": 200}],
	"apple_evolution": [{}, {"t": 0.25}],
	"probability_bars": [{}, {"amplitudes": [0.5, 0.866], "labels": ["A", "B"]}, {"amplitudes": [0.6, 0.0, 0.8], "labels": ["red", "rotten", "eaten"]}],
	"phasor_widget": [{}, {"mode": "single", "wavelength_nm": 405}, {"mode": "sum", "wavelength_nm": 808}],
	"malus_widget": [{}, {"input_angle": 45}],
	"polarizer_chain": [{}, {"polarizers": [0, 45, 90], "input_angle": 45, "max": 3}, {"polarizers": [0, 90], "max": 3}],
	"slit_pattern": [{}, {"wavelength_nm": 808, "slit_width_um": 200, "separation_um": 400, "slits": 2, "distance_m": 0.5}, {"slits": 1}, {"slits": 4, "wavelength_nm": 405}],
	"eraser_widget": [{}, {"p1_angle": 45, "entangled": false, "p2_angle": 45}, {"entangled": true, "p1_angle": 45, "p2_angle": 0}],
	"coincidence_widget": [{}, {"alpha": 0, "beta": 0}, {"alpha": 30, "beta": 120}],
	"tensor_widget": [{}, {"left": ["↔", "↕"], "right": ["A", "B"]}],
}

var _failures := 0


func _init() -> void:
	_run()


func _run() -> void:
	var root := get_root()
	var host := PanelContainer.new()
	host.theme = ThemeBuilder.build()
	host.position = Vector2(20, 20)
	host.size = Vector2(860, 360)
	root.add_child(host)
	for name in CASES:
		var scene_path := "res://ui/widgets/%s.tscn" % name
		if not ResourceLoader.exists(scene_path):
			_fail("%s: scene missing" % name)
			continue
		for p in CASES[name]:
			var w: Node = load(scene_path).instantiate()
			if not w.has_method("configure"):
				_fail("%s: no configure()" % name)
				w.free()
				continue
			w.configure(p)
			host.add_child(w)
			await process_frame
			await process_frame
			# reconfigure while in the tree (block_factory never does this, but chapters may rebuild)
			w.configure(p)
			await process_frame
			var ok := w is Control and (w as Control).get_child_count() > 0
			if not ok:
				_fail("%s %s: no children built" % [name, JSON.stringify(p)])
			else:
				print("OK  %-20s %s" % [name, JSON.stringify(p)])
			host.remove_child(w)
			w.free()
	# shrink test: 420×240
	host.size = Vector2(420, 240)
	for name in CASES:
		var w: Node = load("res://ui/widgets/%s.tscn" % name).instantiate()
		w.configure({})
		host.add_child(w)
		await process_frame
		await process_frame
		host.remove_child(w)
		w.free()
	host.free()
	await process_frame  # let the freed controls release their resources before the exit leak check
	print("SMOKE_WIDGETS ", "OK" if _failures == 0 else "FAILED (%d)" % _failures)
	quit(0 if _failures == 0 else 1)


func _fail(msg: String) -> void:
	_failures += 1
	push_error(msg)
	printerr("FAIL ", msg)
