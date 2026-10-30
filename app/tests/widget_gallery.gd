extends SceneTree
## Renders widget screenshots (needs a real window, e.g. under xvfb-run):
##   godot --path app -s tests/widget_gallery.gd -- <name>|all [out_dir]
## Each widget is shown at 860×360 inside a card on a 1600×900 window; variants from the
## guide's params are rendered as <name>_<variant>.png.

const SHOTS := {
	"vector_playground": {"": {}, "projection": {"mode": "projection"}, "superposition": {"mode": "superposition"}, "basis_change": {"mode": "basis_change", "labels": ["↔", "↕"], "angle": 20}},
	"apple_evolution": {"": {"t": 0.25}},
	"probability_bars": {"": {}},
	"phasor_widget": {"": {}, "sum": {"mode": "sum"}},
	"malus_widget": {"": {"input_angle": 45, "polarizer_angle": 20}},
	"polarizer_chain": {"": {}},
	"slit_pattern": {"": {}, "covered": {}},
	"eraser_widget": {"": {}, "entangled": {"entangled": true, "p1_angle": 45, "p2_angle": 45}},
	"coincidence_widget": {"": {"alpha": 30, "beta": 60}},
	"tensor_widget": {"": {}},
}
const DEFAULT_OUT := "/tmp/claude-1000/-home-soliax-testing-reality/004aee99-7022-4e58-a91f-54eb6cea8640/scratchpad/shots/widgets"


func _init() -> void:
	_run()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var which := args[0] if args.size() > 0 else "all"
	var out_dir := args[1] if args.size() > 1 else DEFAULT_OUT
	DirAccess.make_dir_recursive_absolute(out_dir)
	var root := get_root()
	root.size = Vector2i(1600, 900)
	root.theme = ThemeBuilder.build()
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var card := PanelContainer.new()
	card.position = Vector2(40, 40)
	card.size = Vector2(860, 360)
	root.add_child(card)
	var small := PanelContainer.new()
	small.position = Vector2(40, 440)
	small.size = Vector2(430, 260)
	root.add_child(small)
	await process_frame
	var names: Array = SHOTS.keys() if which == "all" else [which]
	for name in names:
		if not SHOTS.has(name):
			printerr("unknown widget ", name)
			continue
		var variants: Dictionary = SHOTS[name]
		for variant in variants:
			var w: Node = load("res://ui/widgets/%s.tscn" % name).instantiate()
			w.configure(variants[variant])
			card.add_child(w)
			var w2: Node = load("res://ui/widgets/%s.tscn" % name).instantiate()
			w2.configure(variants[variant])
			small.add_child(w2)
			await process_frame
			await process_frame
			if variant == "covered" and w.has_method("_update"):
				w._cover = true
				w._cover_check.button_pressed = true
			await process_frame
			await process_frame
			await process_frame
			var img := root.get_texture().get_image()
			var file := "%s/%s%s.png" % [out_dir, name, "" if variant == "" else "_" + variant]
			var err := img.save_png(file)
			print("shot ", file, " ", "ok" if err == OK else "error %d" % err)
			card.remove_child(w)
			w.free()
			small.remove_child(w2)
			w2.free()
	quit(0)
