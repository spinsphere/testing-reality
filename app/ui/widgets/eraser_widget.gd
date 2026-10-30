extends WidgetBase
## Quantum eraser simulator (Exp 3 single photons; Exp 5/6 entangled pairs).
## A 45°-polarized photon meets a double slit whose slits carry orthogonal polarizers
## (markers: A → ↕, B → ↔). P1 (eraser) sits in front of the screen; in entangled mode an
## idler polarizer P2 selects coincidences. All curves come from QuagmireSystem.screen_profile.

const WAVELENGTH := 810e-9
const SLIT_W := 200e-6
const SLIT_D := 400e-6
const DIST := 0.5
const HALF := 2e-3
const POINTS := 401

var _p1 := 45.0
var _p2 := 45.0
var _entangled := false
var _markers := true
var _p1_in := true
var _p2_in := true

var _plot: PatternPlot
var _dial1: WidgetKit.Dial
var _dial2: WidgetKit.Dial
var _p2_check: CheckBox
var _out_singles: Label
var _out_coinc: Label
var _out_state: Label


func defaults() -> Dictionary:
	return {"p1_angle": 45.0, "entangled": false, "p2_angle": 45.0}


func build() -> void:
	_p1 = fposmod(pf("p1_angle", 45.0), 180.0)
	_p2 = fposmod(pf("p2_angle", 45.0), 180.0)
	_entangled = pb("entangled", false)

	var parts := split(262.0)
	var left: VBoxContainer = parts[0]
	var panel: VBoxContainer = parts[1]
	_plot = PatternPlot.new()
	_plot.size_flags_vertical = SIZE_EXPAND_FILL
	_plot.auto_x = false
	_plot.x_range = Vector2(-HALF * 1e3, HALF * 1e3)
	_plot.x_label = "position on the screen y (mm)"
	_plot.y_label = "counts (relative)"
	_plot.padding = Rect2(44, 24, 12, 34)
	left.add_child(_plot)

	var mode := WidgetKit.option(panel, ["Single photons (Exp 3)", "Entangled pair + idler P2 (Exp 5/6)"], 1 if _entangled else 0)
	mode.item_selected.connect(func(i: int) -> void:
		_entangled = i == 1
		_dial2.visible = _entangled
		_p2_check.visible = _entangled
		_update())
	var dials := HBoxContainer.new()
	dials.add_theme_constant_override("separation", 8)
	dials.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(dials)
	_dial1 = WidgetKit.Dial.new("P1 (eraser)", _p1)
	_dial1.custom_minimum_size = Vector2(96, 104)
	_dial1.changed.connect(func(a: float) -> void:
		_p1 = a
		_update())
	dials.add_child(_dial1)
	_dial2 = WidgetKit.Dial.new("P2 (idler)", _p2)
	_dial2.custom_minimum_size = Vector2(96, 104)
	_dial2.visible = _entangled
	_dial2.changed.connect(func(a: float) -> void:
		_p2 = a
		_update())
	dials.add_child(_dial2)
	var checks := HBoxContainer.new()
	checks.add_theme_constant_override("separation", 10)
	panel.add_child(checks)
	var mk := WidgetKit.check(checks, "markers", _markers)
	mk.tooltip_text = "Polarizers on the slits: A → ↕, B → ↔ (which-path marking)"
	mk.toggled.connect(func(on: bool) -> void:
		_markers = on
		_update())
	var p1c := WidgetKit.check(checks, "P1 in", _p1_in)
	p1c.toggled.connect(func(on: bool) -> void:
		_p1_in = on
		_dial1.modulate.a = 1.0 if on else 0.4
		_update())
	var p2c := WidgetKit.check(checks, "P2 in", _p2_in)
	_p2_check = p2c
	p2c.visible = _entangled
	p2c.toggled.connect(func(on: bool) -> void:
		_p2_in = on
		_dial2.modulate.a = 1.0 if on else 0.4
		_update())
	_out_singles = WidgetKit.readout(panel, "", 12)
	_out_coinc = WidgetKit.readout(panel, "", 12)
	_out_state = WidgetKit.ket_label(panel, "", 12)
	_out_state.max_lines_visible = 2
	_out_state.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_update()


func _system() -> QuagmireSystem:
	var e := QuagmireSystem.new()
	if _entangled:
		e.add_property("pump", WidgetKit.HV)
		e.set_linear_polarization("pump", WidgetKit.HV, 45.0)
		e.spdc("pump", WidgetKit.HV, "pol1", "pol2", WidgetKit.HV, 0.0)
	else:
		e.add_property("pol1", WidgetKit.HV)
		e.set_linear_polarization("pol1", WidgetKit.HV, 45.0)
	e.add_property("path", PackedStringArray(["S"]))
	e.slits("path", "S", PackedStringArray(["A", "B"]), 1.0, 0.0, "")
	if _markers:
		e.polarizer("pol1", WidgetKit.HV, 90.0, "lost@MA", {"is": {"path": "A"}})
		e.polarizer("pol1", WidgetKit.HV, 0.0, "lost@MB", {"is": {"path": "B"}})
	if _p1_in:
		e.polarizer("pol1", WidgetKit.HV, _p1, "lost@P1", {})
	if _entangled and _p2_in:
		e.polarizer("pol2", WidgetKit.HV, _p2, "lost@P2", {})
	return e


func _update() -> void:
	var e := _system()
	var screen := QuagmireScreen.new()
	screen.set_double_slit(WAVELENGTH, SLIT_W, SLIT_D, DIST, "A", "B")
	var ys := QuagmireScreen.linspace(HALF, POINTS)
	var xs := PackedFloat64Array()
	xs.resize(ys.size())
	for i in ys.size():
		xs[i] = ys[i] * 1e3
	var series: Array = []
	var singles: QuagmireProfile = e.screen_profile("path", screen, ys, {"alive": PackedStringArray(["pol1"])})
	var ref_norm := 1.0
	# normalise to the brightest possible singles curve (no markers, no P1): the "incoherent" reference
	var ref: QuagmireProfile = e.screen_profile("path", screen, ys, {})
	if ref:
		ref_norm = maxf(1e-300, ref.incoherent()[ref.incoherent().size() / 2])
	if singles:
		series.append({"name": "signal alone (singles)", "xs": xs, "ys": _scaled(singles.intensity(), ref_norm), "color": Palette.ACCENT_SOFT, "width": 2.2})
		_out_singles.text = "singles: visibility %.2f, rate %s" % [singles.visibility(), WidgetKit.fmt_pct(e.probability({"alive": PackedStringArray(["pol1"])}))]
	if _entangled:
		var coinc: QuagmireProfile = e.screen_profile("path", screen, ys, {"alive": PackedStringArray(["pol1", "pol2"])})
		if coinc:
			series.append({"name": "coincidences with P2", "xs": xs, "ys": _scaled(coinc.intensity(), ref_norm), "color": Palette.PINK, "width": 2.2})
			_out_coinc.text = "coincidences: visibility %.2f, rate %s" % [coinc.visibility(), WidgetKit.fmt_pct(e.probability({"alive": PackedStringArray(["pol1", "pol2"])}))]
	else:
		_out_coinc.text = "P1 at 45° erases the marks; at 0°/90° it reads the slit"
	_plot.set_series(series)
	var txt := e.ket_text_mapped({"pol1/↔": "↔", "pol1/↕": "↕", "pol2/↔": "↔", "pol2/↕": "↕"})
	_out_state.text = txt


func _scaled(a: PackedFloat64Array, norm: float) -> PackedFloat64Array:
	var out := PackedFloat64Array()
	out.resize(a.size())
	for i in a.size():
		out[i] = a[i] / norm
	return out
