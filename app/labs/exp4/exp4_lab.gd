extends EntangledLabBase
## Experiment 4 — Entanglement: Bell state. Two polarizers, two detectors, coincidences.

var p1: Optics.Polarizer
var p2: Optics.Polarizer
var d1: Optics.Detector
var d2: Optics.Detector
var _grid: Array = []


func _init() -> void:
	chapter_id = "exp4"


func build() -> void:
	build_pump()
	on_signal(Optics.Lens.new("L4", 500.0), 0.3)
	p1 = on_signal(Optics.Polarizer.new("P1", 0.0), 0.6)
	d1 = on_signal(Optics.Detector.new("D1"), 1.0)
	on_idler(Optics.Lens.new("L5", 500.0), 0.3)
	p2 = on_idler(Optics.Polarizer.new("P2", 0.0), 0.6)
	d2 = on_idler(Optics.Detector.new("D2"), 1.0)
	finish_layout()
	controller.ctx["wavelength"] = 405.0
	_grid = LabData.load_grid("res://data/lab/experiment-4/Acquisition_-_Feuille_1.csv")
	add_preset("Parallel 0°, 0°", func() -> void: _angles(0, 0), "Both horizontal: half the pairs pass both.")
	add_preset("45°, 45°", func() -> void: _angles(45, 45), "Both diagonal: still half — the correlation survives a change of basis.")
	add_preset("Crossed 0°, 90°", func() -> void: _angles(0, 90), "Perpendicular: no coincidences at all.")
	add_preset("0°, 45°", func() -> void: _angles(0, 45), "A quarter of the pairs.")
	add_preset("30°, 60°", func() -> void: _angles(60, 30), "3/8 of the pairs: cos²(30°)/2.")


func _angles(a: float, b: float) -> void:
	p2.set_param("angle", a, false)
	p1.set_param("angle", b, false)


func on_rebuilt(_snapshots: Array, _result: Dictionary) -> void:
	clear_results()
	var sys := controller.system
	var alpha := float(p2.get_param("angle"))
	var beta := float(p1.get_param("angle"))
	var both := sys.probability({"alive": PackedStringArray(["pol1", "pol2"])})
	var s1 := sys.probability({"alive": PackedStringArray(["pol1"])})
	var s2 := sys.probability({"alive": PackedStringArray(["pol2"])})
	add_result_row("Polarizer angles (α on P2, β on P1)", "α = %d°, β = %d°, α − β = %d°" % [roundi(alpha), roundi(beta), roundi(alpha - beta)])
	add_result_row("Coincidence probability", "%.3f   (½cos²(α−β) = %.3f)" % [both, 0.5 * pow(cos(deg_to_rad(alpha - beta)), 2)], Palette.PINK)
	add_result_row("Singles D1 / D2", "%.2f / %.2f" % [s1, s2])
	var pair := _pair_state()
	add_result_row("Pair state leaving the crystal", "%s   (VV %.0f %%, HH %.0f %%)" % [pair.ket_text(), pair.probability({"is": {"pol1": "↕", "pol2": "↕"}}) * 100.0, pair.probability({"is": {"pol1": "↔", "pol2": "↔"}}) * 100.0])

	# coincidence curve vs β at fixed α, computed with the engine, plus lab points
	var xs := PackedFloat64Array()
	var ys := PackedFloat64Array()
	var lab_xs := PackedFloat64Array()
	var lab_ys := PackedFloat64Array()
	var lab_peak := 0.0
	for row in _grid:
		if absf(float(row["a"]) - alpha) < 5.0:
			lab_xs.append(float(row["b"]))
			lab_ys.append(float(row["coinc"]))
			lab_peak = maxf(lab_peak, float(row["coinc"]))
	# model in pairs / s from the source's pair rate; the lab's points are scaled to its peak
	var scale := controller.rate_scale()
	var best := 0.0
	for row in _grid:
		best = maxf(best, float(row["coinc"]))
	if best > 0.0 and scale > 0.0:
		var k := 0.5 * scale / best
		for i in lab_ys.size():
			lab_ys[i] *= k
	for i in 73:
		var b := -90.0 + i * 2.5
		var probe := QuagmireSystem.with_seed(1)
		probe.add_property("pump", PackedStringArray(["↔", "↕"]))
		probe.set_linear_polarization("pump", PackedStringArray(["↔", "↕"]), 2.0 * float(pump_hwp.get_param("angle")))
		probe.spdc("pump", PackedStringArray(["↔", "↕"]), "pol1", "pol2", PackedStringArray(["↔", "↕"]), float(bbo.get_param("phase")))
		probe.polarizer("pol1", PackedStringArray(["↔", "↕"]), b, "lost@P1", {})
		probe.polarizer("pol2", PackedStringArray(["↔", "↕"]), alpha, "lost@P2", {})
		xs.append(b)
		ys.append(probe.probability({"alive": PackedStringArray(["pol1", "pol2"])}) * scale)
	var p := PatternPlot.new()
	p.title = "coincidences per second vs P1 angle β   (P2 fixed at α = %d°)" % roundi(alpha)
	p.x_label = "P1 angle β (°)"
	p.y_label = "coincidences / s"
	p.size_flags_vertical = Control.SIZE_EXPAND_FILL
	p.custom_minimum_size = Vector2(0, 170)
	var series := [{"name": "quantum prediction", "xs": xs, "ys": ys, "color": Palette.PINK, "width": 2.2}]
	p.set_series(series)
	if lab_xs.size() > 0:
		p.set_points([{"xs": lab_xs, "ys": lab_ys, "color": Palette.WARNING, "radius": 3.0}])
	series.append({"name": "current β", "xs": PackedFloat64Array([beta, beta]), "ys": PackedFloat64Array([0.0, p.y_range.y]), "color": Palette.ACCENT_SOFT, "dashed": true, "width": 1.0})
	p.set_series(series)
	add_result_control(p)
	var note := Label.new()
	note.text = "Lab points: the site's 19×19 angle scan (1 s windows). Note the real pair was unbalanced (more VV than HH) — try moving the pump λ/2 off 22.5° to reproduce that."
	note.theme_type_variation = "Muted"
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_result_control(note)


## The two-photon state right after the BBO, from the pump wave plate and crystal phase.
func acquisition_channels() -> Array:
	var out := super()
	out.append({"name": "D1·D2", "rate": controller.rate_scale() * controller.system.probability({"alive": PackedStringArray(["pol1", "pol2"])})})
	return out


func _pair_state() -> QuagmireSystem:
	var probe := QuagmireSystem.with_seed(1)
	probe.add_property("pump", PackedStringArray(["↔", "↕"]))
	probe.set_linear_polarization("pump", PackedStringArray(["↔", "↕"]), 2.0 * float(pump_hwp.get_param("angle")))
	probe.spdc("pump", PackedStringArray(["↔", "↕"]), "pol1", "pol2", PackedStringArray(["↔", "↕"]), float(bbo.get_param("phase")))
	return probe


func _finish(_sys: QuagmireSystem, _ctx: Dictionary) -> Dictionary:
	return {}
