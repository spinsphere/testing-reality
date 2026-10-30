class_name EntangledLabBase
extends SlitLabBase
## Shared layout for Experiments 4–7: pump preparation line, U-turn, BBO at the origin,
## signal arm (towards −x, +z) and idler arm (towards −x, −z).

const BBO_POS := Vector2(0.12, 0.0)
const SIGNAL_END := Vector2(-0.56, 0.16)
const IDLER_END := Vector2(-0.56, -0.16)

var bbo: Optics.SPDCSource
var pump_hwp: Optics.HalfWavePlate
var pump_path: Array = []
var signal_path: Array = []
var idler_path: Array = []


## Builds the pump line and the BBO; returns nothing. Call before adding arm elements.
func build_pump() -> void:
	controller.ctx["pol"] = "pump"
	var z := 0.2
	var laser := place(Optics.Laser.new(405.0, 0.0, "LASER"), -0.55, z)
	laser.model = "laser_405"
	var bs := place(Optics.BeamSplitterCube.new("BS"), -0.45, z)
	var bd := place_decor(Optics.BeamDump.new("BD"), -0.45, z + 0.075, -90.0)
	add_stray_beam(bs, bd, 405.0)
	var hwp1 := place(Optics.HalfWavePlate.new("λ/2", 0.0), -0.37, z)
	hwp1.description = "First half-wave plate: with the beam splitter it controls the pump intensity."
	var l1 := place(Optics.Lens.new("L1", 100.0), -0.28, z)
	var l2 := place(Optics.Lens.new("L2", 25.0), -0.16, z)
	var m1 := place(Optics.Mirror.new("M1", 0.0), 0.48, z)
	aim(m1, Vector2(0.48, 0.0))
	m1.rotation_degrees.y += 45.0
	var m2 := place(Optics.Mirror.new("M2", 0.0), 0.48, 0.0)
	m2.rotation_degrees.y = 135.0
	var l3 := place_on(Optics.Lens.new("L3", 250.0), Vector2(0.48, 0.0), BBO_POS, 0.3)
	pump_hwp = place_on(Optics.HalfWavePlate.new("λ/2 pump", 22.5), Vector2(0.48, 0.0), BBO_POS, 0.55)
	pump_hwp.description = "Sets the pump polarization: 22.5° makes it diagonal, so the crystal pair produces equal |↕↕⟩ and |↔↔⟩ amplitudes (a balanced Bell state). Move it to see the state become unbalanced — exactly what happened in the real lab."
	var berek := place_on(Optics.Berek.new("Berek"), Vector2(0.48, 0.0), BBO_POS, 0.78)
	bbo = place(Optics.SPDCSource.new("BBO"), BBO_POS.x, BBO_POS.y)
	aim(bbo, Vector2(-1.0, 0.0))
	# almost all pump photons pass the crystal unconverted and must be stopped
	var pump_dump := place_decor(Optics.BeamDump.new("PD"), BBO_POS.x - 0.20, 0.0, 180.0)
	pump_dump.description = "Beam dump for the pump: only about one pump photon in a billion is converted into a pair, so the violet beam continues straight through the crystal and has to be stopped here."
	add_stray_beam(bbo, pump_dump, 405.0, "fixed", 0.85)
	pump_path = [laser, bs, hwp1, l1, l2, m1, m2, l3, pump_hwp, berek, bbo]


## Place an element on the signal arm at fraction `t` of the way from the BBO to the arm end;
## `side` shifts it across the arm (metres) for parts that sit next to each other.
func on_signal(app: Apparatus, t: float, side: float = 0.0) -> Apparatus:
	app.ctx_overrides = {"pol": "pol1"}
	place_on(app, BBO_POS, SIGNAL_END, t)
	if side != 0.0:
		var dir := (SIGNAL_END - BBO_POS).normalized()
		app.position += Vector3(-dir.y, 0.0, dir.x) * side
	signal_path.append(app)
	return app


## Length of the signal arm from the crystal to the detector (metres).
func signal_arm_length() -> float:
	return BBO_POS.distance_to(SIGNAL_END)


func on_idler(app: Apparatus, t: float) -> Apparatus:
	app.ctx_overrides = {"pol": "pol2"}
	place_on(app, BBO_POS, IDLER_END, t)
	idler_path.append(app)
	return app


func finish_layout() -> void:
	beam_paths = [pump_path, [bbo] + signal_path, [bbo] + idler_path]
	# three label heights along the dense arms to limit overlap
	var i := 0
	for app in signal_path + idler_path:
		if app._label3d:
			app._label3d.position.y = BEAM_HEIGHT + 0.06 + 0.03 * (i % 3)
		i += 1
	# counting electronics beside the idler arm; its display mirrors the acquisition
	counter_display = place_decor(Optics.CoincidenceCounter.new("CC"), 0.52, -0.26, 180.0)
	camera_rig.set_home(Vector3(-0.05, BEAM_HEIGHT, 0.0), 1.5, 150.0, 26.0)
