class_name SettingsOverlay
extends Control
## Settings, keyboard map and "about" panel, opened from the hub.

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			queue_free())
	add_child(dim)

	var panel := PanelContainer.new()
	panel.theme_type_variation = "Card"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(760, 0)
	panel.offset_left = -380
	panel.offset_right = 380
	panel.offset_top = -300
	add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	panel.add_child(v)

	var title := Label.new()
	title.text = "Settings"
	title.theme_type_variation = "H2"
	v.add_child(title)

	v.add_child(_toggle("Reduce motion (no camera smoothing, no photon animation)", "reduce_motion"))
	v.add_child(_toggle("Show LaTeX source as equation tooltips", "show_latex"))
	var quality := HBoxContainer.new()
	var ql := Label.new()
	ql.text = "3D quality (applies when a lab opens)"
	ql.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quality.add_child(ql)
	var qo := OptionButton.new()
	for o in ["Low — integrated graphics: no shadows or glow, 75 % render scale", "Medium — 2× MSAA, shadows, glow", "High — 4× MSAA"]:
		qo.add_item(o)
	qo.selected = AppState.quality()
	qo.item_selected.connect(func(i: int) -> void:
		AppState.settings["quality"] = i
		AppState.save_progress())
	quality.add_child(qo)
	v.add_child(quality)

	var keys := Label.new()
	keys.text = "Keyboard"
	keys.theme_type_variation = "H3"
	v.add_child(keys)
	v.add_child(BlockFactory.table(["Key", "Reading", "Laboratory"], [
		["← / →  (PgUp / PgDn)", "previous / next page", "—"],
		["Esc", "back to experiments", "back to reading"],
		["L", "enter the lab", "—"],
		["Space", "—", "fire single photons"],
		["R", "—", "recompute"],
		["F", "—", "reset the camera"],
		["mouse drag / shift-drag / wheel", "—", "orbit / pan / zoom"],
	]))

	var about := BlockFactory.rich_text("[b]About.[/b] Course, experiments and data: [url=https://testing-reality.webflow.io]Testing Reality[/url] (© 2018–2026, Creative Commons). Interactive edition built with Godot, the Quagmire Engine (Rust), Blender and MathJax. Progress is saved in your user folder.")
	v.add_child(about)

	var row := HBoxContainer.new()
	var reset := Button.new()
	reset.text = "Reset progress"
	reset.theme_type_variation = "GhostButton"
	reset.pressed.connect(func() -> void:
		AppState.progress = {}
		AppState.save_progress()
		AppState.progress_changed.emit()
		queue_free()
		AppState.go_hub())
	row.add_child(reset)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(sp)
	var close := Button.new()
	close.text = "Close"
	close.pressed.connect(queue_free)
	row.add_child(close)
	v.add_child(row)


func _toggle(text: String, key: String) -> Control:
	var cb := CheckBox.new()
	cb.text = text
	cb.button_pressed = bool(AppState.settings.get(key, false))
	cb.toggled.connect(func(on: bool) -> void:
		AppState.settings[key] = on
		AppState.save_progress())
	return cb


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
