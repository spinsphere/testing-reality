class_name Palette
## The blue/purple colour system shared by UI, plots and 3D highlights.

const BG := Color("#0f1020")
const BG_PANEL := Color("#161733")
const BG_PANEL_RAISED := Color("#1d1f44")
const BORDER := Color("#2b2d5e")
const PRIMARY := Color("#5b5bd6")
const PRIMARY_HOVER := Color("#6e6ee8")
const ACCENT := Color("#8b5cf6")
const ACCENT_SOFT := Color("#a78bfa")
const PINK := Color("#ec4899")   # the site's "pink handle" colour, used for draggable controls
const TEXT := Color("#e8e4ff")
const TEXT_DIM := Color("#a7a3c9")
const TEXT_MUTED := Color("#6f6b94")
const SUCCESS := Color("#34d399")
const WARNING := Color("#fbbf24")
const DANGER := Color("#f87171")

## Plot series colours (colour-blind friendly on the dark background).
const SERIES := [Color("#a78bfa"), Color("#ec4899"), Color("#34d399"), Color("#fbbf24"), Color("#60a5fa")]

## Site-like component colours for schematics.
const LASER_RED := Color("#ff6b6b")
const POLARIZER := Color("#8b5cf6")


## Approximate RGB colour of monochromatic light at `nm` (Bruton's algorithm);
## wavelengths outside 380–780 nm return a dim "invisible" placeholder.
static func wavelength_to_color(nm: float) -> Color:
	var r := 0.0
	var g := 0.0
	var b := 0.0
	if nm < 380.0 or nm > 780.0:
		return Color(0.35, 0.05, 0.05, 1.0)
	if nm < 440.0:
		r = -(nm - 440.0) / (440.0 - 380.0)
		b = 1.0
	elif nm < 490.0:
		g = (nm - 440.0) / (490.0 - 440.0)
		b = 1.0
	elif nm < 510.0:
		g = 1.0
		b = -(nm - 510.0) / (510.0 - 490.0)
	elif nm < 580.0:
		r = (nm - 510.0) / (580.0 - 510.0)
		g = 1.0
	elif nm < 645.0:
		r = 1.0
		g = -(nm - 645.0) / (645.0 - 580.0)
	else:
		r = 1.0
	var factor := 1.0
	if nm < 420.0:
		factor = 0.3 + 0.7 * (nm - 380.0) / (420.0 - 380.0)
	elif nm > 700.0:
		factor = 0.3 + 0.7 * (780.0 - nm) / (780.0 - 700.0)
	return Color(r * factor, g * factor, b * factor, 1.0)


## Whether the human eye can see this wavelength.
static func is_visible(nm: float) -> bool:
	return nm >= 380.0 and nm <= 780.0
