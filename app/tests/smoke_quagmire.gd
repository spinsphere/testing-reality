extends SceneTree
## Headless smoke test for the Quagmire GDExtension:
##   godot --headless --path app -s tests/smoke_quagmire.gd

func _init() -> void:
	var failures := 0
	var s := QuagmireSystem.new()
	s.add_property("pol", PackedStringArray(["↔", "↕"]))
	s.set_linear_polarization("pol", PackedStringArray(["↔", "↕"]), 45.0)
	s.polarizer("pol", PackedStringArray(["↔", "↕"]), 0.0, "lost@P1", {})
	s.polarizer("pol", PackedStringArray(["↔", "↕"]), 45.0, "lost@P2", {})
	s.polarizer("pol", PackedStringArray(["↔", "↕"]), 90.0, "lost@P3", {})
	var p := s.probability({"alive": PackedStringArray(["pol"])})
	print("three-polarizer transmission: ", p)
	print("state: ", s.ket_text())
	if absf(p - 0.125) > 1e-12:
		failures += 1
		push_error("expected 0.125, got %f" % p)
	if s.ket_text() != "1/(2√2) |↕⟩ + 1/√2 |lost@P1⟩ + 1/2 |lost@P2⟩ + 1/(2√2) |lost@P3⟩":
		failures += 1
		push_error("unexpected ket text: " + s.ket_text())

	# Experiment 6: entangled pair, marked double slit, local eraser, idler polarizer at 45°.
	var e := QuagmireSystem.with_seed(7)
	e.add_property("pump", PackedStringArray(["↔", "↕"]))
	e.set_linear_polarization("pump", PackedStringArray(["↔", "↕"]), 45.0)
	e.spdc("pump", PackedStringArray(["↔", "↕"]), "pol1", "pol2", PackedStringArray(["↔", "↕"]), 0.0)
	e.add_property("path", PackedStringArray(["S"]))
	e.slits("path", "S", PackedStringArray(["A", "B"]), 1.0, 0.0, "")
	e.polarizer("pol1", PackedStringArray(["↔", "↕"]), 90.0, "lost@PA", {"is": {"path": "A"}})
	e.polarizer("pol1", PackedStringArray(["↔", "↕"]), 0.0, "lost@PB", {"is": {"path": "B"}})
	e.polarizer("pol1", PackedStringArray(["↔", "↕"]), 45.0, "lost@P1", {})
	e.polarizer("pol2", PackedStringArray(["↔", "↕"]), 45.0, "lost@P2", {})
	var screen := QuagmireScreen.new()
	screen.set_double_slit(810e-9, 200e-6, 400e-6, 0.5, "A", "B")
	var ys := QuagmireScreen.linspace(2e-3, 401)
	var singles: QuagmireProfile = e.screen_profile("path", screen, ys, {"alive": PackedStringArray(["pol1"])})
	var coinc: QuagmireProfile = e.screen_profile("path", screen, ys, {"alive": PackedStringArray(["pol1", "pol2"])})
	print("singles visibility: ", singles.visibility(), "  coincidence visibility: ", coinc.visibility())
	if singles.visibility() > 1e-9 or coinc.visibility() < 0.99:
		failures += 1
		push_error("eraser visibilities wrong")
	var pts := coinc.sample_positions(e, 5)
	print("sampled photon positions (m): ", pts)
	if pts.size() != 5:
		failures += 1
	print("amplitudes: ", e.amplitudes().size(), " terms; ket: ", e.ket_text())
	# v0.2 bench helpers: joint draws are correlated, counts are Poisson, rates integrate to the flux
	var bell := QuagmireSystem.with_seed(11)
	bell.add_property("a", PackedStringArray(["0", "1"]))
	bell.add_property("b", PackedStringArray(["0", "1"]))
	bell.set_state([{"labels": PackedStringArray(["0", "0"]), "re": 0.7071067811865476, "im": 0.0},
		{"labels": PackedStringArray(["1", "1"]), "re": 0.7071067811865476, "im": 0.0}])
	var ones := 0
	for i in 200:
		var o: Dictionary = bell.sample_outcome()
		if o["a"] != o["b"]:
			failures += 1
			push_error("joint draw not correlated: %s" % str(o))
			break
		if o["a"] == "1":
			ones += 1
	if ones < 60 or ones > 140:
		failures += 1
		push_error("joint draw biased: %d/200 ones" % ones)
	var total := 0
	for i in 500:
		total += bell.counts(8.0, 0.5)
	if absf(total / 500.0 - 4.0) > 0.4:
		failures += 1
		push_error("counts() mean %.2f, expected 4" % (total / 500.0))
	if bell.counts(0.0, 10.0) != 0 or bell.poisson(0.0) != 0:
		failures += 1
		push_error("zero rate must give zero counts")
	var g2 := QuagmireScreen.new()
	g2.set_double_slit(808e-9, 200e-6, 400e-6, 0.5, "A", "B")
	if absf(g2.fringe_spacing() - 1.01e-3) > 1e-9 or absf(g2.envelope_zero() - 2.02e-3) > 1e-9:
		failures += 1
		push_error("geometry helpers wrong: %f %f" % [g2.fringe_spacing(), g2.envelope_zero()])
	var two := QuagmireSystem.new()
	two.add_property("path", PackedStringArray(["S", "A", "B"]))
	two.slits("path", "S", PackedStringArray(["A", "B"]), 1.0, 0.0, "")
	var ys2 := QuagmireScreen.linspace(3e-3, 601)
	var prof2: QuagmireProfile = two.screen_profile("path", g2, ys2, {}).box_convolve(200e-6)
	var dy := ys2[1] - ys2[0]
	var flux_back := 0.0
	for y in ys2:
		flux_back += prof2.rate_at(y, 200e-6, 3000.0) * dy / 200e-6
	if absf(flux_back - 3000.0) > 60.0:
		failures += 1
		push_error("rate_at does not integrate back to the flux: %.1f" % flux_back)
	if absf(prof2.intensity_at(ys2[300]) - prof2.intensity()[300]) > 1e-12:
		failures += 1
		push_error("intensity_at off-grid")
	var ver := str(QuagmireSystem.engine_version())
	if ver == "" or ver.split(".").size() != 3 or str(ClassDB.class_call_static("QuagmireSystem", "engine_version")) != ver:
		failures += 1
		push_error("engine_version() should be a semver string, got '%s'" % ver)
	print("engine version ", ver)
	print("bench helpers: joint ones=%d/200, counts mean=%.2f, fringe spacing %.2f mm, flux back %.0f" % [ones, total / 500.0, g2.fringe_spacing() * 1e3, flux_back])
	print("SMOKE ", "OK" if failures == 0 else "FAILED (%d)" % failures)
	quit(0 if failures == 0 else 1)
