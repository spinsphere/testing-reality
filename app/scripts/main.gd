extends Control
## Root screen switcher. Routes come from AppState; screens are instantiated on demand.
##
## Debug command line (after `--`): `--go=hub|chapter:exp1:3|lab:exp1` jumps to a route,
## `--shot=/path/file.png` saves a screenshot after a few frames and quits (used with
## xvfb-run for headless verification), `--touch` pretends the screen is a touch screen
## (phone layouts; combine with `--resolution 480x960`).

const HUB_SCENE := preload("res://ui/hub/hub.tscn")
const CHAPTER_SCENE := preload("res://ui/chapter/chapter.tscn")

var _screen: Node
var _bg: ColorRect
var _shot_path := ""
var _perf := false
var _compact := false


func _ready() -> void:
	_parse_args()
	_setup_display()
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
	_on_route_changed(AppState.current_route)
	if _shot_path != "":
		_take_screenshot.call_deferred()
	elif _perf:
		_report_perf.call_deferred()


## Desktop windows keep the project's 1600×900 canvas scaled to fit (stretch mode
## canvas_items). A touch screen instead gets a 1:1 canvas scaled by the screen density
## (Layout.scale), so text has a readable physical size and the screens lay themselves out
## for the real width (Layout.compact). The window size is watched for rotation / resizing.
func _setup_display() -> void:
	if Layout.touch():
		var w := get_window()
		w.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		w.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
		w.content_scale_factor = Layout.scale()
		if not AppState.settings.has("quality"):
			AppState.settings["quality"] = 0   # phones start on the Low 3D preset
	_compact = Layout.compact(self)
	get_viewport().size_changed.connect(_on_size_changed)


func _on_size_changed() -> void:
	var compact := Layout.compact(self)
	if _screen == null:
		return
	if compact != _compact:
		_compact = compact
		if _screen.has_method("relayout"):
			_screen.call("relayout")      # the lab keeps its scene and re-arranges the HUD
		else:
			_on_route_changed(AppState.current_route)   # 2D screens rebuild for the new width
	elif _screen.has_method("on_resized"):
		_screen.call("on_resized")


func _parse_args() -> void:
	var args := OS.get_cmdline_user_args()
	if OS.has_feature("web"):
		# a browser has no command line: `index.html?go=lab:exp1&perf=1` plays the same role
		args = _query_string_args()
	print("BOOT platform=%s renderer=%s quagmire=%s" % [OS.get_name(),
		RenderingServer.get_current_rendering_method(), _engine_version()])
	for arg in args:
		if arg.begins_with("--shot="):
			_shot_path = arg.trim_prefix("--shot=")
		elif arg == "--perf":
			_perf = true
		elif arg == "--touch":
			Layout._touch_override = 1
		elif arg.begins_with("--go="):
			var parts := arg.trim_prefix("--go=").split(":")
			match parts[0]:
				"hub":
					AppState.current_route = {"screen": "hub"}
				"chapter":
					AppState.current_route = {"screen": "chapter", "id": parts[1], "page": int(parts[2]) if parts.size() > 2 else 0}
				"lab":
					AppState.current_route = {"screen": "lab", "id": parts[1]}


## `?go=lab:exp1&perf=1` → ["--go=lab:exp1", "--perf"]; `--shot` has no meaning in a browser.
func _query_string_args() -> PackedStringArray:
	var out := PackedStringArray()
	var q := str(JavaScriptBridge.eval("window.location.search", true)).trim_prefix("?")
	for pair in q.split("&", false):
		var kv := pair.split("=", true, 1)
		match kv[0]:
			"go":
				if kv.size() > 1:
					out.append("--go=" + kv[1].uri_decode())
			"perf":
				out.append("--perf")
	return out


## The Quagmire Engine's version, or "none" when the GDExtension did not load (the boot line
## is what tools/check-web.sh and the harness look for).
func _engine_version() -> String:
	if ClassDB.class_exists("QuagmireSystem"):
		return str(ClassDB.class_call_static("QuagmireSystem", "engine_version"))
	return "none"


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
		_back()
		get_viewport().set_input_as_handled()


## Android's back button / gesture (quit_on_go_back is off in project.godot).
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if not _back():
			get_tree().quit()


## One step up: lab → reading, reading → experiments. False on the hub.
func _back() -> bool:
	match AppState.current_route.get("screen", "hub"):
		"chapter":
			AppState.go_hub()
		"lab":
			AppState.go_chapter(AppState.current_route["id"])
		_:
			return false
	return true
