extends WidgetBase
## Malus's law: an incoming polarization arrow, a polarizer axis (pink handle, draggable),
## the projection (shadow) of the arrow onto the axis, the cos² curve and the transmission.
## Every number comes from a QuagmireSystem with one polarizer.

var _input := 45.0
var _pol := 0.0
var _amp := 0.0      # signed transmitted amplitude cos Δ
var _trans := 0.0    # transmission cos² Δ
var _ket := ""
var _curve_xs := PackedFloat64Array()
var _curve_ys := PackedFloat64Array()

var _canvas: WidgetKit.Canvas
var _plot: PatternPlot
var _in_slider: HSlider
var _pol_slider: HSlider
var _out_delta: Label
var _out_amp: Label
var _out_trans: Label
var _out_ket: Label
var _dragging := false


func defaults() -> Dictionary:
	return {"input_angle": 45.0, "polarizer_angle": 0.0}


func build() -> void:
	_input = fposmod(pf("input_angle", 45.0), 180.0)
	_pol = fposmod(pf("polarizer_angle", 0.0), 180.0)
	var h := HBoxContainer.new()
	h.set_anchors_preset(PRESET_FULL_RECT)
	h.add_theme_constant_override("separation", 10)
	add_child(h)
	_canvas = WidgetKit.Canvas.new(_draw_canvas, _canvas_input)
	_canvas.custom_minimum_size = Vector2(200, 0)
	_canvas.size_flags_stretch_ratio = 1.25
	h.add_child(_canvas)
	_plot = PatternPlot.new()
	_plot.size_flags_horizontal = SIZE_EXPAND_FILL
	_plot.size_flags_vertical = SIZE_EXPAND_FILL
	_plot.custom_minimum_size = Vector2(180, 0)
	_plot.auto_y = false
	_plot.auto_x = false
	_plot.x_range = Vector2(0.0, 180.0)
	_plot.y_range = Vector2(0.0, 1.08)
	_plot.x_label = "polarizer angle θ_P (°)"
	_plot.y_label = "transmission"
	_plot.show_legend = false
	_plot.padding = Rect2(44, 24, 12, 34)
	h.add_child(_plot)
	var panel := WidgetKit.side_panel(236.0)
	h.add_child(panel)

	WidgetKit.heading(panel, "Angles")
	_in_slider = WidgetKit.slider(panel, "incoming polarization θ_in", 0.0, 180.0, 1.0, _input, WidgetKit.fmt_deg)
	_in_slider.value_changed.connect(func(v: float) -> void:
		_input = v
		_update())
	_pol_slider = WidgetKit.slider(panel, "polarizer axis θ_P", 0.0, 180.0, 1.0, _pol, WidgetKit.fmt_deg)
	_pol_slider.value_changed.connect(func(v: float) -> void:
		_pol = v
		_update())
	WidgetKit.heading(panel, "Malus's law")
	_out_delta = WidgetKit.readout(panel)
	_out_amp = WidgetKit.readout(panel)
	_out_trans = WidgetKit.readout(panel)
	_out_ket = WidgetKit.ket_label(panel, "", 14)
	_update()


func _transmission(pol_deg: float) -> Array:
	var s := QuagmireSystem.new()
	s.add_property("pol", WidgetKit.HV)
	s.set_linear_polarization("pol", WidgetKit.HV, _input)
	s.polarizer("pol", WidgetKit.HV, pol_deg, "lost@P1", {})
	var p := s.probability({"alive": PackedStringArray(["pol"])})
	# signed amplitude along the polarizer axis = (alive component) · axis
	var a := deg_to_rad(pol_deg)
	var hv := WidgetKit.amplitude_of(s, PackedStringArray(["↔"])).x
	var vv := WidgetKit.amplitude_of(s, PackedStringArray(["↕"])).x
	return [p, hv * cos(a) + vv * sin(a), s.ket_text()]


func _update() -> void:
	var r := _transmission(_pol)
	_trans = r[0]
	_amp = r[1]
	_ket = r[2]
	_curve_xs.resize(181)
	_curve_ys.resize(181)
	for i in 181:
		_curve_xs[i] = float(i)
		_curve_ys[i] = _transmission(float(i))[0]
	var delta := _pol - _input
	_out_delta.text = "Δ = θ_P − θ_in = %d°" % roundi(delta)
	_out_amp.text = "amplitude  cos Δ = %s" % WidgetKit.fmt_amp(_amp)
	_out_trans.text = "transmission  cos²Δ = %s" % WidgetKit.fmt_pct(_trans)
	_out_ket.text = "after P1:  " + _ket
	_plot.set_series([{"name": "cos²(θ_P − θ_in)", "xs": _curve_xs, "ys": _curve_ys, "color": Palette.ACCENT_SOFT, "width": 2.0}])
	_plot.set_points([{"xs": PackedFloat64Array([_pol]), "ys": PackedFloat64Array([_trans]), "color": Palette.PINK, "radius": 5.5}])
	_canvas.queue_redraw()


func _geometry() -> Array:
	var sz := _canvas.size
	return [Vector2(sz.x / 2.0, sz.y / 2.0 + 4.0), maxf(24.0, minf(sz.x - 90.0, sz.y - 50.0) / 2.0)]


func _axis_handle() -> Vector2:
	var g := _geometry()
	var a := deg_to_rad(_pol)
	return g[0] + Vector2(cos(a), -sin(a)) * g[1]


func _canvas_input(_c: Control, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_set_from(event.position)
		_canvas.accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_set_from(event.position)


func _set_from(p: Vector2) -> void:
	var g := _geometry()
	var d: Vector2 = p - g[0]
	if d.length() < 3.0:
		return
	var a := fposmod(roundf(rad_to_deg(atan2(-d.y, d.x))), 180.0)
	_pol_slider.set_value_no_signal(a)
	_pol_slider.value_changed.emit(a)


func _draw_canvas(c: Control) -> void:
	var g := _geometry()
	var o: Vector2 = g[0]
	var r: float = g[1]
	var mono := ThemeBuilder.mono()
	var body := ThemeBuilder.body()
	var sym := ThemeBuilder.symbol()
	var ai := deg_to_rad(_input)
	var ap := deg_to_rad(_pol)
	var dir_in := Vector2(cos(ai), -sin(ai))
	var dir_p := Vector2(cos(ap), -sin(ap))
	# reference axes
	c.draw_line(o - Vector2(r, 0), o + Vector2(r, 0), Color(Palette.TEXT_DIM, 0.25), 1.0)
	c.draw_line(o - Vector2(0, r), o + Vector2(0, r), Color(Palette.TEXT_DIM, 0.25), 1.0)
	WidgetKit.text(c, sym, o + Vector2(r + 4, 5), "|↔⟩", 14, Palette.TEXT_DIM)
	WidgetKit.text_centered(c, sym, o - Vector2(0, r + 6), "|↕⟩", 14, Palette.TEXT_DIM)
	c.draw_arc(o, r, 0.0, TAU, 96, Color(Palette.ACCENT_SOFT, 0.18), 1.0, true)
	# polarizer disc with its axis
	c.draw_circle(o, r * 0.92, Color(Palette.POLARIZER, 0.10))
	var perp := Vector2(-dir_p.y, dir_p.x)
	for i in range(-4, 5):
		if i == 0:
			continue
		var off := perp * (i * r * 0.92 / 5.0)
		var half := sqrt(maxf(0.0, r * r * 0.846 - off.length_squared()))
		c.draw_line(o + off - dir_p * half, o + off + dir_p * half, Color(Palette.POLARIZER, 0.25), 1.0, true)
	c.draw_line(o - dir_p * r, o + dir_p * r, Palette.POLARIZER, 3.0, true)
	# incoming arrow and its shadow on the axis
	var tip := o + dir_in * r
	var shadow := o + dir_p * (_amp * r)
	WidgetKit.dashed(c, tip, shadow, Color(Palette.WARNING, 0.9), 1.5, 5.0)
	WidgetKit.arrow(c, o, tip, Palette.ACCENT_SOFT, 3.0, 12.0)
	WidgetKit.arrow(c, o, shadow, Palette.SUCCESS, 4.5, 13.0)
	WidgetKit.pill_clamped(c, mono, tip + Vector2(8 if dir_in.x >= 0 else -70, -6), "in θ_in", 12, Palette.ACCENT_SOFT)
	WidgetKit.pill_clamped(c, mono, shadow + Vector2(8, 20), "cos Δ = %s" % WidgetKit.fmt_amp(_amp), 12, Palette.SUCCESS)
	# angle between them
	var delta_rad := deg_to_rad(_pol - _input)
	if absf(delta_rad) > 0.03:
		c.draw_arc(o, r * 0.28, -ai, -ap, 48, Color(Palette.WARNING, 0.9), 1.5, true)
		var mid := -(ai + ap) / 2.0
		WidgetKit.text(c, mono, o + Vector2(cos(mid), sin(mid)) * (r * 0.28 + 12) + Vector2(-6, 5), "Δ", 13, Palette.WARNING)
	# pink handle on the polarizer axis
	WidgetKit.handle(c, _axis_handle(), 8.0)
	WidgetKit.pill_clamped(c, mono, _axis_handle() + Vector2(10, -8), "P1 axis %d°" % roundi(_pol), 12, Palette.PINK)
	WidgetKit.text(c, body, Vector2(8, 16), "transmission = shadow² = %s" % WidgetKit.fmt_pct(_trans), 13, Palette.TEXT)
	WidgetKit.text(c, body, Vector2(8, c.size.y - 8), "drag the pink handle to turn the polarizer", 12, Palette.TEXT_MUTED)
