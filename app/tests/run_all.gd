extends SceneTree
## Full runtime check of the app, for CI and for `tools/test.sh`:
##
##   godot --headless --path app -s tests/run_all.gd          (dummy renderer)
##   xvfb-run -a godot --path app -s tests/run_all.gd         (GL Compatibility, shaders too)
##
## 1. loads every GDScript under res:// (compile errors → load() returns null),
## 2. instantiates every scene,
## 3. drives the real app: hub → settings → every chapter page (TOC, keys, widgets,
##    equations, figures) → every lab (presets, every apparatus parameter through the
##    inspector controls, overlays, photons, picking, camera, keys) and back.
##
## Note: in `-s` mode this script is compiled before the autoloads exist, so it must not name
## classes whose scripts reference AppState (LabBase, SettingsOverlay…); `_is_a()` is used instead.
##
## Prints RUN_ALL OK / FAILED and quits with 0 / 1. Engine error lines (SCRIPT ERROR,
## ERROR, WARNING) go to stderr and are counted by tools/test.sh.

var _fail := 0
var _checks := 0
var _app_state: Node
var _main: Node
var _root: Window


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	_root = get_root()
	_app_state = _root.get_node_or_null("AppState")
	if _app_state == null:
		_fail_msg("autoload AppState missing")
		_finish()
		return
	# Progress is saved to user://; use a scratch copy so the harness never touches real progress.
	_app_state.progress = {}
	await _check_scripts()
	await _check_scenes()
	await _drive_app()
	_finish()


func _finish() -> void:
	print("RUN_ALL %s — %d checks, %d failures" % ["OK" if _fail == 0 else "FAILED", _checks, _fail])
	quit(0 if _fail == 0 else 1)


# ------------------------------------------------------------------ helpers

func _ok(cond: bool, msg: String) -> bool:
	_checks += 1
	if not cond:
		_fail_msg(msg)
	return cond


func _fail_msg(msg: String) -> void:
	_fail += 1
	push_error("run_all: " + msg)
	printerr("FAIL ", msg)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _walk(dir_path: String, ext: String, out: Array) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var name := d.get_next()
	while name != "":
		var p := dir_path.path_join(name)
		if d.current_is_dir():
			if not name.begins_with(".") and p != "res://addons":
				_walk(p, ext, out)
		elif name.ends_with(ext):
			out.append(p)
		name = d.get_next()
	d.list_dir_end()


## All descendants of `n` (depth first).
func _descendants(n: Node, out: Array = []) -> Array:
	for c in n.get_children(true):
		out.append(c)
		_descendants(c, out)
	return out


func _find_button(n: Node, text_prefix: String) -> Button:
	for c in _descendants(n):
		if c is Button and not (c is CheckBox) and not (c is OptionButton) and str((c as Button).text).begins_with(text_prefix):
			return c
	return null


func _texts(n: Node) -> Array:
	var out: Array = []
	for c in _descendants(n):
		if c is Label:
			out.append((c as Label).text)
		elif c is RichTextLabel:
			out.append((c as RichTextLabel).text)
	return out


func _action(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)
	await process_frame
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame


## `obj is <class_name>` without compiling that class into this script.
func _is_a(obj: Object, cls: String) -> bool:
	var s: Script = obj.get_script() if obj else null
	while s:
		if s.get_global_name() == cls:
			return true
		s = s.get_base_script()
	return false


func _screen() -> Node:
	return _main.get("_screen") if _main else null


func _screen_kind() -> String:
	return str(_app_state.current_route.get("screen", ""))


# ------------------------------------------------------------------ 1. scripts

func _check_scripts() -> void:
	var scripts: Array = []
	_walk("res://", ".gd", scripts)
	scripts.sort()
	_ok(scripts.size() >= 40, "expected at least 40 scripts, found %d" % scripts.size())
	for path in scripts:
		var s: Variant = load(path)
		if not _ok(s != null and s is GDScript, "script failed to load: %s" % path):
			continue
		_ok((s as GDScript).can_instantiate(), "script does not compile: %s" % path)
	print("scripts: %d loaded" % scripts.size())
	await process_frame


# ------------------------------------------------------------------ 2. scenes

func _check_scenes() -> void:
	var scenes: Array = []
	_walk("res://", ".tscn", scenes)
	scenes.sort()
	_ok(scenes.size() >= 20, "expected at least 20 scenes, found %d" % scenes.size())
	for path in scenes:
		var ps: Variant = load(path)
		if not _ok(ps != null and ps is PackedScene, "scene failed to load: %s" % path):
			continue
		var node: Node = (ps as PackedScene).instantiate()
		if not _ok(node != null, "scene failed to instantiate: %s" % path):
			continue
		_root.add_child(node)
		await _frames(4)
		node.queue_free()
		await process_frame
	print("scenes: %d instantiated" % scenes.size())


# ------------------------------------------------------------------ 3. the app

func _drive_app() -> void:
	_main = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	_root.add_child(_main)
	await _frames(3)
	_ok(_screen_kind() == "hub" and _screen() != null, "app did not start on the hub")

	await _drive_hub()
	for ch in _app_state.CHAPTERS:
		await _drive_chapter(ch)
	for ch in _app_state.CHAPTERS:
		if str(ch.get("lab", "")) != "":
			await _drive_lab(ch)
	_app_state.go_hub()
	await _frames(2)
	_ok(_screen_kind() == "hub", "did not return to hub at the end")
	_main.queue_free()
	await process_frame


func _drive_hub() -> void:
	var hub := _screen()
	# settings overlay: toggles, quality, reset progress, close
	var settings := _find_button(hub, "⚙")
	if _ok(settings != null, "hub has no settings button"):
		settings.pressed.emit()
		await _frames(2)
		var overlay: Node = null
		for c in _descendants(hub):
			if _is_a(c, "SettingsOverlay"):
				overlay = c
		if _ok(overlay != null, "settings overlay did not open"):
			for c in _descendants(overlay):
				if c is CheckBox:
					(c as CheckBox).button_pressed = not (c as CheckBox).button_pressed
					await process_frame
					(c as CheckBox).button_pressed = not (c as CheckBox).button_pressed
				elif c is OptionButton:
					for i in (c as OptionButton).item_count:
						(c as OptionButton).select(i)
						(c as OptionButton).item_selected.emit(i)
						await process_frame
					(c as OptionButton).select(1)
					(c as OptionButton).item_selected.emit(1)
			var close := _find_button(overlay, "Close")
			if _ok(close != null, "settings overlay has no Close"):
				close.pressed.emit()
				await _frames(2)
			_ok(not is_instance_valid(overlay) or overlay.is_queued_for_deletion(), "settings overlay did not close")
		# open again, Esc closes it
		settings.pressed.emit()
		await _frames(2)
		await _action("ui_cancel")
		# open again, reset progress
		settings.pressed.emit()
		await _frames(2)
		var reset := _find_button(hub, "Reset progress")
		if _ok(reset != null, "settings overlay has no Reset progress"):
			reset.pressed.emit()
			await _frames(3)
			_ok(_screen_kind() == "hub", "reset progress did not return to hub")
	# click every chapter card
	hub = _screen()
	var cards: Array = []
	for c in _descendants(hub):
		if c is PanelContainer and str((c as Control).theme_type_variation) in ["Card", "CardHover"]:
			cards.append(c)
	_ok(cards.size() == _app_state.CHAPTERS.size(), "hub shows %d cards, expected %d" % [cards.size(), _app_state.CHAPTERS.size()])
	for i in cards.size():
		var card: Control = cards[i]
		card.mouse_entered.emit()
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = true
		card.gui_input.emit(ev)
		await _frames(2)
		_ok(_screen_kind() == "chapter" and _app_state.current_route.get("id") == _app_state.CHAPTERS[i]["id"],
			"card %d did not open chapter %s" % [i, _app_state.CHAPTERS[i]["id"]])
		_app_state.go_hub()
		await _frames(2)
		hub = _screen()
		cards.clear()
		for c in _descendants(hub):
			if c is PanelContainer and str((c as Control).theme_type_variation) in ["Card", "CardHover"]:
				cards.append(c)
	print("hub: ok")


func _drive_chapter(ch: Dictionary) -> void:
	var id: String = ch["id"]
	_app_state.go_chapter(id, 0)
	await _frames(2)
	var scr := _screen()
	if not _ok(_screen_kind() == "chapter" and scr != null, "chapter %s did not open" % id):
		return
	var pages: Array = scr.get("_pages")
	if not _ok(pages.size() > 0, "chapter %s has no pages" % id):
		return
	var widgets := 0
	var equations := 0
	for i in pages.size():
		scr.call("_show_page", i)
		await _frames(3)
		_ok(int(scr.get("page_index")) == i, "chapter %s page %d not shown" % [id, i])
		for t in _texts(scr):
			var s := str(t)
			if s.begins_with("[widget") or s.begins_with("[equation") or s.begins_with("[figure"):
				_fail_msg("chapter %s page %d: %s" % [id, i, s])
		for c in _descendants(scr):
			if _is_a(c, "WidgetBase"):
				widgets += 1
			elif c is TextureRect and (c as TextureRect).texture != null and str((c as TextureRect).texture.resource_path).contains("/math/"):
				equations += 1
		# the page counter must match
		var counter: Label = scr.get("_counter")
		_ok(counter.text == "%d / %d" % [i + 1, pages.size()], "chapter %s page counter wrong: %s" % [id, counter.text])
	print("chapter %s: %d pages, %d widgets, %d equations" % [id, pages.size(), widgets, equations])
	# table of contents buttons
	var toc: Dictionary = scr.get("_toc_buttons")
	for sid in toc:
		(toc[sid] as Button).pressed.emit()
		await _frames(2)
	# keyboard: first page, prev (clamped), next, prev
	scr.call("_show_page", 0)
	await process_frame
	await _action("ui_page_prev")
	_ok(int(scr.get("page_index")) == 0, "chapter %s: prev on first page moved" % id)
	if pages.size() > 1:
		await _action("ui_page_next")
		_ok(int(scr.get("page_index")) == 1, "chapter %s: ui_page_next did not advance" % id)
		await _action("ui_page_prev")
		_ok(int(scr.get("page_index")) == 0, "chapter %s: ui_page_prev did not go back" % id)
	# bottom buttons
	var nextb: Button = scr.get("_next_btn")
	var prevb: Button = scr.get("_prev_btn")
	_ok(prevb.disabled, "chapter %s: prev button enabled on first page" % id)
	if pages.size() > 1:
		nextb.pressed.emit()
		await _frames(2)
		prevb.pressed.emit()
		await _frames(2)
	# last page → "Next" goes to the next chapter or the hub
	scr.call("_show_page", pages.size() - 1)
	await _frames(2)
	nextb.pressed.emit()
	await _frames(2)
	var nxt: String = _app_state.next_chapter_id(id)
	if nxt != "":
		_ok(_screen_kind() == "chapter" and _app_state.current_route.get("id") == nxt, "chapter %s: Next did not open %s" % [id, nxt])
	else:
		_ok(_screen_kind() == "hub", "chapter %s: Next did not return to hub" % id)
	# L enters the lab (if any) and Esc comes back; Esc from a chapter → hub
	_app_state.go_chapter(id, 0)
	await _frames(2)
	if str(ch.get("lab", "")) != "":
		await _action("lab_toggle")
		await _frames(2)
		_ok(_screen_kind() == "lab", "chapter %s: L did not enter the lab" % id)
		await _action("ui_cancel")
		await _frames(2)
		_ok(_screen_kind() == "chapter", "lab %s: Esc did not return to the chapter" % id)
		var enter := _find_button(_screen(), "◆  Enter the lab")
		_ok(enter != null, "chapter %s has no Enter-the-lab button" % id)
	var home := _find_button(_screen(), "‹  All experiments")
	if _ok(home != null, "chapter %s has no home button" % id):
		home.pressed.emit()
		await _frames(2)
		_ok(_screen_kind() == "hub", "chapter %s: home button did not return to hub" % id)
	# progress was recorded
	_ok(_app_state.completion(id) > 0.99, "chapter %s: completion %.2f after reading every page" % [id, _app_state.completion(id)])


func _drive_lab(ch: Dictionary) -> void:
	var id: String = ch["id"]
	_app_state.go_lab(id)
	await _frames(6)
	var lab := _screen()
	if not _ok(_screen_kind() == "lab" and _is_a(lab, "LabBase"), "lab %s did not open" % id):
		return
	var controller = lab.get("controller")
	_ok(controller.components.size() >= 2, "lab %s has %d components" % [id, controller.components.size()])
	_ok(controller.snapshots.size() == controller.components.size(), "lab %s: %d snapshots for %d components" % [id, controller.snapshots.size(), controller.components.size()])
	_ok(controller.system != null, "lab %s: no quantum system after rebuild" % id)
	var has_slits: bool = lab.get("mask") != null
	if has_slits:
		_ok(controller.result.has("profile"), "lab %s: no screen profile in result" % id)
	for app in controller.components:
		_ok(is_instance_valid(app.get("model_root")) or is_instance_valid(app.get("_placeholder")), "lab %s: %s has no model" % [id, app.label])
	var hud_texts := _texts(lab.get("hud"))
	_ok(hud_texts.size() > 5, "lab %s: HUD is empty" % id)

	# presets
	var presets: HBoxContainer = lab.get("presets_box")
	var n_presets := 0
	for b in presets.get_children():
		if b is Button:
			(b as Button).pressed.emit()
			await _frames(3)
			n_presets += 1
			_ok(controller.snapshots.size() == controller.components.size(), "lab %s preset '%s': rebuild incomplete" % [id, (b as Button).text])
	_ok(n_presets > 0, "lab %s has no presets" % id)

	# every apparatus: select, then every parameter through the inspector controls
	var n_params := 0
	for app in controller.components:
		lab.call("select", app)
		await process_frame
		var inspector: VBoxContainer = lab.get("inspector_box")
		var title: Label = lab.get("inspector_title")
		_ok(title.text.contains(app.label), "lab %s: inspector title '%s' for %s" % [id, title.text, app.label])
		var params: Dictionary = app.params
		var sliders: Array = []
		var checks: Array = []
		var options: Array = []
		var small_buttons: Array = []
		for c in _descendants(inspector):
			if c is HSlider:
				sliders.append(c)
			elif c is CheckBox:
				checks.append(c)
			elif c is OptionButton:
				options.append(c)
			elif c is Button and str((c as Button).text).ends_with("°"):
				small_buttons.append(c)
		var want_sliders := 0
		var want_checks := 0
		var want_options := 0
		for name in params:
			match str(params[name].get("type", "float")):
				"float", "int": want_sliders += 1
				"bool": want_checks += 1
				"enum": want_options += 1
		_ok(sliders.size() == want_sliders and checks.size() == want_checks and options.size() == want_options,
			"lab %s: inspector for %s shows %d/%d/%d controls, expected %d/%d/%d" % [id, app.label, sliders.size(), checks.size(), options.size(), want_sliders, want_checks, want_options])
		for s in sliders:
			var sl: HSlider = s
			var orig := sl.value
			for v in [sl.min_value, sl.max_value, (sl.min_value + sl.max_value) * 0.5, orig]:
				sl.value = v
				await _frames(2)
			n_params += 1
		for b in small_buttons:
			(b as Button).pressed.emit()
			await _frames(2)
		for c in checks:
			var cb: CheckBox = c
			cb.button_pressed = not cb.button_pressed
			await _frames(2)
			cb.button_pressed = not cb.button_pressed
			await _frames(2)
			n_params += 1
		for o in options:
			var ob: OptionButton = o
			var orig := ob.selected
			for i in ob.item_count:
				ob.select(i)
				ob.item_selected.emit(i)
				await _frames(2)
			ob.select(orig)
			ob.item_selected.emit(orig)
			await _frames(2)
			n_params += 1
		_ok(controller.snapshots.size() == controller.components.size(), "lab %s: rebuild broke while editing %s" % [id, app.label])
		var look := _find_button(inspector, "Look at it")
		if look:
			look.pressed.emit()
			await _frames(3)
	# restore defaults with the first preset so the rest of the run is deterministic
	for b in presets.get_children():
		if b is Button:
			(b as Button).pressed.emit()
			await _frames(3)
			break
	lab.call("select", null)

	# lab-data overlays
	var n_overlays := 0
	if has_slits:
		# the results panel (and this dropdown) is rebuilt after every recompute, so re-fetch it
		var ob: OptionButton = lab.get("_overlay_button")
		if _ok(ob != null, "lab %s has no overlay selector" % id):
			var count := ob.item_count
			_ok(count >= 2, "lab %s: overlay selector has only %d entries" % [id, count])
			for i in count:
				ob = lab.get("_overlay_button")
				ob.select(i)
				ob.item_selected.emit(i)
				await _frames(3)
				n_overlays += 1
				var fresh: OptionButton = lab.get("_overlay_button")
				_ok(fresh != null and fresh.selected == i, "lab %s: overlay %d not kept after rebuild" % [id, i])
				if i > 0:
					var plots := 0
					for c in _descendants(lab.get("results_box")):
						if _is_a(c, "PatternPlot") and not (c.get("points") as Array).is_empty():
							plots += 1
					_ok(plots >= 1, "lab %s: overlay %d (%s) drew no measured points" % [id, i, fresh.get_item_text(i)])
			ob = lab.get("_overlay_button")
			ob.select(0)
			ob.item_selected.emit(0)
			await _frames(3)

	# photons, keys, camera, picking
	lab.call("toggle_photons")
	await _frames(45)
	lab.call("toggle_photons")
	await _frames(2)
	await _action("lab_run")
	await _frames(20)
	await _action("lab_run")
	await _action("lab_reset")
	await _frames(3)
	var cam = lab.get("camera_rig")
	cam.focus_on(Vector3(0.1, 0.1, 0.0), 0.4)
	await _frames(5)
	cam.go_home()
	await _frames(5)
	await _mouse_drag(Vector2(800, 450), Vector2(900, 480), MOUSE_BUTTON_LEFT, false)
	await _mouse_drag(Vector2(800, 450), Vector2(700, 420), MOUSE_BUTTON_LEFT, true)
	await _mouse_drag(Vector2(800, 450), Vector2(820, 430), MOUSE_BUTTON_MIDDLE, false)
	for i in 3:
		var w := InputEventMouseButton.new()
		w.button_index = MOUSE_BUTTON_WHEEL_UP
		w.pressed = true
		w.position = Vector2(800, 450)
		Input.parse_input_event(w)
		await process_frame
	cam.go_home(true)
	await _frames(3)
	# pick: project every component to the screen and click it
	var picked := 0
	for app in controller.components:
		var pos3: Vector3 = (app as Node3D).global_position + Vector3(0, float(lab.get("BEAM_HEIGHT")), 0)
		if cam.camera.is_position_behind(pos3):
			continue
		var sp: Vector2 = cam.camera.unproject_position(pos3)
		lab.call("_try_pick", sp)
		await process_frame
		if lab.get("selected") == app:
			picked += 1
	_ok(picked >= 1, "lab %s: clicking on the apparatus selected nothing (%d/%d)" % [id, picked, controller.components.size()])
	lab.call("_try_pick", Vector2(5, 5))
	await process_frame
	print("lab %s: %d components, %d presets, %d params, %d overlays, picked %d/%d" % [id, controller.components.size(), n_presets, n_params, n_overlays, picked, controller.components.size()])

	# back to reading via the HUD button, then via Esc
	var back := _find_button(lab.get("hud"), "‹  Back to reading")
	if _ok(back != null, "lab %s has no back button" % id):
		back.pressed.emit()
		await _frames(2)
		_ok(_screen_kind() == "chapter", "lab %s: back button did not return to the chapter" % id)
	_app_state.go_lab(id)
	await _frames(3)
	await _action("ui_cancel")
	await _frames(2)
	_ok(_screen_kind() == "chapter", "lab %s: Esc did not return to the chapter" % id)


func _mouse_drag(from: Vector2, to: Vector2, button: MouseButton, shift: bool) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = button
	down.pressed = true
	down.position = from
	down.shift_pressed = shift
	Input.parse_input_event(down)
	await process_frame
	for i in 4:
		var mv := InputEventMouseMotion.new()
		mv.position = from.lerp(to, (i + 1) / 4.0)
		mv.relative = (to - from) / 4.0
		mv.button_mask = MOUSE_BUTTON_MASK_LEFT if button == MOUSE_BUTTON_LEFT else MOUSE_BUTTON_MASK_MIDDLE
		mv.shift_pressed = shift
		Input.parse_input_event(mv)
		await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = button
	up.pressed = false
	up.position = to
	up.shift_pressed = shift
	Input.parse_input_event(up)
	await _frames(2)
