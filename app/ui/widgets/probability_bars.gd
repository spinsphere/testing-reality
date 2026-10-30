extends WidgetBase
## Amplitudes → squared probabilities. One slider per amplitude; when one changes, the
## others are rescaled so the state stays a unit vector (normalisation done by Quagmire).

var _labels := PackedStringArray(["A", "B"])
var _amps := PackedFloat64Array([0.5, sqrt(3.0) / 2.0])
var _probs := PackedFloat64Array()
var _ket := ""
var _sliders: Array = []
var _lock := false

var _canvas: WidgetKit.Canvas
var _out_norm: Label
var _out_ket: Label


func defaults() -> Dictionary:
	return {"amplitudes": [0.5, sqrt(3.0) / 2.0], "labels": ["A", "B"]}


func build() -> void:
	_labels = WidgetKit.to_strings(params.get("labels"), PackedStringArray(["A", "B"]))
	_amps = WidgetKit.to_floats(params.get("amplitudes"), PackedFloat64Array([0.5, sqrt(3.0) / 2.0]))
	while _amps.size() < _labels.size():
		_amps.append(0.0)
	_amps.resize(_labels.size())
	_sliders.clear()
	_normalize_via_quagmire(-1)

	var parts := split(270.0)
	var left: VBoxContainer = parts[0]
	var panel: VBoxContainer = parts[1]
	_canvas = WidgetKit.Canvas.new(_draw_canvas)
	left.add_child(_canvas)

	WidgetKit.heading(panel, "Amplitudes (drag; others rescale)")
	for i in _labels.size():
		var idx := i
		var s := WidgetKit.slider(panel, "amplitude of %s" % WidgetKit.ket(_labels[i]), -1.0, 1.0, 0.001, _amps[i], WidgetKit.fmt_amp)
		s.value_changed.connect(func(v: float) -> void: _on_slider(idx, v))
		_sliders.append(s)
	_out_norm = WidgetKit.readout(panel)
	_out_ket = WidgetKit.ket_label(panel, "", 15)
	_update()


func _on_slider(idx: int, v: float) -> void:
	if _lock:
		return
	_lock = true
	var rest := 0.0
	for i in _amps.size():
		if i != idx:
			rest += _amps[i] * _amps[i]
	var target := maxf(0.0, 1.0 - v * v)
	_amps[idx] = v
	if rest > 1e-12:
		var k := sqrt(target / rest)
		for i in _amps.size():
			if i != idx:
				_amps[i] *= k
	elif _amps.size() > 1:
		var share := sqrt(target / (_amps.size() - 1))
		for i in _amps.size():
			if i != idx:
				_amps[i] = share
	_normalize_via_quagmire(idx)
	for i in _sliders.size():
		if i != idx:
			(_sliders[i] as HSlider).set_value_no_signal(_amps[i])
			(_sliders[i] as HSlider).value_changed.emit(_amps[i])
	_lock = false
	_update()


## Hand the (possibly un-normalised) amplitudes to a QuagmireSystem, normalise there and
## read back amplitudes, probabilities and the pretty ket.
func _normalize_via_quagmire(_changed: int) -> void:
	var s := QuagmireSystem.new()
	s.add_property("s", _labels)
	var entries: Array = []
	var any := false
	for i in _labels.size():
		if absf(_amps[i]) > 1e-12:
			any = true
		entries.append({"labels": PackedStringArray([_labels[i]]), "re": _amps[i], "im": 0.0})
	if not any:
		entries[0]["re"] = 1.0
	s.set_state(entries)
	s.normalize()
	_probs.resize(_labels.size())
	var m := s.marginals("s")
	for i in _labels.size():
		_amps[i] = WidgetKit.amplitude_of(s, PackedStringArray([_labels[i]])).x
		_probs[i] = float(m.get(_labels[i], 0.0))
	_ket = s.ket_text()


func _update() -> void:
	var total := 0.0
	var terms := PackedStringArray()
	for i in _probs.size():
		total += _probs[i]
		terms.append("%.3f" % _probs[i])
	_out_norm.text = "Σ amplitude² = %s = %.3f" % [" + ".join(terms), total]
	_out_ket.text = "|ψ⟩ = " + _ket
	if _canvas:
		_canvas.queue_redraw()


func _draw_canvas(c: Control) -> void:
	var sz := c.size
	var mono := ThemeBuilder.mono()
	var sym := ThemeBuilder.symbol()
	var body := ThemeBuilder.body()
	var n := _labels.size()
	var gap := 18.0
	var left_pad := 56.0
	var bw := maxf(16.0, (sz.x - left_pad - gap * (n + 1)) / n)
	# upper band: signed amplitudes around a midline; lower band: probabilities
	var top := 26.0
	var mid_h := (sz.y - top - 46.0) * 0.5
	var amp_mid := top + mid_h / 2.0
	var amp_scale := mid_h / 2.0 - 4.0
	var prob_bottom := sz.y - 26.0
	var prob_h := sz.y - 26.0 - (top + mid_h + 14.0)
	c.draw_line(Vector2(left_pad, amp_mid), Vector2(sz.x - 6, amp_mid), Palette.BORDER, 1.0)
	c.draw_line(Vector2(left_pad, prob_bottom), Vector2(sz.x - 6, prob_bottom), Palette.BORDER, 1.0)
	c.draw_line(Vector2(left_pad, prob_bottom - prob_h), Vector2(sz.x - 6, prob_bottom - prob_h), Color(Palette.BORDER, 0.6), 1.0)
	WidgetKit.text(c, body, Vector2(6, amp_mid - amp_scale + 2), "amplitude", 12, Palette.TEXT_DIM)
	WidgetKit.text(c, mono, Vector2(left_pad - 20, amp_mid - amp_scale + 10), "+1", 11, Palette.TEXT_MUTED)
	WidgetKit.text(c, mono, Vector2(left_pad - 20, amp_mid + amp_scale), "−1", 11, Palette.TEXT_MUTED)
	WidgetKit.text(c, body, Vector2(6, prob_bottom - prob_h + 2), "probability", 12, Palette.TEXT_DIM)
	WidgetKit.text(c, mono, Vector2(left_pad - 14, prob_bottom - prob_h + 10), "1", 11, Palette.TEXT_MUTED)
	WidgetKit.text(c, mono, Vector2(left_pad - 14, prob_bottom), "0", 11, Palette.TEXT_MUTED)
	for i in n:
		var x := left_pad + gap + i * (bw + gap)
		var col: Color = Palette.SERIES[i % Palette.SERIES.size()]
		var a := _amps[i]
		var ah := a * amp_scale
		var r := Rect2(x, amp_mid - maxf(ah, 0.0), bw, absf(ah))
		c.draw_rect(r, Color(col, 0.6))
		c.draw_rect(r, col, false, 1.2)
		WidgetKit.text_centered(c, mono, Vector2(x + bw / 2.0, (amp_mid - ah) + (-6 if a >= 0.0 else 14)), WidgetKit.fmt_amp(a), 12, col.lightened(0.3))
		var p := _probs[i]
		var ph := prob_h * p
		var pr := Rect2(x, prob_bottom - ph, bw, ph)
		c.draw_rect(pr, Color(col, 0.75))
		c.draw_rect(pr, col, false, 1.2)
		WidgetKit.text_centered(c, mono, Vector2(x + bw / 2.0, prob_bottom - ph - 5), "%.3f² = %s" % [absf(a), WidgetKit.fmt_pct(p)], 12, col.lightened(0.3))
		WidgetKit.text_centered(c, sym, Vector2(x + bw / 2.0, prob_bottom + 18), WidgetKit.ket(_labels[i]), 15, Palette.TEXT)
