extends WidgetBase
## The site's Experiment 1 simulator: LASER → 45° preparation → up to `max` polarizers
## (drag the pink dot on each to turn it) → detector D1 with the transmitted fraction.
## Transmission after every stage and the final ket come from a QuagmireSystem.

var _angles := PackedFloat64Array([0.0, 45.0, 90.0])
var _input := 45.0
var _max := 3
var _stage_probs := PackedFloat64Array()   # transmission after each polarizer
var _final := 1.0
var _ket := ""

var _canvas: WidgetKit.Canvas
var _add_btn: Button
var _rem_btn: Button
var _in_slider: HSlider
var _out_ket: Label
var _out_formula: Label
var _drag_index := -1


func defaults() -> Dictionary:
	return {"polarizers": [0.0, 45.0, 90.0], "input_angle": 45.0, "max": 3}


func build() -> void:
	_angles = WidgetKit.to_floats(params.get("polarizers"), PackedFloat64Array([0.0, 45.0, 90.0]))
	if params.get("polarizers") is Array and (params["polarizers"] as Array).is_empty():
		_angles = PackedFloat64Array()
	_input = fposmod(pf("input_angle", 45.0), 180.0)
	_max = maxi(1, pi_("max", 3))
	if _angles.size() > _max:
		_angles.resize(_max)

	var v := VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 6)
	add_child(v)
	_canvas = WidgetKit.Canvas.new(_draw_canvas, _canvas_input)
	v.add_child(_canvas)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	_add_btn = WidgetKit.button(row, "+ Add polarizer", false)
	_add_btn.pressed.connect(func() -> void:
		if _angles.size() < _max:
			_angles.append(45.0 if _angles.is_empty() else fposmod(_angles[_angles.size() - 1] + 45.0, 180.0))
			_update())
	_rem_btn = WidgetKit.button(row, "− Remove last", true)
	_rem_btn.pressed.connect(func() -> void:
		if not _angles.is_empty():
			_angles.resize(_angles.size() - 1)
			_update())
	var sl_box := VBoxContainer.new()
	sl_box.size_flags_horizontal = SIZE_EXPAND_FILL
	sl_box.custom_minimum_size = Vector2(200, 0)
	row.add_child(sl_box)
	_in_slider = WidgetKit.slider(sl_box, "laser polarization", 0.0, 180.0, 1.0, _input, WidgetKit.fmt_deg)
	_in_slider.value_changed.connect(func(x: float) -> void:
		_input = x
		_update())
	_out_formula = WidgetKit.readout(v)
	_out_ket = WidgetKit.ket_label(v, "", 14)
	_update()


func _update() -> void:
	var s := QuagmireSystem.new()
	s.add_property("pol", WidgetKit.HV)
	s.set_linear_polarization("pol", WidgetKit.HV, _input)
	_stage_probs.resize(_angles.size())
	for i in _angles.size():
		s.polarizer("pol", WidgetKit.HV, _angles[i], "lost@P%d" % (i + 1), {})
		_stage_probs[i] = s.probability({"alive": PackedStringArray(["pol"])})
	_final = s.probability({"alive": PackedStringArray(["pol"])})
	_ket = s.ket_text()
	_add_btn.disabled = _angles.size() >= _max
	_rem_btn.disabled = _angles.is_empty()
	var factors := PackedStringArray()
	var prev := _input
	for i in _angles.size():
		factors.append("cos²(%d°)" % roundi(_angles[i] - prev))
		prev = _angles[i]
	_out_formula.text = ("transmission = " + " · ".join(factors) + " = " if not factors.is_empty() else "no polarizer: transmission = ") + WidgetKit.fmt_pct(_final)
	_out_ket.text = "state at D1:  " + _ket
	_canvas.queue_redraw()


## Positions of the optical elements along the beam line.
func _layout() -> Dictionary:
	var sz := _canvas.size
	var y := sz.y * 0.46
	var laser_w := 64.0
	var det_w := 34.0
	var x0 := 14.0 + laser_w + 8.0
	var x1 := sz.x - det_w - 70.0
	var slots := _angles.size() + 1  # prep + polarizers
	var step := (x1 - x0) / float(slots + 1)
	var radius := clampf(minf(step * 0.36, sz.y * 0.22), 14.0, 40.0)
	var centers := PackedVector2Array()
	for i in slots:
		centers.append(Vector2(x0 + step * (i + 1), y))
	return {"y": y, "laser": Rect2(14.0, y - 16.0, laser_w, 32.0), "det": Rect2(x1 + 10.0, y - 46.0, det_w, 92.0), "centers": centers, "r": radius}


func _handle_pos(i: int, lay: Dictionary) -> Vector2:
	var cpos: Vector2 = lay["centers"][i + 1]
	var a := deg_to_rad(_angles[i])
	return cpos + Vector2(cos(a), -sin(a)) * float(lay["r"])


func _canvas_input(_c: Control, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var lay := _layout()
			_drag_index = -1
			var best := 18.0
			for i in _angles.size():
				var d: float = event.position.distance_to(_handle_pos(i, lay))
				if d < best:
					best = d
					_drag_index = i
			if _drag_index < 0:
				for i in _angles.size():
					if event.position.distance_to(lay["centers"][i + 1]) <= float(lay["r"]) + 4.0:
						_drag_index = i
			if _drag_index >= 0:
				_set_angle(event.position, lay)
		else:
			_drag_index = -1
		_canvas.accept_event()
	elif event is InputEventMouseMotion and _drag_index >= 0:
		_set_angle(event.position, _layout())


func _set_angle(p: Vector2, lay: Dictionary) -> void:
	var d: Vector2 = p - lay["centers"][_drag_index + 1]
	if d.length() < 3.0:
		return
	_angles[_drag_index] = fposmod(roundf(rad_to_deg(atan2(-d.y, d.x))), 180.0)
	_update()


func _draw_disc(c: Control, cpos: Vector2, r: float, angle_deg: float, color: Color, hatch_alpha := 0.35) -> void:
	c.draw_circle(cpos, r, Color(color, 0.16))
	c.draw_arc(cpos, r, 0.0, TAU, 64, Color(color, 0.9), 2.0, true)
	var a := deg_to_rad(angle_deg)
	var dir := Vector2(cos(a), -sin(a))
	var perp := Vector2(-dir.y, dir.x)
	for i in range(-3, 4):
		var off := perp * (i * r / 4.0)
		var half := sqrt(maxf(0.0, r * r - off.length_squared()))
		c.draw_line(cpos + off - dir * half, cpos + off + dir * half, Color(color, 0.95 if i == 0 else hatch_alpha), 2.5 if i == 0 else 1.2, true)


func _draw_canvas(c: Control) -> void:
	var lay := _layout()
	var y: float = lay["y"]
	var r: float = lay["r"]
	var centers: PackedVector2Array = lay["centers"]
	var mono := ThemeBuilder.mono()
	var body := ThemeBuilder.body()
	var sym := ThemeBuilder.symbol()
	var laser: Rect2 = lay["laser"]
	var det: Rect2 = lay["det"]
	# beam segments, dimmer as light is lost
	var xs := PackedFloat64Array([laser.end.x])
	var alphas := PackedFloat64Array([1.0])
	for i in centers.size():
		xs.append(centers[i].x)
		alphas.append(1.0 if i == 0 else _stage_probs[i - 1])
	xs.append(det.position.x)
	for i in xs.size() - 1:
		var a: float = alphas[i]
		c.draw_line(Vector2(xs[i], y), Vector2(xs[i + 1], y), Color(Palette.LASER_RED, 0.15 + 0.85 * a), 1.5 + 4.0 * a, true)
	# laser
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#f4a0b5")
	sb.set_corner_radius_all(6)
	c.draw_style_box(sb, laser)
	c.draw_rect(Rect2(laser.end.x - 2, y - 5, 8, 10), Color("#f4a0b5"))
	WidgetKit.text_centered(c, body, laser.get_center() + Vector2(0, 5), "LASER", 12, Color("#3b0a1e"))
	# preparation disc (grey hatched)
	_draw_disc(c, centers[0], r, _input, Color("#9ca3af"), 0.5)
	WidgetKit.text_centered(c, mono, centers[0] + Vector2(0, r + 18), "prep %d°" % roundi(_input), 12, Palette.TEXT_DIM)
	WidgetKit.text_centered(c, sym, centers[0] + Vector2(0, -r - 10), "Ψ₀", 14, Palette.TEXT_DIM)
	# polarizers
	for i in _angles.size():
		var cpos := centers[i + 1]
		_draw_disc(c, cpos, r, _angles[i], Palette.POLARIZER)
		WidgetKit.handle(c, _handle_pos(i, lay), 7.0)
		WidgetKit.text_centered(c, mono, cpos + Vector2(0, r + 18), "P%d  %d°" % [i + 1, roundi(_angles[i])], 13, Palette.TEXT)
		WidgetKit.text_centered(c, mono, cpos + Vector2(0, r + 34), WidgetKit.fmt_pct(_stage_probs[i]), 12, Palette.ACCENT_SOFT)
		WidgetKit.text_centered(c, sym, cpos + Vector2(0, -r - 10), "Ψ%s" % ["₁", "₂", "₃", "₄", "₅", "₆"][mini(i, 5)], 14, Palette.TEXT_DIM)
	# detector with percentage
	var dsb := StyleBoxFlat.new()
	dsb.bg_color = Color("#f4a0b5")
	dsb.set_corner_radius_all(5)
	c.draw_style_box(dsb, det)
	WidgetKit.text_centered(c, body, det.get_center() + Vector2(0, det.size.y / 2.0 + 16), "D1", 12, Palette.TEXT_DIM)
	WidgetKit.text(c, ThemeBuilder.body(700.0), Vector2(det.end.x + 8, y + 9), "%d%%" % roundi(_final * 100.0), 26, Palette.TEXT)
	if c.size.y >= 150.0:
		WidgetKit.text(c, body, Vector2(8, 15), "drag a pink dot to turn a polarizer; % = light reaching D1 relative to the laser", 12, Palette.TEXT_MUTED)
