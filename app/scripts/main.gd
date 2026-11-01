extends Control
## Root screen switcher. Routes come from AppState; screens are instantiated on demand.
##
## Debug command line (after `--`): `--go=hub|chapter:exp1:3|lab:exp1` jumps to a route,
## `--shot=/path/file.png` saves a screenshot after a few frames and quits (used with
## xvfb-run for headless verification).

const HUB_SCENE := preload("res://ui/hub/hub.tscn")
const CHAPTER_SCENE := preload("res://ui/chapter/chapter.tscn")

var _screen: Node
var _bg: ColorRect
var _shot_path := ""
var _perf := false


func _ready() -> void:
	theme = ThemeBuilder.build()
	# This full-screen Control must not swallow mouse events: in the laboratory the camera rig
	# and the apparatus picking read them from _unhandled_input.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg = ColorRect.new()
	_bg.color = Palette.BG
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	AppState.route_changed.connect(_on_route_changed)
	_parse_args()
	_on_route_changed(AppState.current_route)


func _parse_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot="):
			_shot_path = arg.trim_prefix("--shot=")
		elif arg == "--perf":
			_perf = true
		elif arg.begins_with("--go="):
			var parts := arg.trim_prefix("--go=").split(":")
			match parts[0]:
				"hub":
					AppState.current_route = {"screen": "hub"}
				"chapter":
					AppState.current_route = {"screen": "chapter", "id": parts[1], "page": int(parts[2]) if parts.size() > 2 else 0}
				"lab":
					AppState.current_route = {"screen": "lab", "id": parts[1]}
	if _shot_path != "":
		_take_screenshot.call_deferred()
	elif _perf:
		_report_perf.call_deferred()


func _take_screenshot() -> void:
	for i in 12:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(_shot_path)
	print("screenshot %s -> %s" % [_shot_path, error_string(err)])
	get_tree().quit()


## `--perf`: after warm-up, average the renderer's per-frame counters over 60 frames and
## print one PERF line (objects, primitives, draw calls are the same on every GPU; the
## frame time is only meaningful on real hardware).
func _report_perf() -> void:
	for i in 20:
		await get_tree().process_frame
	var frames := 60
	var t0 := Time.get_ticks_usec()
	var objects := 0.0
	var prims := 0.0
	var calls := 0.0
	for i in frames:
		await get_tree().process_frame
		objects += Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		prims += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var ms := (Time.get_ticks_usec() - t0) / 1000.0 / frames
	print("PERF route=%s objects=%d primitives=%d draw_calls=%d vram_mb=%.1f nodes=%d frame_ms=%.1f" % [
		str(AppState.current_route), roundi(objects / frames), roundi(prims / frames), roundi(calls / frames),
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		Performance.get_monitor(Performance.OBJECT_NODE_COUNT), ms])
	get_tree().quit()


func _on_route_changed(route: Dictionary) -> void:
	if _screen:
		_screen.queue_free()
		_screen = null
	# The 2D background would hide the 3D world, so only show it for 2D screens.
	_bg.visible = route.get("screen", "hub") != "lab"
	match route.get("screen", "hub"):
		"hub":
			_screen = HUB_SCENE.instantiate()
		"chapter":
			_screen = CHAPTER_SCENE.instantiate()
			_screen.setup(route["id"], int(route.get("page", 0)))
		"lab":
			var chapter := AppState.chapter(route["id"])
			var lab_path: String = chapter.get("lab", "")
			if lab_path != "" and ResourceLoader.exists(lab_path):
				_screen = load(lab_path).instantiate()
			else:
				push_warning("No lab scene for chapter %s" % route["id"])
				_screen = CHAPTER_SCENE.instantiate()
				_screen.setup(route["id"], 0)
	add_child(_screen)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match AppState.current_route.get("screen", "hub"):
			"chapter":
				AppState.go_hub()
			"lab":
				AppState.go_chapter(AppState.current_route["id"])
		get_viewport().set_input_as_handled()
