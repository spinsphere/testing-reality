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


func _ready() -> void:
	theme = ThemeBuilder.build()
	# This full-screen Control must not swallow mouse events: in the laboratory the camera rig
	# and the apparatus picking read them from _unhandled_input.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg = ColorRect.new()
	_bg.color = Palette.BG
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	AppState.route_changed.connect(_on_route_changed)
	_parse_args()
	_on_route_changed(AppState.current_route)


func _parse_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot="):
			_shot_path = arg.trim_prefix("--shot=")
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


func _take_screenshot() -> void:
	for i in 12:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var err := img.save_png(_shot_path)
	print("screenshot %s -> %s" % [_shot_path, error_string(err)])
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
