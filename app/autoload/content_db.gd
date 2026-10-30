extends Node
## Loads chapter content (pages.json) and the rendered-equation index (index.json).
## Autoloaded as `ContentDB`.

var _chapters: Dictionary = {}   # id -> parsed pages.json
var _math_index: Dictionary = {} # id -> parsed index.json["equations"]


## Parsed chapter content: {"sections": [{"id", "title", "pages": [{"title", "blocks": [...]}]}]}
func chapter(id: String) -> Dictionary:
	if _chapters.has(id):
		return _chapters[id]
	var path := "res://content/%s/pages.json" % id
	var data := _load_json(path)
	if data.is_empty():
		push_warning("ContentDB: no content for chapter '%s' (%s)" % [id, path])
		data = {"sections": []}
	_chapters[id] = data
	return data


## Flat list of pages for a chapter, each with "section_id", "section_title" added.
func pages(id: String) -> Array:
	var out: Array = []
	for section in chapter(id).get("sections", []):
		for page in section.get("pages", []):
			var p: Dictionary = page.duplicate()
			p["section_id"] = section.get("id", "")
			p["section_title"] = section.get("title", "")
			out.append(p)
	return out


## Equation metadata for `eq_id` in chapter `id`: {file, png, width, height, baseline, tex}.
func equation(id: String, eq_id: String) -> Dictionary:
	if not _math_index.has(id):
		var data := _load_json("res://assets/math/%s/index.json" % id)
		_math_index[id] = data.get("equations", {})
	return _math_index[id].get(eq_id, {})


## Texture for an equation: the SVG (imported at 3x by Godot's own rasteriser, which
## handles MathJax output faithfully), with the PNG as a fallback.
func equation_texture(id: String, eq_id: String) -> Texture2D:
	var meta := equation(id, eq_id)
	if meta.is_empty():
		return null
	var base := "res://assets/math/%s/" % id
	if ResourceLoader.exists(base + meta["file"]):
		return load(base + meta["file"])
	if meta.has("png") and ResourceLoader.exists(base + meta["png"]):
		return load(base + meta["png"])
	return null


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var data: Variant = JSON.parse_string(f.get_as_text())
	return data if typeof(data) == TYPE_DICTIONARY else {}
