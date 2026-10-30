class_name WidgetKit
## Shared building blocks for the interactive teaching widgets: a callback canvas,
## a draggable polarizer dial, control-row builders and small drawing primitives.

## Horizontal/vertical labels (a function, not a `static var`: scripts holding static state are
## kept alive until exit and show up as leaked resources).
static func hv() -> PackedStringArray:
	return PackedStringArray(["↔", "↕"])
const PANEL_WIDTH := 250.0
const FONT_SMALL := 13
const FONT_TEXT := 15


## A Control that forwards drawing and mouse input to callables on the owner.
class Canvas extends Control:
	var draw_fn: Callable
	var input_fn: Callable

	func _init(p_draw: Callable = Callable(), p_input: Callable = Callable()) -> void:
		draw_fn = p_draw
		input_fn = p_input
		mouse_filter = Control.MOUSE_FILTER_STOP
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_EXPAND_FILL
		clip_contents = true
		resized.connect(queue_redraw)

	func _draw() -> void:
		if draw_fn.is_valid():
			draw_fn.call(self)

	func _gui_input(event: InputEvent) -> void:
		if input_fn.is_valid():
			input_fn.call(self, event)


## A polarizer drawn as a hatched disc with a pink handle on the rim; drag to set the angle.
class Dial extends Control:
	signal changed(angle_deg: float)
	var angle := 0.0:
		set(v):
			angle = v
			queue_redraw()
	var title := ""
	var color: Color = Palette.POLARIZER
	var full_turn := false
	var _dragging := false

	func _init(p_title: String = "", p_angle: float = 0.0) -> void:
		title = p_title
		angle = p_angle
		custom_minimum_size = Vector2(104, 124)
		mouse_filter = Control.MOUSE_FILTER_STOP
		resized.connect(queue_redraw)

	func _center() -> Vector2:
		return Vector2(size.x / 2.0, 20.0 + _radius() + 2.0)

	func _radius() -> float:
		return maxf(12.0, minf(size.x, size.y - 44.0) / 2.0 - 10.0)

	func _dir() -> Vector2:
		var a := deg_to_rad(angle)
		return Vector2(cos(a), -sin(a))

	func _handle_pos() -> Vector2:
		return _center() + _dir() * _radius()

	func _draw() -> void:
		var c := _center()
		var r := _radius()
		draw_circle(c, r, Color(color, 0.16))
		draw_arc(c, r, 0.0, TAU, 64, Color(color, 0.9), 2.0, true)
		var dir := _dir()
		var perp := Vector2(-dir.y, dir.x)
		for i in range(-3, 4):
			var off := perp * (i * r / 4.0)
			var half := sqrt(maxf(0.0, r * r - off.length_squared()))
			var main := i == 0
			draw_line(c + off - dir * half, c + off + dir * half, Color(color, 0.95 if main else 0.35), 2.5 if main else 1.2, true)
		# angle reference ticks at 0° and 90°
		draw_line(c + Vector2(r + 2, 0), c + Vector2(r + 6, 0), Palette.TEXT_MUTED, 1.0)
		draw_line(c - Vector2(0, r + 2), c - Vector2(0, r + 6), Palette.TEXT_MUTED, 1.0)
		var h := _handle_pos()
		draw_circle(h, 7.0, Palette.PINK)
		draw_arc(h, 7.0, 0.0, TAU, 24, Color.WHITE, 1.2, true)
		WidgetKit.text_centered(self, ThemeBuilder.body(600.0), Vector2(size.x / 2.0, 14.0), title, 14, Palette.TEXT_DIM)
		WidgetKit.text_centered(self, ThemeBuilder.mono(), Vector2(size.x / 2.0, size.y - 6.0), "%d°" % roundi(angle), 15, Palette.TEXT)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and event.position.distance_to(_center()) <= _radius() + 12.0:
				_dragging = true
				_set_from(event.position)
			else:
				_dragging = false
			accept_event()
		elif event is InputEventMouseMotion and _dragging:
			_set_from(event.position)
			accept_event()

	func _set_from(p: Vector2) -> void:
		var d := p - _center()
		if d.length() < 2.0:
			return
		var a := rad_to_deg(atan2(-d.y, d.x))
		a = fposmod(roundf(a), 360.0 if full_turn else 180.0)
		if not is_equal_approx(a, angle):
			angle = a
			changed.emit(angle)


# ---------------------------------------------------------------- drawing

static func arrow(c: CanvasItem, from: Vector2, to: Vector2, color: Color, width := 3.0, head := 12.0) -> void:
	var d := to - from
	if d.length() < 0.5:
		return
	var dir := d.normalized()
	var h := minf(head, d.length())
	var base := to - dir * h
	c.draw_line(from, base, color, width, true)
	var perp := Vector2(-dir.y, dir.x) * h * 0.42
	c.draw_colored_polygon(PackedVector2Array([to, base + perp, base - perp]), color)


static func dashed(c: CanvasItem, from: Vector2, to: Vector2, color: Color, width := 1.5, dash := 6.0) -> void:
	if from.distance_to(to) < 0.5:
		return
	c.draw_dashed_line(from, to, color, width, dash, true, true)


static func handle(c: CanvasItem, at: Vector2, r := 8.0) -> void:
	c.draw_circle(at, r, Palette.PINK)
	c.draw_arc(at, r, 0.0, TAU, 28, Color.WHITE, 1.3, true)


static func text(c: CanvasItem, font: Font, pos: Vector2, s: String, size := FONT_TEXT, color: Color = Palette.TEXT) -> void:
	c.draw_string(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


static func text_centered(c: CanvasItem, font: Font, pos: Vector2, s: String, size := FONT_TEXT, color: Color = Palette.TEXT) -> void:
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	c.draw_string(font, pos - Vector2(w / 2.0, 0.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


static func text_right(c: CanvasItem, font: Font, pos: Vector2, s: String, size := FONT_TEXT, color: Color = Palette.TEXT) -> void:
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	c.draw_string(font, pos - Vector2(w, 0.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## Text on a rounded dark pill so it stays legible over drawings.
static func pill(c: CanvasItem, font: Font, pos: Vector2, s: String, size := FONT_TEXT, color: Color = Palette.TEXT, bg: Color = Color(0.06, 0.06, 0.13, 0.85)) -> void:
	var dims := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(6)
	c.draw_style_box(sb, Rect2(pos.x - 5, pos.y - dims.y + 2, dims.x + 10, dims.y + 4))
	c.draw_string(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## Like `pill`, but shifted so it stays inside the canvas.
static func pill_clamped(c: Control, font: Font, pos: Vector2, s: String, size := FONT_TEXT, color: Color = Palette.TEXT) -> void:
	var dims := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	var x := clampf(pos.x, 6.0, maxf(6.0, c.size.x - dims.x - 6.0))
	var y := clampf(pos.y, dims.y + 2.0, maxf(dims.y + 2.0, c.size.y - 4.0))
	pill(c, font, Vector2(x, y), s, size, color)


static func ket(label: String) -> String:
	return "|%s⟩" % label


# ---------------------------------------------------------------- controls

static func side_panel(width := PANEL_WIDTH) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.custom_minimum_size = Vector2(width, 0)
	v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	return v


static func heading(parent: Node, s: String) -> Label:
	var l := Label.new()
	l.text = s.to_upper()
	l.theme_type_variation = "Kicker"
	l.add_theme_font_override("font", ThemeBuilder.body(600.0))
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Palette.TEXT_DIM)
	parent.add_child(l)
	return l


## Labelled slider with a live value readout; `fmt` maps value -> String.
static func slider(parent: Node, label_text: String, lo: float, hi: float, step: float, value: float, fmt: Callable) -> HSlider:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label_text
	l.add_theme_font_override("font", ThemeBuilder.symbol())
	l.add_theme_font_size_override("font_size", FONT_TEXT)
	l.add_theme_color_override("font_color", Palette.TEXT_DIM)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	var v := Label.new()
	v.add_theme_font_override("font", ThemeBuilder.mono())
	v.add_theme_font_size_override("font_size", FONT_TEXT)
	v.add_theme_color_override("font_color", Palette.TEXT)
	row.add_child(v)
	box.add_child(row)
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.value = value
	s.custom_minimum_size = Vector2(0, 16)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.value_changed.connect(func(x: float) -> void: v.text = str(fmt.call(x)))
	v.text = str(fmt.call(value))
	box.add_child(s)
	parent.add_child(box)
	return s


static func option(parent: Node, items: Array, selected: int) -> OptionButton:
	var o := OptionButton.new()
	for it in items:
		o.add_item(str(it))
	o.selected = clampi(selected, 0, maxi(0, items.size() - 1))
	o.add_theme_font_size_override("font_size", FONT_TEXT)
	o.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(o)
	return o


static func check(parent: Node, text_: String, pressed: bool) -> CheckBox:
	var c := CheckBox.new()
	c.text = text_
	c.button_pressed = pressed
	c.add_theme_font_override("font", ThemeBuilder.symbol())
	c.add_theme_font_size_override("font_size", FONT_TEXT)
	for state in ["normal", "pressed", "hover", "hover_pressed", "focus", "disabled"]:
		c.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	c.add_theme_color_override("font_pressed_color", Palette.TEXT)
	c.add_theme_color_override("font_hover_pressed_color", Palette.TEXT)
	c.add_theme_color_override("font_hover_color", Palette.TEXT)
	parent.add_child(c)
	return c


static func button(parent: Node, text_: String, ghost := true) -> Button:
	var b := Button.new()
	b.text = text_
	if ghost:
		b.theme_type_variation = "GhostButton"
	b.add_theme_font_size_override("font_size", 14)
	parent.add_child(b)
	return b


## A one-line live readout in the mono font (kets fall back to DejaVu).
static func readout(parent: Node, initial := "", size := 13) -> Label:
	var l := Label.new()
	l.text = initial
	l.add_theme_font_override("font", ThemeBuilder.mono())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Palette.TEXT)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	return l


## A ket string in the symbol font, wrapping over several lines.
static func ket_label(parent: Node, initial := "", size := 16) -> Label:
	var l := Label.new()
	l.text = initial
	l.theme_type_variation = "Ket"
	l.add_theme_font_override("font", ThemeBuilder.symbol())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#c4b5fd"))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(l)
	return l


# ---------------------------------------------------------------- formatting

static func fmt_deg(x: float) -> String:
	return "%d°" % roundi(x)


static func fmt_amp(a: float) -> String:
	return "%.3f" % a


static func fmt_pct(p: float) -> String:
	return "%.1f %%" % (p * 100.0)


static func fmt_num(x: float, digits := 2) -> String:
	return ("%." + str(digits) + "f") % x


static func to_strings(a: Variant, fallback: PackedStringArray) -> PackedStringArray:
	if a is PackedStringArray:
		return a
	if a is Array and not (a as Array).is_empty():
		var out := PackedStringArray()
		for x in a:
			out.append(str(x))
		return out
	return fallback


static func to_floats(a: Variant, fallback: PackedFloat64Array) -> PackedFloat64Array:
	if a is PackedFloat64Array:
		return a
	if a is Array and not (a as Array).is_empty():
		var out := PackedFloat64Array()
		for x in a:
			out.append(float(x))
		return out
	return fallback


## Real amplitude of the component whose labels match `labels` (0 if absent).
static func amplitude_of(sys: QuagmireSystem, labels: PackedStringArray) -> Vector2:
	for e in sys.amplitudes():
		if e["labels"] == labels:
			return Vector2(float(e["re"]), float(e["im"]))
	return Vector2.ZERO
