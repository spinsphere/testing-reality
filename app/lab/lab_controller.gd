class_name LabController
extends Node
## Rebuilds the quantum state from the apparatus chain whenever a parameter changes, and
## publishes per-stage snapshots for the HUD, beam intensities and detector results.

signal rebuilt(snapshots: Array, result: Dictionary)

## Ordered apparatus along the beam.
var components: Array[Apparatus] = []
## Shared naming context passed to every apparatus.
var ctx: Dictionary = {"pol": "pol", "path": "path", "live": PackedStringArray(["↔", "↕"]), "wavelength": 405.0}
## Last build.
var system: QuagmireSystem
var snapshots: Array = []   # [{label, stage: "Ψ0", ket, alive, apparatus}]
var alive_by_apparatus: Dictionary = {}
var result: Dictionary = {}  # free-form, filled by hooks (e.g. {"detector_probability": 0.125})
## Optional hook called after the chain: `Callable(sys, ctx) -> Dictionary` to compute profiles etc.
var finish_hook: Callable
## Source state read from the chain: the laser's shutter and power, and the SPDC source's
## pair rate when there is one. `rate_scale()` is what every count rate is multiplied by.
var source_on := true
var power := 1000.0
var _dirty := false
var _seed := 1234


func add(apparatus: Apparatus) -> Apparatus:
	components.append(apparatus)
	apparatus.param_changed.connect(func(_n: String, _v: Variant) -> void: mark_dirty())
	return apparatus


func mark_dirty() -> void:
	if _dirty:
		return
	_dirty = true
	rebuild.call_deferred()


func rebuild() -> void:
	_dirty = false
	system = QuagmireSystem.with_seed(_seed)
	snapshots.clear()
	alive_by_apparatus.clear()
	var label_map := {}
	for l in ctx["live"]:
		label_map["%s/%s" % [ctx["pol"], l]] = l
	var stage := 0
	var alive := 1.0
	source_on = true
	for app in components:
		var c := ctx.duplicate()
		c.merge(app.ctx_overrides, true)
		app.apply(system, c)
		if app is Optics.Laser:
			alive = 1.0
			source_on = (app as Optics.Laser).is_on()
			power = float(app.get_param("power"))
		elif _has_property(c["pol"]):
			alive = system.probability({"alive": PackedStringArray([c["pol"]])})
		if app is Optics.SPDCSource:
			power = float(app.get_param("pairs"))
		alive_by_apparatus[app] = alive
		snapshots.append({
			"label": app.label,
			"stage": "Ψ%d" % stage,
			"ket": _pretty_ket(system, label_map),
			"alive": alive,
			"apparatus": app,
		})
		app.refresh_visual()
		stage += 1
	result = {}
	if finish_hook.is_valid():
		result = finish_hook.call(system, ctx)
	# the kets are deterministic; the draws (photon fates) should not replay after each rebuild
	system.reseed(int(Time.get_ticks_usec()))
	rebuilt.emit(snapshots, result)


## Ket text with property names hidden and sinks written as |lost P1⟩.
func _pretty_ket(sys: QuagmireSystem, label_map: Dictionary) -> String:
	var map := label_map.duplicate()
	for p in sys.get_properties():
		var labels: PackedStringArray = p["labels"]
		for l in labels:
			if l.begins_with("lost@"):
				map["%s/%s" % [p["name"], l]] = "lost " + l.trim_prefix("lost@")
	return sys.ket_text_mapped(map)


func _has_property(name: String) -> bool:
	for p in system.get_properties():
		if p["name"] == name:
			return true
	return false


## Fraction of the source's photons still in the beam after `app` (0 with the shutter closed).
func alive_after_apparatus(app: Apparatus) -> float:
	return float(alive_by_apparatus.get(app, 1.0)) if source_on else 0.0


## Fraction of the source's photons that survive up to and including `index`.
func alive_after(index: int) -> float:
	if not source_on:
		return 0.0
	if index < 0 or index >= snapshots.size():
		return 1.0
	return float(snapshots[index]["alive"])


## Photons (or pairs) per second entering the experiment; 0 while the shutter is closed.
func rate_scale() -> float:
	return power if source_on else 0.0
