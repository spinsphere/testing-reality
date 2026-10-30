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
## `--quick` (after `--`): fewer frames and shorter parameter sweeps, for the slow software-GL pass.
var _quick := false
var _f := 2  # frames to wait after a UI change
var _checks := 0
var _app_state: Node
var _main: Node
var _root: Window


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	_quick = "--quick" in OS.get_cmdline_user_args()
	_f = 1 if _quick else 2
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
	await _frames(_f)
	_ok(_screen_kind() == "hub", "did not return to hub at the end")
	_main.queue_free()
	await process_frame


func _drive_hub() -> void:
	var hub := _screen()
	# settings overlay: toggles, quality, reset progress, close
	var settings := _find_button(hub, "⚙")
	if _ok(settings != null, "hub has no settings button"):
		settings.pressed.emit()
		await _frames(_f)
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
				await _frames(_f)
			_ok(not is_instance_valid(overlay) or overlay.is_queued_for_deletion(), "settings overlay did not close")
		# open again, Esc closes it
		settings.pressed.emit()
		await _frames(_f)
		await _action("ui_cancel")
		# open again, reset progress
		settings.pressed.emit()
		await _frames(_f)
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
		await _frames(_f)
		_ok(_screen_kind() == "chapter" and _app_state.current_route.get("id") == _app_state.CHAPTERS[i]["id"],
			"card %d did not open chapter %s" % [i, _app_state.CHAPTERS[i]["id"]])
		_app_state.go_hub()
		await _frames(_f)
		hub = _screen()
		cards.clear()
		for c in _descendants(hub):
			if c is PanelContainer and str((c as Control).theme_type_variation) in ["Card", "CardHover"]:
				cards.append(c)
	print("hub: ok")


func _drive_chapter(ch: Dictionary) -> void:
	var id: String = ch["id"]
	_app_state.go_chapter(id, 0)
	await _frames(_f)
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
		await _frames(_f)
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
		await _frames(_f)
		prevb.pressed.emit()
		await _frames(_f)
	# last page → "Next" goes to the next chapter or the hub
	scr.call("_show_page", pages.size() - 1)
	await _frames(_f)
	nextb.pressed.emit()
	await _frames(_f)
	var nxt: String = _app_state.next_chapter_id(id)
	if nxt != "":
		_ok(_screen_kind() == "chapter" and _app_state.current_route.get("id") == nxt, "chapter %s: Next did not open %s" % [id, nxt])
	else:
		_ok(_screen_kind() == "hub", "chapter %s: Next did not return to hub" % id)
	# L enters the lab (if any) and Esc comes back; Esc from a chapter → hub
	_app_state.go_chapter(id, 0)
	await _frames(_f)
	if str(ch.get("lab", "")) != "":
		await _action("lab_toggle")
		await _frames(_f)
		_ok(_screen_kind() == "lab", "chapter %s: L did not enter the lab" % id)
		await _action("ui_cancel")
		await _frames(_f)
		_ok(_screen_kind() == "chapter", "lab %s: Esc did not return to the chapter" % id)
		var enter := _find_button(_screen(), "◆  Enter the lab")
		_ok(enter != null, "chapter %s has no Enter-the-lab button" % id)
	var home := _find_button(_screen(), "‹  All experiments")
	if _ok(home != null, "chapter %s has no home button" % id):
		home.pressed.emit()
		await _frames(_f)
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
	# bench consistency: nothing floats, "out" means set aside on the table, films sit on the
	# mask, the slit → detector distance on the table is the one the physics uses, every
	# beam splitter has its dump
	var mask: Node = lab.get("mask")
	var scanner_node: Node = lab.get("scanner")
	for app in controller.components:
		var mr: Node3D = app.get("model_root")
		_ok(is_zero_approx(mr.position.y), "lab %s: %s's model floats %.3f m above its base" % [id, app.label, mr.position.y])
		_ok(is_zero_approx((app as Node3D).position.y), "lab %s: %s is placed %.3f m above the table" % [id, app.label, (app as Node3D).position.y])
		if (app.params as Dictionary).has("enabled") and (app.params as Dictionary).has("angle"):
			var was: bool = app.get_param("enabled")
			app.set_param("enabled", false, false)
			app.refresh_visual()
			_ok(is_zero_approx(mr.position.y) and absf(mr.position.z) > 0.01, "lab %s: %s taken out of the beam is not set aside on the table (offset %s)" % [id, app.label, mr.position])
			app.set_param("enabled", was, false)
			app.refresh_visual()
		if str(app.model) == "polarizer_film" and mask != null:
			var gap: float = (app as Node3D).global_position.distance_to((mask as Node3D).global_position)
			_ok(gap < 0.02, "lab %s: film %s is %.3f m from the slit mask" % [id, app.label, gap])
	if mask != null and scanner_node != null:
		var table_l: float = (mask as Node3D).global_position.distance_to((scanner_node as Node3D).global_position)
		var model_l: float = scanner_node.get_param("distance")
		_ok(absf(table_l - model_l) < 0.03, "lab %s: slit → D1 is %.2f m on the table but L = %.2f m in the physics" % [id, table_l, model_l])
	var has_bs := false
	for app in controller.components:
		if str(app.model) == "pbs_cube":
			has_bs = true
	if has_bs:
		var dumps := 0
		for c in (lab.get("apparatus_root") as Node).get_children():
			if str(c.get("model")) == "beam_dump" and str(c.get("label")) == "BD":
				dumps += 1
		_ok(dumps >= 1, "lab %s: the beam splitter has no beam dump" % id)
		_ok((lab.get("stray_beams") as Array).size() >= 1, "lab %s: no stray beam for the splitter's reflection" % id)
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
		var origs: Array = []
		for s in sliders:
			var sl: HSlider = s
			var orig := sl.value
			origs.append(orig)
			for v in ([sl.max_value, orig] if _quick else [sl.min_value, sl.max_value, (sl.min_value + sl.max_value) * 0.5, orig]):
				sl.value = v
				await _frames(_f)
			n_params += 1
		for b in ([] if _quick else small_buttons):
			(b as Button).pressed.emit()
			await _frames(_f)
		# the quick angle buttons leave the sliders changed (e.g. laser polarization at 90°, which
		# the beam splitter then blocks): put every slider back so later checks see the preset
		for i in sliders.size():
			(sliders[i] as HSlider).value = origs[i]
		await _frames(_f)
		for c in checks:
			var cb: CheckBox = c
			cb.button_pressed = not cb.button_pressed
			await _frames(_f)
			cb.button_pressed = not cb.button_pressed
			await _frames(_f)
			n_params += 1
		for o in options:
			var ob: OptionButton = o
			var orig := ob.selected
			for i in ob.item_count:
				ob.select(i)
				ob.item_selected.emit(i)
				await _frames(_f)
			ob.select(orig)
			ob.item_selected.emit(orig)
			await _frames(_f)
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

	# shutter and power: closing the shutter kills every rate, the beam and every channel
	var laser: Node = null
	for app in controller.components:
		if (app.params as Dictionary).has("on") and (app.params as Dictionary).has("power"):
			laser = app
	if _ok(laser != null, "lab %s has no laser with a shutter" % id):
		var rate_before: float = controller.rate_scale()
		_ok(rate_before > 0.0, "lab %s: rate scale is %.1f with the shutter open" % [id, rate_before])
		laser.set_param("on", false)
		await _frames(3)
		_ok(controller.rate_scale() == 0.0, "lab %s: shutter closed but rate scale %.1f" % [id, controller.rate_scale()])
		var banner := false
		for t in _texts(lab.get("hud")):
			if str(t).begins_with("SHUTTER CLOSED"):
				banner = true
		_ok(banner, "lab %s: no shutter banner in the state panel" % id)
		var any_beam := false
		for c in (lab.get("beams") as Node).get_children():
			if (c as Node3D).visible:
				any_beam = true
		_ok(not any_beam, "lab %s: beam still drawn with the shutter closed" % id)
		for chan in lab.call("acquisition_channels"):
			_ok(float(chan["rate"]) == 0.0, "lab %s: channel %s has rate %.1f with the shutter closed" % [id, chan["name"], chan["rate"]])
		laser.set_param("on", true)
		await _frames(3)
		_ok(is_equal_approx(controller.rate_scale(), rate_before), "lab %s: rate scale did not recover after reopening the shutter" % id)
	# acquisition: 4 s of counting must give Poisson-compatible counts on every channel
	var channels: Array = lab.call("acquisition_channels")
	_ok(channels.size() >= 1, "lab %s has no acquisition channels" % id)
	lab.call("acquisition_toggle")
	_ok(bool(lab.get("acq_running")), "lab %s: Run did not start the acquisition" % id)
	await _frames(3)   # a few real frames through _process
	lab.call("acquisition_advance", 4.0)
	await process_frame
	var t_acq: float = lab.get("acq_time")
	_ok(t_acq >= 4.0, "lab %s: acquisition time %.2f after 4 s" % [id, t_acq])
	var counts: Dictionary = lab.get("acq_counts")
	var any_count := false
	for chan in channels:
		var expected := float(chan["rate"]) * t_acq
		var n := int(counts.get(chan["name"], 0))
		var tol := 6.0 * sqrt(maxf(expected, 1.0)) + 2.0
		_ok(absf(n - expected) <= tol, "lab %s: channel %s counted %d, expected %.0f ± %.0f" % [id, chan["name"], n, expected, tol])
		if n > 0:
			any_count = true
	_ok(any_count, "lab %s: nothing counted in %.1f s" % [id, t_acq])
	var acq_texts := _texts(lab.get("acq_box"))
	_ok(acq_texts.size() >= channels.size() * 2, "lab %s: counting panel shows %d labels for %d channels" % [id, acq_texts.size(), channels.size()])
	var counter: Node = lab.get("counter_display")
	if counter != null:
		_ok(str((counter.get("_label3d") as Label3D).text).contains("D1"), "lab %s: counter display does not show the counts" % id)
	lab.call("acquisition_reset")
	_ok(not bool(lab.get("acq_running")) and (lab.get("acq_counts") as Dictionary).is_empty(), "lab %s: reset did not clear the acquisition" % id)

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

	# detector scan (slit labs): every position counted, points drawn, detector back under control
	if has_slits:
		var steps: int = lab.get("scan_steps")
		var dwell: float = lab.get("scan_dwell")
		var scan_btn := _find_button(lab.get("results_box"), "▶  Scan D1")
		if _ok(scan_btn != null, "lab %s has no Scan button" % id):
			scan_btn.pressed.emit()
		await _frames(_f)
		_ok(bool(lab.get("scan_running")), "lab %s: scan did not start" % id)
		var scanner: Node = lab.get("scanner")
		_ok(is_equal_approx(float(scanner.get_param("position")), -float(scanner.get_param("range"))), "lab %s: scan did not move D1 to the start" % id)
		_ok(_find_button(lab.get("results_box"), "■  Stop scan") != null, "lab %s: no Stop button while scanning" % id)
		for i in steps + 2:
			if not bool(lab.get("scan_running")):
				break
			lab.call("scan_advance", dwell)
			await _frames(_f)
		_ok(not bool(lab.get("scan_running")), "lab %s: scan still running after %d steps" % [id, steps])
		var pts: Array = lab.get("scan_points")
		_ok(pts.size() == steps, "lab %s: scan recorded %d points, expected %d" % [id, pts.size(), steps])
		var total := 0
		for pt in pts:
			total += int(pt["n"])
		_ok(total > 0, "lab %s: the scan counted nothing" % id)
		var green := 0
		for c in _descendants(lab.get("results_box")):
			if _is_a(c, "PatternPlot"):
				for pset in (c.get("points") as Array):
					if (pset["xs"] as PackedFloat64Array).size() == steps:
						green += 1
		_ok(green >= 1, "lab %s: scan points not drawn on the plot" % id)
		var clear_btn := _find_button(lab.get("results_box"), "clear scan")
		if _ok(clear_btn != null, "lab %s: no clear-scan button after the scan" % id):
			clear_btn.pressed.emit()
			await _frames(_f)
			_ok((lab.get("scan_points") as Array).is_empty(), "lab %s: clear scan left points" % id)

	# stage stepping: follow the beam up to the second element, then lift the focus
	var comps: Array = controller.components
	lab.call("focus_stage", comps[1])
	await _frames(_f)
	_ok(lab.get("_focus_app") == comps[1] and lab.get("selected") == comps[1], "lab %s: focus_stage did not select the stage" % id)
	_ok(lab.call("beyond_focus", comps[comps.size() - 1]) and not lab.call("beyond_focus", comps[0]), "lab %s: beyond_focus wrong" % id)
	var dim_rows := 0
	for c in (lab.get("state_box") as Node).get_children():
		if (c as Control).modulate.a < 0.9:
			dim_rows += 1
	_ok(dim_rows >= 1, "lab %s: no dimmed stages while following the beam" % id)
	# clicking the focused row again lifts the focus
	var rows: Array = (lab.get("state_box") as Node).get_children()
	var row1: Control = null
	for c in rows:
		if c is VBoxContainer and (c as Control).modulate.a > 0.9:
			row1 = c
			break
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	lab.call("focus_stage", comps[1])
	await _frames(_f)
	_ok(lab.get("_focus_app") == null, "lab %s: second focus_stage did not lift the focus" % id)
	if row1:
		row1.gui_input.emit(ev)
		await _frames(_f)
		_ok(lab.get("_focus_app") != null, "lab %s: clicking a state row did not focus it" % id)
		lab.call("focus_stage", lab.get("_focus_app"))
		await _frames(_f)
	lab.call("select", null)

	# photons: deterministic ticks, every photon ends at a detector or an absorber
	lab.call("toggle_photons")
	_ok(bool(lab.get("_photon_mode")), "lab %s: photon mode did not start" % id)
	var branched: bool = not (lab.get("beam_paths") as Array).is_empty()
	for i in (60 if _quick else 240):
		lab.call("tick_photons", 0.05)
		if i % 20 == 19:
			await process_frame
	var anim: Dictionary = lab.get("_anim")
	_ok(int(anim["sent"]) >= 3, "lab %s: only %d photons sent in photon mode" % [id, int(anim["sent"])])
	if not _quick:
		var det: Dictionary = anim["detected"]
		var hits := 0
		for k in det:
			hits += int(det[k])
		_ok(hits >= 1, "lab %s: no photon reached a detector in 12 s of animation" % id)
		if branched:
			_ok(det.size() >= 1, "lab %s: pair animation detected nothing" % id)
	var anim_label: Label = lab.get("_anim_label")
	_ok(anim_label.visible and anim_label.text.contains("sent"), "lab %s: photon-mode readout missing" % id)
	lab.call("toggle_photons")
	await _frames(_f)
	_ok((lab.get("_photons") as Array).is_empty(), "lab %s: photons left after switching the mode off" % id)
	await _action("lab_run")
	await _frames(5 if _quick else 20)
	await _action("lab_run")
	await _action("lab_reset")
	await _frames(3)
	var cam = lab.get("camera_rig")
	cam.focus_on(Vector3(0.1, 0.1, 0.0), 0.4)
	await _frames(5)
	cam.go_home()
	await _frames(5)
	# mouse events go through the whole pipeline (Window → GUI → _unhandled_input), so this
	# also proves no full-screen Control swallows them
	var centre := Vector2(_root.size) * 0.5
	var yaw0: float = cam._yaw_goal
	var target0: Vector3 = cam._target_goal
	var dist0: float = cam._distance_goal
	await _mouse_drag(centre, centre + Vector2(100, 30), MOUSE_BUTTON_LEFT, false)
	_ok(not is_equal_approx(cam._yaw_goal, yaw0), "lab %s: left drag did not orbit the camera" % id)
	await _mouse_drag(centre, centre + Vector2(-100, -30), MOUSE_BUTTON_LEFT, true)
	_ok(not (cam._target_goal as Vector3).is_equal_approx(target0), "lab %s: shift-drag did not pan the camera" % id)
	await _mouse_drag(centre, centre + Vector2(20, -20), MOUSE_BUTTON_MIDDLE, false)
	for i in 3:
		var w := InputEventMouseButton.new()
		w.button_index = MOUSE_BUTTON_WHEEL_UP
		w.pressed = true
		w.position = centre
		Input.parse_input_event(w)
		await process_frame
	_ok(cam._distance_goal < dist0, "lab %s: mouse wheel did not zoom the camera" % id)
	cam.go_home(true)
	await _frames(3)
	# pick: project every component to the screen and click it
	var picked := 0
	for app in controller.components:
		var pos3: Vector3 = (app as Node3D).global_position + Vector3(0, float(lab.get("BEAM_HEIGHT")), 0)
		if cam.camera.is_position_behind(pos3):
			continue
		# parse_input_event takes window coordinates; the stretch transform maps them to the viewport
		var sp: Vector2 = _root.get_final_transform() * (cam.camera.unproject_position(pos3) as Vector2)
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		click.position = sp
		Input.parse_input_event(click)
		await process_frame
		click = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = false
		click.position = sp
		Input.parse_input_event(click)
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
		await _frames(_f)
		_ok(_screen_kind() == "chapter", "lab %s: back button did not return to the chapter" % id)
	_app_state.go_lab(id)
	await _frames(3)
	await _action("ui_cancel")
	await _frames(_f)
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
	await _frames(_f)
