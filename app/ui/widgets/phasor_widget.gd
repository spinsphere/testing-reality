extends WidgetBase
## The complex phase as a rotating arrow e^{iks}. Mode "single": one arrow vs distance s,
## with a trace of its real part. Mode "sum": two arrows tip-to-tail with a path
## difference Δ and |sum|² = 2(1 + cos kΔ). Phases are applied by QuagmireSystem.phase().

const MODES := ["single", "sum"]
const MODE_TITLES := ["One arrow  e^{iks}", "Two arrows  e^{ika} + e^{ikb}"]
const SAMPLES := 181

var _mode := "single"
var _lambda := 405e-9
var _s := 0.25        # distance in wavelengths
var _delta := 0.0     # path difference in wavelengths
var _k := 0.0

var _arrow := Vector2.RIGHT          # e^{iks} as (re, im)
var _arrow_a := Vector2.RIGHT
var _arrow_b := Vector2.RIGHT
var _sum := Vector2.ZERO
var _curve_xs := PackedFloat64Array()
var _curve_ys := PackedFloat64Array()

var _canvas: WidgetKit.Canvas
var _plot: PatternPlot
var _slider: HSlider
var _mode_btn: OptionButton
var _out_k: Label
var _out_phase: Label
var _out_value: Label
var _out_sum: Label
var _dragging := false


func defaults() -> Dictionary:
	return {"mode": "single", "wavelength_nm": 405.0}


func build() -> void:
	_mode = ps("mode", "single")
	if not MODES.has(_mode):
		_mode = "single"
	_lambda = pf("wavelength_nm", 405.0) * 1e-9
	_k = TAU / _lambda

	var h := HBoxContainer.new()
	h.set_anchors_preset(PRESET_FULL_RECT)
	h.add_theme_constant_override("separation", 10)
	add_child(h)
	_canvas = WidgetKit.Canvas.new(_draw_canvas, _canvas_input)
	_canvas.custom_minimum_size = Vector2(200, 0)
	_canvas.size_flags_stretch_ratio = 0.85
	h.add_child(_canvas)
	_plot = PatternPlot.new()
	_plot.size_flags_horizontal = SIZE_EXPAND_FILL
	_plot.size_flags_vertical = SIZE_EXPAND_FILL
	_plot.custom_minimum_size = Vector2(180, 0)
	_plot.auto_y = false
	_plot.show_legend = false
	_plot.padding = Rect2(44, 24, 12, 34)
	h.add_child(_plot)
	var panel := WidgetKit.side_panel(236.0)
	h.add_child(panel)

	WidgetKit.heading(panel, "Mode")
	_mode_btn = WidgetKit.option(panel, MODE_TITLES, MODES.find(_mode))
	_mode_btn.item_selected.connect(func(i: int) -> void:
		_mode = MODES[i]
		_setup_slider()
		_update())
	_slider = WidgetKit.slider(panel, "", 0.0, 3.0, 0.01, _s, func(v: float) -> String: return "%.2f λ" % v)
	_slider.value_changed.connect(func(v: float) -> void:
		if _mode == "single":
			_s = v
		else:
			_delta = v
		_update())
	WidgetKit.heading(panel, "Live values")
	_out_k = WidgetKit.readout(panel)
	_out_phase = WidgetKit.readout(panel)
	_out_value = WidgetKit.readout(panel)
	_out_sum = WidgetKit.readout(panel)
	_setup_slider()
	_update()


func _setup_slider() -> void:
	var box := _slider.get_parent() as VBoxContainer
	var lab := (box.get_child(0) as HBoxContainer).get_child(0) as Label
	if _mode == "single":
		lab.text = "distance s"
		_slider.max_value = 3.0
		_slider.set_value_no_signal(_s)
		_slider.value_changed.emit(_s)
	else:
		lab.text = "path difference Δ = b − a"
		_slider.max_value = 2.0
		_slider.set_value_no_signal(_delta)
		_slider.value_changed.emit(_delta)


## One arrow after travelling `s_wl` wavelengths: Quagmire applies the phase e^{iks}.
func _phasor(s_wl: float) -> Vector2:
	var q := QuagmireSystem.new()
	q.add_property("path", PackedStringArray(["A"]))
	q.phase("path", "A", _k * s_wl * _lambda)
	return WidgetKit.amplitude_of(q, PackedStringArray(["A"]))


## Two paths from one source; path B is longer by `d_wl` wavelengths. Returns [a, b] as unit arrows.
func _two_paths(d_wl: float) -> Array:
	var q := QuagmireSystem.new()
	q.add_property("path", PackedStringArray(["S"]))
	q.slits("path", "S", PackedStringArray(["A", "B"]), 1.0, 0.0, "")
	q.phase("path", "B", _k * d_wl * _lambda)
	var a := WidgetKit.amplitude_of(q, PackedStringArray(["A"])) * sqrt(2.0)
	var b := WidgetKit.amplitude_of(q, PackedStringArray(["B"])) * sqrt(2.0)
	return [a, b]


func _update() -> void:
	_curve_xs.resize(SAMPLES)
	_curve_ys.resize(SAMPLES)
	if _out_k == null:
		return
	_out_k.text = "k = 2π/λ = %.3f × 10⁷ rad/m   (λ = %d nm)" % [_k / 1e7, roundi(_lambda * 1e9)]
	if _mode == "single":
		_arrow = _phasor(_s)
		for i in SAMPLES:
			var x := 3.0 * i / float(SAMPLES - 1)
			_curve_xs[i] = x
			_curve_ys[i] = _phasor(x).x
		var ph := _k * _s * _lambda
		_out_phase.text = "ks = 2π·s/λ = %.2f rad = %d°" % [ph, roundi(fposmod(rad_to_deg(ph), 360.0))]
		_out_value.text = "e^{iks} = cos ks + i sin ks\n       = %s + %s i" % [WidgetKit.fmt_amp(_arrow.x), WidgetKit.fmt_amp(_arrow.y)]
		_out_sum.text = "|e^{iks}|² = %.3f  (always 1)" % _arrow.length_squared()
		_plot.x_label = "distance s (wavelengths)"
		_plot.y_label = "Re e^{iks} = cos ks"
		_plot.y_range = Vector2(-1.15, 1.15)
		var n_done := clampi(roundi(_s / 3.0 * (SAMPLES - 1)) + 1, 1, SAMPLES)
		_plot.set_series([
			{"name": "cos ks", "xs": _curve_xs, "ys": _curve_ys, "color": Color(Palette.TEXT_MUTED, 0.6), "width": 1.0},
			{"name": "", "xs": _curve_xs.slice(0, n_done), "ys": _curve_ys.slice(0, n_done), "color": Palette.PINK, "width": 2.5},
		])
		_plot.set_points([{"xs": PackedFloat64Array([_s]), "ys": PackedFloat64Array([_arrow.x]), "color": Palette.PINK, "radius": 5.0}])
	else:
		var ab := _two_paths(_delta)
		_arrow_a = ab[0]
		_arrow_b = ab[1]
		_sum = _arrow_a + _arrow_b
		for i in SAMPLES:
			var x := 2.0 * i / float(SAMPLES - 1)
			var pair := _two_paths(x)
			_curve_xs[i] = x
			_curve_ys[i] = (pair[0] + pair[1]).length_squared()
		var ph := _k * _delta * _lambda
		_out_phase.text = "kΔ = 2π·Δ/λ = %.2f rad = %d°" % [ph, roundi(fposmod(rad_to_deg(ph), 360.0))]
		_out_value.text = "sum = %s + %s i   |sum| = %.3f" % [WidgetKit.fmt_amp(_sum.x), WidgetKit.fmt_amp(_sum.y), _sum.length()]
		_out_sum.text = "|sum|² = 2(1 + cos kΔ) = %.3f" % _sum.length_squared()
		_plot.x_label = "path difference Δ (wavelengths)"
		_plot.y_label = "|sum|²"
		_plot.y_range = Vector2(0.0, 4.3)
		_plot.set_series([{"name": "|sum|²", "xs": _curve_xs, "ys": _curve_ys, "color": Palette.ACCENT_SOFT, "width": 2.0}])
		_plot.set_points([{"xs": PackedFloat64Array([_delta]), "ys": PackedFloat64Array([_sum.length_squared()]), "color": Palette.PINK, "radius": 5.0}])
	_canvas.queue_redraw()


func _geometry() -> Array:
	var sz := _canvas.size
	var unit := maxf(20.0, (minf(sz.x, sz.y) - 48.0) / (2.0 if _mode == "single" else 4.0))
	return [Vector2(sz.x / 2.0, sz.y / 2.0 + 8.0), unit]


func _canvas_input(_c: Control, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_set_from(event.position)
		_canvas.accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_set_from(event.position)


## Dragging the arrow head sets the phase; whole turns are kept so the slider stays continuous.
func _set_from(p: Vector2) -> void:
	var g := _geometry()
	var o: Vector2 = g[0]
	var d := p - o
	if _mode == "sum":
		d = p - (o + _arrow_a * g[1])
	if d.length() < 3.0:
		return
	var turns_now := _s if _mode == "single" else _delta
	var frac := fposmod(rad_to_deg(atan2(-d.y, d.x)), 360.0) / 360.0
	var whole := floorf(turns_now)
	var candidates := [whole - 1.0 + frac, whole + frac, whole + 1.0 + frac]
	var best: float = candidates[0]
	for cnd in candidates:
		if absf(cnd - turns_now) < absf(best - turns_now):
			best = cnd
	best = clampf(snappedf(best, 0.01), _slider.min_value, _slider.max_value)
	_slider.set_value_no_signal(best)
	_slider.value_changed.emit(best)


func _draw_canvas(c: Control) -> void:
	var g := _geometry()
	var o: Vector2 = g[0]
	var u: float = g[1]
	var mono := ThemeBuilder.mono()
	var body := ThemeBuilder.body()
	# axes and unit circle
	c.draw_line(o - Vector2(u * (1.0 if _mode == "single" else 2.0) + 10, 0), o + Vector2(u * (1.0 if _mode == "single" else 2.0) + 10, 0), Color(Palette.TEXT_DIM, 0.4), 1.0)
	c.draw_line(o - Vector2(0, u * (1.0 if _mode == "single" else 2.0) + 10), o + Vector2(0, u * (1.0 if _mode == "single" else 2.0) + 10), Color(Palette.TEXT_DIM, 0.4), 1.0)
	WidgetKit.text(c, body, o + Vector2(u * (1.0 if _mode == "single" else 2.0) - 14, 16), "real", 12, Palette.TEXT_DIM)
	WidgetKit.text_right(c, body, o + Vector2(-6, -u * (1.0 if _mode == "single" else 2.0) + 4), "imaginary", 12, Palette.TEXT_DIM)
	c.draw_arc(o, u, 0.0, TAU, 96, Color(Palette.ACCENT_SOFT, 0.35), 1.0, true)
	if _mode == "single":
		var tip := o + Vector2(_arrow.x, -_arrow.y) * u
		# the angle swept so far
		var ph := _k * _s * _lambda
		c.draw_arc(o, u * 0.3, 0.0, -fposmod(ph, TAU), 64, Color(Palette.WARNING, 0.9), 1.5, true)
		WidgetKit.dashed(c, tip, Vector2(tip.x, o.y), Color(Palette.PINK, 0.7), 1.2, 4.0)
		c.draw_line(o, Vector2(tip.x, o.y), Palette.PINK, 3.0, true)
		WidgetKit.arrow(c, o, tip, Palette.ACCENT_SOFT, 3.5, 13.0)
		WidgetKit.handle(c, tip, 8.0)
		WidgetKit.pill_clamped(c, mono, tip + Vector2(12, -8), "e^{iks}", 14, Palette.TEXT)
		WidgetKit.pill_clamped(c, mono, Vector2(tip.x - 30, o.y + (20 if _arrow.y >= 0.0 else -10)), "cos ks = %s" % WidgetKit.fmt_amp(_arrow.x), 12, Palette.PINK)
		if absf(fposmod(ph, TAU)) > 0.05:
			WidgetKit.text(c, mono, o + Vector2(u * 0.3 + 6, -u * 0.3 * 0.3), "ks", 13, Palette.WARNING)
		WidgetKit.text(c, body, Vector2(8, 16), "one wavelength of travel = one full turn", 12, Palette.TEXT_MUTED)
	else:
		var tip_a := o + Vector2(_arrow_a.x, -_arrow_a.y) * u
		var tip_b := tip_a + Vector2(_arrow_b.x, -_arrow_b.y) * u
		c.draw_arc(o, 2.0 * u, 0.0, TAU, 128, Color(Palette.ACCENT_SOFT, 0.15), 1.0, true)
		WidgetKit.arrow(c, o, tip_a, Palette.ACCENT_SOFT, 3.0, 12.0)
		WidgetKit.arrow(c, tip_a, tip_b, Palette.PINK, 3.0, 12.0)
		WidgetKit.arrow(c, o, tip_b, Palette.SUCCESS, 4.0, 14.0)
		WidgetKit.handle(c, tip_b, 8.0)
		WidgetKit.pill_clamped(c, mono, (o + tip_a) / 2.0 + Vector2(-26, -10), "e^{ika}", 13, Palette.ACCENT_SOFT)
		WidgetKit.pill_clamped(c, mono, (tip_a + tip_b) / 2.0 + Vector2(-26, 24), "e^{ikb}", 13, Palette.PINK)
		WidgetKit.pill_clamped(c, mono, tip_b + Vector2(12, -8), "sum", 13, Palette.SUCCESS)
		WidgetKit.text(c, body, Vector2(8, 16), "arrows add tip-to-tail; the result's length² is the intensity", 12, Palette.TEXT_MUTED)
	WidgetKit.text(c, body, Vector2(8, c.size.y - 8), "drag the pink handle", 12, Palette.TEXT_MUTED)
