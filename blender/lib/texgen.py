#!/usr/bin/env python3
"""Texture generator for the Testing Reality apparatus models.

Runs with the *system* python3 (needs numpy) and ImageMagick (`convert`).
Blender's bundled Python has no numpy, so qlab.py calls this script via
subprocess whenever a texture is missing.  Everything is deterministic
(seeded noise) so a rebuild reproduces byte-identical images.

Outputs go to blender/textures/ (next to this file's parent directory).

Conventions
    *_color.png   sRGB base colour
    *_orm.png     linear: R = ambient occlusion, G = roughness, B = metallic
                  (the glTF packed layout; wire through a Separate Color node)
    *_normal.png  tangent-space normal map, OpenGL convention (+Y up)

Usage:  texgen.py all | <texture-name> [...]     (see TEXTURES at the bottom)
        texgen.py label <out.png> <text> [--size WxH] [--fg #fff] [--bg #000]
                  [--font DejaVu-Sans-Bold] [--pt N]
"""
import math
import os
import subprocess
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
TEXDIR = os.path.normpath(os.path.join(HERE, "..", "textures"))
MAGICK = "convert"


# ----------------------------------------------------------------------------
# ImageMagick <-> numpy plumbing (PGM/PPM, no PIL needed)
# ----------------------------------------------------------------------------
def run(args):
    subprocess.run(args, check=True)


def magick(*args):
    run([MAGICK, *args])


def read_gray(path):
    """Read any image as float32 [0,1] grayscale via a 16-bit PGM round trip."""
    with tempfile.NamedTemporaryFile(suffix=".pgm", delete=False) as t:
        tmp = t.name
    magick(path, "-colorspace", "Gray", "-depth", "16", "-compress", "none", tmp)
    with open(tmp, "rb") as f:
        data = f.read()
    os.unlink(tmp)
    tokens = data.split()
    assert tokens[0] == b"P2", "expected plain PGM"
    w, h, maxv = int(tokens[1]), int(tokens[2]), int(tokens[3])
    arr = np.array(tokens[4:4 + w * h], dtype=np.float32).reshape(h, w)
    return arr / maxv


def write_rgb(path, rgb):
    """Write float [0,1] HxWx3 array as PNG (through binary PPM)."""
    rgb = np.clip(rgb, 0, 1)
    h, w, _ = rgb.shape
    data = (rgb * 65535 + 0.5).astype(">u2").tobytes()
    with tempfile.NamedTemporaryFile(suffix=".ppm", delete=False) as t:
        t.write(b"P6\n%d %d\n65535\n" % (w, h))
        t.write(data)
        tmp = t.name
    magick(tmp, "-depth", "8", "-define", "png:color-type=2", path)
    os.unlink(tmp)


def write_gray(path, g):
    g = np.clip(g, 0, 1)
    h, w = g.shape
    data = (g * 65535 + 0.5).astype(">u2").tobytes()
    with tempfile.NamedTemporaryFile(suffix=".pgm", delete=False) as t:
        t.write(b"P5\n%d %d\n65535\n" % (w, h))
        t.write(data)
        tmp = t.name
    magick(tmp, "-depth", "8", path)
    os.unlink(tmp)


def height_to_normal(h, strength=1.0, wrap=True):
    """Tangent-space normal map from a height field (rows top->bottom)."""
    if wrap:
        dx = (np.roll(h, -1, axis=1) - np.roll(h, 1, axis=1)) * 0.5
        drow = (np.roll(h, -1, axis=0) - np.roll(h, 1, axis=0)) * 0.5
    else:
        dx = np.gradient(h, axis=1)
        drow = np.gradient(h, axis=0)
    # v increases upwards while row index increases downwards -> dh/dv = -drow
    nx = -dx * strength
    ny = drow * strength
    nz = np.ones_like(h)
    n = np.stack([nx, ny, nz], axis=-1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    return n * 0.5 + 0.5


def noise(size, seed, blur=0):
    """Deterministic white/blurred noise in [0,1] via ImageMagick."""
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as t:
        tmp = t.name
    args = ["-size", "%dx%d" % (size, size), "xc:gray50", "-seed", str(seed),
            "+noise", "Random", "-colorspace", "Gray"]
    if blur:
        args += ["-blur", "0x%g" % blur]
    magick(*args, "-auto-level", tmp)
    g = read_gray(tmp)
    os.unlink(tmp)
    return g


def brushed(size, seed, length=40, seed2=None):
    """Horizontal brushed-metal streak field in [0,1], tileable in x."""
    g = noise(size, seed)
    # motion blur along x = average over a window with wrap-around
    acc = np.zeros_like(g)
    for k in range(length):
        acc += np.roll(g, k, axis=1)
    acc /= length
    acc = (acc - acc.min()) / (acc.max() - acc.min() + 1e-9)
    if seed2 is not None:
        fine = noise(size, seed2)
        acc = 0.8 * acc + 0.2 * fine
    return acc


# ----------------------------------------------------------------------------
# Individual textures
# ----------------------------------------------------------------------------
def tex_anodised(out):
    """Black anodised aluminium: ORM + subtle brushed normal (512, tileable)."""
    s = 512
    streak = brushed(s, 11, 48, seed2=12)
    rough = 0.45 + (streak - 0.5) * 0.14          # 0.38 .. 0.52
    orm = np.stack([np.ones_like(rough), rough, np.full_like(rough, 0.9)], -1)
    write_rgb(os.path.join(out, "anodised_orm.png"), orm)
    write_rgb(os.path.join(out, "anodised_normal.png"),
              height_to_normal(streak * 0.6, strength=0.9))


def tex_stainless(out):
    """Stainless steel: shinier, finer brush."""
    s = 512
    streak = brushed(s, 21, 24, seed2=22)
    rough = 0.30 + (streak - 0.5) * 0.16
    orm = np.stack([np.ones_like(rough), rough, np.ones_like(rough)], -1)
    write_rgb(os.path.join(out, "stainless_orm.png"), orm)
    write_rgb(os.path.join(out, "stainless_normal.png"),
              height_to_normal(streak * 0.8, strength=1.0))


def tex_knurl(out):
    """Straight knurl (vertical ridges) normal map; u wraps around the rim."""
    s = 256
    x = np.arange(s) / s
    ridges = 24
    prof = np.abs(((x * ridges) % 1.0) - 0.5) * 2.0   # triangle wave 0..1
    h = np.tile(prof, (s, 1))
    write_rgb(os.path.join(out, "knurl_normal.png"), height_to_normal(h * 6, 1.0))
    rough = np.full((s, s), 0.5)
    orm = np.stack([np.ones_like(rough), rough, np.full_like(rough, 0.9)], -1)
    write_rgb(os.path.join(out, "knurl_orm.png"), orm)


def tex_breadboard(out, px_per_mm=10.24, pitch_mm=25.0, holes=2):
    """Breadboard tile: `holes` x `holes` countersunk M6 holes at 25 mm pitch.

    Hole centre of cell (0,0) sits at the tile origin + pitch/2, so a UV
    mapping with u = x/(holes*pitch), v = y/(holes*pitch) (x, y measured
    from a hole centre minus pitch/2) lines the texture up with real holes.
    """
    s = int(round(px_per_mm * pitch_mm * holes))
    yy, xx = np.mgrid[0:s, 0:s].astype(np.float32)
    mm_x = xx / px_per_mm
    mm_y = (s - 1 - yy) / px_per_mm           # v up
    r_hole = 3.25      # M6 tapped (minor diameter ~5 mm, show 6.5 mm with thread)
    r_csk = 4.0        # countersink outer radius
    height = np.ones((s, s), np.float32)
    colour = np.zeros((s, s, 3), np.float32)
    rough = np.zeros((s, s), np.float32)
    metal = np.full((s, s), 0.9, np.float32)
    streak = brushed(s, 31, 60, seed2=32)
    # anodised black surface
    base_rgb = np.array([0.028, 0.028, 0.030])
    colour[:] = base_rgb * (0.85 + 0.3 * streak[..., None])
    rough[:] = 0.42 + (streak - 0.5) * 0.12
    height[:] = 1.0 + (streak - 0.5) * 0.02
    for i in range(holes):
        for j in range(holes):
            cx = (i + 0.5) * pitch_mm
            cy = (j + 0.5) * pitch_mm
            r = np.sqrt((mm_x - cx) ** 2 + (mm_y - cy) ** 2)
            csk = (r >= r_hole) & (r < r_csk)
            bore = r < r_hole
            # countersink: linear ramp down into the hole
            t = (r_csk - r) / (r_csk - r_hole)
            height[csk] = 1.0 - 0.45 * t[csk]
            height[bore] = 0.0
            colour[csk] = np.array([0.30, 0.30, 0.31])      # bare steel chamfer
            rough[csk] = 0.25
            metal[csk] = 1.0
            colour[bore] = np.array([0.012, 0.012, 0.012])
            rough[bore] = 0.7
            metal[bore] = 0.6
    write_rgb(os.path.join(out, "breadboard_color.png"), colour ** (1 / 2.2))
    write_rgb(os.path.join(out, "breadboard_orm.png"),
              np.stack([np.ones_like(rough), rough, metal], -1))
    write_rgb(os.path.join(out, "breadboard_normal.png"),
              height_to_normal(height * 14.0, strength=1.0, wrap=True))


def tex_scale_ring(out, name="scale_360.png", size=1024, r_out=0.98, r_in=0.80,
                   minor=2, major=10, number_every=20, numbers_reverse=False):
    """Engraved 360-degree scale, planar-mapped onto an annulus (u,v in 0..1).

    Dark background; ticks and numerals in a light 'engraved' colour.
    Angle 0 at +Y (top), increasing clockwise as seen looking at the dial
    (standard Thorlabs RSP1 reading).
    """
    cx = cy = size / 2
    R = size / 2
    args = ["-size", "%dx%d" % (size, size), "xc:#0a0a0b",
            "-stroke", "#e8e8e8", "-fill", "none"]
    for a in range(0, 360, minor):
        if a % major == 0:
            r1, w = R * (r_out - 0.075), 2.5
        else:
            r1, w = R * (r_out - 0.040), 1.5
        args += ["-strokewidth", str(w),
                 "-draw", "translate %g,%g rotate %d line 0,%g 0,%g"
                 % (cx, cy, a, -R * r_out, -r1)]
    # Slight ring groove at inner edge for a machined look
    args += ["-stroke", "#1a1a1c", "-strokewidth", "3", "-fill", "none",
             "-draw", "circle %g,%g %g,%g" % (cx, cy, cx + R * r_in, cy)]
    # Numerals: pre-rotated label images composited around the ring
    pt = int(size * 0.044)
    rn = R * (r_out - 0.145)
    for a in range(0, 360, number_every):
        txt = str((360 - a) % 360) if numbers_reverse else str(a)
        dx = int(round(rn * math.sin(math.radians(a))))
        dy = int(round(-rn * math.cos(math.radians(a))))
        args += ["(", "-background", "none", "-fill", "#e8e8e8", "-stroke", "none",
                 "-font", "DejaVu-Sans", "-pointsize", str(pt), "label:" + txt,
                 "-rotate", str(a), ")", "-gravity", "center",
                 "-geometry", "%+d%+d" % (dx, dy), "-composite"]
    magick(*args, os.path.join(out, name))


def tex_pcb(out, size=512):
    """Red solder-mask PCB with traces, pads and silkscreen (tileable-ish)."""
    rng = np.random.default_rng(7)
    args = ["-size", "%dx%d" % (size, size), "xc:#7a0f14"]
    # traces
    args += ["-stroke", "#8f1b20", "-strokewidth", "3", "-fill", "none"]
    for _ in range(60):
        x0, y0 = rng.integers(0, size, 2)
        L = rng.integers(20, 160)
        if rng.random() < 0.5:
            x1, y1 = x0 + L, y0
        else:
            x1, y1 = x0, y0 + L
        args += ["-draw", "line %d,%d %d,%d" % (x0, y0, x1, y1)]
    # vias / pads (tinned)
    args += ["-stroke", "#b9b9b0", "-strokewidth", "1", "-fill", "#d9d9cf"]
    for _ in range(90):
        x0, y0 = rng.integers(8, size - 8, 2)
        r = int(rng.integers(3, 6))
        args += ["-draw", "circle %d,%d %d,%d" % (x0, y0, x0 + r, y0)]
    # silkscreen
    args += ["-stroke", "none", "-fill", "#f0f0f0", "-font", "DejaVu-Sans-Mono",
             "-pointsize", "12"]
    for k in range(18):
        x0, y0 = rng.integers(10, size - 40, 2)
        args += ["-draw", "text %d,%d '%s%d'" % (x0, y0, rng.choice(["R", "C", "U", "J"]), k + 1)]
    args += ["-fill", "none", "-stroke", "#f0f0f0", "-strokewidth", "1"]
    for _ in range(14):
        x0, y0 = rng.integers(10, size - 40, 2)
        w, h = rng.integers(10, 36, 2)
        args += ["-draw", "rectangle %d,%d %d,%d" % (x0, y0, x0 + w, y0 + h)]
    magick(*args, os.path.join(out, "pcb_color.png"))
    rough = np.full((size, size), 0.55, np.float32)
    orm = np.stack([np.ones_like(rough), rough, np.zeros_like(rough)], -1)
    write_rgb(os.path.join(out, "pcb_orm.png"), orm)


def tex_laser_warning(out, size=(512, 256)):
    """Yellow IEC laser warning label background (text added per model)."""
    w, h = size
    magick("-size", "%dx%d" % (w, h), "xc:#f3c514",
           "-stroke", "#111", "-strokewidth", "6", "-fill", "none",
           "-draw", "rectangle 6,6 %d,%d" % (w - 7, h - 7),
           # sunburst symbol on the left
           "-stroke", "#111", "-strokewidth", "5",
           *sum([["-draw", "translate 80,%d rotate %d line 0,-18 0,-50" % (h // 2, a)]
                 for a in range(0, 360, 45)], []),
           "-fill", "#111", "-stroke", "none",
           "-draw", "circle 80,%d 92,%d" % (h // 2, h // 2),
           os.path.join(out, "laser_warning_bg.png"))


def label(out_path, text, size="512x128", fg="#ffffff", bg="#000000",
          font="DejaVu-Sans-Bold", pt=None, gravity="center", transparent=False,
          lines=None, bg_image=None, extra=(), xoff=0):
    """Render text (one or several lines) into out_path.

    With transparent=True the background is alpha-0 so the label can be used
    as a decal; otherwise a flat colour.  bg_image uses an existing image
    (e.g. laser_warning_bg.png) as the backdrop.
    """
    w, h = [int(v) for v in size.split("x")]
    if bg_image:
        base = [bg_image, "-resize", "%dx%d!" % (w, h)]
    elif transparent:
        base = ["-size", size, "xc:none"]
    else:
        base = ["-size", size, "xc:" + bg]
    lines = lines or [text]
    if pt is None:
        pt = int(min(h / (len(lines) * 1.35), w / (max(len(l) for l in lines) * 0.62 + 1)))
    args = base + ["-font", font, "-pointsize", str(pt), "-fill", fg, "-stroke", "none",
                   "-gravity", gravity]
    total = len(lines)
    for i, line in enumerate(lines):
        off = int((i - (total - 1) / 2) * pt * 1.25)
        args += ["-draw", "text %d,%d '%s'" % (xoff, off, line.replace("'", "\\'"))]
    args += list(extra)
    magick(*args, out_path)


TEXTURES = {
    "anodised": tex_anodised,
    "stainless": tex_stainless,
    "knurl": tex_knurl,
    "breadboard": tex_breadboard,
    "scale": lambda out: tex_scale_ring(out),
    "pcb": tex_pcb,
    "laser_warning": tex_laser_warning,
}


def main(argv):
    os.makedirs(TEXDIR, exist_ok=True)
    if not argv or argv[0] == "all":
        for name, fn in TEXTURES.items():
            print("texgen:", name)
            fn(TEXDIR)
        return
    if argv[0] == "label":
        out = argv[1]
        text = argv[2]
        opts = {}
        rest = argv[3:]
        i = 0
        while i < len(rest):
            k = rest[i].lstrip("-")
            v = rest[i + 1] if i + 1 < len(rest) else ""
            if k == "lines":
                opts["lines"] = v.split("|")
            elif k == "transparent":
                opts["transparent"] = True
                i += 1
                continue
            elif k in ("pt", "xoff"):
                opts[k] = int(v)
            else:
                opts[k] = v
            i += 2
        label(out, text, **opts)
        return
    for name in argv:
        TEXTURES[name](TEXDIR)


if __name__ == "__main__":
    main(sys.argv[1:])
