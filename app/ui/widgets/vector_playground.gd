extends WidgetBase
## A draggable unit arrow between two perpendicular basis arrows: components as
## projections, Pythagoras length check, probabilities as squares, and (mode
## "basis_change") the same arrow written in the diagonal basis.
## Components come from a QuagmireSystem (set_linear_polarization / rotate_polarization).

const MODES := ["unit", "superposition", "projection", "basis_change"]
const MODE_TITLES := ["Unit arrow", "Superposition (sum of arrows)", "Projection (components)", "Change of basis"]

var _labels := PackedStringArray(["A", "B"])
var _angle := 60.0
var _mode := "unit"
var _show_prob := true

var _ca := 0.0      # component along |A⟩
var _cb := 0.0      # component along |B⟩
var _cd := 0.0      # component along |↗↙⟩ (45°)
var _ce := 0.0      # component along |↘↖⟩ (135°)
var _pa := 0.0
var _pb := 0.0
var _ket := ""
var _ket_diag := ""

var _canvas: WidgetKit.Canvas
var _slider: HSlider
var _mode_btn: OptionButton
var _prob_check: CheckBox
var _out_components: Label
var _out_length: Label
var _out_prob: Label
var _out_ket: Label
var _dragging := false


func defaults() -> Dictionary:
	return {"labels": ["A", "B"], "angle": 60.0, "mode": "unit", "show_probabilities": true}


func build() -> void:
	_labels = WidgetKit.to_strings(params.get("labels"), PackedStringArray(["A", "B"]))
	if _labels.size() < 2:
		_labels = PackedStringArray(["A", "B"])
	_angle = fposmod(pf("angle", 60.0), 360.0)
	_mode = ps("mode", "unit")
	if not MODES.has(_mode):
		_mode = "unit"
	_show_prob = pb("show_probabilities", true)

	var parts := split()
	var left: VBoxContainer = parts[0]
	var panel: VBoxContainer = parts[1]
	_canvas = WidgetKit.Canvas.new(_draw_canvas, _canvas_input)
	left.add_child(_canvas)

	WidgetKit.heading(panel, "What to show")
	_mode_btn = WidgetKit.option(panel, MODE_TITLES, MODES.find(_mode))
	_mode_btn.item_selected.connect(func(i: int) -> void:
		_mode = MODES[i]
		_update())
	_slider = WidgetKit.slider(panel, "angle θ", 0.0, 360.0, 1.0, _angle, WidgetKit.fmt_deg)
	_slider.value_changed.connect(func(v: float) -> void:
		_angle = v
		_update())
	_prob_check = WidgetKit.check(panel, "probabilities as squares", _show_prob)
	_prob_check.toggled.connect(func(on: bool) -> void:
		_show_prob = on
		_update())
	WidgetKit.heading(panel, "Live values")
	_out_components = WidgetKit.readout(panel)
	_out_length = WidgetKit.readout(panel)
	_out_prob = WidgetKit.readout(panel)
	_out_ket = WidgetKit.ket_label(panel, "", 15)
	_update()


func _compute() -> void:
	var s := QuagmireSystem.new()
	s.add_property("v", _labels)
	s.set_linear_polarization("v", _labels, _angle)
	_ca = WidgetKit.amplitude_of(s, PackedStringArray([_labels[0]])).x
	_cb = WidgetKit.amplitude_of(s, PackedStringArray([_labels[1]])).x
	var m := s.marginals("v")
	_pa = float(m.get(_labels[0], 0.0))
	_pb = float(m.get(_labels[1], 0.0))
	_ket = s.ket_text()
	# Same arrow written in the diagonal basis: rotate the frame by −45°.
	var d := s.duplicate()
	d.rotate_polarization("v", _labels, -45.0)
	_cd = WidgetKit.amplitude_of(d, PackedStringArray([_labels[0]])).x
	_ce = WidgetKit.amplitude_of(d, PackedStringArray([_labels[1]])).x
	_ket_diag = d.ket_text_mapped({"v/%s" % _labels[0]: "↗↙", "v/%s" % _labels[1]: "↘↖"})


func _update() -> void:
	_compute()
	_out_components.text = "cos θ = %s    sin θ = %s" % [WidgetKit.fmt_amp(_ca), WidgetKit.fmt_amp(_cb)]
	_out_length.text = "length √(cos²θ + sin²θ) = √(%.3f + %.3f) = %.3f" % [_ca * _ca, _cb * _cb, sqrt(_ca * _ca + _cb * _cb)]
	_out_prob.text = "P(%s) = %s    P(%s) = %s" % [_labels[0], WidgetKit.fmt_pct(_pa), _labels[1], WidgetKit.fmt_pct(_pb)]
	if _mode == "basis_change":
		_out_ket.text = "|ψ⟩ = %s\n     = %s" % [_ket, _ket_diag]
	else:
		_out_ket.text = "|ψ⟩ = " + _ket
	_prob_check.visible = _mode != "unit"
	_canvas.queue_redraw()


func _geometry() -> Array:
	var sz := _canvas.size
	var r := maxf(30.0, minf(sz.x, sz.y) / 2.0 - 30.0)
	return [Vector2(sz.x / 2.0, sz.y / 2.0 - 4.0), r]


func _canvas_input(_c: Control, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_set_angle_from(event.position)
		_canvas.accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_set_angle_from(event.position)


func _set_angle_from(p: Vector2) -> void:
	var g := _geometry()
	var d: Vector2 = p - g[0]
	if d.length() < 3.0:
		return
	var a := fposmod(roundf(rad_to_deg(atan2(-d.y, d.x))), 360.0)
	_angle = a
	_slider.set_value_no_signal(a)
	_slider.value_changed.emit(a)  # updates the slider's readout and calls _update


func _draw_canvas(c: Control) -> void:
	var g := _geometry()
	var o: Vector2 = g[0]
	var r: float = g[1]
	var body := ThemeBuilder.body()
	var mono := ThemeBuilder.mono()
	var sym := ThemeBuilder.symbol()
	var tip := o + Vector2(_ca, -_cb) * r
	var foot_x := Vector2(tip.x, o.y)
	var foot_y := Vector2(o.x, tip.y)

	# unit circle, faint
	c.draw_arc(o, r, 0.0, TAU, 96, Color(Palette.ACCENT_SOFT, 0.22), 1.0, true)
	# basis axes
	var ax := Color(Palette.TEXT_DIM, 0.9)
	c.draw_line(o - Vector2(r, 0), o + Vector2(r, 0), Color(ax, 0.3), 1.0)
	c.draw_line(o - Vector2(0, r), o + Vector2(0, r), Color(ax, 0.3), 1.0)
	WidgetKit.arrow(c, o, o + Vector2(r, 0), ax, 2.0, 10.0)
	WidgetKit.arrow(c, o, o - Vector2(0, r), ax, 2.0, 10.0)
	WidgetKit.text(c, sym, o + Vector2(r + 6, 6), WidgetKit.ket(_labels[0]), 17, Palette.TEXT)
	WidgetKit.text_centered(c, sym, o - Vector2(0, r + 8), WidgetKit.ket(_labels[1]), 17, Palette.TEXT)

	if _mode == "basis_change":
		var dd := Vector2(cos(PI / 4.0), -sin(PI / 4.0))
		var ee := Vector2(cos(3.0 * PI / 4.0), -sin(3.0 * PI / 4.0))
		var dc := Color(Palette.SUCCESS, 0.8)
		c.draw_line(o - dd * r, o + dd * r, Color(dc, 0.3), 1.0)
		c.draw_line(o - ee * r, o + ee * r, Color(dc, 0.3), 1.0)
		WidgetKit.arrow(c, o, o + dd * r, dc, 2.0, 10.0)
		WidgetKit.arrow(c, o, o + ee * r, dc, 2.0, 10.0)
		WidgetKit.text(c, sym, o + dd * (r + 10) + Vector2(2, 4), "|↗↙⟩", 16, Palette.SUCCESS)
		WidgetKit.text_right(c, sym, o + ee * (r + 10) + Vector2(-2, 4), "|↘↖⟩", 16, Palette.SUCCESS)
		# projections onto the diagonal axes
		var pd := o + dd * (_cd * r)
		var pe := o + ee * (_ce * r)
		WidgetKit.dashed(c, tip, pd, Color(Palette.SUCCESS, 0.8), 1.5, 5.0)
		WidgetKit.dashed(c, tip, pe, Color(Palette.SUCCESS, 0.8), 1.5, 5.0)
		c.draw_line(o, pd, Palette.SUCCESS, 3.0, true)
		c.draw_line(o, pe, Palette.SUCCESS, 3.0, true)
		var md := o + dd * (_cd * r * 0.5)
		var me := o + ee * (_ce * r * 0.5)
		WidgetKit.pill_clamped(c, mono, md + Vector2(14, 22), "cos(θ−45°) = %s" % WidgetKit.fmt_amp(_cd), 13, Palette.SUCCESS)
		WidgetKit.pill_clamped(c, mono, me + Vector2(-140, 22), "sin(θ−45°) = %s" % WidgetKit.fmt_amp(_ce), 13, Palette.SUCCESS)

	if _mode == "basis_change":
		# only the dashed drop lines to the original axes; the numbers live in the panel
		WidgetKit.dashed(c, tip, foot_x, Color(Palette.ACCENT_SOFT, 0.5), 1.0, 4.0)
		WidgetKit.dashed(c, tip, foot_y, Color(Palette.ACCENT_SOFT, 0.5), 1.0, 4.0)
	if _mode in ["projection", "superposition"]:
		# squares on the components = probabilities (areas)
		if _show_prob:
			var sa := absf(_ca) * r
			var sb := absf(_cb) * r
			var side_y := 1.0 if _cb >= 0.0 else -1.0   # arrow above axis -> square below
			var side_x := 1.0 if _ca >= 0.0 else -1.0   # arrow right -> square on the left
			var rect_a := Rect2(minf(o.x, tip.x), o.y if side_y > 0 else o.y - sa, sa, sa)
			var rect_b := Rect2(o.x - sb if side_x > 0 else o.x, minf(o.y, tip.y), sb, sb)
			c.draw_rect(rect_a, Color(Palette.ACCENT, 0.18))
			c.draw_rect(rect_a, Color(Palette.ACCENT, 0.7), false, 1.2)
			c.draw_rect(rect_b, Color(Palette.PINK, 0.14))
			c.draw_rect(rect_b, Color(Palette.PINK, 0.6), false, 1.2)
			if sa > 36.0:
				WidgetKit.text_centered(c, mono, rect_a.get_center() + Vector2(0, 12 if side_y > 0 else -2), "cos²θ = %.3f" % _pa, 12, Palette.ACCENT_SOFT)
			if sb > 36.0:
				WidgetKit.text_centered(c, mono, rect_b.get_center() + Vector2(0, 5), "sin²θ = %.3f" % _pb, 12, Palette.PINK)
		# dashed projections and component values
		WidgetKit.dashed(c, tip, foot_x, Color(Palette.ACCENT_SOFT, 0.9), 1.5, 5.0)
		WidgetKit.dashed(c, tip, foot_y, Color(Palette.ACCENT_SOFT, 0.9), 1.5, 5.0)
		if _mode == "superposition":
			WidgetKit.arrow(c, o, foot_x, Palette.ACCENT_SOFT, 3.0, 11.0)
			WidgetKit.arrow(c, foot_x, tip, Palette.SUCCESS, 3.0, 11.0)
			var ty := 15.0 if _cb >= 0.0 else -6.0
			WidgetKit.pill_clamped(c, sym, Vector2(minf(o.x, foot_x.x) + 4, o.y + ty), "cos θ %s" % WidgetKit.ket(_labels[0]), 13, Palette.ACCENT_SOFT)
			WidgetKit.pill_clamped(c, sym, Vector2(foot_x.x + (10 if _ca >= 0.0 else -110), (foot_x.y + tip.y) / 2.0 + 5), "+ sin θ %s" % WidgetKit.ket(_labels[1]), 13, Palette.SUCCESS)
		else:
			c.draw_line(o, foot_x, Palette.ACCENT_SOFT, 3.0, true)
			c.draw_line(o, foot_y, Palette.PINK, 3.0, true)
			var ty := 15.0 if _cb >= 0.0 else -6.0
			WidgetKit.pill_clamped(c, mono, Vector2(minf(o.x, foot_x.x) + 4, o.y + ty), "cos θ = %s" % WidgetKit.fmt_amp(_ca), 13, Palette.ACCENT_SOFT)
			var tx := 10.0 if _ca >= 0.0 else -110.0
			WidgetKit.pill_clamped(c, mono, Vector2(tip.x + tx, (o.y + foot_y.y) / 2.0 + 5), "sin θ = %s" % WidgetKit.fmt_amp(_cb), 13, Palette.PINK)

	# angle arc
	if _angle > 0.5:
		c.draw_arc(o, r * 0.22, 0.0, -deg_to_rad(_angle), 48, Color(Palette.WARNING, 0.9), 1.5, true)
		var mid := -deg_to_rad(_angle) / 2.0
		WidgetKit.text(c, mono, o + Vector2(cos(mid), sin(mid)) * (r * 0.22 + 14) + Vector2(-8, 5), "θ = %d°" % roundi(_angle), 13, Palette.WARNING)

	# the state arrow with its pink handle
	WidgetKit.arrow(c, o, tip, Palette.PINK, 3.5, 13.0)
	WidgetKit.handle(c, tip, 8.0)
	var ket_pos := tip + Vector2(14 if _ca >= 0.0 else -46, -10 if _cb >= 0.0 else 22)
	WidgetKit.pill_clamped(c, sym, ket_pos, "|ψ⟩", 16, Palette.TEXT)

	# length check, bottom left; hint bottom right
	var msg := "length = √(cos²θ + sin²θ) = 1"
	if _mode == "unit":
		msg = "unit arrow: every point of the circle is a valid state"
	WidgetKit.text(c, body, Vector2(8, c.size.y - 8), msg, 13, Palette.TEXT_DIM)
	WidgetKit.text_right(c, body, Vector2(c.size.x - 8, c.size.y - 8), "drag the pink handle", 12, Palette.TEXT_MUTED)
