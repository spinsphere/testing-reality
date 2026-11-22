class_name FitWidthBox
extends Container
## A box as wide as its column whose height follows from an aspect ratio (optionally capped),
## for figures and photo sliders. Children fill it, except controls flagged with the
## `side` meta ("left" / "right"), which keep their minimum size and sit on that edge,
## vertically centred (the slider arrows).

var ratio := 16.0 / 9.0
var max_height := 0.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var h := size.x / maxf(0.01, ratio)
		if max_height > 0.0:
			h = minf(h, max_height)
		if absf(custom_minimum_size.y - h) > 0.5:
			custom_minimum_size.y = h   # the parent re-sorts; the second pass is a no-op
		for c in get_children():
			if not (c is Control):
				continue
			var ctl := c as Control
			var side := str(ctl.get_meta("side", ""))
			if side == "":
				fit_child_in_rect(ctl, Rect2(Vector2.ZERO, size))
			else:
				var ms := ctl.get_combined_minimum_size()
				var x := 8.0 if side == "left" else size.x - ms.x - 8.0
				fit_child_in_rect(ctl, Rect2(Vector2(x, (size.y - ms.y) * 0.5), ms))
