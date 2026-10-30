extends Control
## A chapter: sidebar table of contents + one story page at a time, built from blocks.

var chapter_id := "intro"
var page_index := 0
var _pages: Array = []
var _chapter: Dictionary = {}

var _toc: VBoxContainer
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
	_build_layout()
	_show_page(clampi(page_index, 0, maxi(_pages.size() - 1, 0)))


func _build_layout() -> void:
	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	# ---- sidebar
	var side := PanelContainer.new()
	side.theme_type_variation = "Sidebar"
	side.custom_minimum_size = Vector2(300, 0)
	root.add_child(side)
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

	_toc = VBoxContainer.new()
	_toc.add_theme_constant_override("separation", 2)
	side_v.add_child(_toc)
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
		b.pressed.connect(func() -> void: _show_page(first_page))
		_toc.add_child(b)
		_toc_buttons[p["section_id"]] = b

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

	# ---- page area
	var main := VBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	_page_box.custom_minimum_size = Vector2(860, 0)
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
	_prev_btn.text = "←  Previous"
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
	_next_btn.text = "Next  →" if not last else ("Next chapter  →" if nxt != "" else "Back to experiments")
	for sid in _toc_buttons:
		var b: Button = _toc_buttons[sid]
		b.add_theme_color_override("font_color", Palette.ACCENT_SOFT if sid == page["section_id"] else Palette.TEXT_DIM)
	AppState.mark_page(chapter_id, page_index, _pages.size())
	_page_scroll.scroll_vertical = 0


func _render_blocks(blocks: Array) -> void:
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
