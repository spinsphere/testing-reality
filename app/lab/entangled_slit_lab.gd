class_name EntangledSlitLab
extends EntangledLabBase
## Experiments 5, 6 and 7: entangled pairs, the signal photon through the marked double slit
## with an optional eraser P1 and a scanning D1; the idler through an optional P2 to D2.

var pa: Optics.Polarizer
var pb: Optics.Polarizer
var p1: Optics.Polarizer
var p2: Optics.Polarizer
var wall: Optics.Wall
var d2: Optics.Detector
var idler_path_prop := "idler_path"


func _init() -> void:
	results_width = 1000.0


## `slit_to_detector_m` is the effective slit → D1 distance L; the mask is placed on the
## arm so the bench geometry matches it (the fringe spacing λL/d of the site's scans fixes L).
func build_entangled_slit(with_p2: bool, with_wall: bool, slit_to_detector_m: float = 0.43) -> void:
	build_pump()
	var arm := signal_arm_length()
	var slit_t := 1.0 - slit_to_detector_m / arm
	on_signal(Optics.Lens.new("L4", 500.0), slit_t - 0.14)
	var m := on_signal(Optics.SlitMask.new("SLIT", 200.0, 400.0), slit_t)
	# polarizer films glued over the two slits (the site: "mounted linear polarizers")
	pa = on_signal(Optics.Polarizer.new("PA", 90.0, {"is": {"path": "A"}}, "polarizer_film"), slit_t + 0.012 / arm, 0.0045)
	pb = on_signal(Optics.Polarizer.new("PB", 0.0, {"is": {"path": "B"}}, "polarizer_film"), slit_t + 0.012 / arm, -0.0045)
	pa.display_name = "Polarizer film on slit A"
	pb.display_name = "Polarizer film on slit B"
	p1 = on_signal(Optics.Polarizer.new("P1", 45.0), slit_t + 0.5 * (1.0 - slit_t))
	p1.display_name = "Eraser polarizer on the signal"
	var d := on_signal(Optics.ScanningDetector.new("D1", 2.0), 1.0)
	on_idler(Optics.Lens.new("L5", 500.0), 0.25)
	if with_wall:
		wall = on_idler(Optics.Wall.new("WALL"), 0.45)
	if with_p2:
		p2 = on_idler(Optics.Polarizer.new("P2", 45.0), 0.62)
		p2.display_name = "Idler polarizer (basis choice)"
	d2 = on_idler(Optics.Detector.new("D2"), 1.0)
	d2.extra_alive = PackedStringArray(["idler_path"])  # a wall on the idler arm stops its clicks
	d2.description = "Stationary detector for the idler photon. Its clicks are compared with D1's in a coincidence counter (10 ns window)."
	finish_layout()
	setup_slit_lab(m, d, 810.0, slit_to_detector_m)
	wavelength_nm = 810.0
	controller.ctx["wavelength"] = 405.0
	post_select = {"alive": PackedStringArray(["pol1"])}
	coincidence_pred = {"alive": PackedStringArray(["pol1", "pol2"]), "is": {idler_path_prop: "D2"}}


## The SPDC source also creates the idler path label so later elements can route it.
func _ready() -> void:
	super()


func _finish(sys: QuagmireSystem, ctx: Dictionary) -> Dictionary:
	return super(sys, ctx)
