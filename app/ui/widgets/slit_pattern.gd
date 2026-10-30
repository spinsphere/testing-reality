extends WidgetBase
## The site's Experiment 2 simulator: N slits of width w and spacing d, wavelength λ,
## far-field pattern on a screen at distance L. "Cover one slit" removes path A.
## The pattern (and the no-interference envelope) come from QuagmireSystem.screen_profile.

const HALF_WIDTH_M := 6e-3
const POINTS := 601

var _lambda_nm := 808.0
var _w_um := 200.0
var _d_um := 400.0
var _n := 2
var _L := 0.5
var _cover := false
var _show_env := true
var _visibility := 0.0

var _plot: PatternPlot
var _mask: WidgetKit.Canvas
var _cover_check: CheckBox
var _out_geom: Label
var _out_vis: Label


func defaults() -> Dictionary:
	return {"wavelength_nm": 808.0, "slit_width_um": 200.0, "separation_um": 400.0, "slits": 2, "distance_m": 0.5}


func build() -> void:
	_lambda_nm = pf("wavelength_nm", 808.0)
	_w_um = pf("slit_width_um", 200.0)
	_d_um = pf("separation_um", 400.0)
	_n = clampi(pi_("slits", 2), 1, 6)
	_L = pf("distance_m", 0.5)

	var parts := split(250.0)
	var left: VBoxContainer = parts[0]
	var panel: VBoxContainer = parts[1]
	_plot = PatternPlot.new()
	_plot.size_flags_vertical = SIZE_EXPAND_FILL
	_plot.auto_y = false
	_plot.auto_x = false
	_plot.x_range = Vector2(-HALF_WIDTH_M * 1e3, HALF_WIDTH_M * 1e3)
	_plot.x_label = "position on the screen y (mm)"
	_plot.y_label = "relative intensity"
	_plot.padding = Rect2(44, 24, 12, 34)
	left.add_child(_plot)
	_mask = WidgetKit.Canvas.new(_draw_mask)
	_mask.custom_minimum_size = Vector2(0, 26)
	_mask.size_flags_vertical = SIZE_FILL
	left.add_child(_mask)

	WidgetKit.heading(panel, "Geometry")
	var n_s := WidgetKit.slider(panel, "number of slits N", 1, 6, 1, _n, func(v: float) -> String: return "%d" % roundi(v))
	n_s.value_changed.connect(func(v: float) -> void:
		_n = roundi(v)
		_update())
	var w_s := WidgetKit.slider(panel, "slit width w", 20.0, 400.0, 5.0, _w_um, func(v: float) -> String: return "%d µm" % roundi(v))
	w_s.value_changed.connect(func(v: float) -> void:
		_w_um = v
		_update())
	var d_s := WidgetKit.slider(panel, "slit separation d", 100.0, 1200.0, 10.0, _d_um, func(v: float) -> String: return "%d µm" % roundi(v))
	d_s.value_changed.connect(func(v: float) -> void:
		_d_um = v
		_update())
	var l_s := WidgetKit.slider(panel, "wavelength λ", 380.0, 900.0, 1.0, _lambda_nm, func(v: float) -> String: return "%d nm" % roundi(v))
	l_s.value_changed.connect(func(v: float) -> void:
		_lambda_nm = v
		_update())
	var checks := HBoxContainer.new()
	checks.add_theme_constant_override("separation", 6)
	panel.add_child(checks)
	_cover_check = WidgetKit.check(checks, "cover one slit", _cover)
	_cover_check.toggled.connect(func(on: bool) -> void:
		_cover = on
		_update())
	var env_check := WidgetKit.check(checks, "envelope", _show_env)
	env_check.tooltip_text = "Show the single-slit envelope (sin α/α)²: the same photons without interference"
	env_check.toggled.connect(func(on: bool) -> void:
		_show_env = on
		_update())
	_out_geom = WidgetKit.readout(panel, "", 12)
	_out_vis = _out_geom
	_update()


func _slit_names() -> PackedStringArray:
	var names := PackedStringArray()
	for i in _n:
		names.append(String.chr(65 + i))
	return names


func _system(cover: bool) -> QuagmireSystem:
	var s := QuagmireSystem.new()
	s.add_property("path", PackedStringArray(["S"]))
	s.slits("path", "S", _slit_names(), 1.0, 0.0, "")
	if cover and _n >= 2:
		s.project({"is_not": {"path": "A"}})
	return s


func _screen() -> QuagmireScreen:
	var scr := QuagmireScreen.new()
	scr.wavelength = _lambda_nm * 1e-9
	scr.slit_width = _w_um * 1e-6
	scr.distance = _L
	scr.clear_slits()
	var names := _slit_names()
	for i in _n:
		scr.add_slit(names[i], (i - (_n - 1) / 2.0) * _d_um * 1e-6)
	return scr


func _update() -> void:
	_cover_check.disabled = _n < 2
	var ys := QuagmireScreen.linspace(HALF_WIDTH_M, POINTS)
	var scr := _screen()
	var full: QuagmireProfile = _system(false).screen_profile("path", scr, ys, {})
	var shown: QuagmireProfile = _system(_cover and _n >= 2).screen_profile("path", scr, ys, {})
	if full == null or shown == null:
		return
	var norm := maxf(1e-300, full.max())
	var xs_mm := PackedFloat64Array()
	xs_mm.resize(ys.size())
	for i in ys.size():
		xs_mm[i] = ys[i] * 1e3
	var inten := shown.intensity()
	var env := shown.incoherent()
	var ys_i := PackedFloat64Array()
	var ys_e := PackedFloat64Array()
	ys_i.resize(inten.size())
	ys_e.resize(env.size())
	for i in inten.size():
		ys_i[i] = inten[i] / norm
		ys_e[i] = env[i] / norm
	_visibility = shown.visibility()
	var col := Palette.wavelength_to_color(_lambda_nm) if Palette.is_visible(_lambda_nm) else Palette.LASER_RED
	if col.get_luminance() < 0.25:
		col = col.lightened(0.4)
	var series: Array = []
	if _show_env:
		series.append({"name": "envelope (sin α/α)²", "xs": xs_mm, "ys": ys_e, "color": Color(Palette.TEXT_DIM, 0.9), "width": 1.5, "dashed": true})
	series.append({"name": "pattern" + (" (one slit covered)" if _cover and _n >= 2 else " (N = %d)" % _n), "xs": xs_mm, "ys": ys_i, "color": col, "width": 2.2})
	_plot.y_range = Vector2(0.0, 1.08)
	_plot.set_series(series)
	var lam := _lambda_nm * 1e-9
	_out_geom.text = "fringe period λL/d = %.2f mm\nenvelope half-width λL/w = %.2f mm\nL = %.2f m   visibility = %.2f" % [lam * _L / (_d_um * 1e-6) * 1e3, lam * _L / (_w_um * 1e-6) * 1e3, _L, _visibility]
	_mask.queue_redraw()


## A to-scale strip of the slit mask under the plot.
func _draw_mask(c: Control) -> void:
	var sz := c.size
	var r := _plot._plot_rect()
	var body := ThemeBuilder.body()
	var mono := ThemeBuilder.mono()
	var x0 := r.position.x
	var width := r.size.x
	var mid := sz.y / 2.0 + 2.0
	c.draw_rect(Rect2(x0, mid - 5, width, 10), Color(Palette.BORDER, 0.9))
	var span_um := maxf(_d_um * (_n - 1) + _w_um, _w_um) * 2.4 + 300.0
	var px_per_um := width / span_um
	for i in _n:
		var centre := x0 + width / 2.0 + (i - (_n - 1) / 2.0) * _d_um * px_per_um
		var half := maxf(1.0, _w_um * px_per_um / 2.0)
		var covered := _cover and _n >= 2 and i == 0
		c.draw_rect(Rect2(centre - half, mid - 5, half * 2.0, 10), Color(Palette.TEXT_MUTED, 0.9) if covered else Color("#0b0c1a"))
		WidgetKit.text_centered(c, mono, Vector2(centre, mid - 7), String.chr(65 + i) + (" ✕" if covered else ""), 10, Palette.TEXT_DIM)
	WidgetKit.text(c, body, Vector2(2, mid + 4), "mask", 10, Palette.TEXT_MUTED)
