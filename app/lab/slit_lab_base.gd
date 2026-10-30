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
var post_select: Dictionary = {}   # alive condition for the singles curve (default: signal alive)
var coincidence_pred: Dictionary = {}  # when set, a second (coincidence) profile is computed
var overlay_options: Array = []    # [{name, file, pos_col, count_col, window, centre_um, average}]
var overlay_index := 0
var _overlay_button: OptionButton
var _fit_scale := true
var _summary_rows: Array = []  # [[key, value]] filled by subclasses before plotting
var last_profile: QuagmireProfile
var last_scale := 1.0

# motorised detector scan: count `scan_dwell` seconds at each of `scan_steps` positions
var scan_running := false
var scan_points: Array = []   # [{x_mm, n, nc}] counts of D1 and of D1·D2 at each position
var scan_steps := 41
var scan_dwell := 0.5
var _scan_timer := 0.0
var _scan_index := 0


func setup_slit_lab(p_mask: Optics.SlitMask, p_scanner: Optics.ScanningDetector, p_wavelength_nm: float, p_distance_m: float) -> void:
	mask = p_mask
	scanner = p_scanner
	wavelength_nm = p_wavelength_nm
	distance_m = p_distance_m
	scanner.set_param("distance", p_distance_m, false)
	controller.ctx["wavelength"] = wavelength_nm
	controller.finish_hook = Callable(self, "_finish")
	screen_plane = ScreenPlane.new()
	add_child(screen_plane)
	screen_plane.transform = scanner.transform.translated_local(Vector3(-0.012, BEAM_HEIGHT, 0.0))
	screen_plane.rotate_object_local(Vector3.UP, deg_to_rad(90.0))


func set_overlays(options: Array) -> void:
	overlay_options = options


func scan_start() -> void:
	scan_points.clear()
	_scan_index = 0
	_scan_timer = 0.0
	scan_running = true
	scanner.set_param("position", -float(scanner.get_param("range")))
	controller.mark_dirty()


func scan_stop() -> void:
	scan_running = false
	controller.mark_dirty()


func scan_clear() -> void:
	scan_running = false
	scan_points.clear()
	controller.mark_dirty()


func _process(delta: float) -> void:
	super(delta)
	if scan_running:
		scan_advance(delta)


## Count for `dt` more seconds at the current position; once `scan_dwell` is reached, record
## the point and step the detector. At most one point per call (the rates must be rebuilt
## between positions).
func scan_advance(dt: float) -> void:
	_scan_timer += dt
	if _scan_timer < scan_dwell:
		return
	_scan_timer = 0.0
	var n := 0
	var nc := 0
	for ch in acquisition_channels():
		if ch["name"] == scanner.label:
			n = _poisson(float(ch["rate"]) * scan_dwell)
		elif ch["name"] == "D1·D2":
			nc = _poisson(float(ch["rate"]) * scan_dwell)
	scan_points.append({"x_mm": float(scanner.get_param("position")), "n": n, "nc": nc})
	_scan_index += 1
	if _scan_index >= scan_steps:
		scan_running = false
		controller.mark_dirty()
		return
	var half := float(scanner.get_param("range"))
	scanner.set_param("position", lerpf(-half, half, float(_scan_index) / float(scan_steps - 1)))


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
	var slit_w := float(scanner.get_param("slit")) * 1e-6
	prof = prof.box_convolve(slit_w)
	last_profile = prof
	var out := {"profile": prof, "ys": ys, "geometry": geom}
	out["singles_scale"] = _rate_scale_for(prof, slit_w, sys.probability(alive_pred()))
	if not coincidence_pred.is_empty():
		var cp: QuagmireProfile = sys.screen_profile(ctx["path"], geom, ys, coincidence_pred)
		if cp != null:
			cp = cp.box_convolve(slit_w)
			out["coincidence"] = cp
			out["coinc_scale"] = _rate_scale_for(cp, slit_w, sys.probability(coincidence_pred))
	return out


## Counts per second per unit of profile intensity: the source rate × the probability that the
## photon is counted at all × the share of the pattern the detector slit covers (slit / ∫I dy).
func _rate_scale_for(prof: QuagmireProfile, slit_w: float, p_counted: float) -> float:
	var ys: PackedFloat64Array = prof.ys()
	var inten: PackedFloat64Array = prof.intensity()
	var integral := 0.0
	for i in range(1, ys.size()):
		integral += 0.5 * (inten[i] + inten[i - 1]) * (ys[i] - ys[i - 1])
	if integral <= 0.0:
		return 0.0
	return controller.rate_scale() * p_counted * slit_w / integral


## Acquisition channels: the scanning detector at its current position, the coincidences
## (when the lab has an idler), and every fixed detector.
func acquisition_channels() -> Array:
	var out: Array = []
	var r: Dictionary = controller.result
	if r.has("profile"):
		var pos := float(scanner.get_param("position")) * 1e-3
		var prof: QuagmireProfile = r["profile"]
		out.append({"name": scanner.label, "rate": _sample(prof.ys(), prof.intensity(), pos) * float(r.get("singles_scale", 0.0))})
		if r.has("coincidence"):
			var cp: QuagmireProfile = r["coincidence"]
			out.append({"name": "D1·D2", "rate": _sample(cp.ys(), cp.intensity(), pos) * float(r.get("coinc_scale", 0.0))})
	out.append_array(super())
	return out


func on_rebuilt(_snapshots: Array, result: Dictionary) -> void:
	clear_results()
	if not result.has("profile"):
		return
	var prof: QuagmireProfile = result["profile"]
	var ys: PackedFloat64Array = prof.ys()
	var pos_m := float(scanner.get_param("position")) * 1e-3
	var overlay := _load_overlay()
	var target := str(overlay.get("target", "singles"))

	# singles, in counts / s from the source rate (lab points are scaled to the predicted peak)
	var s_overlay := overlay if target == "singles" else {}
	var s_scale := float(result.get("singles_scale", 0.0))
	var rate := _sample(ys, prof.intensity(), pos_m) * s_scale
	scanner.last_rate = rate
	scanner.refresh_visual()
	var light := Palette.wavelength_to_color(wavelength_nm) if Palette.is_visible(wavelength_nm) else Color(0.9, 0.2, 0.25)
	screen_plane.set_profile(ys, prof.intensity(), light, float(scanner.get_param("range")) * 1e-3)

	var top := HFlowContainer.new()
	top.add_theme_constant_override("h_separation", 12)
	var lbl := Label.new()
	lbl.text = "Lab data"
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
	var vis := Label.new()
	vis.text = "singles visibility %.2f" % prof.visibility()
	vis.theme_type_variation = "Mono"
	vis.add_theme_color_override("font_color", Palette.ACCENT_SOFT)
	top.add_child(vis)
	if result.has("coincidence"):
		var cvis := Label.new()
		cvis.text = "coincidence visibility %.2f" % (result["coincidence"] as QuagmireProfile).visibility()
		cvis.theme_type_variation = "Mono"
		cvis.add_theme_color_override("font_color", Palette.PINK)
		top.add_child(cvis)
	var rate_l := Label.new()
	rate_l.text = "D1 @ %.2f mm: %d /s" % [pos_m * 1000.0, roundi(rate)]
	rate_l.theme_type_variation = "Mono"
	top.add_child(rate_l)
	var scan_btn := Button.new()
	scan_btn.theme_type_variation = "GhostButton"
	if scan_running:
		scan_btn.text = "■  Stop scan  (%d / %d)" % [_scan_index, scan_steps]
		scan_btn.pressed.connect(scan_stop)
	else:
		scan_btn.text = "▶  Scan D1  (%d points × %.1f s)" % [scan_steps, scan_dwell]
		scan_btn.pressed.connect(scan_start)
	scan_btn.tooltip_text = "Step the detector across the pattern and count at each position, like the real motorised scan. Green points: your counts."
	top.add_child(scan_btn)
	if not scan_points.is_empty() and not scan_running:
		var clear_btn := Button.new()
		clear_btn.theme_type_variation = "GhostButton"
		clear_btn.text = "clear scan"
		clear_btn.pressed.connect(scan_clear)
		top.add_child(clear_btn)
	if not overlay.is_empty():
		var note := Label.new()
		note.text = "lab points scaled to the predicted peak"
		note.theme_type_variation = "Muted"
		top.add_child(note)
	add_result_control(top)
	for row in _summary_rows:
		add_result_row(row[0], row[1])

	var plots := HBoxContainer.new()
	plots.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plots.add_theme_constant_override("separation", 8)
	plot = _make_plot(prof, s_scale, s_overlay, pos_m, "D1 singles" if result.has("coincidence") else "", Palette.ACCENT_SOFT, "n")
	plots.add_child(plot)
	if result.has("coincidence"):
		var c_overlay := overlay if target == "coinc" else {}
		var cprof: QuagmireProfile = result["coincidence"]
		var cplot := _make_plot(cprof, float(result.get("coinc_scale", 0.0)), c_overlay, pos_m, "D1·D2 coincidences", Palette.PINK, "nc")
		plots.add_child(cplot)
	add_result_control(plots)


func _make_plot(prof: QuagmireProfile, scale: float, overlay: Dictionary, pos_m: float, title: String, color: Color, scan_key: String = "n") -> PatternPlot:
	var ys: PackedFloat64Array = prof.ys()
	var intensity: PackedFloat64Array = prof.intensity()
	var incoherent: PackedFloat64Array = prof.incoherent()
	var xs_mm := PackedFloat64Array()
	var model := PackedFloat64Array()
	var env := PackedFloat64Array()
	for i in ys.size():
		xs_mm.append(ys[i] * 1000.0)
		model.append(intensity[i] * scale)
		env.append(incoherent[i] * scale)
	var p := PatternPlot.new()
	p.title = title
	p.size_flags_vertical = Control.SIZE_EXPAND_FILL
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.custom_minimum_size = Vector2(0, 170)
	p.x_label = "distance on the screen (mm)"
	p.y_label = "counts / s"
	var series := [
		{"name": "quantum prediction", "xs": xs_mm, "ys": model, "color": color, "width": 2.2},
		{"name": "no-interference envelope", "xs": xs_mm, "ys": env, "color": Color(Palette.TEXT_DIM, 0.8), "dashed": true, "width": 1.5},
	]
	p.set_series(series)
	var pts: Array = []
	if not overlay.is_empty():
		# the lab's counts are in its own units: scale them so their peak meets the prediction's
		var peak := 0.0
		for v in model:
			peak = maxf(peak, v)
		var k := peak / float(overlay["peak"]) if float(overlay.get("peak", 0.0)) > 0.0 and peak > 0.0 else 1.0
		var oys := PackedFloat64Array()
		for v in overlay["ys"]:
			oys.append(float(v) * k)
		pts.append({"xs": overlay["xs"], "ys": oys, "color": Palette.PINK if color != Palette.PINK else Palette.WARNING, "radius": 2.5})
	if not scan_points.is_empty():
		# the user's own scan: counts per dwell → counts / s
		var sx := PackedFloat64Array()
		var sy := PackedFloat64Array()
		for pt in scan_points:
			sx.append(float(pt["x_mm"]))
			sy.append(float(pt[scan_key]) / scan_dwell)
		pts.append({"xs": sx, "ys": sy, "color": Palette.SUCCESS, "radius": 3.0})
	if not pts.is_empty():
		p.set_points(pts)
	var marker := PackedFloat64Array([pos_m * 1000.0, pos_m * 1000.0])
	var marker_y := PackedFloat64Array([0.0, p.y_range.y])
	series.append({"name": "detector", "xs": marker, "ys": marker_y, "color": Palette.WARNING, "width": 1.0, "dashed": true})
	p.set_series(series)
	return p


func _load_overlay() -> Dictionary:
	if overlay_index <= 0 or overlay_index > overlay_options.size():
		return {}
	var o: Dictionary = overlay_options[overlay_index - 1]
	var scan := LabData.load_scan(o["file"], int(o.get("pos_col", 0)), int(o.get("count_col", 1)), float(o.get("window", 1.0)), float(o.get("centre_um", 0.0)), o.get("count_cols", []))
	if bool(o.get("average", false)):
		scan = LabData.average_by_position(scan)
	if not scan.is_empty():
		scan["target"] = o.get("target", "singles")
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
