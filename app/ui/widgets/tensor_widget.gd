extends WidgetBase
## "And" lists: two two-level factors (e.g. polarization and path) each with an angle
## slider for its amplitudes; the product state expands into four terms whose amplitudes
## and probabilities are read from a QuagmireSystem holding both properties.

var _left := PackedStringArray(["↔", "↕"])
var _right := PackedStringArray(["A", "B"])
var _theta_l := 30.0
var _theta_r := 60.0
var _l := Vector2(1.0, 0.0)   # left amplitudes
var _r := Vector2(1.0, 0.0)   # right amplitudes
var _terms: Array = []        # [{labels, amp, prob}]
var _ket := ""
var _ket_l := ""
var _ket_r := ""

var _canvas: WidgetKit.Canvas
var _out_left: Label
var _out_right: Label
var _out_ket: Label


func defaults() -> Dictionary:
	return {"left": ["↔", "↕"], "right": ["A", "B"], "left_angle": 30.0, "right_angle": 60.0}


func build() -> void:
	_left = WidgetKit.to_strings(params.get("left"), PackedStringArray(["↔", "↕"]))
	_right = WidgetKit.to_strings(params.get("right"), PackedStringArray(["A", "B"]))
	if _left.size() != 2:
		_left = PackedStringArray([_left[0] if _left.size() > 0 else "↔", _left[1] if _left.size() > 1 else "↕"])
	if _right.size() != 2:
		_right = PackedStringArray([_right[0] if _right.size() > 0 else "A", _right[1] if _right.size() > 1 else "B"])
	_theta_l = pf("left_angle", 30.0)
	_theta_r = pf("right_angle", 60.0)

	var parts := split(262.0)
	var left: VBoxContainer = parts[0]
	var panel: VBoxContainer = parts[1]
	_canvas = WidgetKit.Canvas.new(_draw_canvas)
	left.add_child(_canvas)

	WidgetKit.heading(panel, "First factor  (%s, %s)" % [WidgetKit.ket(_left[0]), WidgetKit.ket(_left[1])])
	var sl := WidgetKit.slider(panel, "angle: cos θ %s + sin θ %s" % [WidgetKit.ket(_left[0]), WidgetKit.ket(_left[1])], 0.0, 360.0, 1.0, _theta_l, WidgetKit.fmt_deg)
	sl.value_changed.connect(func(v: float) -> void:
		_theta_l = v
		_update())
	_out_left = WidgetKit.ket_label(panel, "", 14)
	WidgetKit.heading(panel, "Second factor  (%s, %s)" % [WidgetKit.ket(_right[0]), WidgetKit.ket(_right[1])])
	var sr := WidgetKit.slider(panel, "angle: cos φ %s + sin φ %s" % [WidgetKit.ket(_right[0]), WidgetKit.ket(_right[1])], 0.0, 360.0, 1.0, _theta_r, WidgetKit.fmt_deg)
	sr.value_changed.connect(func(v: float) -> void:
		_theta_r = v
		_update())
	_out_right = WidgetKit.ket_label(panel, "", 14)
	WidgetKit.heading(panel, "Product state")
	_out_ket = WidgetKit.ket_label(panel, "", 13)
	_update()


func _update() -> void:
	var s := QuagmireSystem.new()
	s.add_property("left", _left)
	s.add_property("right", _right)
	s.set_linear_polarization("left", _left, _theta_l)
	s.set_linear_polarization("right", _right, _theta_r)
	_terms.clear()
	for e in s.amplitudes():
		_terms.append({"labels": e["labels"], "amp": float(e["re"]), "prob": float(e["prob"])})
	_ket = s.ket_text()
	var fl := QuagmireSystem.new()
	fl.add_property("left", _left)
	fl.set_linear_polarization("left", _left, _theta_l)
	_l = Vector2(WidgetKit.amplitude_of(fl, PackedStringArray([_left[0]])).x, WidgetKit.amplitude_of(fl, PackedStringArray([_left[1]])).x)
	_ket_l = fl.ket_text()
	var fr := QuagmireSystem.new()
	fr.add_property("right", _right)
	fr.set_linear_polarization("right", _right, _theta_r)
	_r = Vector2(WidgetKit.amplitude_of(fr, PackedStringArray([_right[0]])).x, WidgetKit.amplitude_of(fr, PackedStringArray([_right[1]])).x)
	_ket_r = fr.ket_text()
	_out_left.text = "|a⟩ = " + _ket_l
	_out_right.text = "|b⟩ = " + _ket_r
	_out_ket.text = "|a⟩|b⟩ = " + _ket
	_canvas.queue_redraw()


func _amp_for(l: String, r: String) -> Dictionary:
	for t in _terms:
		var labels: PackedStringArray = t["labels"]
		if labels.size() == 2 and labels[0] == l and labels[1] == r:
			return t
	return {"amp": 0.0, "prob": 0.0}


func _draw_canvas(c: Control) -> void:
	var sz := c.size
	var sym := ThemeBuilder.symbol()
	var mono := ThemeBuilder.mono()
	var body := ThemeBuilder.body()
	# header line: ( a0|l0⟩ + a1|l1⟩ ) ⊗ ( b0|r0⟩ + b1|r1⟩ )
	var head := "( %s %s + %s %s )  ⊗  ( %s %s + %s %s )" % [
		WidgetKit.fmt_amp(_l.x), WidgetKit.ket(_left[0]), WidgetKit.fmt_amp(_l.y), WidgetKit.ket(_left[1]),
		WidgetKit.fmt_amp(_r.x), WidgetKit.ket(_right[0]), WidgetKit.fmt_amp(_r.y), WidgetKit.ket(_right[1])]
	WidgetKit.text_centered(c, sym, Vector2(sz.x / 2.0, 22), head, 15, Palette.TEXT)
	WidgetKit.text_centered(c, body, Vector2(sz.x / 2.0, 42), "= every combination of one label from each list; amplitudes multiply, probabilities multiply", 12, Palette.TEXT_DIM)
	# 2×2 table: rows = left labels, columns = right labels
	var top := 58.0
	var left_col := 100.0
	var table := Rect2(left_col, top + 22.0, sz.x - left_col - 10.0, sz.y - top - 30.0)
	var cw := table.size.x / 2.0
	var ch := table.size.y / 2.0
	for j in 2:
		WidgetKit.text_centered(c, sym, Vector2(table.position.x + cw * (j + 0.5), top + 14), "%s %s" % [WidgetKit.fmt_amp(_r[j]), WidgetKit.ket(_right[j])], 14, Palette.SUCCESS)
	for i in 2:
		WidgetKit.text_right(c, sym, Vector2(left_col - 8, table.position.y + ch * (i + 0.5) + 5), "%s %s" % [WidgetKit.fmt_amp(_l[i]), WidgetKit.ket(_left[i])], 14, Palette.ACCENT_SOFT)
	for i in 2:
		for j in 2:
			var cell := Rect2(table.position + Vector2(cw * j, ch * i), Vector2(cw, ch)).grow(-4.0)
			var t := _amp_for(_left[i], _right[j])
			var amp := float(t["amp"])
			var prob := float(t["prob"])
			c.draw_rect(cell, Color(Palette.BG_PANEL_RAISED, 0.9))
			c.draw_rect(cell, Palette.BORDER, false, 1.0)
			# probability as a filled area in the cell (square whose area is prob of the cell area)
			var side := sqrt(prob) * minf(cell.size.x, cell.size.y) * 0.8
			var sq := Rect2(cell.end - Vector2(side + 6.0, side + 6.0), Vector2(side, side))
			c.draw_rect(sq, Color(Palette.PINK, 0.25))
			c.draw_rect(sq, Color(Palette.PINK, 0.7), false, 1.0)
			var term := "%s %s%s" % [WidgetKit.fmt_amp(amp), WidgetKit.ket(_left[i]), WidgetKit.ket(_right[j])]
			WidgetKit.text(c, sym, cell.position + Vector2(8, 20), term, 14, Palette.TEXT)
			WidgetKit.text(c, mono, cell.position + Vector2(8, 38), "%s × %s" % [WidgetKit.fmt_amp(_l[i]), WidgetKit.fmt_amp(_r[j])], 11, Palette.TEXT_DIM)
			WidgetKit.text(c, mono, cell.position + Vector2(8, ch - 14), "P = %s" % WidgetKit.fmt_pct(prob), 12, Palette.PINK)
