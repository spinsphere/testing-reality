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
	print("SMOKE ", "OK" if failures == 0 else "FAILED (%d)" % failures)
	quit(0 if failures == 0 else 1)
