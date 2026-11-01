class_name BlockFactory
## Turns content blocks (dictionaries from pages.json) into Controls.
##
## Block types:
##   section  {text}                      small kicker above a heading
##   heading  {text}                      page heading (H1)
##   subheading {text}                    H2
##   text     {text}                      BBCode paragraph; inline kets like |↔⟩ render in the symbol font
##   equation {id, caption?}              rendered equation from assets/math/<chapter>/
##   figure   {src, caption?, height?}    image (res:// path)
##   table    {header: [..], rows: [[..]]}
##   callout  {kind: math|note|paradox|lab, title?, text}
##   widget   {scene, params?, height?}   an interactive widget scene (must have `configure(params)`)
##   lab      {label?}                    button that enters the chapter's lab
##   video    {title, url}                external video reference
##   list     {items: [..]}               bullet list (BBCode items)
##   spacer   {height}

const WIDGET_DEFAULT_HEIGHT := 360.0


static func make(block: Dictionary, chapter_id: String) -> Control:
	match block.get("type", "text"):
		"section":
			return _label(str(block.get("text", "")).to_upper(), "Kicker")
		"heading":
			var l := _label(block.get("text", ""), "H1")
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			return l
		"subheading":
			var l := _label(block.get("text", ""), "H2")
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			return l
		"text":
			return rich_text(block.get("text", ""))
		"list":
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 6)
			for item in block.get("items", []):
				var h := HBoxContainer.new()
				h.add_theme_constant_override("separation", 10)
				var dot := Label.new()
				dot.text = "•"
				dot.add_theme_color_override("font_color", Palette.ACCENT_SOFT)
				dot.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
				h.add_child(dot)
				var t := rich_text(str(item))
				t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				h.add_child(t)
				v.add_child(h)
			return v
		"equation":
			return equation(chapter_id, block.get("id", ""), block.get("caption", ""))
		"figure":
			return figure(block.get("src", ""), block.get("caption", ""), float(block.get("height", 320.0)))
		"table":
			return table(block.get("header", []), block.get("rows", []))
		"callout":
			return callout(block.get("kind", "note"), block.get("title", ""), block.get("text", ""))
		"widget":
			return widget(block.get("scene", ""), block.get("params", {}), float(block.get("height", WIDGET_DEFAULT_HEIGHT)))
		"lab":
			var b := Button.new()
			b.text = block.get("label", "◆  Enter the lab")
			b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			b.pressed.connect(func() -> void: AppState.go_lab(chapter_id))
			return b
		"video":
			return callout("video", block.get("title", "Video"), "[url=%s]%s[/url]" % [block.get("url", ""), block.get("url", "")])
		"spacer":
			var c := Control.new()
			c.custom_minimum_size = Vector2(0, float(block.get("height", 20)))
			return c
	push_warning("BlockFactory: unknown block type %s" % str(block.get("type")))
	return null


static func _label(text: String, variation: String) -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	return l


## BBCode paragraph. Ket notation is wrapped in the symbol font automatically.
static func rich_text(text: String) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.selection_enabled = true
	r.meta_clicked.connect(func(meta: Variant) -> void: OS.shell_open(str(meta)))
	r.text = ketify(text)
	return r


## Wrap |…⟩ and ⟨…| occurrences in a mono/symbol font so arrows and angle brackets render.
static func ketify(text: String) -> String:
	# Leave [url=…]…[/url] spans untouched (file names contain underscores).
	var url_re := RegEx.new()
	url_re.compile("\\[url=[^\\]]*\\][\\s\\S]*?\\[/url\\]")
	var out := ""
	var last := 0
	for m in url_re.search_all(text):
		out += _ketify_plain(text.substr(last, m.get_start() - last))
		out += m.get_string()
		last = m.get_end()
	out += _ketify_plain(text.substr(last))
	return out


const SUPERSCRIPTS := {"0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴", "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
	"+": "⁺", "-": "⁻", "−": "⁻", "i": "ⁱ", "k": "ᵏ", "a": "ᵃ", "b": "ᵇ", "l": "ˡ", "n": "ⁿ", "s": "ˢ", "x": "ˣ", "m": "ᵐ", "t": "ᵗ", "d": "ᵈ", "e": "ᵉ"}


## `e^{ika}` → `eⁱᵏᵃ`, `cos^2` → `cos²`; falls back to small text when a glyph is missing.
static func _superscript(m: RegExMatch) -> String:
	var body := m.get_string(2)
	var out := ""
	for ch in body:
		if not SUPERSCRIPTS.has(ch):
			return "%s[font_size=12]%s[/font_size]" % [m.get_string(1), body]
		out += SUPERSCRIPTS[ch]
	return m.get_string(1) + out


static func _ketify_plain(text: String) -> String:
	# superscripts: e^{ika}, cos^2
	var sup_re := RegEx.new()
	sup_re.compile("([A-Za-z0-9)⟩])\\^\\{?([A-Za-z0-9+\\-−]{1,4})\\}?")
	var pos := 0
	while true:
		var m := sup_re.search(text, pos)
		if m == null:
			break
		var rep := _superscript(m)
		text = text.substr(0, m.get_start()) + rep + text.substr(m.get_end())
		pos = m.get_start() + rep.length()
	# subscripts: P_↔, Ψ_0, lost_PA → small raised-baseline text
	var sub_re := RegEx.new()
	sub_re.compile("([A-Za-zΨψΦφ⟩])_([A-Za-z0-9↔↕↗↙↘↖±⁺⁻]{1,4})")
	text = sub_re.sub(text, "$1[font_size=12]$2[/font_size]", true)
	var re := RegEx.new()
	re.compile("(\\|[^|\\[\\]⟩]{1,40}⟩|⟨[^|\\[\\]⟨]{1,24}\\|)")
	var out := ""
	var last := 0
	for m in re.search_all(text):
		out += text.substr(last, m.get_start() - last)
		out += "[font=res://assets/fonts/DejaVuSans.ttf][color=#c4b5fd]%s[/color][/font]" % m.get_string()
		last = m.get_end()
	out += text.substr(last)
	return out


static func equation(chapter_id: String, eq_id: String, caption: String = "") -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	var meta := ContentDB.equation(chapter_id, eq_id)
	var tex := ContentDB.equation_texture(chapter_id, eq_id)
	var center := CenterContainer.new()
	v.add_child(center)
	if tex == null:
		var missing := Label.new()
		missing.text = "[equation %s missing]" % eq_id
		missing.theme_type_variation = "Mono"
		center.add_child(missing)
	else:
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		var w := float(meta.get("width", tex.get_width()))
		var h := float(meta.get("height", tex.get_height()))
		var scale := 1.15
		if w * scale > 820.0:
			scale = 820.0 / w
		tr.custom_minimum_size = Vector2(w * scale, h * scale)
		tr.tooltip_text = str(meta.get("tex", ""))
		center.add_child(tr)
	if caption != "":
		var c := rich_text("[center][i]%s[/i][/center]" % caption)
		c.add_theme_color_override("default_color", Palette.TEXT_DIM)
		v.add_child(c)
	return v


static func figure(src: String, caption: String, height: float) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	var center := CenterContainer.new()
	v.add_child(center)
	if ResourceLoader.exists(src):
		var tr := TextureRect.new()
		tr.texture = load(src)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		var t: Texture2D = tr.texture
		var aspect := float(t.get_width()) / maxf(1.0, float(t.get_height()))
		var w := minf(820.0, height * aspect)
		tr.custom_minimum_size = Vector2(w, w / aspect)
		center.add_child(tr)
	else:
		var missing := Label.new()
		missing.text = "[figure %s missing]" % src
		missing.theme_type_variation = "Mono"
		center.add_child(missing)
	if caption != "":
		var c := rich_text("[center][i]%s[/i][/center]" % caption)
		c.add_theme_color_override("default_color", Palette.TEXT_DIM)
		v.add_child(c)
	return v


static func table(header: Array, rows: Array) -> Control:
	var panel := PanelContainer.new()
	var grid := GridContainer.new()
	grid.columns = maxi(1, header.size() if not header.is_empty() else (rows[0].size() if not rows.is_empty() else 1))
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 8)
	panel.add_child(grid)
	# cells need a minimum width: a wrapping RichTextLabel with no width collapses to one
	# character per line inside a grid (the settings card showed a 4000 px empty box)
	var cell_w := 150.0
	for h in header:
		var l := rich_text("[b]%s[/b]" % str(h))
		l.add_theme_color_override("default_color", Palette.ACCENT_SOFT)
		l.custom_minimum_size = Vector2(cell_w, 0)
		grid.add_child(l)
	for row in rows:
		for cell in row:
			var c := rich_text(str(cell))
			c.custom_minimum_size = Vector2(cell_w, 0)
			grid.add_child(c)
	return panel


static func callout(kind: String, title: String, text: String) -> Control:
	var panel := PanelContainer.new()
	panel.theme_type_variation = "Callout"
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	panel.add_child(v)
	var icons := {"math": "∑  Maths check-in", "note": "ⓘ  Note", "paradox": "?  The puzzle", "lab": "◆  In the laboratory", "video": "▶  Watch", "history": "✎  A bit of history"}
	var head := Label.new()
	head.text = title if title != "" else str(icons.get(kind, "Note"))
	head.theme_type_variation = "H3"
	head.add_theme_color_override("font_color", Palette.ACCENT_SOFT if kind != "paradox" else Palette.PINK)
	v.add_child(head)
	if title != "" and icons.has(kind):
		var k := Label.new()
		k.text = str(icons[kind]).to_upper()
		k.theme_type_variation = "Kicker"
		v.add_child(k)
		v.move_child(k, 0)
	v.add_child(rich_text(text))
	return panel


static func widget(scene_path: String, params: Dictionary, height: float) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, height)
	if not scene_path.begins_with("res://"):
		scene_path = "res://ui/widgets/" + scene_path
	if not scene_path.ends_with(".tscn"):
		scene_path += ".tscn"
	if not ResourceLoader.exists(scene_path):
		var missing := Label.new()
		missing.text = "[widget %s missing]" % scene_path
		missing.theme_type_variation = "Mono"
		panel.add_child(missing)
		return panel
	var w: Node = load(scene_path).instantiate()
	if w.has_method("configure"):
		w.configure(params)
	if w is Control:
		(w as Control).size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(w)
	return panel
