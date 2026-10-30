class_name LabBase
extends Node3D
## Base scene for every laboratory: dark room, lit optical table, camera rig, beam renderer,
## apparatus picking, and the HUD (state panel, inspector, results panel).
## Subclasses override `build()` to place apparatus and `on_rebuilt()` to fill the results.

const TABLE_LENGTH := 1.2
const TABLE_WIDTH := 0.6
const BEAM_HEIGHT := 0.10

var chapter_id := "exp1"
var controller: LabController
var camera_rig: LabCamera
var beams: BeamRenderer
var table_root: Node3D
var apparatus_root: Node3D
var selected: Apparatus
## Explicit beam paths for multi-arm layouts: an Array of Arrays of Apparatus. When empty,
## the controller's linear chain is used.
var beam_paths: Array = []
## Beams that leave the chain: the PBS reflection into its dump, the undepleted pump behind
## the crystal. [{from: Apparatus, to: Apparatus, wavelength, mode: "blocked"|"fixed", intensity}]
var stray_beams: Array = []

# HUD
var hud: CanvasLayer
var state_box: VBoxContainer
var inspector_box: VBoxContainer
var inspector_title: Label
var results_box: VBoxContainer
var presets_box: HBoxContainer
var hint_label: Label
var _photon_mode := false
var _photon_timer := 0.0
var _photons: Array = []  # [{mesh, path, seg, t, dies_after, kind, outcome, pair?}]
var _anim: Dictionary = {"sent": 0, "detected": {}, "coinc": 0}
var _anim_label: Label
## Stage the user is following (focus_stage): everything downstream is dimmed.
var _focus_app: Apparatus
var _ray_length := 20.0
## Width of the bottom-right results panel (labs with two plots use a wider one).
var results_width := 640.0

# acquisition: real-time counting of every channel (detectors, coincidences)
var acq_running := false
var acq_time := 0.0
var acq_counts: Dictionary = {}   # channel name -> counts so far
var acq_box: VBoxContainer
var _acq_time_label: Label
var _acq_run_btn: Button
## Optional counting electronics on the table whose display mirrors the acquisition.
var counter_display: Apparatus
var _acq_rows: Dictionary = {}   # channel name -> {value: Label, expect: Label}
## Engine instance used only as the lab's random source (Poisson counts); seeded from the
## clock so every session counts differently.
var dice: QuagmireSystem


func _ready() -> void:
	dice = QuagmireSystem.with_seed(int(Time.get_ticks_usec()))
	_build_world()
	_build_hud()
	controller = LabController.new()
	controller.name = "Controller"
	add_child(controller)
	controller.rebuilt.connect(_on_rebuilt_internal)
	build()
	_layout_apparatus()
	controller.rebuild()


# ---------------------------------------------------------------- overridables

## Place apparatus with `place(apparatus, x_metres)`; set presets with `add_preset(name, callable)`.
func build() -> void:
	pass


## Fill the results panel from `controller.result`; default shows detector probabilities.
func on_rebuilt(_snapshots: Array, _result: Dictionary) -> void:
	pass


## Channels counted while an acquisition runs: [{name, rate}] with rates in counts / s.
## Default: every point detector on the chain. Labs add coincidences or scanning detectors.
func acquisition_channels() -> Array:
	var out: Array = []
	for app in controller.components:
		if app is Optics.Detector:
			out.append({"name": app.label, "rate": controller.rate_scale() * (app as Optics.Detector).last_probability})
	return out


# ---------------------------------------------------------------- world

func _build_world() -> void:
	# quality preset (Settings): Low is meant for integrated graphics
	var q := AppState.quality()
	var vp := get_viewport()
	vp.msaa_3d = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X][q]
	vp.scaling_3d_scale = 0.75 if q == 0 else 1.0
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("#07070f")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("#3a3a6a")
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = q >= 1
	e.glow_intensity = 0.6
	e.glow_bloom = 0.1
	e.glow_hdr_threshold = 0.9
	for i in 7:  # the beams only need a small halo: keep the two finest blur levels, drop the rest
		e.set_glow_level(i, 1.0 if i < 2 else 0.0)
	e.fog_enabled = false
	env.environment = e
	add_child(env)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-55, 35, 0)
	key.light_energy = 1.6
	key.light_color = Color("#fff4e6")
	key.shadow_enabled = q >= 1
	# one orthogonal cascade covering just the table: cheaper than 4 cascades over 100 m and sharper
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	key.directional_shadow_max_distance = 4.0
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, -120, 0)
	fill.light_energy = 0.5
	fill.light_color = Color("#aab4ff")
	add_child(fill)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0.0, 1.4, 0.3)
	lamp.light_energy = 2.5
	lamp.omni_range = 4.0
	lamp.light_color = Color("#f2f0ff")
	add_child(lamp)

	table_root = Node3D.new()
	table_root.name = "Table"
	add_child(table_root)
	var table_path := "res://assets/models/optical_table.glb"
	if ResourceLoader.exists(table_path):
		table_root.add_child((load(table_path) as PackedScene).instantiate())
	else:
		var top := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(TABLE_LENGTH, 0.06, TABLE_WIDTH)
		top.mesh = bm
		top.position = Vector3(0, -0.03, 0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.08, 0.08, 0.1)
		mat.metallic = 0.6
		mat.roughness = 0.55
		top.material_override = mat
		table_root.add_child(top)
	# floor
	var floor_mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(8, 8)
	floor_mi.mesh = pm
	floor_mi.position = Vector3(0, -0.8, 0)
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(0.05, 0.05, 0.08)
	fm.roughness = 0.9
	floor_mi.material_override = fm
	add_child(floor_mi)

	apparatus_root = Node3D.new()
	apparatus_root.name = "Apparatus"
	add_child(apparatus_root)
	beams = BeamRenderer.new()
	beams.name = "Beams"
	add_child(beams)

	camera_rig = LabCamera.new()
	camera_rig.name = "CameraRig"
	add_child(camera_rig)
	camera_rig.set_home(Vector3(0.0, BEAM_HEIGHT, 0.0), 1.5, -28.0, 24.0)


## Place an apparatus on the table at `x` (metres along the beam, 0 = table centre),
## optionally offset sideways `z`, and register it with the controller.
func place(app: Apparatus, x: float, z: float = 0.0, yaw_deg: float = 0.0) -> Apparatus:
	app.beam_height = BEAM_HEIGHT
	app.position = Vector3(x, 0.0, z)
	app.rotation_degrees.y = yaw_deg
	apparatus_root.add_child(app)
	controller.add(app)
	# alternate label heights so neighbouring labels do not overlap
	if controller.components.size() % 2 == 0 and app._label3d:
		app._label3d.position.y += 0.035
	return app


## Rotate `app` so its optical axis points from its position towards `target` (x, z).
func aim(app: Apparatus, target: Vector2) -> void:
	var d := target - Vector2(app.position.x, app.position.z)
	app.rotation_degrees.y = rad_to_deg(atan2(-d.y, d.x))


## Place `app` on the straight line from `a` to `b` (table x,z) at fraction `t`, facing along it.
func place_on(app: Apparatus, a: Vector2, b: Vector2, t: float) -> Apparatus:
	var p := a.lerp(b, t)
	place(app, p.x, p.y)
	aim(app, b)
	return app


## Put a piece of equipment on the table without adding it to the beam chain (counters,
## power supplies): it is visible, selectable and labelled, but has no optical effect.
func place_decor(app: Apparatus, x: float, z: float, yaw_deg: float = 0.0) -> Apparatus:
	app.beam_height = BEAM_HEIGHT
	app.position = Vector3(x, 0.0, z)
	app.rotation_degrees.y = yaw_deg
	apparatus_root.add_child(app)
	return app


## A beam that leaves the chain at `from_app` and ends on `to_app` (a beam dump).
## mode "blocked": its brightness is the fraction `from_app` removed from the main beam;
## mode "fixed": constant `intensity` while the source is on (e.g. the undepleted pump).
func add_stray_beam(from_app: Apparatus, to_app: Apparatus, wavelength_nm: float, mode: String = "blocked", intensity: float = 0.85) -> void:
	stray_beams.append({"from": from_app, "to": to_app, "wavelength": wavelength_nm, "mode": mode, "intensity": intensity})


func add_preset(text: String, fn: Callable, tooltip: String = "") -> void:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = "GhostButton"
	b.tooltip_text = tooltip
	b.pressed.connect(func() -> void:
		fn.call()
		controller.mark_dirty())
	presets_box.add_child(b)


func _layout_apparatus() -> void:
	pass


# ---------------------------------------------------------------- HUD

func _build_hud() -> void:
	hud = CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = ThemeBuilder.build()
	hud.add_child(root)

	# top bar
	var top := HBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 16
	top.offset_top = 12
	top.offset_right = -16
	top.add_theme_constant_override("separation", 14)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top)
	var back := Button.new()
	back.text = "‹  Back to reading   (Esc)"
	back.theme_type_variation = "GhostButton"
	back.pressed.connect(func() -> void: AppState.go_chapter(chapter_id))
	top.add_child(back)
	var ch := AppState.chapter(chapter_id)
	var title := Label.new()
	title.text = "%s — %s" % [ch.get("kicker", ""), ch.get("title", "")]
	title.theme_type_variation = "H3"
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)
	presets_box = HBoxContainer.new()
	presets_box.add_theme_constant_override("separation", 8)
	top.add_child(presets_box)
	var photons := Button.new()
	photons.text = "▶  Photons  (Space)"
	photons.theme_type_variation = "GhostButton"
	photons.pressed.connect(toggle_photons)
	top.add_child(photons)

	# left: state panel
	var left := PanelContainer.new()
	left.theme_type_variation = "Hud"
	left.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	left.offset_left = 16
	left.offset_bottom = -16
	left.offset_top = -300
	left.offset_right = 560
	left.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(left)
	var left_v := VBoxContainer.new()
	left_v.add_theme_constant_override("separation", 4)
	left.add_child(left_v)
	var st := Label.new()
	st.text = "QUANTUM STATE ALONG THE BEAM   ·   click a stage to follow the beam that far"
	st.theme_type_variation = "Kicker"
	left_v.add_child(st)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left_v.add_child(scroll)
	state_box = VBoxContainer.new()
	state_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_box.add_theme_constant_override("separation", 6)
	scroll.add_child(state_box)

	# right, top: counting (acquisition)
	var acq := PanelContainer.new()
	acq.theme_type_variation = "Hud"
	acq.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	acq.offset_left = -360
	acq.offset_right = -16
	acq.offset_top = 64
	acq.offset_bottom = 64 + 150
	acq.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	root.add_child(acq)
	var acq_v := VBoxContainer.new()
	acq_v.add_theme_constant_override("separation", 4)
	acq.add_child(acq_v)
	var acq_head := HBoxContainer.new()
	acq_head.add_theme_constant_override("separation", 8)
	var at := Label.new()
	at.text = "COUNTING"
	at.theme_type_variation = "Kicker"
	at.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	acq_head.add_child(at)
	_acq_time_label = Label.new()
	_acq_time_label.theme_type_variation = "Mono"
	_acq_time_label.text = "t = 0.0 s"
	acq_head.add_child(_acq_time_label)
	_acq_run_btn = Button.new()
	_acq_run_btn.text = "●  Run"
	_acq_run_btn.theme_type_variation = "GhostButton"
	_acq_run_btn.tooltip_text = "Start / pause counting photons in real time (Poisson statistics, like the real counter)."
	_acq_run_btn.pressed.connect(acquisition_toggle)
	acq_head.add_child(_acq_run_btn)
	var acq_reset := Button.new()
	acq_reset.text = "↺"
	acq_reset.theme_type_variation = "GhostButton"
	acq_reset.tooltip_text = "Reset the counters"
	acq_reset.pressed.connect(acquisition_reset)
	acq_head.add_child(acq_reset)
	acq_v.add_child(acq_head)
	_anim_label = Label.new()
	_anim_label.theme_type_variation = "Muted"
	_anim_label.add_theme_font_size_override("font_size", 12)
	_anim_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_anim_label.visible = false
	acq_v.add_child(_anim_label)
	var acq_scroll := ScrollContainer.new()
	acq_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	acq_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	acq_v.add_child(acq_scroll)
	acq_box = VBoxContainer.new()
	acq_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	acq_box.add_theme_constant_override("separation", 2)
	acq_scroll.add_child(acq_box)

	# right: inspector
	var right := PanelContainer.new()
	right.theme_type_variation = "Hud"
	right.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	right.offset_left = -360
	right.offset_right = -16
	right.offset_top = 64 + 150 + 10
	right.offset_bottom = -340
	root.add_child(right)
	var right_v := VBoxContainer.new()
	right_v.add_theme_constant_override("separation", 8)
	right.add_child(right_v)
	var it := Label.new()
	it.text = "APPARATUS"
	it.theme_type_variation = "Kicker"
	right_v.add_child(it)
	inspector_title = Label.new()
	inspector_title.text = "Click a component on the table"
	inspector_title.theme_type_variation = "H3"
	inspector_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_v.add_child(inspector_title)
	var iscroll := ScrollContainer.new()
	iscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	iscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_v.add_child(iscroll)
	inspector_box = VBoxContainer.new()
	inspector_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector_box.add_theme_constant_override("separation", 8)
	iscroll.add_child(inspector_box)

	# bottom right: results
	var res := PanelContainer.new()
	res.theme_type_variation = "Hud"
	res.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	res.offset_left = -results_width
	res.offset_right = -16
	res.offset_top = -300
	res.offset_bottom = -16
	root.add_child(res)
	results_box = VBoxContainer.new()
	results_box.add_theme_constant_override("separation", 6)
	results_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	res.add_child(results_box)
	var rt := Label.new()
	rt.text = "RESULTS"
	rt.theme_type_variation = "Kicker"
	results_box.add_child(rt)

	hint_label = Label.new()
	hint_label.text = "drag: orbit   ·   shift-drag / middle: pan   ·   wheel: zoom   ·   F: reset view   ·   click: select"
	hint_label.theme_type_variation = "Muted"
	hint_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hint_label.offset_top = 52
	hint_label.offset_left = -330
	hint_label.offset_right = 330
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hint_label)


func _on_rebuilt_internal(snapshots: Array, result: Dictionary) -> void:
	_refresh_state_panel(snapshots)
	_refresh_beams(snapshots)
	on_rebuilt(snapshots, result)
	_refresh_acq()


func _refresh_state_panel(snapshots: Array) -> void:
	for c in state_box.get_children():
		c.queue_free()
	if not controller.source_on:
		var banner := Label.new()
		banner.text = "SHUTTER CLOSED — no photons in the beam. The states below describe a photon once it opens."
		banner.theme_type_variation = "Muted"
		banner.add_theme_color_override("font_color", Palette.WARNING)
		banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		state_box.add_child(banner)
	for s in snapshots:
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 0)
		var app_ref: Apparatus = s["apparatus"]
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		row.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				focus_stage(app_ref))
		if beyond_focus(app_ref):
			row.modulate = Color(1, 1, 1, 0.4)
		var head := HBoxContainer.new()
		var stage := Label.new()
		stage.text = "%s  after %s" % [s["stage"], s["label"]]
		stage.theme_type_variation = "Kicker"
		stage.add_theme_color_override("font_color", Palette.PINK if s["apparatus"] == selected else Palette.TEXT_DIM)
		head.add_child(stage)
		var sp := Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(sp)
		var alive := Label.new()
		alive.text = "%d %% of photons" % roundi(float(s["alive"]) * 100.0)
		alive.theme_type_variation = "Muted"
		head.add_child(alive)
		row.add_child(head)
		var ket := Label.new()
		ket.text = "|%s⟩ = %s" % [s["stage"], s["ket"]]
		ket.theme_type_variation = "Ket"
		ket.add_theme_font_size_override("font_size", 17 if ket.text.length() < 70 else 14)
		ket.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(ket)
		state_box.add_child(row)


func _refresh_beams(_snapshots: Array) -> void:
	var segs: Array = []
	var nm := float(controller.ctx.get("wavelength", 405.0))
	var paths: Array = beam_paths if not beam_paths.is_empty() else [controller.components]
	for path in paths:
		var path_nm := nm
		for i in path.size() - 1:
			var a: Apparatus = path[i]
			var b: Apparatus = path[i + 1]
			if a.has_meta("wavelength_after"):
				path_nm = float(a.get_meta("wavelength_after"))
			var from := a.global_position + Vector3(0, BEAM_HEIGHT, 0)
			var to := b.global_position + Vector3(0, BEAM_HEIGHT, 0)
			var intensity := controller.alive_after_apparatus(a)
			if beyond_focus(b):
				intensity *= 0.08  # following the beam only up to the focused stage
			segs.append({"from": from, "to": to, "intensity": intensity, "wavelength": path_nm})
	for sb in stray_beams:
		var a: Apparatus = sb["from"]
		var i := controller.components.find(a)
		var intensity: float
		if sb["mode"] == "blocked":
			var before := controller.alive_after(i - 1) if i > 0 else (1.0 if controller.source_on else 0.0)
			intensity = maxf(0.0, before - controller.alive_after_apparatus(a))
		else:
			intensity = float(sb["intensity"]) if controller.source_on else 0.0
		segs.append({"from": _beam_point(a), "to": _beam_point(sb["to"]), "intensity": intensity, "wavelength": float(sb["wavelength"])})
	beams.set_segments(segs)


# ---------------------------------------------------------------- selection + inspector

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_pick((event as InputEventMouseButton).position)
	elif event.is_action_pressed("lab_run"):
		toggle_photons()
	elif event.is_action_pressed("lab_reset"):
		controller.reseed_and_rebuild() if controller.has_method("reseed_and_rebuild") else controller.mark_dirty()


func _try_pick(screen_pos: Vector2) -> void:
	var cam := camera_rig.camera
	var from := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * _ray_length, 2)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		select(null)
		return
	var collider: Object = hit.get("collider")
	if collider and collider.has_meta("apparatus"):
		select(collider.get_meta("apparatus") as Apparatus)


func select(app: Apparatus) -> void:
	if selected and is_instance_valid(selected):
		selected.set_selected(false)
	selected = app
	if app:
		app.set_selected(true)
	_refresh_inspector()
	_refresh_state_panel(controller.snapshots)


func _refresh_inspector() -> void:
	for c in inspector_box.get_children():
		c.queue_free()
	if selected == null:
		inspector_title.text = "Click a component on the table"
		return
	inspector_title.text = "%s  ·  %s" % [selected.label, selected.display_name]
	if selected.description != "":
		var d := BlockFactory.rich_text(selected.description)
		d.add_theme_color_override("default_color", Palette.TEXT_DIM)
		inspector_box.add_child(d)
	for name in selected.params:
		var spec: Dictionary = selected.params[name]
		inspector_box.add_child(_make_param_control(selected, name, spec))
	var focus := Button.new()
	focus.text = "Look at it"
	focus.theme_type_variation = "GhostButton"
	focus.pressed.connect(func() -> void: camera_rig.focus_on(selected.global_position + Vector3(0, BEAM_HEIGHT, 0), 0.45))
	inspector_box.add_child(focus)


func _make_param_control(app: Apparatus, name: String, spec: Dictionary) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	var head := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = str(spec.get("label", name))
	lbl.theme_type_variation = "H3"
	lbl.add_theme_font_size_override("font_size", 16)
	head.add_child(lbl)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(sp)
	var value_lbl := Label.new()
	value_lbl.theme_type_variation = "Mono"
	head.add_child(value_lbl)
	v.add_child(head)
	match spec.get("type", "float"):
		"float", "int":
			var slider := HSlider.new()
			slider.min_value = float(spec.get("min", 0.0))
			slider.max_value = float(spec.get("max", 1.0))
			slider.step = float(spec.get("step", 0.01 if spec.get("type") == "float" else 1))
			slider.value = float(spec.get("value", 0.0))
			slider.custom_minimum_size = Vector2(0, 28)
			var unit := str(spec.get("unit", ""))
			value_lbl.text = "%s%s" % [_fmt_value(slider.value, spec), unit]
			slider.value_changed.connect(func(val: float) -> void:
				value_lbl.text = "%s%s" % [_fmt_value(val, spec), unit]
				app.set_param(name, val))
			v.add_child(slider)
			# quick angle presets for angle-like params
			if unit == "°":
				var row := HBoxContainer.new()
				row.add_theme_constant_override("separation", 4)
				for a in [-45.0, 0.0, 22.5, 45.0, 90.0]:
					if a < slider.min_value or a > slider.max_value:
						continue
					var b := Button.new()
					b.text = ("%d°" % int(a)) if a == floorf(a) else ("%.1f°" % a)
					b.theme_type_variation = "GhostButton"
					b.add_theme_font_size_override("font_size", 13)
					b.pressed.connect(func() -> void: slider.value = a)
					row.add_child(b)
				v.add_child(row)
		"bool":
			var cb := CheckBox.new()
			cb.button_pressed = bool(spec.get("value", false))
			cb.text = "yes" if cb.button_pressed else "no"
			value_lbl.text = ""
			cb.toggled.connect(func(on: bool) -> void:
				cb.text = "yes" if on else "no"
				app.set_param(name, on))
			v.add_child(cb)
		"enum":
			var ob := OptionButton.new()
			var options: Array = spec.get("options", [])
			for o in options:
				ob.add_item(str(o))
			ob.selected = maxi(0, options.find(spec.get("value")))
			ob.item_selected.connect(func(idx: int) -> void: app.set_param(name, options[idx]))
			v.add_child(ob)
	if spec.has("help"):
		var h := Label.new()
		h.text = str(spec["help"])
		h.theme_type_variation = "Muted"
		h.add_theme_font_size_override("font_size", 13)
		h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(h)
	return v


func _fmt_value(val: float, spec: Dictionary) -> String:
	if spec.get("type") == "int" or is_equal_approx(val, roundf(val)):
		return "%d" % roundi(val)
	return "%.1f" % val


# ---------------------------------------------------------------- results helpers

func clear_results() -> void:
	for i in range(results_box.get_child_count() - 1, 0, -1):
		results_box.get_child(i).queue_free()


func add_result_row(key: String, value: String, color: Color = Palette.TEXT) -> void:
	var h := HBoxContainer.new()
	var k := Label.new()
	k.text = key
	k.theme_type_variation = "Muted"
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(k)
	var v := Label.new()
	v.text = value
	v.theme_type_variation = "Mono"
	v.add_theme_color_override("font_color", color)
	v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_stretch_ratio = 2.0
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(v)
	results_box.add_child(h)


func add_result_control(c: Control) -> void:
	results_box.add_child(c)


# ---------------------------------------------------------------- acquisition

func acquisition_toggle() -> void:
	acq_running = not acq_running
	_refresh_acq()


func acquisition_reset() -> void:
	acq_running = false
	acq_time = 0.0
	acq_counts.clear()
	_refresh_acq()


## Count for `dt` more seconds: every channel receives a Poisson number of clicks with mean
## rate × dt. Called each frame while running; tests call it directly.
func acquisition_advance(dt: float) -> void:
	if dt <= 0.0:
		return
	acq_time += dt
	for ch in acquisition_channels():
		var n := int(dice.counts(float(ch["rate"]), dt))
		acq_counts[ch["name"]] = int(acq_counts.get(ch["name"], 0)) + n
	_refresh_acq()


func _refresh_acq() -> void:
	if acq_box == null:
		return
	_acq_run_btn.text = "❚❚  Pause" if acq_running else "●  Run"
	_acq_time_label.text = "t = %.1f s" % acq_time
	var channels := acquisition_channels()
	var names: Array = []
	for ch in channels:
		names.append(str(ch["name"]))
	if names != _acq_rows.keys():
		# the channel set changed (rare): rebuild the rows; otherwise only the texts change,
		# which keeps a running acquisition from allocating controls every frame
		for c in acq_box.get_children():
			c.queue_free()
		_acq_rows.clear()
		for name in names:
			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 8)
			var k := Label.new()
			k.text = name
			k.theme_type_variation = "Muted"
			k.custom_minimum_size = Vector2(56, 0)
			h.add_child(k)
			var v := Label.new()
			v.theme_type_variation = "Mono"
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(v)
			var e := Label.new()
			e.theme_type_variation = "Muted"
			e.add_theme_font_size_override("font_size", 12)
			h.add_child(e)
			acq_box.add_child(h)
			_acq_rows[name] = {"value": v, "expect": e}
	for ch in channels:
		var name := str(ch["name"])
		var n := int(acq_counts.get(name, 0))
		var row: Dictionary = _acq_rows[name]
		(row["value"] as Label).text = ("%d   (%.0f ± %.0f /s)" % [n, n / acq_time, sqrt(float(n)) / acq_time]) if acq_time > 0.0 else "—"
		(row["expect"] as Label).text = "expect %d /s" % roundi(float(ch["rate"]))
	if counter_display and is_instance_valid(counter_display) and counter_display.has_method("set_counts"):
		counter_display.call("set_counts", acq_counts)


# ---------------------------------------------------------------- stage stepping

## Follow the beam only up to `app`: select and frame it, dim everything beyond it (beam and
## state rows). Clicking the same stage again lifts the focus.
func focus_stage(app: Apparatus) -> void:
	if _focus_app == app:
		_focus_app = null
	else:
		_focus_app = app
		camera_rig.focus_on(_beam_point(app), 0.5)
	select(app)
	_refresh_beams(controller.snapshots)


## True when `app` lies downstream of the focused stage (same path, or an arm fed by it).
func beyond_focus(app: Apparatus) -> bool:
	if _focus_app == null or app == _focus_app:
		return false
	var paths: Array = beam_paths if not beam_paths.is_empty() else [controller.components]
	var focus_path := -1
	var focus_index := -1
	for j in paths.size():
		var k: int = (paths[j] as Array).find(_focus_app)
		if k >= 0:
			focus_path = j
			focus_index = k
			break
	if focus_path < 0:
		return false
	var same: int = (paths[focus_path] as Array).find(app)
	if same >= 0:
		return same > focus_index
	# the focus is on the pump line: every arm element is downstream
	return focus_path == 0


# ---------------------------------------------------------------- photon animation

func toggle_photons() -> void:
	if bool(AppState.settings.get("reduce_motion", false)):
		return
	_photon_mode = not _photon_mode
	if not _photon_mode:
		for p in _photons:
			(p["mesh"] as Node).queue_free()
		_photons.clear()
	else:
		_anim = {"sent": 0, "detected": {}, "coinc": 0}
		_photon_timer = 0.0
	_refresh_anim_label()


func _process(delta: float) -> void:
	if acq_running:
		acquisition_advance(delta)
	if _photon_mode:
		tick_photons(delta)


## Advance the photon animation by `dt` seconds (called every frame; tests call it directly).
func tick_photons(dt: float) -> void:
	if controller.components.size() < 2:
		return
	_photon_timer -= dt
	if _photon_timer <= 0.0:
		_photon_timer = 0.7 if not beam_paths.is_empty() else 0.12
		_spawn_photon()
	var speed := 1.2  # m/s on screen
	for p in _photons.duplicate():
		_advance_photon(p, dt * speed)


func _beam_point(app: Apparatus) -> Vector3:
	return app.global_position + Vector3(0, BEAM_HEIGHT, 0)


## One joint draw from the final state, property -> label (the engine draws every property
## together, so a photon lost at PA is also the one that went through A).
func sample_outcome() -> Dictionary:
	if controller.system == null:
		return {}
	return controller.system.sample_outcome()


## Index on `path` of the element that absorbs a photon with this outcome, else the last one.
func _dies_at(path: Array, outcome: Dictionary) -> int:
	for prop in outcome:
		var l := str(outcome[prop])
		var target := ""
		if l.begins_with("lost@"):
			target = l.trim_prefix("lost@")
		elif prop == "idler_path" and l == "wall":
			for app in path:
				if app is Optics.Wall:
					target = app.label
		if target != "":
			for i in path.size():
				if (path[i] as Apparatus).label == target:
					return i
	return path.size() - 1


func _make_photon(color: Color, at: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.006
	sm.height = 0.012
	mi.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 3.0
	mi.material_override = mat
	add_child(mi)
	mi.global_position = at
	return mi


## Fire one photon (or one pump photon that will become a pair at the crystal).
func _spawn_photon() -> void:
	if controller.system == null or not controller.source_on:
		return
	var outcome := sample_outcome()
	var color := Palette.wavelength_to_color(float(controller.ctx.get("wavelength", 405.0))).lightened(0.5)
	var path: Array = controller.components if beam_paths.is_empty() else beam_paths[0]
	var mi := _make_photon(color, _beam_point(path[0]))
	_photons.append({"mesh": mi, "path": path, "seg": 0, "t": 0.0, "dies_after": _dies_at(path, outcome),
		"kind": "single" if beam_paths.is_empty() else "pump", "outcome": outcome})
	_anim["sent"] = int(_anim["sent"]) + 1
	_refresh_anim_label()


func _advance_photon(p: Dictionary, dist: float) -> void:
	var path: Array = p["path"]
	var seg: int = p["seg"]
	p["t"] = float(p["t"]) + dist
	var a := _beam_point(path[seg])
	var b := _beam_point(path[seg + 1])
	var length := a.distance_to(b)
	while float(p["t"]) >= length:
		p["t"] = float(p["t"]) - length
		var arrived := seg + 1
		if arrived >= path.size() - 1 or arrived >= int(p["dies_after"]):
			_photons.erase(p)
			(p["mesh"] as Node).queue_free()
			_photon_finished(p, path[arrived])
			return
		seg = arrived
		p["seg"] = seg
		a = _beam_point(path[seg])
		b = _beam_point(path[seg + 1])
		length = a.distance_to(b)
	(p["mesh"] as Node3D).global_position = a.lerp(b, float(p["t"]) / maxf(length, 1e-6))


func _photon_finished(p: Dictionary, at: Apparatus) -> void:
	var outcome: Dictionary = p["outcome"]
	if p["kind"] == "pump" and at is Optics.SPDCSource:
		# the pump photon becomes a pair: one photon down each arm, fates drawn together
		var color := Color(1.0, 0.3, 0.35)
		var kinds := ["signal", "idler"]
		for k in 2:
			if beam_paths.size() <= k + 1:
				break
			var path: Array = beam_paths[k + 1]
			var mi := _make_photon(color, _beam_point(path[0]))
			_photons.append({"mesh": mi, "path": path, "seg": 0, "t": 0.0, "dies_after": _dies_at(path, outcome),
				"kind": kinds[k], "outcome": outcome, "pair": p})
		return
	if at.is_detector():
		var det: Dictionary = _anim["detected"]
		det[at.label] = int(det.get(at.label, 0)) + 1
		if p.has("pair"):
			var pair: Dictionary = p["pair"]
			pair["hits"] = int(pair.get("hits", 0)) + 1
			if int(pair["hits"]) == 2:
				_anim["coinc"] = int(_anim["coinc"]) + 1
	_photon_arrived(p, at)
	_refresh_anim_label()


## Called when an animated photon reaches `at` (absorbed there or detected).
func _photon_arrived(_photon: Dictionary, _at: Apparatus) -> void:
	pass


func _refresh_anim_label() -> void:
	if _anim_label == null:
		return
	_anim_label.visible = _photon_mode
	if not _photon_mode:
		return
	var det: Dictionary = _anim["detected"]
	var parts: PackedStringArray = []
	for k in det:
		parts.append("%s %d" % [k, int(det[k])])
	var branched := not beam_paths.is_empty()
	var txt := "photon mode: %d %s sent" % [int(_anim["sent"]), "pairs" if branched else "photons"]
	if parts.size() > 0:
		txt += "   ·   " + "   ".join(parts)
	if branched:
		txt += "   ·   both %d" % int(_anim["coinc"])
	_anim_label.text = txt
