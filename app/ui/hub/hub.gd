extends Control
## Home screen: the site's hero text and the experiment grid as cards.

var _cards: Array[PanelContainer] = []


func _ready() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(1180, 0)
	column.add_theme_constant_override("separation", 18)
	center.add_child(column)

	column.add_child(_spacer(40))
	var head := HBoxContainer.new()
	var kicker := Label.new()
	kicker.text = "TESTING REALITY"
	kicker.theme_type_variation = "Kicker"
	kicker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(kicker)
	var settings := Button.new()
	settings.text = "⚙  Settings & keys"
	settings.theme_type_variation = "GhostButton"
	settings.pressed.connect(func() -> void: add_child(SettingsOverlay.new()))
	head.add_child(settings)
	column.add_child(head)

	var title := Label.new()
	title.text = "Quantum Experiments"
	title.theme_type_variation = "H1"
	title.add_theme_font_size_override("font_size", 56)
	column.add_child(title)

	var tagline := Label.new()
	tagline.text = "From simple polarizers to the double-slit quantum eraser: a pedagogical journey through the heart of quantum mystery."
	tagline.theme_type_variation = "Muted"
	tagline.add_theme_font_size_override("font_size", 20)
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(tagline)

	var mystery := RichTextLabel.new()
	mystery.bbcode_enabled = true
	mystery.fit_content = true
	mystery.text = ("You may have heard that particles can exist in two places at once, that the act of observation " +
		"collapses the wave function, and that entangled particles respond to each other instantly across any distance. " +
		"[i]But is that really how it works?[/i] Before buying into the hype, we take a step back and check these claims against " +
		"the mathematical formalism and real experimental observations — in a laboratory you can walk around and adjust yourself.")
	mystery.custom_minimum_size = Vector2(0, 0)
	column.add_child(mystery)

	column.add_child(_spacer(10))
	var grid_title := Label.new()
	grid_title.text = "Experiments"
	grid_title.theme_type_variation = "H2"
	column.add_child(grid_title)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	column.add_child(grid)

	for chapter in AppState.CHAPTERS:
		grid.add_child(_make_card(chapter))

	column.add_child(_spacer(30))
	var footer := Label.new()
	footer.text = "Based on testing-reality.webflow.io · Testing Reality © 2018–2026 · Creative Commons · Interactive edition built with Godot and the Quagmire Engine"
	footer.theme_type_variation = "Muted"
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(footer)
	column.add_child(_spacer(40))


func _spacer(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _make_card(chapter: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = "Card"
	card.custom_minimum_size = Vector2(560, 150)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	card.add_child(row)

	var thumb := _make_thumbnail(chapter["id"])
	row.add_child(thumb)

	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	row.add_child(v)

	var kicker := Label.new()
	kicker.text = str(chapter["kicker"]).to_upper()
	kicker.theme_type_variation = "Kicker"
	v.add_child(kicker)
	var title := Label.new()
	title.text = chapter["title"]
	title.theme_type_variation = "H2"
	title.add_theme_font_size_override("font_size", 26)
	v.add_child(title)
	var sub := Label.new()
	sub.text = chapter["subtitle"]
	sub.theme_type_variation = "Muted"
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(sub)

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 10)
	v.add_child(bottom)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(160, 6)
	bar.show_percentage = false
	bar.max_value = 1.0
	bar.value = AppState.completion(chapter["id"])
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bottom.add_child(bar)
	var pct := Label.new()
	pct.theme_type_variation = "Muted"
	pct.text = "%d %%" % roundi(bar.value * 100.0)
	bottom.add_child(pct)
	if chapter.get("lab", "") != "":
		var lab_tag := Label.new()
		lab_tag.text = "  ◆ 3D lab"
		lab_tag.theme_type_variation = "Muted"
		lab_tag.add_theme_color_override("font_color", Palette.ACCENT_SOFT)
		bottom.add_child(lab_tag)

	card.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			AppState.go_chapter(chapter["id"]))
	card.mouse_entered.connect(func() -> void: card.theme_type_variation = "CardHover")
	card.mouse_exited.connect(func() -> void: card.theme_type_variation = "Card")
	_cards.append(card)
	return card


## A small schematic drawn in code (laser → components → detector), one per chapter.
func _make_thumbnail(id: String) -> Control:
	var t := ChapterThumbnail.new()
	t.chapter_id = id
	t.custom_minimum_size = Vector2(150, 110)
	return t


class ChapterThumbnail extends Control:
	var chapter_id := "intro"

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color("#0b0c1a"))
		draw_rect(r, Palette.BORDER, false, 1.0)
		var y := size.y * 0.5
		var x0 := 14.0
		var x1 := size.x - 14.0
		match chapter_id:
			"intro":
				# a ket arrow diagram: two orthogonal arrows and a diagonal superposition
				var o := Vector2(size.x * 0.3, size.y * 0.78)
				draw_line(o, o + Vector2(80, 0), Palette.LASER_RED, 2.0)
				draw_line(o, o + Vector2(0, -60), Palette.ACCENT, 2.0)
				draw_line(o, o + Vector2(56, -56), Palette.TEXT, 2.0)
				draw_circle(o, 3.0, Palette.TEXT)
			_:
				var beam := Palette.wavelength_to_color(405.0)
				draw_line(Vector2(x0 + 18, y), Vector2(x1 - 12, y), Color(beam, 0.9), 2.0)
				draw_rect(Rect2(x0, y - 7, 18, 14), Palette.LASER_RED)
				var n: int = {"exp1": 3, "exp2": 0, "exp3": 3, "exp4": 2, "exp5": 3, "exp6": 4, "exp7": 4}.get(chapter_id, 2)
				for i in n:
					var x := lerpf(x0 + 36, x1 - 40, (i + 0.5) / float(n))
					draw_circle(Vector2(x, y), 9.0, Color(Palette.POLARIZER, 0.35))
					draw_arc(Vector2(x, y), 9.0, 0, TAU, 24, Palette.POLARIZER, 1.5)
				if chapter_id in ["exp2", "exp3", "exp5", "exp6", "exp7"]:
					var sx := lerpf(x0, x1, 0.42)
					draw_rect(Rect2(sx - 2, y - 22, 4, 16), Palette.TEXT_DIM)
					draw_rect(Rect2(sx - 2, y - 3, 4, 6), Palette.TEXT_DIM)
					draw_rect(Rect2(sx - 2, y + 6, 4, 16), Palette.TEXT_DIM)
				if chapter_id in ["exp4", "exp5", "exp6", "exp7"]:
					draw_line(Vector2(x0 + 60, y), Vector2(x1 - 12, y - 30), Color(Palette.PINK, 0.8), 2.0)
					draw_rect(Rect2(x1 - 12, y - 36, 10, 12), Palette.TEXT)
				draw_rect(Rect2(x1 - 12, y - 7, 10, 14), Palette.TEXT)
