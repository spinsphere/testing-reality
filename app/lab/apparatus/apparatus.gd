class_name Apparatus
extends Node3D
## Base class for a piece of optical equipment on the table.
##
## Subclasses declare `params` (what the student can adjust), implement `apply()` to act on
## the QuagmireSystem, and optionally override `summary()` for the floating label.
## Models come from `app/assets/models/<model>.glb`; a placeholder is drawn if missing.

signal param_changed(name: String, value: Variant)
signal selected_changed(is_selected: bool)

## Short id used in the state display, e.g. "P1", "L1", "D1".
@export var label := ""
## Human-readable name, e.g. "Polarizer".
@export var display_name := ""
## glTF model name under res://assets/models/ (without extension).
@export var model := ""
## Height of the optical axis above the table (metres).
@export var beam_height := 0.10
## Optional explanation shown in the inspector.
@export_multiline var description := ""

## Parameter specs: name -> {label, type: "float"|"int"|"bool"|"enum", min, max, step, unit,
## options (for enum), value, help}
var params: Dictionary = {}
var is_selected := false
var model_root: Node3D
var _placeholder: MeshInstance3D
var _label3d: Label3D
var _highlight: MeshInstance3D
var _body: StaticBody3D


func _ready() -> void:
	_load_model()
	_make_pick_body()
	_make_label()
	refresh_visual()


# ---------------------------------------------------------------- params

func add_param(name: String, spec: Dictionary) -> void:
	params[name] = spec


func get_param(name: String) -> Variant:
	return params.get(name, {}).get("value", null)


func set_param(name: String, value: Variant, emit := true) -> void:
	if not params.has(name):
		push_warning("%s has no param %s" % [display_name, name])
		return
	var spec: Dictionary = params[name]
	match spec.get("type", "float"):
		"float":
			value = clampf(float(value), float(spec.get("min", -INF)), float(spec.get("max", INF)))
		"int":
			value = clampi(int(value), int(spec.get("min", -2147483648)), int(spec.get("max", 2147483647)))
	if spec.get("value") == value:
		return
	spec["value"] = value
	refresh_visual()
	if emit:
		param_changed.emit(name, value)


## Called by the lab controller, in beam order. `ctx` carries shared names:
## {"pol": "pol", "path": "path", "live": PackedStringArray(["↔","↕"]), "wavelength": nm}.
func apply(_sys: QuagmireSystem, _ctx: Dictionary) -> void:
	pass


## Whether this element is a detector (ends the beam).
func is_detector() -> bool:
	return false


## One-line summary for the 3D label, e.g. "P1 · 45°".
func summary() -> String:
	return label


## Update the model (rotations etc.) from params. Override and call super.
func refresh_visual() -> void:
	if _label3d:
		_label3d.text = summary()


func set_selected(v: bool) -> void:
	if is_selected == v:
		return
	is_selected = v
	if _highlight:
		_highlight.visible = v
	if _label3d:
		_label3d.modulate = Palette.PINK if v else Palette.TEXT
	selected_changed.emit(v)


# ---------------------------------------------------------------- visuals

func _load_model() -> void:
	model_root = Node3D.new()
	model_root.name = "Model"
	add_child(model_root)
	var path := "res://assets/models/%s.glb" % model
	if model != "" and ResourceLoader.exists(path):
		var scene: PackedScene = load(path)
		var inst := scene.instantiate()
		model_root.add_child(inst)
	else:
		_placeholder = _make_placeholder()
		model_root.add_child(_placeholder)


## Simple stand-in geometry so labs work before the Blender models exist.
func _make_placeholder() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0254
	mesh.bottom_radius = 0.0254
	mesh.height = 0.006
	mi.mesh = mesh
	mi.rotation_degrees = Vector3(0, 0, 90)  # axis along X (beam)
	mi.position = Vector3(0, beam_height, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.12, 0.16)
	mat.metallic = 0.8
	mat.roughness = 0.4
	mi.material_override = mat
	# a post
	var post := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 0.006
	pm.bottom_radius = 0.006
	pm.height = beam_height - 0.025
	post.mesh = pm
	post.position = Vector3(0, (beam_height - 0.025) / 2.0, 0)
	post.material_override = mat
	mi.add_child(post)
	post.rotation_degrees = Vector3(0, 0, -90)
	post.position = Vector3(-(beam_height - 0.025) / 2.0 - 0.003, 0, 0) # compensate parent rotation
	return mi


func _make_pick_body() -> void:
	_body = StaticBody3D.new()
	_body.collision_layer = 2
	_body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var aabb := _compute_aabb()
	box.size = aabb.size.max(Vector3(0.03, 0.03, 0.03))
	shape.shape = box
	shape.position = aabb.get_center()
	_body.add_child(shape)
	_body.set_meta("apparatus", self)
	add_child(_body)
	# selection highlight: a translucent box slightly larger than the model
	_highlight = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = box.size * 1.08 + Vector3(0.01, 0.01, 0.01)
	_highlight.mesh = bm
	_highlight.position = aabb.get_center()
	var hm := StandardMaterial3D.new()
	hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hm.albedo_color = Color(Palette.PINK, 0.18)
	hm.cull_mode = BaseMaterial3D.CULL_DISABLED
	_highlight.material_override = hm
	_highlight.visible = false
	add_child(_highlight)


func _compute_aabb() -> AABB:
	var aabb := AABB(Vector3(-0.02, 0.0, -0.02), Vector3(0.04, beam_height + 0.03, 0.04))
	var first := true
	for mi in _find_meshes(model_root):
		var local := mi.get_aabb()
		var xf := model_root.global_transform.affine_inverse() * mi.global_transform
		var box := xf * local
		if first:
			aabb = box
			first = false
		else:
			aabb = aabb.merge(box)
	return aabb


func _find_meshes(n: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_find_meshes(c))
	return out


func _make_label() -> void:
	_label3d = Label3D.new()
	_label3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label3d.no_depth_test = true
	_label3d.font_size = 40
	_label3d.pixel_size = 0.0006
	_label3d.outline_size = 8
	_label3d.modulate = Palette.TEXT
	_label3d.position = Vector3(0, beam_height + 0.075, 0)
	_label3d.font = ThemeBuilder.symbol()
	add_child(_label3d)
