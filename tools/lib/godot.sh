# Locate the Godot 4.7 binary. Source this file; it sets GODOT (a command string).
#   GODOT=/path/to/godot tools/test.sh      # explicit override
# Otherwise: `godot` / `godot4` on PATH, ~/.local/bin/godot, or the Flatpak
# (flatpak run org.godotengine.Godot — needs filesystem access to this repository, which the
# Flatpak grants for the home directory by default).
if [ -z "${GODOT:-}" ]; then
	if command -v godot >/dev/null 2>&1; then GODOT="godot"
	elif command -v godot4 >/dev/null 2>&1; then GODOT="godot4"
	elif [ -x "$HOME/.local/bin/godot" ]; then GODOT="$HOME/.local/bin/godot"
	elif command -v flatpak >/dev/null 2>&1 && flatpak info org.godotengine.Godot >/dev/null 2>&1; then
		GODOT="flatpak run --filesystem=host org.godotengine.Godot"
	else
		echo "Godot 4.7 not found: install it (https://godotengine.org/download) or set GODOT=/path/to/godot" >&2
		exit 1
	fi
fi
# Use it unquoted: `$GODOT --headless ...` (the Flatpak form is several words; `timeout` and
# `xvfb-run` need a real command, not a shell function).
export GODOT
