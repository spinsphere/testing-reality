class_name ScreenPlane
extends MeshInstance3D
## A small glowing "screen" at the detector plane that shows the predicted pattern as light.

var _image: Image
var _texture: ImageTexture
var _mat: StandardMaterial3D
var half_width := 0.003  # metres (scan half-range)


func _init() -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(0.006, 0.012)
	mesh = quad
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mat.emission_enabled = true
	_mat.emission_energy_multiplier = 1.6
	material_override = _mat
	_image = Image.create(256, 8, false, Image.FORMAT_RGBA8)
	_texture = ImageTexture.create_from_image(_image)
	_mat.albedo_texture = _texture
	_mat.emission_texture = _texture
	_mat.albedo_color = Color.WHITE
	_mat.emission = Color.WHITE


## `ys` are positions across the screen (m), `intensity` the pattern, `color` the light colour.
func set_profile(ys: PackedFloat64Array, intensity: PackedFloat64Array, color: Color, p_half_width: float) -> void:
	half_width = p_half_width
	(mesh as QuadMesh).size = Vector2(half_width * 2.0, 0.012)
	var n := ys.size()
	var peak := 0.0
	for v in intensity:
		peak = maxf(peak, v)
	for px in 256:
		var x := lerpf(-half_width, half_width, float(px) / 255.0)
		var v := 0.0
		if n > 1 and peak > 0.0:
			var t := (x - ys[0]) / (ys[n - 1] - ys[0])
			var fi := clampf(t * (n - 1), 0.0, n - 1.0)
			var i0 := int(fi)
			var i1 := mini(i0 + 1, n - 1)
			v = lerpf(intensity[i0], intensity[i1], fi - i0) / peak
		var c := Color(color.r * v, color.g * v, color.b * v, 1.0)
		for py in 8:
			_image.set_pixel(px, py, c)
	_texture.update(_image)
