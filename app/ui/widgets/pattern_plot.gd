class_name PatternPlot
extends Control
## A small scientific line plot drawn in code: series, optional scatter points, axes.

var title := ""
var x_label := "position (mm)"
var y_label := "counts / s"
var series: Array = []     # [{name, xs: PackedFloat64Array, ys: PackedFloat64Array, color, dashed, width}]
var points: Array = []     # [{xs, ys, color, radius}]
var x_range := Vector2(-2.0, 2.0)
var y_range := Vector2(0.0, 1.0)
var auto_y := true
var auto_x := true
var show_legend := true
var padding := Rect2(52, 26, 14, 34)  # left, top, right, bottom

func set_series(p_series: Array) -> void:
	series = p_series
	_autorange()
	queue_redraw()


func set_points(p_points: Array) -> void:
	points = p_points
	queue_redraw()


func _autorange() -> void:
	var lo_x := INF
	var hi_x := -INF
	var hi_y := 0.0
	for s in series:
		var xs: PackedFloat64Array = s["xs"]
		var ys: PackedFloat64Array = s["ys"]
		for i in xs.size():
			lo_x = minf(lo_x, xs[i])
			hi_x = maxf(hi_x, xs[i])
			hi_y = maxf(hi_y, ys[i])
	if auto_x and lo_x < hi_x:
		x_range = Vector2(lo_x, hi_x)
	if auto_y:
		y_range = Vector2(0.0, hi_y * 1.08 if hi_y > 0.0 else 1.0)


func _plot_rect() -> Rect2:
	return Rect2(padding.position.x, padding.position.y,
		size.x - padding.position.x - padding.size.x, size.y - padding.position.y - padding.size.y)


func _to_px(x: float, y: float) -> Vector2:
	var r := _plot_rect()
	var fx := (x - x_range.x) / maxf(1e-12, x_range.y - x_range.x)
	var fy := (y - y_range.x) / maxf(1e-12, y_range.y - y_range.x)
	return Vector2(r.position.x + fx * r.size.x, r.end.y - fy * r.size.y)


func _draw() -> void:
	var r := _plot_rect()
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0b0c1a"))
	draw_rect(r, Color("#101230"))
	var font := ThemeBuilder.body()
	var small := 12
	# grid + ticks
	var nx := 6
	var ny := 4
	for i in nx + 1:
		var x := lerpf(x_range.x, x_range.y, float(i) / nx)
		var p := _to_px(x, y_range.x)
		draw_line(Vector2(p.x, r.position.y), Vector2(p.x, r.end.y), Color(Palette.BORDER, 0.6), 1.0)
		var txt := _fmt(x)
		var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, small).x
		draw_string(font, Vector2(p.x - w / 2.0, r.end.y + 16), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, small, Palette.TEXT_DIM)
	for i in ny + 1:
		var y := lerpf(y_range.x, y_range.y, float(i) / ny)
		var p := _to_px(x_range.x, y)
		draw_line(Vector2(r.position.x, p.y), Vector2(r.end.x, p.y), Color(Palette.BORDER, 0.6), 1.0)
		var txt := _fmt(y)
		var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, small).x
		draw_string(font, Vector2(r.position.x - w - 6, p.y + 4), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, small, Palette.TEXT_DIM)
	draw_rect(r, Palette.BORDER, false, 1.0)
	# labels
	draw_string(font, Vector2(r.position.x + r.size.x / 2.0 - 40, size.y - 6), x_label, HORIZONTAL_ALIGNMENT_LEFT, -1, small, Palette.TEXT_DIM)
	draw_set_transform(Vector2(12, r.position.y + r.size.y / 2.0 + 30), -PI / 2.0)
	draw_string(font, Vector2.ZERO, y_label, HORIZONTAL_ALIGNMENT_LEFT, -1, small, Palette.TEXT_DIM)
	draw_set_transform(Vector2.ZERO, 0.0)
	if title != "":
		draw_string(font, Vector2(r.position.x, 18), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.TEXT)
	# points
	for pt in points:
		var xs: PackedFloat64Array = pt["xs"]
		var ys: PackedFloat64Array = pt["ys"]
		var c: Color = pt.get("color", Palette.PINK)
		var rad := float(pt.get("radius", 2.5))
		for i in xs.size():
			var p := _to_px(xs[i], ys[i])
			if r.has_point(p):
				draw_circle(p, rad, c)
	# series
	for s in series:
		var xs: PackedFloat64Array = s["xs"]
		var ys: PackedFloat64Array = s["ys"]
		var c: Color = s.get("color", Palette.ACCENT_SOFT)
		var w := float(s.get("width", 2.0))
		var dashed := bool(s.get("dashed", false))
		# Antialiased polylines cost three strips per segment, so a 481-point curve becomes
		# thousands of canvas primitives. Keep at most ~1 vertex per 2 px and antialias only
		# short series (markers, legends); the long curves are drawn plain at 2 px.
		var step := maxi(1, int(ceil(float(xs.size()) / maxf(1.0, r.size.x / 2.0))))
		var pts := PackedVector2Array()
		for i in range(0, xs.size(), step):
			pts.append(_to_px(xs[i], ys[i]))
		if step > 1 and (xs.size() - 1) % step != 0:
			pts.append(_to_px(xs[xs.size() - 1], ys[ys.size() - 1]))
		var aa := pts.size() <= 64
		if pts.size() >= 2:
			if dashed:
				# one draw call for all dashes (a dash every other segment)
				var dashes := PackedVector2Array()
				for i in range(0, pts.size() - 1, 2):
					dashes.append(pts[i])
					dashes.append(pts[i + 1])
				draw_multiline(dashes, c, w, aa)
			else:
				draw_polyline(pts, c, maxf(w, 2.0), aa)
	# legend
	if show_legend:
		var y := r.position.y + 10
		for s in series:
			var c: Color = s.get("color", Palette.ACCENT_SOFT)
			draw_line(Vector2(r.end.x - 150, y), Vector2(r.end.x - 128, y), c, 3.0)
			draw_string(font, Vector2(r.end.x - 122, y + 4), str(s.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, small, Palette.TEXT)
			y += 16


func _fmt(v: float) -> String:
	if absf(v) >= 1000.0:
		return "%.0f" % v
	if absf(v - roundf(v)) < 1e-6:
		return "%d" % roundi(v)
	return "%.2f" % v
