class_name BeamRenderer
extends Node3D
## Draws laser beam segments as additive glowing cylinders.
## `set_segments([{from: Vector3, to: Vector3, intensity: 0..1, wavelength: nm, visible_light: bool}])`.

var _pool: Array[MeshInstance3D] = []


func set_segments(segments: Array) -> void:
	while _pool.size() < segments.size() * 2:
		var mi := MeshInstance3D.new()
		mi.mesh = CylinderMesh.new()
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.no_depth_test = false
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)
		_pool.append(mi)
	for mi in _pool:
		mi.visible = false
	var i := 0
	for seg in segments:
		var from: Vector3 = seg["from"]
		var to: Vector3 = seg["to"]
		var intensity := clampf(float(seg.get("intensity", 1.0)), 0.0, 1.0)
		var nm := float(seg.get("wavelength", 405.0))
		var color := Palette.wavelength_to_color(nm)
		if not Palette.is_visible(nm):
			color = Color(0.55, 0.08, 0.1)  # "visualised" infrared: deep red, dimmer
			intensity *= 0.6
		# core
		_place(_pool[i], from, to, 0.0016, Color(color.lightened(0.45), 0.25 + 0.7 * intensity))
		# glow
		_place(_pool[i + 1], from, to, 0.006, Color(color, 0.05 + 0.35 * intensity))
		i += 2


func _place(mi: MeshInstance3D, from: Vector3, to: Vector3, radius: float, color: Color) -> void:
	var length := from.distance_to(to)
	if length <= 0.0001 or color.a <= 0.002:
		mi.visible = false
		return
	var mesh := mi.mesh as CylinderMesh
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = length
	mesh.radial_segments = 12
	mi.visible = true
	var mid := (from + to) * 0.5
	var dir := (to - from).normalized()
	var up := Vector3.UP if absf(dir.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	var basis := Basis.looking_at(dir, up)
	# CylinderMesh is along local Y; rotate so Y maps to dir.
	var fix := Basis(Vector3.RIGHT, deg_to_rad(90.0))
	mi.global_transform = Transform3D(basis * fix, mid)
	(mi.material_override as StandardMaterial3D).albedo_color = color
