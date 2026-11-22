class_name Carousel
extends VBoxContainer
## Image slider for the lab photos, like the site's: one picture at the width of the text,
## arrows on both sides, dots below, a caption, automatic rotation every few seconds (paused
## while the pointer is over it, and off entirely with "reduce motion"), and a horizontal
## swipe on a touch screen. Built by BlockFactory from a `carousel` block.

const AUTO_SECONDS := 5.0
const SWIPE_PX := 40.0

var slides: Array = []          # [{src, caption}]
var index := 0
var _frame: FitWidthBox
var _image: TextureRect
var _missing: Label
var _caption: RichTextLabel
var _dots: HBoxContainer
var _timer: Timer
var _hover := false
var _press_x := INF


func setup(p_slides: Array) -> void:
	slides = p_slides


func _ready() -> void:
	add_theme_constant_override("separation", 8)
	var textures: Array[Texture2D] = []
	var ratio := 16.0 / 9.0
	for s in slides:
		var src := str(s.get("src", ""))
		var t: Texture2D = load(src) if ResourceLoader.exists(src) else null
		textures.append(t)
	for t in textures:
		if t != null:
			ratio = float(t.get_width()) / maxf(1.0, float(t.get_height()))
			break
	# the picture fills the column; its height follows from the aspect ratio
	_frame = FitWidthBox.new()
	_frame.ratio = ratio
	_frame.max_height = BlockFactory.FIGURE_MAX_HEIGHT
	_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_frame.mouse_filter = Control.MOUSE_FILTER_PASS
	_frame.gui_input.connect(_on_frame_input)
	_frame.mouse_entered.connect(func() -> void: _hover = true)
	_frame.mouse_exited.connect(func() -> void: _hover = false)
	add_child(_frame)
	_image = TextureRect.new()
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_image)
	_missing = Label.new()
	_missing.theme_type_variation = "Mono"
	_missing.visible = false
	_missing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_missing)
	set_meta("textures", textures)

	if slides.size() > 1:
		_frame.add_child(_arrow("‹", -1, "left"))
		_frame.add_child(_arrow("›", 1, "right"))
		_dots = HBoxContainer.new()
		_dots.alignment = BoxContainer.ALIGNMENT_CENTER
		_dots.add_theme_constant_override("separation", 6)
		for i in slides.size():
			var d := Button.new()
			d.custom_minimum_size = Vector2(28, 28)   # a touch target; the dot itself is drawn
			d.flat = true
			d.focus_mode = Control.FOCUS_NONE
			d.theme_type_variation = "GhostButton"
			d.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
			d.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
			d.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
			d.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
			d.tooltip_text = "Picture %d of %d" % [i + 1, slides.size()]
			d.pressed.connect(func() -> void: show_slide(i, true))
			d.draw.connect(func() -> void:
				var c := Palette.ACCENT_SOFT if i == index else Palette.BORDER
				d.draw_circle(d.size * 0.5, 5.0 if i == index else 4.0, c))
			_dots.add_child(d)
		add_child(_dots)
		_timer = Timer.new()
		_timer.wait_time = AUTO_SECONDS
		_timer.timeout.connect(_on_tick)
		add_child(_timer)
		_timer.start()

	_caption = BlockFactory.rich_text("")
	_caption.add_theme_color_override("default_color", Palette.TEXT_DIM)
	add_child(_caption)
	show_slide(0, false)


func _arrow(glyph: String, dir: int, side: String) -> Button:
	var b := Button.new()
	b.text = glyph
	b.theme_type_variation = "GhostButton"
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(44, 56)
	b.add_theme_font_size_override("font_size", 30)
	b.tooltip_text = "Next picture" if dir > 0 else "Previous picture"
	b.set_meta("side", side)
	b.pressed.connect(func() -> void: show_slide(index + dir, true))
	return b


func show_slide(i: int, by_user: bool) -> void:
	if slides.is_empty():
		return
	index = posmod(i, slides.size())
	var textures: Array = get_meta("textures")
	var t: Texture2D = textures[index]
	_image.texture = t
	_missing.visible = t == null
	if t == null:
		_missing.text = "[figure %s missing]" % str(slides[index].get("src", ""))
	var cap := str(slides[index].get("caption", ""))
	var n := "%d / %d  ·  " % [index + 1, slides.size()] if slides.size() > 1 else ""
	_caption.text = BlockFactory.ketify("[center][i]%s%s[/i][/center]" % [n, cap])
	_caption.visible = cap != "" or slides.size() > 1
	if _dots:
		for d in _dots.get_children():
			(d as Control).queue_redraw()
	if by_user and _timer:
		_timer.start()   # a manual change restarts the countdown


func _on_tick() -> void:
	if _hover or bool(AppState.settings.get("reduce_motion", false)):
		return
	show_slide(index + 1, false)


## Horizontal swipe (touch or mouse): the press position is remembered, and a release more
## than SWIPE_PX away turns the page. Vertical drags are left to the ScrollContainer.
func _on_frame_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_press_x = st.position.x
		else:
			_end_swipe(st.position.x)
	elif event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			_press_x = mb.position.x
		else:
			_end_swipe(mb.position.x)


func _end_swipe(x: float) -> void:
	if _press_x == INF:
		return
	var dx := x - _press_x
	_press_x = INF
	if absf(dx) >= SWIPE_PX and slides.size() > 1:
		show_slide(index + (1 if dx < 0.0 else -1), true)
		_frame.accept_event()
