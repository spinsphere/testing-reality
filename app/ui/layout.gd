class_name Layout
## Screen-size and input facts the UI adapts to. Everything is read from the window and the
## display server, so a phone, a tablet, a browser on a phone and a desktop all get the
## layout that fits — no per-platform code in the screens.
##
##   touch()    a touch screen is the main pointer (phones, tablets, touch laptops)
##   compact()  the window is narrower than COMPACT_WIDTH logical pixels: sidebars become
##              drawers, grids become single columns, HUD panels become tabs
##   scale()    content scale factor for this screen (see main.gd), so text keeps a readable
##              physical size: ~1.0 on a desktop monitor, 2–3 on a phone

## Below this logical width the compact layouts apply (a phone in either orientation, a
## narrow browser window; a 1600×900 desktop window is wide).
const COMPACT_WIDTH := 1000.0
## Logical width the content is designed for; a page column never grows past it.
const PAGE_WIDTH := 860.0
const GUTTER := 16.0

static var _touch_override := -1   # tests: force touch() on (1) / off (0)


static func touch() -> bool:
	if _touch_override >= 0:
		return _touch_override == 1
	return DisplayServer.is_touchscreen_available()


static func window_size(node: Node) -> Vector2:
	var vp := node.get_viewport()
	return vp.get_visible_rect().size if vp else Vector2(1600, 900)


static func compact(node: Node) -> bool:
	return window_size(node).x < COMPACT_WIDTH


static func portrait(node: Node) -> bool:
	var s := window_size(node)
	return s.y > s.x


## Width available for a page column: the design width, or the window minus gutters.
static func page_width(node: Node) -> float:
	return minf(PAGE_WIDTH, window_size(node).x - 2.0 * GUTTER)


## Content scale for the physical screen. Desktop monitors keep 1:1 (the stretch mode
## already fits 1600×900 into the window). On a touch device the scale follows the screen
## density so that 17 px body text comes out around 2.5 mm tall, like a phone's own UI; a
## browser on a phone reports its device pixel ratio through the same DPI call.
static func scale() -> float:
	if not touch():
		return 1.0
	var dpi := float(DisplayServer.screen_get_dpi())
	if dpi <= 0.0:
		dpi = 160.0
	# screen_get_dpi() is per physical pixel; the window is in physical pixels on Android and
	# in CSS pixels on the web (where Godot already applies the device pixel ratio).
	var density := dpi / 160.0
	if OS.has_feature("web"):
		density = 1.0
	# phones (short side under ~5 in) read better slightly larger than tablets
	var px := DisplayServer.screen_get_size()
	var short_in := minf(px.x, px.y) / maxf(dpi, 1.0)
	var k := 0.9 if short_in > 4.0 else 1.0
	return clampf(density * k, 1.0, 4.0)
