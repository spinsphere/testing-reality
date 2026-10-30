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
var result: Dictionary = {}  # free-form, filled by hooks (e.g. {"detector_probability": 0.125})
## Optional hook called after the chain: `Callable(sys, ctx) -> Dictionary` to compute profiles etc.
var finish_hook: Callable
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
	var label_map := {}
	for l in ctx["live"]:
		label_map["%s/%s" % [ctx["pol"], l]] = l
	var stage := 0
	var alive := 1.0
	for app in components:
		app.apply(system, ctx)
		if app is Optics.Laser:
			alive = 1.0
		elif system.get_properties().size() > 0:
			alive = system.probability({"alive": PackedStringArray([ctx["pol"]])})
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


## Probability that a photon survives up to and including `index`.
func alive_after(index: int) -> float:
	if index < 0 or index >= snapshots.size():
		return 1.0
	return float(snapshots[index]["alive"])
