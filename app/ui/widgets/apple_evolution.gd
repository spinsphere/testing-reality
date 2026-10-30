extends WidgetBase
## The Introduction's quantum apple: a slider t ∈ [0,1] rotates the (red, rotten) pair
## by θ = t·90° while the eaten amplitude 1/√3 stays put. Bars show the probabilities,
## the ket text comes from QuagmireSystem.ket_text() (nice fractions).

var LABELS := PackedStringArray(["red", "rotten", "eaten"])
const COLORS := [Color("#f87171"), Color("#b4873b"), Color("#a78bfa")]
const SNAPSHOTS := [0.0, 0.25, 0.75, 1.0]

var _t := 0.0
var _amps := PackedFloat64Array([0.0, 0.0, 0.0])
var _probs := PackedFloat64Array([0.0, 0.0, 0.0])
var _ket := ""
var _playing := false

var _canvas: WidgetKit.Canvas
var _slider: HSlider
var _out_theta: Label
var _out_ket: Label
var _play_btn: Button


func defaults() -> Dictionary:
	return {"t": 0.0}


func build() -> void:
	_t = clampf(pf("t", 0.0), 0.0, 1.0)
	var parts := split(290.0)
	var left: VBoxContainer = parts[0]
	var panel: VBoxContainer = parts[1]
	_canvas = WidgetKit.Canvas.new(_draw_canvas)
	left.add_child(_canvas)

	WidgetKit.heading(panel, "Time")
	_slider = WidgetKit.slider(panel, "t", 0.0, 1.0, 0.01, _t, func(v: float) -> String: return "%.2f" % v)
	_slider.value_changed.connect(func(v: float) -> void:
		_t = v
		_update())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)
	_play_btn = WidgetKit.button(row, "▶ Play", false)
	_play_btn.pressed.connect(func() -> void:
		_playing = not _playing
		if _playing and _t >= 1.0:
			_t = 0.0
		_play_btn.text = "❚❚ Pause" if _playing else "▶ Play")
	for snap in SNAPSHOTS:
		var b := WidgetKit.button(row, str(snap), true)
		b.pressed.connect(func() -> void:
			_playing = false
			_play_btn.text = "▶ Play"
			_slider.value = snap)
	_out_theta = WidgetKit.readout(panel)
	WidgetKit.heading(panel, "Rule")
	WidgetKit.ket_label(panel, "|red⟩ ↦ |rotten⟩ gradually,  |eaten⟩ ↦ |eaten⟩", 14)
	WidgetKit.heading(panel, "State")
	_out_ket = WidgetKit.ket_label(panel, "", 16)
	_update()


func _process(delta: float) -> void:
	if _playing:
		_t = minf(1.0, _t + delta * 0.25)
		_slider.set_value_no_signal(_t)
		_slider.value_changed.emit(_t)
		if _t >= 1.0:
			_playing = false
			_play_btn.text = "▶ Play"


func _update() -> void:
	var theta := deg_to_rad(_t * 90.0)
	var a_red := sqrt(2.0 / 3.0) * cos(theta)
	var a_rot := sqrt(2.0 / 3.0) * sin(theta)
	var a_eat := 1.0 / sqrt(3.0)
	var s := QuagmireSystem.new()
	s.add_property("apple", LABELS)
	s.set_state([
		{"labels": PackedStringArray(["red"]), "re": a_red, "im": 0.0},
		{"labels": PackedStringArray(["rotten"]), "re": a_rot, "im": 0.0},
		{"labels": PackedStringArray(["eaten"]), "re": a_eat, "im": 0.0},
	])
	var m := s.marginals("apple")
	for i in 3:
		_amps[i] = WidgetKit.amplitude_of(s, PackedStringArray([LABELS[i]])).x
		_probs[i] = float(m.get(LABELS[i], 0.0))
	_ket = s.ket_text()
	_out_theta.text = "θ = t · 90° = %.1f°   amplitudes  √⅔·cos θ,  √⅔·sin θ,  1/√3" % (_t * 90.0)
	_out_ket.text = "|Ψ_%s⟩ = %s" % [("%.2f" % _t).trim_suffix("0").trim_suffix("0").trim_suffix("."), _ket]
	_canvas.queue_redraw()


func _draw_canvas(c: Control) -> void:
	var sz := c.size
	var body := ThemeBuilder.body()
	var mono := ThemeBuilder.mono()
	var sym := ThemeBuilder.symbol()
	var top := 44.0
	var bottom := sz.y - 40.0
	var h := maxf(10.0, bottom - top)
	var n := 3
	var gap := 24.0
	var bw := maxf(20.0, (sz.x - gap * (n + 1)) / n)
	# baseline and the 1/3, 2/3 guides
	c.draw_line(Vector2(gap * 0.5, bottom), Vector2(sz.x - gap * 0.5, bottom), Palette.BORDER, 1.0)
	var guides := PackedFloat64Array([1.0 / 3.0, 2.0 / 3.0, 1.0])
	var guide_names := PackedStringArray(["⅓", "⅔", "1"])
	for gi in guides.size():
		var y: float = bottom - h * guides[gi]
		c.draw_line(Vector2(gap * 0.5, y), Vector2(sz.x - gap * 0.5, y), Color(Palette.BORDER, 0.7), 1.0)
		WidgetKit.text(c, mono, Vector2(gap * 0.5, y - 3), guide_names[gi], 11, Palette.TEXT_MUTED)
	for i in n:
		var x := gap + i * (bw + gap)
		var p := _probs[i]
		var bh := h * p
		var col: Color = COLORS[i]
		c.draw_rect(Rect2(x, bottom - h, bw, h), Color(col, 0.08))
		c.draw_rect(Rect2(x, bottom - bh, bw, bh), Color(col, 0.75))
		c.draw_rect(Rect2(x, bottom - bh, bw, bh), col, false, 1.5)
		WidgetKit.text_centered(c, sym, Vector2(x + bw / 2.0, bottom + 20), WidgetKit.ket(LABELS[i]), 16, Palette.TEXT)
		WidgetKit.text_centered(c, mono, Vector2(x + bw / 2.0, maxf(top - 26.0, bottom - bh - 22)), "amplitude %s" % WidgetKit.fmt_amp(_amps[i]), 12, Palette.TEXT_DIM)
		WidgetKit.text_centered(c, mono, Vector2(x + bw / 2.0, maxf(top - 10.0, bottom - bh - 6)), "P = %s" % WidgetKit.fmt_pct(p), 13, col.lightened(0.3))
	WidgetKit.text(c, body, Vector2(6, 14), "probability = amplitude²  (bars sum to 1)", 12, Palette.TEXT_MUTED)
