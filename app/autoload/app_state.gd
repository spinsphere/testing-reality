extends Node
## Global application state: navigation requests, progress, settings.
## Autoloaded as `AppState`.

signal route_changed(route: Dictionary)
signal progress_changed

const SAVE_PATH := "user://progress.json"

## Chapter registry, in site order. `lab` is the lab scene for the chapter, if any.
const CHAPTERS: Array[Dictionary] = [
	{"id": "intro", "kicker": "Introduction", "title": "Quantum for everyone",
	 "subtitle": "The quantum formalism: learn the basics for everyone", "lab": ""},
	{"id": "exp1", "kicker": "Experiment 1", "title": "Polarizers",
	 "subtitle": "Polarizers and the three-polarizer paradox", "lab": "res://labs/exp1/exp1_lab.tscn"},
	{"id": "exp2", "kicker": "Experiment 2", "title": "Single and double slit",
	 "subtitle": "Where does interference come from, if each photon travels alone?", "lab": "res://labs/exp2/exp2_lab.tscn"},
	{"id": "exp3", "kicker": "Experiment 3", "title": "Polarized double slit",
	 "subtitle": "Which-way information and the quantum eraser", "lab": "res://labs/exp3/exp3_lab.tscn"},
	{"id": "exp4", "kicker": "Experiment 4", "title": "Entanglement and Bell state",
	 "subtitle": "Photon pairs from a crystal, correlated beyond anything classical", "lab": "res://labs/exp4/exp4_lab.tscn"},
	{"id": "exp5", "kicker": "Experiment 5", "title": "Putting it all together",
	 "subtitle": "Entangled photons meet the polarized double slit", "lab": "res://labs/exp5/exp5_lab.tscn"},
	{"id": "exp6", "kicker": "Experiment 6", "title": "Delayed choice quantum eraser",
	 "subtitle": "Can a choice made now change a pattern recorded earlier?", "lab": "res://labs/exp6/exp6_lab.tscn"},
	{"id": "exp7", "kicker": "Experiment 7", "title": "Detecting, but not recording",
	 "subtitle": "Walls, unplugged detectors, flies and other what-ifs", "lab": "res://labs/exp7/exp7_lab.tscn"},
]

var current_route: Dictionary = {"screen": "hub"}
var progress: Dictionary = {}  # chapter id -> {"page": int, "pages_seen": int, "lab_visited": bool}
var settings: Dictionary = {"master_volume": 0.8, "reduce_motion": false, "show_latex": false}


func _ready() -> void:
	load_progress()


## 3D quality preset: 0 low, 1 medium (default), 2 high. The old "msaa" key maps onto it.
func quality() -> int:
	return clampi(int(settings.get("quality", settings.get("msaa", 1))), 0, 2)


func chapter(id: String) -> Dictionary:
	for c in CHAPTERS:
		if c["id"] == id:
			return c
	return {}


func chapter_index(id: String) -> int:
	for i in CHAPTERS.size():
		if CHAPTERS[i]["id"] == id:
			return i
	return -1


func next_chapter_id(id: String) -> String:
	var i := chapter_index(id)
	if i >= 0 and i + 1 < CHAPTERS.size():
		return CHAPTERS[i + 1]["id"]
	return ""


## Navigate. Routes: {"screen": "hub"} | {"screen": "chapter", "id": "exp1", "page": 0}
## | {"screen": "lab", "id": "exp1"}.
func go(route: Dictionary) -> void:
	current_route = route
	route_changed.emit(route)


func go_hub() -> void:
	go({"screen": "hub"})


func go_chapter(id: String, page: int = -1) -> void:
	if page < 0:
		page = int(progress.get(id, {}).get("page", 0))
	go({"screen": "chapter", "id": id, "page": page})


func go_lab(id: String) -> void:
	mark_lab_visited(id)
	go({"screen": "lab", "id": id})


func mark_page(id: String, page: int, total: int) -> void:
	var p: Dictionary = progress.get(id, {"page": 0, "pages_seen": 0, "lab_visited": false, "total": total})
	p["page"] = page
	p["total"] = total
	p["pages_seen"] = maxi(int(p.get("pages_seen", 0)), page + 1)
	progress[id] = p
	progress_changed.emit()
	save_progress()


func mark_lab_visited(id: String) -> void:
	var p: Dictionary = progress.get(id, {"page": 0, "pages_seen": 0, "lab_visited": false})
	p["lab_visited"] = true
	progress[id] = p
	progress_changed.emit()
	save_progress()


func completion(id: String) -> float:
	var p: Dictionary = progress.get(id, {})
	var total := int(p.get("total", 0))
	if total <= 0:
		return 0.0
	return clampf(float(p.get("pages_seen", 0)) / float(total), 0.0, 1.0)


func save_progress() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"progress": progress, "settings": settings}))


func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var data: Variant = JSON.parse_string(f.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		progress = data.get("progress", {})
		for k in data.get("settings", {}):
			settings[k] = data["settings"][k]
