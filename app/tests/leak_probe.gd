extends SceneTree
## Leak probe: instantiates one widget (name after `--`), frees it and quits, so the engine's
## exit-time leak report can be attributed to a single widget. "none" = theme only.
##   godot --headless --path app -s tests/leak_probe.gd -- slit_pattern

func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var which := args[0] if args.size() > 0 else "none"
	var host := PanelContainer.new()
	host.theme = ThemeBuilder.build()
	host.size = Vector2(860, 360)
	get_root().add_child(host)
	# `which` is a comma-separated list of widget names, or "all"; a trailing ",shrink" adds the
	# smoke test's second (420x240) pass.
	var cases: Dictionary = (load("res://tests/smoke_widgets.gd") as GDScript).get_script_constant_map()["CASES"]
	var names: Array = []
	var shrink := false
	for n in which.split(","):
		if n == "all":
			names.append_array(cases.keys())
		elif n == "shrink":
			shrink = true
		elif n != "none":
			names.append(n)
	for name in names:
		# the same parameter sets as smoke_widgets.gd, configured twice like the smoke test does
		for p in cases.get(name, [{}]):
			var w: Node = load("res://ui/widgets/%s.tscn" % name).instantiate()
			w.configure(p)
			host.add_child(w)
			await process_frame
			await process_frame
			w.configure(p)
			await process_frame
			host.remove_child(w)
			w.free()
	if shrink:
		host.size = Vector2(420, 240)
		for name in names:
			var w: Node = load("res://ui/widgets/%s.tscn" % name).instantiate()
			w.configure({})
			host.add_child(w)
			await process_frame
			await process_frame
			host.remove_child(w)
			w.free()
	host.free()
	await process_frame
	quit(0)
