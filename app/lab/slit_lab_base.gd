class_name SlitLabBase
extends LabBase
## Shared machinery for the slit experiments (2, 3, 5, 6, 7): screen geometry from the
## mask, the predicted profile, the glowing screen plane, the PatternPlot and CSV overlays.

var mask: Optics.SlitMask
var scanner: Optics.ScanningDetector
var screen_plane: ScreenPlane
var plot: PatternPlot
var distance_m := 0.5          # slit → detector distance (lens focal length in far-field mode)
var wavelength_nm := 405.0
var post_select: Dictionary = {}   # coincidence / alive condition for the main curve
var overlay_options: Array = []    # [{name, file, pos_col, count_col, window, centre_um, average}]
var overlay_index := 0
var _overlay_button: OptionButton
var _fit_scale := true
var _summary_rows: Array = []  # [[key, value]] filled by subclasses before plotting
var last_profile: QuagmireProfile
var last_scale := 1.0


func setup_slit_lab(p_mask: Optics.SlitMask, p_scanner: Optics.ScanningDetector, p_wavelength_nm: float, p_distance_m: float) -> void:
	mask = p_mask
	scanner = p_scanner
	wavelength_nm = p_wavelength_nm
	distance_m = p_distance_m
	scanner.set_param("distance", p_distance_m, false)
	controller.ctx["wavelength"] = wavelength_nm
	controller.finish_hook = Callable(self, "_finish")
	screen_plane = ScreenPlane.new()
	screen_plane.position = Vector3(scanner.position.x - 0.012, BEAM_HEIGHT, 0.0)
	screen_plane.rotation_degrees = Vector3(0, 90, 0)
	add_child(screen_plane)


func set_overlays(options: Array) -> void:
	overlay_options = options


## Alive condition for the signal photon by default.
func alive_pred() -> Dictionary:
	if post_select.is_empty():
		return {"alive": PackedStringArray([controller.ctx["pol"]])}
	return post_select


func _finish(sys: QuagmireSystem, ctx: Dictionary) -> Dictionary:
	distance_m = float(scanner.get_param("distance"))
	var geom := QuagmireScreen.new()
	geom.set_double_slit(wavelength_nm * 1e-9, float(mask.get_param("width")) * 1e-6,
		float(mask.get_param("separation")) * 1e-6, distance_m, "A", "B")
	var half := float(scanner.get_param("range")) * 1e-3
	var ys := QuagmireScreen.linspace(half, 481)
	var prof: QuagmireProfile = sys.screen_profile(ctx["path"], geom, ys, alive_pred())
	if prof == null:
		return {}
	prof = prof.box_convolve(float(scanner.get_param("slit")) * 1e-6)
	last_profile = prof
	return {"profile": prof, "ys": ys, "geometry": geom}


func on_rebuilt(_snapshots: Array, result: Dictionary) -> void:
	clear_results()
	if not result.has("profile"):
		return
	var prof: QuagmireProfile = result["profile"]
	var ys: PackedFloat64Array = prof.ys()
	var intensity: PackedFloat64Array = prof.intensity()
	var incoherent: PackedFloat64Array = prof.incoherent()
	# overlay + scale
	var overlay := _load_overlay()
	last_scale = 1.0
	if not overlay.is_empty() and _fit_scale and prof.max() > 0.0:
		last_scale = float(overlay["peak"]) / prof.max()
	var xs_mm := PackedFloat64Array()
	var model := PackedFloat64Array()
	var env := PackedFloat64Array()
	for i in ys.size():
		xs_mm.append(ys[i] * 1000.0)
		model.append(intensity[i] * last_scale)
		env.append(incoherent[i] * last_scale)
	# detector readout at its current position
	var pos_m := float(scanner.get_param("position")) * 1e-3
	var rate := _sample(ys, intensity, pos_m) * last_scale
	scanner.last_rate = rate
	scanner.refresh_visual()
	screen_plane.set_profile(ys, intensity, Palette.wavelength_to_color(wavelength_nm) if Palette.is_visible(wavelength_nm) else Color(0.9, 0.2, 0.25), float(scanner.get_param("range")) * 1e-3)

	# top row: overlay chooser + rows
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	var lbl := Label.new()
	lbl.text = "Lab data overlay"
	lbl.theme_type_variation = "Muted"
	top.add_child(lbl)
	_overlay_button = OptionButton.new()
	_overlay_button.add_item("none")
	for o in overlay_options:
		_overlay_button.add_item(str(o["name"]))
	_overlay_button.selected = overlay_index
	_overlay_button.item_selected.connect(func(i: int) -> void:
		overlay_index = i
		controller.mark_dirty())
	top.add_child(_overlay_button)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	var vis := Label.new()
	vis.text = "visibility %.2f" % prof.visibility()
	vis.theme_type_variation = "Mono"
	vis.add_theme_color_override("font_color", Palette.ACCENT_SOFT)
	top.add_child(vis)
	var rate_l := Label.new()
	rate_l.text = "D1 @ %.2f mm: %d /s" % [pos_m * 1000.0, roundi(rate)]
	rate_l.theme_type_variation = "Mono"
	top.add_child(rate_l)
	add_result_control(top)
	for row in _summary_rows:
		add_result_row(row[0], row[1])

	plot = PatternPlot.new()
	plot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plot.custom_minimum_size = Vector2(0, 170)
	plot.x_label = "distance on the screen (mm)"
	plot.y_label = "counts / s" if not overlay.is_empty() else "relative intensity"
	var series := [
		{"name": "quantum prediction", "xs": xs_mm, "ys": model, "color": Palette.ACCENT_SOFT, "width": 2.2},
		{"name": "no-interference envelope", "xs": xs_mm, "ys": env, "color": Color(Palette.TEXT_DIM, 0.8), "dashed": true, "width": 1.5},
	]
	plot.set_series(series)
	if not overlay.is_empty():
		plot.set_points([{"xs": overlay["xs"], "ys": overlay["ys"], "color": Palette.PINK, "radius": 2.5}])
	# detector marker
	var marker := PackedFloat64Array([pos_m * 1000.0, pos_m * 1000.0])
	var marker_y := PackedFloat64Array([0.0, plot.y_range.y])
	series.append({"name": "detector", "xs": marker, "ys": marker_y, "color": Palette.WARNING, "width": 1.0, "dashed": true})
	plot.set_series(series)
	add_result_control(plot)


func _load_overlay() -> Dictionary:
	if overlay_index <= 0 or overlay_index > overlay_options.size():
		return {}
	var o: Dictionary = overlay_options[overlay_index - 1]
	var scan := LabData.load_scan(o["file"], int(o.get("pos_col", 0)), int(o.get("count_col", 1)), float(o.get("window", 1.0)), float(o.get("centre_um", 0.0)))
	if bool(o.get("average", false)):
		scan = LabData.average_by_position(scan)
	return scan


static func _sample(ys: PackedFloat64Array, vals: PackedFloat64Array, x: float) -> float:
	var n := ys.size()
	if n == 0:
		return 0.0
	if x <= ys[0]:
		return vals[0]
	if x >= ys[n - 1]:
		return vals[n - 1]
	var t := (x - ys[0]) / (ys[n - 1] - ys[0]) * (n - 1)
	var i := int(t)
	return lerpf(vals[i], vals[mini(i + 1, n - 1)], t - i)
