class_name LabData
## Loads the site's raw CSV scans from res://data/lab/ into plot-ready arrays.
## Files have one description line, one header line, then numeric rows.

## Returns {"xs": PackedFloat64Array (mm, centred), "ys": PackedFloat64Array (counts/s),
## "peak": float, "n": int} or an empty dictionary on failure.
## `pos_col`/`count_col` are 0-based column indices; `window_s` divides raw counts
## (use 1.0 when the column is already per second); `centre_um` is subtracted from positions.
static func load_scan(path: String, pos_col: int, count_col: int, window_s: float, centre_um: float) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("LabData: missing %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var xs := PackedFloat64Array()
	var ys := PackedFloat64Array()
	var line_no := 0
	var peak := 0.0
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		line_no += 1
		if line == "" or line_no <= 2:
			continue
		var cells := line.split(",")
		if cells.size() <= maxi(pos_col, count_col):
			continue
		if not cells[pos_col].is_valid_float() or not cells[count_col].is_valid_float():
			continue
		var x := (float(cells[pos_col]) - centre_um) / 1000.0
		var y := float(cells[count_col]) / window_s
		xs.append(x)
		ys.append(y)
		peak = maxf(peak, y)
	return {"xs": xs, "ys": ys, "peak": peak, "n": xs.size()}


## Average repeated positions (files with several samples per position).
static func average_by_position(scan: Dictionary) -> Dictionary:
	if scan.is_empty():
		return scan
	var sums := {}
	var counts := {}
	var order := []
	for i in scan["xs"].size():
		var key := snappedf(scan["xs"][i], 0.0005)
		if not sums.has(key):
			sums[key] = 0.0
			counts[key] = 0
			order.append(key)
		sums[key] += scan["ys"][i]
		counts[key] += 1
	var xs := PackedFloat64Array()
	var ys := PackedFloat64Array()
	var peak := 0.0
	for key in order:
		xs.append(key)
		var y: float = sums[key] / counts[key]
		ys.append(y)
		peak = maxf(peak, y)
	return {"xs": xs, "ys": ys, "peak": peak, "n": xs.size()}
