extends WidgetBase
## Experiment 4: a polarization-entangled pair |Φ⁺⟩ from SPDC, polarizers at α (signal)
## and β (idler). The coincidence probability P(both pass) = ½cos²(α−β) is read from
## QuagmireSystem; the heat-map shows it for every angle pair.

const STEP := 5
const CELLS := 180 / STEP + 1

var _alpha := 0.0
var _beta := 0.0
var _p_both := 0.0
var _p_a := 0.0
var _p_b := 0.0
var _ket := ""
var _grid := PackedFloat64Array()

var _canvas: WidgetKit.Canvas
var _dial_a: WidgetKit.Dial
var _dial_b: WidgetKit.Dial
var _out_prob: Label
var _out_single: Label
var _out_ket: Label
var _dragging := false


func defaults() -> Dictionary:
	return {"alpha": 0.0, "beta": 0.0}


func build() -> void:
	_alpha = fposmod(pf("alpha", 0.0), 180.0)
	_beta = fposmod(pf("beta", 0.0), 180.0)
	var parts := split(262.0)
	var left: VBoxContainer = parts[0]
	var panel: VBoxContainer = parts[1]
	_canvas = WidgetKit.Canvas.new(_draw_canvas, _canvas_input)
	left.add_child(_canvas)

	var dials := HBoxContainer.new()
	dials.add_theme_constant_override("separation", 8)
	dials.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(dials)
	_dial_a = WidgetKit.Dial.new("α (signal)", _alpha)
	_dial_a.changed.connect(func(a: float) -> void:
		_alpha = a
		_update())
	dials.add_child(_dial_a)
	_dial_b = WidgetKit.Dial.new("β (idler)", _beta)
	_dial_b.color = Palette.PRIMARY
	_dial_b.changed.connect(func(a: float) -> void:
		_beta = a
		_update())
	dials.add_child(_dial_b)
	WidgetKit.heading(panel, "Coincidences")
	_out_prob = WidgetKit.readout(panel)
	_out_single = WidgetKit.readout(panel)
	_out_ket = WidgetKit.ket_label(panel, "", 14)
	_compute_grid()
	_update()


func _pair(alpha: float, beta: float) -> QuagmireSystem:
	var s := QuagmireSystem.new()
	s.add_property("pump", WidgetKit.HV)
	s.set_linear_polarization("pump", WidgetKit.HV, 45.0)
	s.spdc("pump", WidgetKit.HV, "pol1", "pol2", WidgetKit.HV, 0.0)
	s.polarizer("pol1", WidgetKit.HV, alpha, "lost@A", {})
	s.polarizer("pol2", WidgetKit.HV, beta, "lost@B", {})
	return s


func _compute_grid() -> void:
	_grid.resize(CELLS * CELLS)
	for j in CELLS:
		for i in CELLS:
			_grid[j * CELLS + i] = _pair(i * STEP, j * STEP).probability({"alive": PackedStringArray(["pol1", "pol2"])})


func _update() -> void:
	var s := _pair(_alpha, _beta)
	_p_both = s.probability({"alive": PackedStringArray(["pol1", "pol2"])})
	_p_a = s.probability({"alive": PackedStringArray(["pol1"])})
	_p_b = s.probability({"alive": PackedStringArray(["pol2"])})
	var before := QuagmireSystem.new()
	before.add_property("pump", WidgetKit.HV)
	before.set_linear_polarization("pump", WidgetKit.HV, 45.0)
	before.spdc("pump", WidgetKit.HV, "pol1", "pol2", WidgetKit.HV, 0.0)
	_ket = before.ket_text()
	var diff := _alpha - _beta
	_out_prob.text = "P(both) = ½cos²(α−β)\n        = ½cos²(%d°) = %s" % [roundi(diff), WidgetKit.fmt_pct(_p_both)]
	_out_single.text = "alone: P(α) = %s, P(β) = %s\n(no angle dependence)" % [WidgetKit.fmt_pct(_p_a), WidgetKit.fmt_pct(_p_b)]
	_out_ket.text = "|Φ⁺⟩ = " + _ket
	_canvas.queue_redraw()


func _map_rect() -> Rect2:
	var sz := _canvas.size
	var side := maxf(40.0, minf(sz.x - 60.0, sz.y - 44.0))
	return Rect2(Vector2(44.0 + (sz.x - 60.0 - side) / 2.0, 10.0), Vector2(side, side))


func _canvas_input(_c: Control, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed and _map_rect().grow(10.0).has_point(event.position)
		if _dragging:
			_set_from(event.position)
		_canvas.accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_set_from(event.position)


func _set_from(p: Vector2) -> void:
	var r := _map_rect()
	var fa := clampf((p.x - r.position.x) / r.size.x, 0.0, 1.0)
	var fb := clampf(1.0 - (p.y - r.position.y) / r.size.y, 0.0, 1.0)
	_alpha = roundf(fa * 180.0)
	_beta = roundf(fb * 180.0)
	_dial_a.angle = fmod(_alpha, 180.0)
	_dial_b.angle = fmod(_beta, 180.0)
	_update()


func _heat(p: float) -> Color:
	var t := clampf(p / 0.5, 0.0, 1.0)
	if t < 0.5:
		return Color("#13142e").lerp(Palette.PRIMARY, t * 2.0)
	return Palette.PRIMARY.lerp(Color("#fbe3ff"), (t - 0.5) * 2.0)


func _draw_canvas(c: Control) -> void:
	var r := _map_rect()
	var mono := ThemeBuilder.mono()
	var body := ThemeBuilder.body()
	var cell := r.size.x / float(CELLS - 1)
	for j in CELLS:
		for i in CELLS:
			var p := _grid[j * CELLS + i]
			var x := r.position.x + (i - 0.5) * cell
			var y := r.end.y - (j + 0.5) * cell
			var cr := Rect2(x, y, cell, cell).intersection(r)
			c.draw_rect(cr, _heat(p))
	c.draw_rect(r, Palette.BORDER, false, 1.0)
	for t in PackedInt32Array([0, 45, 90, 135, 180]):
		var fx: float = r.position.x + t / 180.0 * r.size.x
		var fy: float = r.end.y - t / 180.0 * r.size.y
		WidgetKit.text_centered(c, mono, Vector2(fx, r.end.y + 14), "%d°" % t, 11, Palette.TEXT_DIM)
		WidgetKit.text_right(c, mono, Vector2(r.position.x - 5, fy + 4), "%d°" % t, 11, Palette.TEXT_DIM)
	WidgetKit.text_centered(c, body, Vector2(r.get_center().x, r.end.y + 28), "α  (signal polarizer)", 12, Palette.TEXT_DIM)
	c.draw_set_transform(Vector2(12, r.get_center().y + 40), -PI / 2.0)
	WidgetKit.text(c, body, Vector2.ZERO, "β  (idler polarizer)", 12, Palette.TEXT_DIM)
	c.draw_set_transform(Vector2.ZERO, 0.0)
	# diagonal guides: α = β (max) and α − β = 90° (zero)
	WidgetKit.dashed(c, Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.position.y), Color(Palette.TEXT, 0.25), 1.0, 4.0)
	# current pair
	var px := r.position.x + _alpha / 180.0 * r.size.x
	var py := r.end.y - _beta / 180.0 * r.size.y
	c.draw_line(Vector2(px, r.position.y), Vector2(px, r.end.y), Color(Palette.PINK, 0.35), 1.0)
	c.draw_line(Vector2(r.position.x, py), Vector2(r.end.x, py), Color(Palette.PINK, 0.35), 1.0)
	WidgetKit.handle(c, Vector2(px, py), 7.0)
	var label_pos := Vector2(px, py) + Vector2(12.0 if px < r.end.x - 110.0 else -108.0, -10.0 if py > r.position.y + 24.0 else 24.0)
	WidgetKit.pill(c, mono, label_pos, "α=%d° β=%d°: %s" % [roundi(_alpha), roundi(_beta), WidgetKit.fmt_pct(_p_both)], 12, Palette.TEXT)
	# legend bar on the right
	var lx := r.end.x + 8.0
	if lx + 14.0 < c.size.x:
		for k in 40:
			var f := k / 39.0
			c.draw_rect(Rect2(lx, r.end.y - (k + 1) * r.size.y / 40.0, 8.0, r.size.y / 40.0 + 0.5), _heat(f * 0.5))
		WidgetKit.text(c, mono, Vector2(lx + 10.0, r.position.y + 10.0), "50%", 10, Palette.TEXT_DIM)
		WidgetKit.text(c, mono, Vector2(lx + 10.0, r.end.y), "0", 10, Palette.TEXT_DIM)
