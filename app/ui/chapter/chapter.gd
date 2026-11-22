extends Control
## A chapter: table of contents + one story page at a time, built from blocks.
## Wide windows show the contents as a sidebar; compact ones (phones, narrow browser
## windows, see Layout) put a bar with a contents button on top and open the contents as an
## overlay. Pages scroll with the wheel, the keyboard, or a finger.

var chapter_id := "intro"
var page_index := 0
var _pages: Array = []
var _chapter: Dictionary = {}
var _compact := false

var _toc: VBoxContainer
var _toc_overlay: Control
var _page_scroll: ScrollContainer
var _page_box: VBoxContainer
var _prev_btn: Button
var _next_btn: Button
var _counter: Label
var _toc_buttons: Dictionary = {}  # section_id -> Button


func setup(id: String, page: int) -> void:
	chapter_id = id
	page_index = page


func _ready() -> void:
	_chapter = AppState.chapter(chapter_id)
	_pages = ContentDB.pages(chapter_id)
	_compact = Layout.compact(self)
	_build_layout()
	_show_page(clampi(page_index, 0, maxi(_pages.size() - 1, 0)))


## Called by main.gd when the window changes size without crossing the compact threshold.
func on_resized() -> void:
	_page_box.custom_minimum_size.x = Layout.page_width(self)


func _build_layout() -> void:
	var root: BoxContainer = VBoxContainer.new() if _compact else HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	if _compact:
		root.add_child(_build_top_bar())
	else:
		root.add_child(_build_sidebar())

	# ---- page area
	var main := VBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 0)
	root.add_child(main)

	_page_scroll = ScrollContainer.new()
	_page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.add_child(_page_scroll)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_scroll.add_child(center)
	_page_box = VBoxContainer.new()
	_page_box.custom_minimum_size = Vector2(Layout.page_width(self), 0)
	_page_box.add_theme_constant_override("separation", 18)
	center.add_child(_page_box)

	# ---- bottom nav
	var nav := PanelContainer.new()
	nav.theme_type_variation = "Sidebar"
	main.add_child(nav)
	var nav_h := HBoxContainer.new()
	nav_h.add_theme_constant_override("separation", 12)
	nav.add_child(nav_h)
	_prev_btn = Button.new()
	_prev_btn.text = "‹  Prev" if _compact else "←  Previous"
	_prev_btn.theme_type_variation = "GhostButton"
	_prev_btn.pressed.connect(func() -> void: _show_page(page_index - 1))
	nav_h.add_child(_prev_btn)
	_counter = Label.new()
	_counter.theme_type_variation = "Muted"
	_counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav_h.add_child(_counter)
	_next_btn = Button.new()
	_next_btn.text = "Next  →"
	_next_btn.pressed.connect(_on_next)
	nav_h.add_child(_next_btn)

	if _compact:
		_toc_overlay = _build_toc_overlay()
		add_child(_toc_overlay)


func _build_sidebar() -> Control:
	var side := PanelContainer.new()
	side.theme_type_variation = "Sidebar"
	side.custom_minimum_size = Vector2(300, 0)
	var side_v := VBoxContainer.new()
	side_v.add_theme_constant_override("separation", 10)
	side.add_child(side_v)

	var home := Button.new()
	home.text = "‹  All experiments"
	home.theme_type_variation = "GhostButton"
	home.alignment = HORIZONTAL_ALIGNMENT_LEFT
	home.pressed.connect(AppState.go_hub)
	side_v.add_child(home)

	var kicker := Label.new()
	kicker.text = str(_chapter.get("kicker", "")).to_upper()
	kicker.theme_type_variation = "Kicker"
	side_v.add_child(kicker)
	var title := Label.new()
	title.text = _chapter.get("title", chapter_id)
	title.theme_type_variation = "H2"
	title.add_theme_font_size_override("font_size", 26)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_v.add_child(title)

	var toc_label := Label.new()
	toc_label.text = "TABLE OF CONTENT"
	toc_label.theme_type_variation = "Kicker"
	side_v.add_child(toc_label)
	side_v.add_child(_build_toc())

	var filler := Control.new()
	filler.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_v.add_child(filler)

	if _chapter.get("lab", "") != "":
		var lab := Button.new()
		lab.text = "◆  Enter the lab   (L)"
		lab.pressed.connect(func() -> void: AppState.go_lab(chapter_id))
		side_v.add_child(lab)

	var hint := Label.new()
	hint.text = "← →  pages   ·   Esc  back"
	hint.theme_type_variation = "Muted"
	side_v.add_child(hint)
	return side


## Compact: one bar with back, the chapter name, the lab and the contents.
func _build_top_bar() -> Control:
	var bar := PanelContainer.new()
	bar.theme_type_variation = "Sidebar"
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	bar.add_child(h)
	var home := Button.new()
	home.text = "‹"
	home.theme_type_variation = "GhostButton"
	home.tooltip_text = "All experiments"
	home.pressed.connect(AppState.go_hub)
	h.add_child(home)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 0)
	h.add_child(v)
	var kicker := Label.new()
	kicker.text = str(_chapter.get("kicker", "")).to_upper()
	kicker.theme_type_variation = "Kicker"
	v.add_child(kicker)
	var title := Label.new()
	title.text = _chapter.get("title", chapter_id)
	title.theme_type_variation = "H2"
	title.add_theme_font_size_override("font_size", 20)
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	v.add_child(title)
	if _chapter.get("lab", "") != "":
		var lab := Button.new()
		lab.text = "◆"
		lab.tooltip_text = "Enter the lab"
		lab.pressed.connect(func() -> void: AppState.go_lab(chapter_id))
		h.add_child(lab)
	var toc_btn := Button.new()
	toc_btn.text = "≡"
	toc_btn.theme_type_variation = "GhostButton"
	toc_btn.tooltip_text = "Table of content"
	toc_btn.pressed.connect(func() -> void: _toc_overlay.visible = not _toc_overlay.visible)
	h.add_child(toc_btn)
	return bar


func _build_toc() -> Control:
	_toc = VBoxContainer.new()
	_toc.add_theme_constant_override("separation", 2)
	var seen := {}
	for i in _pages.size():
		var p: Dictionary = _pages[i]
		if seen.has(p["section_id"]):
			continue
		seen[p["section_id"]] = true
		var b := Button.new()
		b.text = p["section_title"]
		b.theme_type_variation = "GhostButton"
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.flat = true
		var first_page := i
		b.pressed.connect(func() -> void:
			_show_page(first_page)
			if _toc_overlay:
				_toc_overlay.visible = false)
		_toc.add_child(b)
		_toc_buttons[p["section_id"]] = b
	return _toc


## Compact: the contents as a sheet over the page, closed by a tap outside or a choice.
func _build_toc_overlay() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			overlay.visible = false)
	overlay.add_child(dim)
	var panel := PanelContainer.new()
	panel.theme_type_variation = "Sidebar"
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.offset_top = 64
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	panel.add_child(v)
	var toc_label := Label.new()
	toc_label.text = "TABLE OF CONTENT"
	toc_label.theme_type_variation = "Kicker"
	v.add_child(toc_label)
	v.add_child(_build_toc())
	v.add_child(HSeparator.new())
	if _chapter.get("lab", "") != "":
		var lab := Button.new()
		lab.text = "◆  Enter the lab"
		lab.pressed.connect(func() -> void: AppState.go_lab(chapter_id))
		v.add_child(lab)
	var home := Button.new()
	home.text = "‹  All experiments"
	home.theme_type_variation = "GhostButton"
	home.pressed.connect(AppState.go_hub)
	v.add_child(home)
	overlay.add_child(panel)
	return overlay


func _on_next() -> void:
	if page_index + 1 < _pages.size():
		_show_page(page_index + 1)
	else:
		var nxt := AppState.next_chapter_id(chapter_id)
		if nxt != "":
			AppState.go_chapter(nxt, 0)
		else:
			AppState.go_hub()


func _show_page(i: int) -> void:
	if _pages.is_empty():
		_render_blocks([{"type": "heading", "text": "Content coming soon"},
			{"type": "text", "text": "This chapter has not been written yet."}])
		_counter.text = ""
		_prev_btn.disabled = true
		return
	page_index = clampi(i, 0, _pages.size() - 1)
	var page: Dictionary = _pages[page_index]
	var blocks: Array = []
	if page.get("title", "") != "":
		blocks.append({"type": "section", "text": page["section_title"]})
		blocks.append({"type": "heading", "text": page["title"]})
	blocks.append_array(page.get("blocks", []))
	_render_blocks(blocks)
	_counter.text = "%d / %d" % [page_index + 1, _pages.size()]
	_prev_btn.disabled = page_index == 0
	var last := page_index == _pages.size() - 1
	var nxt := AppState.next_chapter_id(chapter_id)
	if _compact:
		_next_btn.text = "Next  ›" if not last else ("Next chapter  ›" if nxt != "" else "Experiments  ›")
	else:
		_next_btn.text = "Next  →" if not last else ("Next chapter  →" if nxt != "" else "Back to experiments")
	for sid in _toc_buttons:
		var b: Button = _toc_buttons[sid]
		b.add_theme_color_override("font_color", Palette.ACCENT_SOFT if sid == page["section_id"] else Palette.TEXT_DIM)
	AppState.mark_page(chapter_id, page_index, _pages.size())
	# the route remembers the page, so a relayout (window resize, rotation) reopens it
	AppState.current_route["page"] = page_index
	_page_scroll.scroll_vertical = 0


func _render_blocks(blocks: Array) -> void:
	BlockFactory.column_width = Layout.page_width(self) - 40.0
	for c in _page_box.get_children():
		c.queue_free()
	_page_box.add_child(_spacer(28))
	for block in blocks:
		var node := BlockFactory.make(block, chapter_id)
		if node:
			_page_box.add_child(node)
	_page_box.add_child(_spacer(40))


func _spacer(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_next"):
		_on_next()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_page_prev"):
		_show_page(page_index - 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("lab_toggle") and _chapter.get("lab", "") != "":
		AppState.go_lab(chapter_id)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and _toc_overlay and _toc_overlay.visible:
		_toc_overlay.visible = false
		get_viewport().set_input_as_handled()
