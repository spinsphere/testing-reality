class_name ThemeBuilder
## Builds the app Theme in code (fonts, colours, styleboxes) so it stays reviewable.

const FONT_BODY := "res://assets/fonts/Inter-Variable.ttf"
const FONT_DISPLAY := "res://assets/fonts/PlayfairDisplay-Variable.ttf"
const FONT_DISPLAY_ITALIC := "res://assets/fonts/PlayfairDisplay-Italic-Variable.ttf"
const FONT_MONO := "res://assets/fonts/JetBrainsMono-Variable.ttf"
const FONT_SYMBOL := "res://assets/fonts/DejaVuSans.ttf"

static var _cache: Theme


static func body(weight: float = 400.0) -> FontVariation:
	return _variation(FONT_BODY, weight)


static func display(weight: float = 600.0) -> FontVariation:
	return _variation(FONT_DISPLAY, weight)


static func display_italic(weight: float = 500.0) -> FontVariation:
	return _variation(FONT_DISPLAY_ITALIC, weight)


static func mono(weight: float = 500.0) -> FontVariation:
	return _variation(FONT_MONO, weight)


## Font for ket strings: DejaVu first (arrows and ⟩ glyphs), body as fallback.
static func symbol() -> FontVariation:
	var f := FontVariation.new()
	f.base_font = load(FONT_SYMBOL)
	f.fallbacks = [load(FONT_BODY)]
	return f


static func _variation(path: String, weight: float) -> FontVariation:
	var f := FontVariation.new()
	f.base_font = load(path)
	f.variation_opentype = {"wght": weight}
	var fallback: Font = load(FONT_SYMBOL)
	f.fallbacks = [fallback]
	return f


static func flat_box(bg: Color, border: Color = Color(0, 0, 0, 0), radius: int = 10, border_w: int = 1, pad: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w if border.a > 0.0 else 0)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(pad)
	sb.anti_aliasing = true
	return sb


static func build() -> Theme:
	if _cache:
		return _cache
	var t := Theme.new()
	t.default_font = body()
	t.default_font_size = 17

	# Labels
	t.set_color("font_color", "Label", Palette.TEXT)
	t.set_color("default_color", "RichTextLabel", Palette.TEXT)
	t.set_font("normal_font", "RichTextLabel", body())
	t.set_font("bold_font", "RichTextLabel", body(700.0))
	t.set_font("italics_font", "RichTextLabel", display_italic())
	t.set_font("mono_font", "RichTextLabel", mono())
	t.set_font_size("normal_font_size", "RichTextLabel", 18)
	t.set_font_size("bold_font_size", "RichTextLabel", 18)
	t.set_font_size("italics_font_size", "RichTextLabel", 20)
	t.set_font_size("mono_font_size", "RichTextLabel", 17)
	t.set_constant("line_separation", "RichTextLabel", 6)

	# Buttons
	var btn := flat_box(Palette.PRIMARY, Color(0, 0, 0, 0), 8, 0, 10)
	btn.content_margin_left = 18
	btn.content_margin_right = 18
	var btn_hover := btn.duplicate()
	btn_hover.bg_color = Palette.PRIMARY_HOVER
	var btn_pressed := btn.duplicate()
	btn_pressed.bg_color = Palette.ACCENT
	var btn_disabled := btn.duplicate()
	btn_disabled.bg_color = Palette.BORDER
	t.set_stylebox("normal", "Button", btn)
	t.set_stylebox("hover", "Button", btn_hover)
	t.set_stylebox("pressed", "Button", btn_pressed)
	t.set_stylebox("disabled", "Button", btn_disabled)
	t.set_stylebox("focus", "Button", flat_box(Color(0, 0, 0, 0), Palette.ACCENT_SOFT, 8, 2, 10))
	t.set_color("font_color", "Button", Color.WHITE)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Palette.TEXT_MUTED)
	t.set_font("font", "Button", body(600.0))

	# Secondary ("ghost") button variation
	t.add_type("GhostButton")
	t.set_type_variation("GhostButton", "Button")
	t.set_stylebox("normal", "GhostButton", flat_box(Color(0, 0, 0, 0), Palette.BORDER, 8, 1, 10))
	t.set_stylebox("hover", "GhostButton", flat_box(Palette.BG_PANEL_RAISED, Palette.ACCENT_SOFT, 8, 1, 10))
	t.set_stylebox("pressed", "GhostButton", flat_box(Palette.PRIMARY, Palette.ACCENT_SOFT, 8, 1, 10))
	t.set_color("font_color", "GhostButton", Palette.TEXT)

	# Card panel
	t.set_stylebox("panel", "PanelContainer", flat_box(Palette.BG_PANEL, Palette.BORDER, 12, 1, 16))
	t.add_type("Card")
	t.set_type_variation("Card", "PanelContainer")
	t.set_stylebox("panel", "Card", flat_box(Palette.BG_PANEL, Palette.BORDER, 14, 1, 20))
	t.add_type("CardHover")
	t.set_type_variation("CardHover", "PanelContainer")
	t.set_stylebox("panel", "CardHover", flat_box(Palette.BG_PANEL_RAISED, Palette.ACCENT, 14, 1, 20))
	t.add_type("Callout")
	t.set_type_variation("Callout", "PanelContainer")
	t.set_stylebox("panel", "Callout", flat_box(Color("#1a1b3d"), Palette.ACCENT, 10, 1, 16))
	t.add_type("Sidebar")
	t.set_type_variation("Sidebar", "PanelContainer")
	t.set_stylebox("panel", "Sidebar", flat_box(Color("#0c0d1b"), Color(0, 0, 0, 0), 0, 0, 16))
	t.add_type("Hud")
	t.set_type_variation("Hud", "PanelContainer")
	t.set_stylebox("panel", "Hud", flat_box(Color(0.06, 0.06, 0.13, 0.86), Palette.BORDER, 10, 1, 12))

	# Sliders
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Palette.PINK
	grabber.set_corner_radius_all(8)
	grabber.set_content_margin_all(8)
	var slider_bg := flat_box(Palette.BORDER, Color(0, 0, 0, 0), 4, 0, 3)
	var slider_fill := flat_box(Palette.ACCENT, Color(0, 0, 0, 0), 4, 0, 3)
	t.set_stylebox("slider", "HSlider", slider_bg)
	t.set_stylebox("grabber_area", "HSlider", slider_fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", slider_fill)
	var grabber_tex := _circle_texture(18, Palette.PINK)
	t.set_icon("grabber", "HSlider", grabber_tex)
	t.set_icon("grabber_highlight", "HSlider", _circle_texture(20, Palette.ACCENT_SOFT))
	t.set_icon("grabber_disabled", "HSlider", _circle_texture(18, Palette.TEXT_MUTED))

	# Headings as label variations
	t.add_type("H1")
	t.set_type_variation("H1", "Label")
	t.set_font("font", "H1", display(600.0))
	t.set_font_size("font_size", "H1", 44)
	t.set_color("font_color", "H1", Palette.TEXT)
	t.add_type("H2")
	t.set_type_variation("H2", "Label")
	t.set_font("font", "H2", display(600.0))
	t.set_font_size("font_size", "H2", 30)
	t.set_color("font_color", "H2", Palette.ACCENT_SOFT)
	t.add_type("H3")
	t.set_type_variation("H3", "Label")
	t.set_font("font", "H3", body(700.0))
	t.set_font_size("font_size", "H3", 20)
	t.set_color("font_color", "H3", Palette.TEXT)
	t.add_type("Kicker")
	t.set_type_variation("Kicker", "Label")
	t.set_font("font", "Kicker", body(600.0))
	t.set_font_size("font_size", "Kicker", 13)
	t.set_color("font_color", "Kicker", Palette.TEXT_DIM)
	t.add_type("Muted")
	t.set_type_variation("Muted", "Label")
	t.set_font_size("font_size", "Muted", 15)
	t.set_color("font_color", "Muted", Palette.TEXT_DIM)
	t.add_type("Ket")
	t.set_type_variation("Ket", "Label")
	t.set_font("font", "Ket", symbol())
	t.set_font_size("font_size", "Ket", 20)
	t.set_color("font_color", "Ket", Palette.TEXT)
	t.add_type("Mono")
	t.set_type_variation("Mono", "Label")
	t.set_font("font", "Mono", mono())
	t.set_font_size("font_size", "Mono", 15)
	t.set_color("font_color", "Mono", Palette.TEXT_DIM)

	# Scroll / separators / tooltips
	t.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())
	t.set_stylebox("panel", "TooltipPanel", flat_box(Palette.BG_PANEL_RAISED, Palette.ACCENT, 6, 1, 8))
	t.set_color("font_color", "TooltipLabel", Palette.TEXT)
	t.set_stylebox("separator", "HSeparator", flat_box(Palette.BORDER, Color(0, 0, 0, 0), 0, 0, 0))
	t.set_constant("separation", "HSeparator", 1)
	t.set_stylebox("normal", "LineEdit", flat_box(Palette.BG, Palette.BORDER, 6, 1, 8))
	t.set_color("font_color", "LineEdit", Palette.TEXT)
	t.set_stylebox("panel", "PopupMenu", flat_box(Palette.BG_PANEL_RAISED, Palette.BORDER, 8, 1, 6))
	t.set_stylebox("normal", "OptionButton", flat_box(Palette.BG_PANEL_RAISED, Palette.BORDER, 8, 1, 8))
	t.set_stylebox("hover", "OptionButton", flat_box(Palette.BG_PANEL_RAISED, Palette.ACCENT_SOFT, 8, 1, 8))
	t.set_stylebox("pressed", "OptionButton", flat_box(Palette.PRIMARY, Palette.ACCENT_SOFT, 8, 1, 8))
	t.set_color("font_color", "OptionButton", Palette.TEXT)
	t.set_stylebox("normal", "CheckBox", StyleBoxEmpty.new())
	t.set_color("font_color", "CheckBox", Palette.TEXT)
	t.set_stylebox("panel", "ProgressBar", flat_box(Palette.BORDER, Color(0, 0, 0, 0), 4, 0, 0))
	t.set_stylebox("fill", "ProgressBar", flat_box(Palette.ACCENT, Color(0, 0, 0, 0), 4, 0, 0))

	_cache = t
	return t


static func _circle_texture(size: int, color: Color) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var c := Vector2(size / 2.0, size / 2.0)
	var r := size / 2.0 - 0.5
	for y in size:
		for x in size:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(c)
			var a := clampf(r - d + 0.5, 0.0, 1.0)
			img.set_pixel(x, y, Color(color.r, color.g, color.b, a))
	return ImageTexture.create_from_image(img)
