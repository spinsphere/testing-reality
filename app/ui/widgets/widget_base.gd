class_name WidgetBase
extends Control
## Base for the teaching widgets: stores `configure()` params, builds its children in
## code on ready and rebuilds when reconfigured. Subclasses override `defaults()` and `build()`.

var params: Dictionary = {}
var _built := false
var _panel: Control
var _panel_width := WidgetKit.PANEL_WIDTH


func _init() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	mouse_filter = MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(0, 200)


func configure(p: Dictionary) -> void:
	params = defaults()
	params.merge(p, true)
	if _built:
		_rebuild()


func defaults() -> Dictionary:
	return {}


func _ready() -> void:
	if params.is_empty():
		params = defaults()
	set_anchors_preset(PRESET_FULL_RECT)
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	build()
	_built = true


## Build the children (called on ready and on reconfigure).
func build() -> void:
	pass


## Root horizontal layout: a drawing/plot area on the left and a control panel on the right.
func split(panel_width := WidgetKit.PANEL_WIDTH) -> Array:
	var h := HBoxContainer.new()
	h.set_anchors_preset(PRESET_FULL_RECT)
	h.add_theme_constant_override("separation", 14)
	add_child(h)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = SIZE_EXPAND_FILL
	left.size_flags_vertical = SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 6)
	h.add_child(left)
	var panel := WidgetKit.side_panel(panel_width)
	h.add_child(panel)
	_panel = panel
	_panel_width = panel_width
	if not resized.is_connected(_fit_panel):
		resized.connect(_fit_panel)
	_fit_panel()
	return [left, panel]


## Narrow widgets give the control panel less room so the drawing stays visible.
func _fit_panel() -> void:
	if size.x <= 0.0 or _panel == null or not is_instance_valid(_panel):
		return
	_panel.custom_minimum_size.x = clampf(size.x * 0.46, 150.0, _panel_width) if size.x < _panel_width * 2.6 else _panel_width


func pf(key: String, fallback: float = 0.0) -> float:
	return float(params.get(key, fallback))


func pi_(key: String, fallback: int = 0) -> int:
	return int(params.get(key, fallback))


func ps(key: String, fallback: String = "") -> String:
	return str(params.get(key, fallback))


func pb(key: String, fallback: bool = false) -> bool:
	return bool(params.get(key, fallback))
