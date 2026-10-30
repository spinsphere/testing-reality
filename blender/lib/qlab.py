"""qlab -- shared library for the Testing Reality apparatus models (Blender 4.3).

Units and conventions
    * Blender metres.  1 inch = 0.0254 m (`IN`).
    * Apparatus origin: the optical-table surface directly under the optical
      axis (x = 0, y = 0, z = 0).  The optical axis runs along +X at
      `BEAM_HEIGHT` (default 0.10 m) above the table.  +Z is up.
    * glTF export converts to Y-up; in Godot the beam runs along +X, up is +Y.
    * Mounts are built around a *centre* point on the optical axis; each
      builder returns a dict with the objects it created and an
      `optic_offset` (distance from the mount's optical centre down to the
      face that sits on a post), so `post_stack()` can size the post.
    * Moving parts stay separate objects with fixed names (see README):
      "Rotor" (rotates about +X through its origin), "Optic" (child of Rotor
      or Body), "Carriage" (translates along its local Y).  Everything else
      is joined into "Body".

Textures are produced by texgen.py (system python3 + ImageMagick + numpy);
`ensure_textures()` regenerates them when missing.
"""
import hashlib
import math
import os
import subprocess
import sys

# The glTF exporter needs numpy.  Debian's Blender shares the system
# interpreter but disables the user site-packages (where `pip install --user
# numpy` puts it), so add that directory when numpy is not importable.
try:
    import numpy  # noqa: F401
except ImportError:  # pragma: no cover
    import site
    _us = site.getusersitepackages()
    if os.path.isdir(_us) and _us not in sys.path:
        sys.path.append(_us)

import bmesh
import bpy
from mathutils import Matrix, Vector

# ----------------------------------------------------------------------------
# Paths / constants
# ----------------------------------------------------------------------------
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
TEXDIR = os.path.join(ROOT, "blender", "textures")
LABELDIR = os.path.join(TEXDIR, "labels")
MODELS_OUT = os.path.join(ROOT, "app", "assets", "models")

IN = 0.0254
MM = 0.001
BEAM_HEIGHT = 0.10
TAU = math.tau

# Standard Thorlabs-ish sizes (metres)
POST_DIA = 0.5 * IN           # TR series post
HOLDER_OD = 1.0 * IN          # PH series post holder outer diameter
BASE_SIZE = (3 * IN, 1 * IN, 0.375 * IN)   # BA1 base: 3" x 1" x 3/8"
OPTIC_DIA = 1 * IN

TEXTURES = [
    "anodised_orm.png", "anodised_normal.png", "stainless_orm.png",
    "stainless_normal.png", "knurl_normal.png", "knurl_orm.png",
    "breadboard_color.png", "breadboard_orm.png", "breadboard_normal.png",
    "scale_360.png", "pcb_color.png", "pcb_orm.png", "laser_warning_bg.png",
]


# ----------------------------------------------------------------------------
# CLI args / scene
# ----------------------------------------------------------------------------
def args(defaults=None):
    """Parse `-- --key value --flag` after Blender's own arguments."""
    out = dict(defaults or {})
    argv = sys.argv
    if "--" in argv:
        rest = argv[argv.index("--") + 1:]
        i = 0
        while i < len(rest):
            a = rest[i]
            if a.startswith("--"):
                key = a[2:].replace("-", "_")
                if i + 1 < len(rest) and not rest[i + 1].startswith("--"):
                    val = rest[i + 1]
                    i += 2
                else:
                    val = True
                    i += 1
                if key in out and not isinstance(out[key], bool):
                    try:
                        val = type(out[key])(val)
                    except (TypeError, ValueError):
                        pass
                out[key] = val
            else:
                i += 1
    return out


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.unit_settings.system = "METRIC"
    sc.unit_settings.scale_length = 1.0
    _MAT_CACHE.clear()
    _IMG_CACHE.clear()


def ensure_textures():
    missing = [t for t in TEXTURES if not os.path.exists(os.path.join(TEXDIR, t))]
    if missing:
        print("qlab: generating textures:", missing)
        subprocess.run(["python3", os.path.join(HERE, "texgen.py"), "all"], check=True)


def label_image(text, lines=None, size="512x128", fg="#ffffff", bg="#000000",
                font="DejaVu-Sans-Bold", pt=None, transparent=False, bg_image=None,
                xoff=0):
    """Render a text label with texgen.py; cached by content hash."""
    os.makedirs(LABELDIR, exist_ok=True)
    key = "|".join(map(str, [text, lines, size, fg, bg, font, pt, transparent, bg_image, xoff]))
    name = "lbl_" + hashlib.sha1(key.encode()).hexdigest()[:12] + ".png"
    path = os.path.join(LABELDIR, name)
    if not os.path.exists(path):
        cmd = ["python3", os.path.join(HERE, "texgen.py"), "label", path, text,
               "--size", size, "--fg", fg, "--bg", bg, "--font", font, "--xoff", str(xoff)]
        if lines:
            cmd += ["--lines", "|".join(lines)]
        if pt:
            cmd += ["--pt", str(pt)]
        if transparent:
            cmd += ["--transparent"]
        if bg_image:
            cmd += ["--bg_image", bg_image]
        subprocess.run(cmd, check=True)
    return path


# ----------------------------------------------------------------------------
# Materials
# ----------------------------------------------------------------------------
_MAT_CACHE = {}
_IMG_CACHE = {}


def _image(path, colorspace="sRGB"):
    key = (path, colorspace)
    if key in _IMG_CACHE:
        return _IMG_CACHE[key]
    img = bpy.data.images.load(path, check_existing=True)
    img.colorspace_settings.name = colorspace
    _IMG_CACHE[key] = img
    return img


def _new_material(name):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (-300, 0)
    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    return mat, nt, bsdf


def _tex(nt, path, colorspace, x=-900, y=0):
    node = nt.nodes.new("ShaderNodeTexImage")
    node.image = _image(path, colorspace)
    node.extension = "REPEAT"
    node.interpolation = "Linear"
    node.location = (x, y)
    return node


def _wire_orm(nt, bsdf, path, y=-300):
    tex = _tex(nt, path, "Non-Color", y=y)
    sep = nt.nodes.new("ShaderNodeSeparateColor")
    sep.location = (-600, y)
    nt.links.new(tex.outputs["Color"], sep.inputs["Color"])
    nt.links.new(sep.outputs["Green"], bsdf.inputs["Roughness"])
    nt.links.new(sep.outputs["Blue"], bsdf.inputs["Metallic"])
    return tex


def _wire_normal(nt, bsdf, path, strength=1.0, y=-650):
    tex = _tex(nt, path, "Non-Color", y=y)
    nm = nt.nodes.new("ShaderNodeNormalMap")
    nm.location = (-600, y)
    nm.inputs["Strength"].default_value = strength
    nt.links.new(tex.outputs["Color"], nm.inputs["Color"])
    nt.links.new(nm.outputs["Normal"], bsdf.inputs["Normal"])
    return tex


def _cached(name, builder):
    if name in _MAT_CACHE:
        return _MAT_CACHE[name]
    mat = builder(name)
    _MAT_CACHE[name] = mat
    return mat


def anodised_black(name="AnodisedBlack", base=(0.022, 0.022, 0.024), normal_strength=0.6):
    """Black anodised aluminium (Thorlabs style): metallic 0.9, rough ~0.45, brushed."""
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (*base, 1)
        bsdf.inputs["Metallic"].default_value = 0.9
        bsdf.inputs["Roughness"].default_value = 0.45
        _wire_orm(nt, bsdf, os.path.join(TEXDIR, "anodised_orm.png"))
        _wire_normal(nt, bsdf, os.path.join(TEXDIR, "anodised_normal.png"), normal_strength)
        return mat
    return _cached(name, build)


def anodised_colour(rgb, name=None):
    """Coloured anodised aluminium (e.g. red adapter plates, blue knobs)."""
    name = name or "Anodised_%02x%02x%02x" % tuple(int(c * 255) for c in rgb)
    return anodised_black(name=name, base=rgb, normal_strength=0.5)


def matte_black(name="MatteBlack", base=(0.012, 0.012, 0.012), rough=0.75):
    """Black oxide / powder coat / beam-dump paint: dielectric, rough."""
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (*base, 1)
        bsdf.inputs["Metallic"].default_value = 0.0
        bsdf.inputs["Roughness"].default_value = rough
        return mat
    return _cached(name, build)


def stainless(name="Stainless"):
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (0.80, 0.80, 0.78, 1)
        bsdf.inputs["Metallic"].default_value = 1.0
        bsdf.inputs["Roughness"].default_value = 0.3
        _wire_orm(nt, bsdf, os.path.join(TEXDIR, "stainless_orm.png"))
        _wire_normal(nt, bsdf, os.path.join(TEXDIR, "stainless_normal.png"), 0.5)
        return mat
    return _cached(name, build)


def knurled(name="Knurled"):
    """Black anodised with a straight-knurl normal map (u around the rim)."""
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (0.022, 0.022, 0.024, 1)
        bsdf.inputs["Metallic"].default_value = 0.9
        bsdf.inputs["Roughness"].default_value = 0.5
        _wire_orm(nt, bsdf, os.path.join(TEXDIR, "knurl_orm.png"))
        _wire_normal(nt, bsdf, os.path.join(TEXDIR, "knurl_normal.png"), 1.0)
        return mat
    return _cached(name, build)


def knurled_steel(name="KnurledSteel"):
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (0.75, 0.75, 0.73, 1)
        bsdf.inputs["Metallic"].default_value = 1.0
        bsdf.inputs["Roughness"].default_value = 0.4
        _wire_normal(nt, bsdf, os.path.join(TEXDIR, "knurl_normal.png"), 1.0)
        return mat
    return _cached(name, build)


def brass(name="Brass"):
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (0.85, 0.65, 0.3, 1)
        bsdf.inputs["Metallic"].default_value = 1.0
        bsdf.inputs["Roughness"].default_value = 0.35
        return mat
    return _cached(name, build)


def glass(ior=1.5, tint=(0.90, 0.95, 1.0), alpha=0.22, roughness=0.03, name="Glass"):
    """Optical glass: transmission + alpha-blend fallback, faint AR-coating tint.

    glTF gets KHR_materials_transmission/ior from the Principled sockets and
    alphaMode BLEND from the alpha < 1; Godot uses the alpha path.
    """
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (*tint, 1)
        bsdf.inputs["Metallic"].default_value = 0.0
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["IOR"].default_value = ior
        bsdf.inputs["Transmission Weight"].default_value = 1.0
        bsdf.inputs["Alpha"].default_value = alpha
        bsdf.inputs["Specular IOR Level"].default_value = 0.6
        mat.surface_render_method = "BLENDED"
        mat.use_backface_culling = False
        mat.show_transparent_back = True
        return mat
    return _cached(name, build)


def ar_coated_glass(name="ARGlass"):
    """BBAR coating: lenses in the lab photos read blue-violet at grazing angles."""
    return glass(ior=1.52, tint=(0.80, 0.86, 1.0), alpha=0.25, roughness=0.02, name=name)


def polarizer_film(name="PolarizerFilm"):
    """Dichroic film laminated between glass: dark neutral grey, semi-transparent."""
    return glass(ior=1.5, tint=(0.22, 0.22, 0.24), alpha=0.72, roughness=0.08, name=name)


def waveplate_quartz(name="QuartzWaveplate"):
    return glass(ior=1.55, tint=(0.95, 0.93, 1.0), alpha=0.2, roughness=0.02, name=name)


def pbs_coating(name="PBSCoating"):
    """The dielectric interface inside a PBS cube: faint golden-violet sheen."""
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (0.85, 0.75, 0.95, 1)
        bsdf.inputs["Metallic"].default_value = 0.6
        bsdf.inputs["Roughness"].default_value = 0.05
        bsdf.inputs["Alpha"].default_value = 0.35
        mat.surface_render_method = "BLENDED"
        mat.use_backface_culling = False
        return mat
    return _cached(name, build)


def mirror(name="Mirror"):
    """Protected-silver mirror coating."""
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (0.96, 0.96, 0.95, 1)
        bsdf.inputs["Metallic"].default_value = 1.0
        bsdf.inputs["Roughness"].default_value = 0.02
        return mat
    return _cached(name, build)


def abs_plastic(rgb, roughness=0.5, name=None):
    name = name or "ABS_%02x%02x%02x" % tuple(int(c * 255) for c in rgb)
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (*rgb, 1)
        bsdf.inputs["Metallic"].default_value = 0.0
        bsdf.inputs["Roughness"].default_value = roughness
        return mat
    return _cached(name, build)


def rubber(name="Rubber"):
    return abs_plastic((0.02, 0.02, 0.02), roughness=0.8, name=name)


def pcb(name="PCB"):
    def build(n):
        mat, nt, bsdf = _new_material(n)
        col = _tex(nt, os.path.join(TEXDIR, "pcb_color.png"), "sRGB", y=200)
        nt.links.new(col.outputs["Color"], bsdf.inputs["Base Color"])
        _wire_orm(nt, bsdf, os.path.join(TEXDIR, "pcb_orm.png"))
        return mat
    return _cached(name, build)


def breadboard(name="Breadboard"):
    """Black anodised breadboard with the 25 mm M6 hole grid in the textures.

    UV convention: one texture tile = 2 x 2 holes = 50 mm; tile origin at a
    hole centre minus 12.5 mm (see texgen.tex_breadboard).
    """
    def build(n):
        mat, nt, bsdf = _new_material(n)
        col = _tex(nt, os.path.join(TEXDIR, "breadboard_color.png"), "sRGB", y=200)
        nt.links.new(col.outputs["Color"], bsdf.inputs["Base Color"])
        _wire_orm(nt, bsdf, os.path.join(TEXDIR, "breadboard_orm.png"))
        _wire_normal(nt, bsdf, os.path.join(TEXDIR, "breadboard_normal.png"), 1.0)
        return mat
    return _cached(name, build)


def scale_ring(name="ScaleRing"):
    """Engraved 360 degree dial; planar UV 0..1 over the ring's bounding square."""
    def build(n):
        mat, nt, bsdf = _new_material(n)
        col = _tex(nt, os.path.join(TEXDIR, "scale_360.png"), "sRGB", y=200)
        col.extension = "EXTEND"
        nt.links.new(col.outputs["Color"], bsdf.inputs["Base Color"])
        bsdf.inputs["Metallic"].default_value = 0.85
        bsdf.inputs["Roughness"].default_value = 0.42
        _wire_normal(nt, bsdf, os.path.join(TEXDIR, "anodised_normal.png"), 0.4)
        return mat
    return _cached(name, build)


def decal(image_path, name=None, metallic=0.0, roughness=0.55):
    """Opaque or alpha-cut label material from an image (alpha from the PNG)."""
    name = name or "Decal_" + os.path.basename(image_path).split(".")[0]
    def build(n):
        mat, nt, bsdf = _new_material(n)
        col = _tex(nt, image_path, "sRGB", y=200)
        col.extension = "CLIP"
        nt.links.new(col.outputs["Color"], bsdf.inputs["Base Color"])
        nt.links.new(col.outputs["Alpha"], bsdf.inputs["Alpha"])
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
        mat.surface_render_method = "BLENDED"
        return mat
    return _cached(name, build)


def emissive(rgb, strength=4.0, name=None):
    name = name or "Emit_%02x%02x%02x" % tuple(int(min(c, 1) * 255) for c in rgb)
    def build(n):
        mat, nt, bsdf = _new_material(n)
        bsdf.inputs["Base Color"].default_value = (*rgb, 1)
        bsdf.inputs["Emission Color"].default_value = (*rgb, 1)
        bsdf.inputs["Emission Strength"].default_value = strength
        bsdf.inputs["Roughness"].default_value = 0.4
        return mat
    return _cached(name, build)


def wavelength_rgb(nm):
    """Approximate visible colour of a wavelength (for LEDs/aperture glow)."""
    if nm < 380 or nm > 780:
        return (0.35, 0.0, 0.0)          # NIR: deep red 'camera' tint
    if nm < 440:
        r, g, b = -(nm - 440) / 60, 0.0, 1.0
    elif nm < 490:
        r, g, b = 0.0, (nm - 440) / 50, 1.0
    elif nm < 510:
        r, g, b = 0.0, 1.0, -(nm - 510) / 20
    elif nm < 580:
        r, g, b = (nm - 510) / 70, 1.0, 0.0
    elif nm < 645:
        r, g, b = 1.0, -(nm - 645) / 65, 0.0
    else:
        r, g, b = 1.0, 0.0, 0.0
    return (r, g, b)


# ----------------------------------------------------------------------------
# Mesh helpers
# ----------------------------------------------------------------------------
_AXIS_ROT = {
    "Z": Matrix.Identity(4),
    "X": Matrix.Rotation(math.radians(90), 4, "Y"),
    "Y": Matrix.Rotation(math.radians(-90), 4, "X"),
    "-X": Matrix.Rotation(math.radians(-90), 4, "Y"),
    "-Y": Matrix.Rotation(math.radians(90), 4, "X"),
    "-Z": Matrix.Rotation(math.radians(180), 4, "X"),
}


def _finish_bm(name, bm, mat, uv="box", uv_scale=0.05, smooth=False, auto_smooth=True):
    """Create a mesh object from bmesh in world coordinates (identity transform)."""
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-6)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(obj)
    if mat is not None:
        if isinstance(mat, (list, tuple)):
            for m in mat:
                me.materials.append(m)
        else:
            me.materials.append(mat)
    if uv == "box":
        uv_box(obj, uv_scale)
    if smooth:
        for p in me.polygons:
            p.use_smooth = True
        if auto_smooth:
            _smooth_by_angle(obj)
    return obj


def _smooth_by_angle(obj, angle_deg=35.0):
    """Shade smooth with sharp edges beyond `angle` (Blender 4.1+ API)."""
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    try:
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(angle_deg))
    except Exception:
        bpy.ops.object.shade_smooth()
    obj.select_set(False)


def uv_box(obj, scale=0.05, offset=(0.0, 0.0)):
    """Tri-planar style UVs: project each face along its dominant normal.
    `offset` (metres) shifts the projection so a texture tile origin can be
    aligned with real geometry (used by the breadboard)."""
    me = obj.data
    if not me.uv_layers:
        me.uv_layers.new(name="UVMap")
    uv = me.uv_layers.active.data
    for poly in me.polygons:
        n = poly.normal
        ax = max(range(3), key=lambda i: abs(n[i]))
        for li in poly.loop_indices:
            co = me.vertices[me.loops[li].vertex_index].co
            if ax == 0:
                u, v = co.y, co.z
            elif ax == 1:
                u, v = co.x, co.z
            else:
                u, v = co.x, co.y
            uv[li].uv = ((u + offset[0]) / scale, (v + offset[1]) / scale)


def uv_planar(obj, axis="X", centre=(0, 0, 0), size=0.05, flip_u=False):
    """Planar projection along `axis` mapping a size x size square to 0..1."""
    me = obj.data
    if not me.uv_layers:
        me.uv_layers.new(name="UVMap")
    uvl = me.uv_layers.active.data
    c = Vector(centre)
    for poly in me.polygons:
        for li in poly.loop_indices:
            p = me.vertices[me.loops[li].vertex_index].co - c
            if axis == "X":
                u, v = p.y, p.z
            elif axis == "Y":
                u, v = p.x, p.z
            else:
                u, v = p.x, p.y
            if flip_u:
                u = -u
            uvl[li].uv = (u / size + 0.5, v / size + 0.5)


def uv_cylindrical(obj, axis="Z", centre=(0, 0, 0), u_repeat=1.0, v_scale=0.05):
    """Cylindrical UVs around `axis` through `centre` (u wraps `u_repeat` times)."""
    me = obj.data
    if not me.uv_layers:
        me.uv_layers.new(name="UVMap")
    uvl = me.uv_layers.active.data
    c = Vector(centre)
    for poly in me.polygons:
        us = []
        for li in poly.loop_indices:
            p = me.vertices[me.loops[li].vertex_index].co - c
            if axis == "Z":
                ang, h = math.atan2(p.y, p.x), p.z
            elif axis == "X":
                ang, h = math.atan2(p.z, p.y), p.x
            else:
                ang, h = math.atan2(p.x, p.z), p.y
            us.append((li, ang / TAU, h))
        # unwrap seam: keep all u within half a turn of each other
        base = us[0][1]
        for li, u, h in us:
            while u - base > 0.5:
                u -= 1.0
            while u - base < -0.5:
                u += 1.0
            uvl[li].uv = (u * u_repeat, h / v_scale)


def transform(obj, matrix):
    """Bake a transform into the mesh data (object stays at identity)."""
    obj.data.transform(matrix)
    obj.data.update()


def move(obj, offset):
    transform(obj, Matrix.Translation(Vector(offset)))


def box(name, size, at=(0, 0, 0), mat=None, bevel=0.0, uv_scale=0.05, anchor="centre"):
    """Axis-aligned box.  `at` is the centre, or the bottom-centre if anchor='bottom'."""
    sx, sy, sz = size
    cx, cy, cz = at
    if anchor == "bottom":
        cz += sz / 2
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    if bevel > 0:
        bmesh.ops.bevel(bm, geom=bm.verts[:] + bm.edges[:], offset=bevel, segments=1,
                        profile=0.7, affect="EDGES")
    bmesh.ops.translate(bm, vec=(cx, cy, cz), verts=bm.verts)
    obj = _finish_bm(name, bm, mat, uv_scale=uv_scale)
    if bevel > 0:
        _smooth_by_angle(obj, 30)     # keeps chamfers crisp, only the bevel strip smooth
    return obj


def revolve(name, profile, at=(0, 0, 0), axis="Z", seg=48, mat=None, smooth=True,
            uv="cyl", uv_scale=0.05, u_repeat=None):
    """Lathe a (r, h) profile around `axis` through `at`.

    `profile` is a closed polygon in (radius, height) -- include points on the
    axis (r = 0) for solid ends.  Pure radial polylines (r > 0 everywhere)
    yield hollow tubes.
    """
    bm = bmesh.new()
    verts = [bm.verts.new((r, 0.0, h)) for r, h in profile]
    edges = []
    n = len(verts)
    for i in range(n):
        a, b = verts[i], verts[(i + 1) % n]
        if (a.co - b.co).length > 1e-9:
            edges.append(bm.edges.new((a, b)))
    geom = verts + edges
    bmesh.ops.spin(bm, geom=geom, cent=(0, 0, 0), axis=(0, 0, 1), angle=TAU,
                   steps=seg, use_merge=True)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-7)
    # drop degenerate faces produced by axis points
    bad = [f for f in bm.faces if f.calc_area() < 1e-14]
    if bad:
        bmesh.ops.delete(bm, geom=bad, context="FACES_ONLY")
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    M = Matrix.Translation(Vector(at)) @ _AXIS_ROT[axis]
    bm.transform(M)
    obj = _finish_bm(name, bm, mat, uv=None, smooth=smooth)
    if uv == "cyl":
        rmax = max(r for r, h in profile)
        uv_cylindrical(obj, axis=axis.strip("-"), centre=at,
                       u_repeat=u_repeat or max(1.0, round(TAU * rmax / uv_scale)),
                       v_scale=uv_scale)
    elif uv == "box":
        uv_box(obj, uv_scale)
    return obj


def cylinder(name, r, h, at=(0, 0, 0), axis="Z", seg=48, mat=None, chamfer=0.0, **kw):
    """Solid cylinder from `at` (base centre) extending `h` along `axis`."""
    if chamfer > 0:
        c = chamfer
        prof = [(0, 0), (r - c, 0), (r, c), (r, h - c), (r - c, h), (0, h)]
    else:
        prof = [(0, 0), (r, 0), (r, h), (0, h)]
    return revolve(name, prof, at=at, axis=axis, seg=seg, mat=mat, **kw)


def tube(name, r_out, r_in, h, at=(0, 0, 0), axis="Z", seg=48, mat=None, **kw):
    prof = [(r_in, 0), (r_out, 0), (r_out, h), (r_in, h)]
    return revolve(name, prof, at=at, axis=axis, seg=seg, mat=mat, **kw)


def disc(name, r, at=(0, 0, 0), axis="Z", seg=48, mat=None, r_in=0.0, uv="planar"):
    """Flat disc or annulus facing +axis (single face layer)."""
    bm = bmesh.new()
    outer = [bm.verts.new((r * math.cos(TAU * i / seg), r * math.sin(TAU * i / seg), 0))
             for i in range(seg)]
    if r_in > 0:
        inner = [bm.verts.new((r_in * math.cos(TAU * i / seg), r_in * math.sin(TAU * i / seg), 0))
                 for i in range(seg)]
        for i in range(seg):
            j = (i + 1) % seg
            bm.faces.new((outer[i], outer[j], inner[j], inner[i]))
    else:
        bm.faces.new(outer)
    M = Matrix.Translation(Vector(at)) @ _AXIS_ROT[axis]
    bm.transform(M)
    obj = _finish_bm(name, bm, mat, uv=None)
    if uv == "planar":
        uv_planar(obj, axis=axis.strip("-"), centre=at, size=2 * r,
                  flip_u=axis.startswith("-"))
    return obj


def plate_with_hole(name, w, h, t, hole_r=None, slot=None, at=(0, 0, 0), axis="X",
                    seg=32, mat=None, uv_scale=0.05):
    """Rectangular plate (w x h, thickness t along `axis`) with a round hole of
    radius `hole_r` or a rectangular `slot=(sw, sh)` through its centre.
    `at` is the plate centre.  w is along the first in-plane axis (Y for
    axis X), h along the second (Z)."""
    bm = bmesh.new()
    if slot is not None:
        sw, sh = slot
        n = 4
        outer2 = [(-w / 2, -h / 2), (w / 2, -h / 2), (w / 2, h / 2), (-w / 2, h / 2)]
        inner2 = [(-sw / 2, -sh / 2), (sw / 2, -sh / 2), (sw / 2, sh / 2), (-sw / 2, sh / 2)]
    else:
        n = seg
        inner2 = [(hole_r * math.cos(TAU * i / n + math.pi / 4),
                   hole_r * math.sin(TAU * i / n + math.pi / 4)) for i in range(n)]
        # outer loop: points on the rectangle perimeter at matching angles
        outer2 = []
        for i in range(n):
            a = TAU * i / n + math.pi / 4
            ca, sa = math.cos(a), math.sin(a)
            # intersect ray with rectangle
            tx = (w / 2) / abs(ca) if abs(ca) > 1e-9 else 1e9
            ty = (h / 2) / abs(sa) if abs(sa) > 1e-9 else 1e9
            tt = min(tx, ty)
            outer2.append((ca * tt, sa * tt))
    o0 = [bm.verts.new((x, y, -t / 2)) for x, y in outer2]
    i0 = [bm.verts.new((x, y, -t / 2)) for x, y in inner2]
    o1 = [bm.verts.new((x, y, t / 2)) for x, y in outer2]
    i1 = [bm.verts.new((x, y, t / 2)) for x, y in inner2]
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((o0[i], i0[i], i0[j], o0[j]))       # back face ring
        bm.faces.new((o1[i], o1[j], i1[j], i1[i]))       # front face ring
        bm.faces.new((o0[i], o0[j], o1[j], o1[i]))       # outer wall
        bm.faces.new((i0[i], i1[i], i1[j], i0[j]))       # hole wall
    M = Matrix.Translation(Vector(at)) @ _AXIS_ROT[axis]
    bm.transform(M)
    obj = _finish_bm(name, bm, mat, uv_scale=uv_scale)
    return obj


def lens_planoconvex(name, dia=OPTIC_DIA, R=0.25, ct=0.003, at=(0, 0, 0), axis="X",
                     mat=None, seg=64, arc_steps=10):
    """Plano-convex lens; flat face at `at`, convex face bulging along +axis.
    R = radius of curvature (f = R/(n-1) ~ 2R for n = 1.5)."""
    r = dia / 2
    sag = R - math.sqrt(max(R * R - r * r, 0))
    et = ct - sag
    prof = [(0, 0), (r, 0), (r, et)]
    for k in range(1, arc_steps + 1):
        rr = r * (1 - k / arc_steps)
        z = et + (sag - (R - math.sqrt(R * R - rr * rr)))
        prof.append((rr, z))
    prof[-1] = (0, ct)
    return revolve(name, prof, at=at, axis=axis, seg=seg, mat=mat, uv="box")


def curve_tube(name, points, radius=0.0015, mat=None, bevel_res=6, res=12):
    """Smooth cable/fibre along `points` (list of xyz) as a bevelled curve -> mesh."""
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = radius
    cu.bevel_resolution = bevel_res
    cu.resolution_u = res
    cu.use_fill_caps = True
    sp = cu.splines.new("NURBS")
    sp.points.add(len(points) - 1)
    for p, co in zip(sp.points, points):
        p.co = (*co, 1.0)
    sp.use_endpoint_u = True
    sp.order_u = min(4, len(points))
    obj = bpy.data.objects.new(name, cu)
    bpy.context.scene.collection.objects.link(obj)
    if mat:
        cu.materials.append(mat)
    # convert to mesh now so finalize can join it
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.convert(target="MESH")
    obj = bpy.context.view_layer.objects.active
    uv_box(obj, 0.02)
    for p in obj.data.polygons:
        p.use_smooth = True
    return obj


def boolean_cut(obj, cutter, delete_cutter=True):
    mod = obj.modifiers.new("cut", "BOOLEAN")
    mod.operation = "DIFFERENCE"
    mod.solver = "EXACT"
    mod.object = cutter
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)
    if delete_cutter:
        bpy.data.objects.remove(cutter, do_unlink=True)
    return obj


def label_decal(name, text, at, size_m, axis="-Y", lines=None, fg="#ffffff",
                bg="#000000", transparent=True, px=(512, 128), pt=None, bg_image=None,
                xoff=0, font="DejaVu-Sans-Bold", offset=0.00015):
    """A flat text decal (plane) centred at `at`, facing `axis`; size_m=(w,h)."""
    img = label_image(text, lines=lines, size="%dx%d" % px, fg=fg, bg=bg,
                      transparent=transparent, pt=pt, bg_image=bg_image, xoff=xoff,
                      font=font)
    w, h = size_m
    bm = bmesh.new()
    vs = [bm.verts.new(v) for v in ((-w / 2, -h / 2, 0), (w / 2, -h / 2, 0),
                                    (w / 2, h / 2, 0), (-w / 2, h / 2, 0))]
    f = bm.faces.new(vs)
    uvl = bm.loops.layers.uv.new("UVMap")
    for loop, uvc in zip(f.loops, ((0, 0), (1, 0), (1, 1), (0, 1))):
        loop[uvl].uv = uvc
    M = Matrix.Translation(Vector(at)) @ _AXIS_ROT[axis] @ Matrix.Translation((0, 0, offset))
    bm.transform(M)
    return _finish_bm(name, bm, decal(img), uv=None)


def curved_label(name, text, centre, axis_len, r, axis="X", ang_span=100.0, ang_centre=-90.0,
                 lines=None, fg="#111111", bg="#f0e000", px=(512, 160), pt=None,
                 bg_image=None, xoff=0, seg=16, offset=0.00012):
    """Label wrapped around a cylinder of radius r along `axis` through `centre`.
    ang_centre is measured in the (y,z) plane: 0 = +Y, 90 = +Z (top),
    180 = -Y (towards the preview camera / operator), 270 = -Z (underside)."""
    img = label_image(text, lines=lines, size="%dx%d" % px, fg=fg, bg=bg,
                      transparent=False, pt=pt, bg_image=bg_image, xoff=xoff)
    bm = bmesh.new()
    uvl = bm.loops.layers.uv.new("UVMap")
    a0 = math.radians(ang_centre - ang_span / 2)
    a1 = math.radians(ang_centre + ang_span / 2)
    rows = []
    for i in range(seg + 1):
        a = a0 + (a1 - a0) * i / seg
        rows.append((math.cos(a) * (r + offset), math.sin(a) * (r + offset)))
    vs = []
    for x in (-axis_len / 2, axis_len / 2):
        vs.append([bm.verts.new((x, cy, cz)) for cy, cz in rows])
    for i in range(seg):
        f = bm.faces.new((vs[0][i], vs[0][i + 1], vs[1][i + 1], vs[1][i]))
        u0, u1 = 1 - i / seg, 1 - (i + 1) / seg
        for loop, uvc in zip(f.loops, ((0, u0), (0, u1), (1, u1), (1, u0))):
            loop[uvl].uv = uvc
    bm.transform(Matrix.Translation(Vector(centre)))
    return _finish_bm(name, bm, decal(img), uv=None, smooth=True, auto_smooth=False)


# ----------------------------------------------------------------------------
# Hardware primitives
# ----------------------------------------------------------------------------
def cap_screw(name, at, dia=0.004, axis="Z", head_h=None, mat=None, hex_socket=True):
    """Socket-head cap screw head sitting on a surface at `at` (head base centre)."""
    mat = mat or stainless()
    hd = dia * 1.5
    head_h = head_h or dia
    objs = [cylinder(name, hd / 2, head_h, at=at, axis=axis, seg=24, mat=mat, chamfer=hd * 0.08)]
    if hex_socket:
        M = _AXIS_ROT[axis]
        top = Vector(at) + (M @ Vector((0, 0, head_h))).xyz
        sock = cylinder(name + "_sock", hd * 0.3, 0.0005, at=top - (M @ Vector((0, 0, 0.0004))).xyz,
                        axis=axis, seg=6, mat=matte_black())
        objs.append(sock)
    return objs


def thumbscrew(name, at, axis="-Y", length=0.012, mat_head=None):
    """Spring-loaded hex-locking thumbscrew (post holder clamp)."""
    shank = cylinder(name + "_shank", 0.002, length * 0.4, at=at, axis=axis, seg=16, mat=stainless())
    M = _AXIS_ROT[axis]
    head_at = Vector(at) + (M @ Vector((0, 0, length * 0.4))).xyz
    head = revolve(name + "_head", [(0, 0), (0.005, 0), (0.0055, 0.0008), (0.0055, length * 0.55),
                                   (0.0045, length * 0.6), (0, length * 0.6)],
                   at=head_at, axis=axis, seg=24, mat=mat_head or knurled_steel(),
                   uv_scale=0.012)
    sock_at = head_at + (M @ Vector((0, 0, length * 0.6 - 0.0004))).xyz
    sock = cylinder(name + "_sock", 0.0015, 0.0005, at=sock_at, axis=axis, seg=6, mat=matte_black())
    return [shank, head, sock]


def post(h, at=(0, 0, 0), dia=POST_DIA, name="Post"):
    """Stainless Ø1/2" post from `at` (bottom centre) up h metres."""
    r = dia / 2
    c = 0.0008
    body = revolve(name, [(0, 0), (r - c, 0), (r, c), (r, h - c), (r - c, h), (0, h)],
                   at=at, axis="Z", seg=40, mat=stainless(), uv_scale=0.04)
    top = Vector(at) + Vector((0, 0, h))
    hole = cylinder(name + "_tap", 0.0022, 0.0008, at=top - Vector((0, 0, 0.0007)), seg=16,
                    mat=matte_black())
    return [body, hole]


def post_holder(h, at=(0, 0, 0), od=HOLDER_OD, name="PostHolder", screw_side="-Y"):
    """Black anodised post holder with a thumbscrew near its top."""
    r = od / 2
    ri = POST_DIA / 2 + 0.0003
    c = 0.0008
    body = revolve(name, [(ri, h), (ri, 0.004), (r - 0.002, 0.004), (r - 0.002, 0), (r - c, 0), (r, c),
                          (r, h - c), (r - c, h)],
                   at=at, axis="Z", seg=40, mat=anodised_black(), uv_scale=0.04)
    sv = (_AXIS_ROT[screw_side] @ Vector((0, 0, 1))).xyz
    screw_at = Vector(at) + sv * (r - 0.001) + Vector((0, 0, h - 0.009))
    objs = [body] + thumbscrew(name + "_ts", screw_at, axis=screw_side, length=0.016)
    return objs


def base_plate(at=(0, 0, 0), along="X", name="Base", screw=True, slots=True):
    """BA1-style base 3" x 1" x 3/8" with two clamping slots and a cap screw.
    `at` is the bottom centre; long axis along `along`."""
    L, W, T = BASE_SIZE
    sx, sy = (L, W) if along == "X" else (W, L)
    b = box(name, (sx, sy, T), at=at, mat=anodised_black(), bevel=0.0007, anchor="bottom")
    objs = [b]
    if slots:
        for sgn in (-1, 1):
            if along == "X":
                cut = box(name + "_slot", (0.019, 0.0066, T * 2), at=(at[0] + sgn * 0.0245, at[1], at[2] + T / 2))
            else:
                cut = box(name + "_slot", (0.0066, 0.019, T * 2), at=(at[0], at[1] + sgn * 0.0245, at[2] + T / 2))
            boolean_cut(b, cut)
        uv_box(b, 0.05)
    if screw:
        sp = (at[0] - 0.0245, at[1], at[2] + T) if along == "X" else (at[0], at[1] - 0.0245, at[2] + T)
        # washer + 1/4-20 cap screw head
        objs.append(tube(name + "_washer", 0.0062, 0.0033, 0.001, at=sp, seg=24, mat=stainless()))
        objs += cap_screw(name + "_screw", (sp[0], sp[1], sp[2] + 0.001), dia=0.00635, axis="Z")
    return objs


def post_stack(top_z, at=(0, 0), beam_h=None, name="Stack", holder_h=None, base=True,
               along="X", screw_side="-Y"):
    """Base + post holder + post whose top face is at height `top_z` (table = 0).
    Returns (objects, top_z).  Holder length is chosen from the standard
    PH series (1", 1.5", 2", 3") to fit."""
    x, y = at
    objs = []
    z0 = 0.0
    if base:
        objs += base_plate(at=(x, y, 0.0), along=along, name=name + "_Base")
        z0 = BASE_SIZE[2]
    if holder_h is None:
        for cand in (3 * IN, 2 * IN, 1.5 * IN, 1 * IN):
            if z0 + cand <= top_z - 0.012:
                holder_h = cand
                break
        else:
            holder_h = max(0.012, top_z - z0 - 0.012)
    objs += post_holder(holder_h, at=(x, y, z0), name=name + "_Holder", screw_side=screw_side)
    post_bottom = z0 + 0.004
    objs += post(top_z - post_bottom, at=(x, y, post_bottom), name=name + "_Post")
    return objs, top_z


# ----------------------------------------------------------------------------
# Optic mounts (all built around `centre` on the optical axis, beam along +X)
# ----------------------------------------------------------------------------
def lens_mount_1in(centre, name="LensMount", thickness=0.0089):
    """Fixed Ø1" lens mount (LMR1 style): ring OD 1.5", tab with 8-32 hole,
    nylon-tipped set screw on top, black retaining ring inside."""
    cx, cy, cz = centre
    r_out = 0.75 * IN
    r_in = OPTIC_DIA / 2 + 0.0002
    t = thickness
    ring = revolve(name + "_Ring", [(r_in, -t / 2), (r_out - 0.0006, -t / 2), (r_out, -t / 2 + 0.0006),
                                    (r_out, t / 2 - 0.0006), (r_out - 0.0006, t / 2), (r_in, t / 2)],
                   at=centre, axis="X", seg=64, mat=anodised_black(), uv_scale=0.04)
    tab = box(name + "_Tab", (t, 0.012, 0.012), at=(cx, cy, cz - r_out + 0.002), mat=anodised_black(),
              bevel=0.0005)
    # retaining ring (SM1RR): thin threaded ring with two spanner notches
    rr = tube(name + "_RetRing", r_in + 0.0001, r_in - 0.0022, 0.0015, at=(cx + 0.0012, cy, cz),
              axis="X", seg=48, mat=matte_black())
    # set screw on top
    ss = cylinder(name + "_SetScrew", 0.0018, 0.004, at=(cx, cy, cz + r_out - 0.0005), seg=12,
                  mat=stainless())
    optic_offset = r_out + 0.004      # centre -> bottom of tab
    return {"objects": [ring, tab, rr, ss], "optic_offset": optic_offset}


def rotation_mount_1in(centre, name="RotMount", angle_scale=True):
    """Manual rotation mount (RSP1 style).  Returns body objects and a separate
    rotor group.  The rotor's front dial carries the engraved scale; the
    body carries the index mark."""
    cx, cy, cz = centre
    R_body = 0.028        # Ø2.2" housing
    body_t = 0.012
    r_bore = 0.0245
    ab = anodised_black()
    # fixed housing: ring with a flat-bottom tab
    housing = revolve(name + "_Housing",
                      [(r_bore, -body_t / 2), (R_body - 0.001, -body_t / 2), (R_body, -body_t / 2 + 0.001),
                       (R_body, body_t / 2 - 0.001), (R_body - 0.001, body_t / 2), (r_bore, body_t / 2)],
                      at=centre, axis="X", seg=72, mat=ab, uv_scale=0.05)
    tab = box(name + "_Tab", (body_t, 0.016, 0.014), at=(cx, cy, cz - R_body + 0.003), mat=ab, bevel=0.0006)
    # index mark on the body front face at 12 o'clock
    idx = label_decal(name + "_Index", "", at=(cx + body_t / 2, cy, cz + R_body - 0.0016), size_m=(0.003, 0.0024),
                      axis="X", lines=["▼"], px=(96, 72), pt=56, fg="#ffffff")
    # locking thumbscrew on the side of the housing
    lock = thumbscrew(name + "_Lock", (cx, cy + R_body - 0.002, cz - 0.004), axis="Y", length=0.012)
    body_objs = [housing, tab, idx] + lock

    # --- rotor (Ø ~ 2" dial ring protruding 4 mm in front of the body)
    r_opt = OPTIC_DIA / 2 + 0.0002
    r_rim = r_bore - 0.0004
    r_dial = 0.025
    front = body_t / 2
    rotor = revolve(name + "_Rotor",
                    [(r_opt, -front + 0.001), (r_rim, -front + 0.001), (r_rim, front),
                     (r_dial, front), (r_dial, front + 0.0045), (r_opt + 0.0025, front + 0.0045),
                     (r_opt + 0.0025, front + 0.002), (r_opt, front + 0.002)],
                    at=centre, axis="X", seg=72, mat=ab, uv_scale=0.05)
    # knurled outer edge of the dial
    knurl = tube(name + "_Knurl", r_dial + 0.0002, r_dial - 0.0005, 0.0045, at=(cx + front, cy, cz),
                 axis="X", seg=72, mat=knurled(), u_repeat=48)
    uv_cylindrical(knurl, axis="X", centre=centre, u_repeat=72, v_scale=0.0045)
    rotor_objs = [rotor, knurl]
    if angle_scale:
        dial = disc(name + "_Dial", r_dial - 0.0006, at=(cx + front + 0.0045 + 0.00005, cy, cz), axis="X",
                    seg=72, mat=scale_ring(), r_in=r_opt + 0.0025)
        rotor_objs.append(dial)
    # retaining ring holding the optic
    rr = tube(name + "_RetRing", r_opt + 0.0001, r_opt - 0.0022, 0.0015, at=(cx + 0.0012, cy, cz),
              axis="X", seg=48, mat=matte_black())
    rotor_objs.append(rr)
    optic_offset = R_body + 0.006
    return {"objects": body_objs, "rotor": rotor_objs, "optic_offset": optic_offset,
            "optic_x": cx}


def kinematic_mirror_mount(centre, name="KinMount", bore=OPTIC_DIA, back_bore=None, size=0.0508):
    """Two-plate kinematic mount (KM100 style), optic plane at `centre`, normal -X.
    Returns dict(objects, optic_offset).  `bore` is the front-plate aperture
    (an adapter ring is added when smaller than 1"), `back_bore` the
    clearance hole in the back plate (None = closed)."""
    cx, cy, cz = centre
    ab = anodised_black()
    ft = 0.0105     # front plate thickness
    gap = 0.004
    bt = 0.010      # back plate thickness
    s = size
    front = plate_with_hole(name + "_Front", s, s, ft, hole_r=OPTIC_DIA / 2 + 0.0003,
                            at=(cx + ft / 2, cy, cz), axis="X", mat=ab)
    bx = cx + ft + gap
    if back_bore:
        back = plate_with_hole(name + "_Back", s, s, bt, hole_r=back_bore / 2,
                               at=(bx + bt / 2, cy, cz), axis="X", mat=ab)
    else:
        back = box(name + "_Back", (bt, s, s), at=(bx + bt / 2, cy, cz), mat=ab, bevel=0.0006)
    objs = [front, back]
    if bore < OPTIC_DIA - 0.001:
        adapter = revolve(name + "_Adapter", [(bore / 2, 0), (OPTIC_DIA / 2 + 0.0001, 0), (OPTIC_DIA / 2 + 0.0001, ft),
                                              (bore / 2, ft)],
                          at=(cx, cy, cz), axis="X", seg=48, mat=ab, uv_scale=0.03)
        objs.append(adapter)
    # springs between plates (two short stainless coils drawn as cylinders)
    for sy, sz in ((-s * 0.3, -s * 0.3), (s * 0.3, s * 0.3)):
        objs.append(cylinder(name + "_Spring", 0.003, gap, at=(cx + ft, cy + sy, cz + sz), axis="X", seg=12,
                             mat=stainless()))
    # adjuster screws: knurled knobs on the back plate at two corners
    kn = knurled_steel()
    for sy, sz in ((-s * 0.33, s * 0.33), (s * 0.33, -s * 0.33)):
        kx = bx + bt
        objs.append(cylinder(name + "_AdjShaft", 0.0025, 0.004, at=(kx, cy + sy, cz + sz), axis="X", seg=16,
                             mat=stainless()))
        knob = revolve(name + "_AdjKnob", [(0, 0), (0.0055, 0), (0.006, 0.0005), (0.006, 0.012),
                                           (0.0055, 0.0125), (0, 0.0125)],
                       at=(kx + 0.004, cy + sy, cz + sz), axis="X", seg=24, mat=kn, uv_scale=0.01)
        objs.append(knob)
        objs.append(cylinder(name + "_AdjSock", 0.0015, 0.0006, at=(kx + 0.004 + 0.0121, cy + sy, cz + sz),
                             axis="X", seg=6, mat=matte_black()))
    # lock screw on the front plate top
    objs.append(cylinder(name + "_SetScrew", 0.0018, 0.004, at=(cx + ft / 2, cy, cz + s / 2 - 0.0005), seg=12,
                         mat=stainless()))
    optic_offset = s / 2        # mounting hole in the bottom of the front plate
    return {"objects": objs, "optic_offset": optic_offset, "front_x": cx, "back_x": bx + bt}


def cube_mount(centre, cube=0.020, name="CubeMount"):
    """Prism/cube platform with a clamping arm (KM100PM/PM3 style).
    Cube centre at `centre`; platform below it."""
    cx, cy, cz = centre
    ab = anodised_black()
    pt = 0.008
    ps = cube + 0.020
    plat_z = cz - cube / 2 - pt
    plat = box(name + "_Platform", (ps, ps, pt), at=(cx, cy, plat_z), mat=ab, bevel=0.0007, anchor="bottom")
    objs = [plat]
    # 4 counterbored holes in the platform (decals)
    for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
        objs.append(cylinder(name + "_Hole", 0.0022, 0.0005, at=(cx + sx * (ps / 2 - 0.005), cy + sy * (ps / 2 - 0.005), plat_z + pt - 0.0004),
                             seg=14, mat=matte_black()))
    # clamp arm: stainless rod rising from a rear corner + black arm over the cube
    rod_at = (cx - ps / 2 + 0.005, cy + ps / 2 - 0.005, plat_z + pt)
    rod_h = cube + 0.014
    objs.append(cylinder(name + "_ClampRod", 0.0025, rod_h, at=rod_at, seg=20, mat=stainless()))
    arm_z = rod_at[2] + rod_h - 0.004
    arm = box(name + "_ClampArm", (0.008, ps / 2 + 0.004, 0.005), at=(rod_at[0], cy + ps / 4 - 0.0025, arm_z + 0.0025),
              mat=ab, bevel=0.0005)
    arm2 = box(name + "_ClampArm2", (ps / 2 + 0.004, 0.008, 0.005), at=(cx - ps / 4 + 0.0025, cy, arm_z + 0.0025),
               mat=ab, bevel=0.0005)
    objs += [arm, arm2]
    # nylon-tipped clamping screw pressing down on the cube top
    objs.append(cylinder(name + "_ClampScrew", 0.002, 0.008, at=(cx, cy, cz + cube / 2 - 0.0005), seg=12,
                         mat=stainless()))
    objs.append(revolve(name + "_ClampKnob", [(0, 0), (0.004, 0), (0.004, 0.005), (0, 0.005)],
                        at=(cx, cy, cz + cube / 2 + 0.0075), seg=20, mat=knurled_steel(), uv_scale=0.008))
    objs.append(cylinder(name + "_ClampRodCap", 0.0025, 0.001, at=(rod_at[0], rod_at[1], rod_at[2] + rod_h), seg=20,
                         mat=stainless()))
    optic_offset = cube / 2 + pt
    return {"objects": objs, "optic_offset": optic_offset}


def pbs_cube(centre, size=0.020, name="PBS"):
    """Polarizing beam-splitter cube: glass cube with the diagonal dielectric
    interface and matte-black painted top/bottom faces.  Beam along +X,
    reflected port +Y."""
    cx, cy, cz = centre
    s = size
    g = glass(ior=1.515, tint=(0.93, 0.95, 1.0), alpha=0.2, name="PBSGlass")
    paint = matte_black()
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=s)
    bmesh.ops.translate(bm, vec=(cx, cy, cz), verts=bm.verts)
    obj = _finish_bm(name + "_Cube", bm, [g, paint], uv_scale=0.02)
    for p in obj.data.polygons:
        p.material_index = 1 if abs(p.normal.z) > 0.5 else 0
    # diagonal interface plane from (-x,+y) ... the hypotenuse faces +X/+Y corner
    h = s / 2 - 0.0003
    bm = bmesh.new()
    vs = [bm.verts.new(v) for v in ((cx - h, cy - h, cz - h), (cx + h, cy + h, cz - h),
                                    (cx + h, cy + h, cz + h), (cx - h, cy - h, cz + h))]
    bm.faces.new(vs)
    coat = _finish_bm(name + "_Coating", bm, pbs_coating(), uv_scale=0.02)
    return [obj, coat]


def beam_dump(at, facing="-Y", name="BeamDump", size=(0.025, 0.040, 0.025)):
    """Small anodised beam dump: box with a conical absorber entrance facing `facing`.
    `at` = bottom centre."""
    w, L, h = size
    x, y, z = at
    if facing in ("-Y", "Y"):
        dims = (w, L, h)
    else:
        dims = (L, w, h)
    body = box(name, dims, at=(x, y, z), mat=anodised_black(), bevel=0.0008, anchor="bottom")
    c = Vector((x, y, z + h / 2))
    nrm = (_AXIS_ROT[facing] @ Vector((0, 0, 1))).xyz
    face_c = c + nrm * (L / 2)
    # entrance: black tube with a dark conical bottom
    ent = revolve(name + "_Entrance", [(0, -0.012), (0.004, 0.0), (0.0085, 0.0), (0.0085, 0.002), (0.0075, 0.003),
                                       (0, 0.003)],
                  at=face_c - nrm * 0.0005, axis=facing, seg=32, mat=matte_black(name="DumpBlack", rough=0.9))
    lbl = label_decal(name + "_Label", "BEAM DUMP", at=(x + (w / 2 if facing in ("-Y", "Y") else 0), y + (0 if facing in ("-Y", "Y") else w / 2), z + h * 0.75),
                      size_m=(0.018, 0.004), axis="X" if facing in ("-Y", "Y") else "Y", px=(360, 80), pt=52,
                      fg="#cccccc")
    return [body, ent, lbl]


def fibre_collimator(at, axis="-X", length=0.034, r=0.006, name="Collimator", with_fc=True):
    """Fibre collimation package (Ø12 mm tube) pointing along `axis` from its
    rear end `at`; FC/PC connector on the rear.  Returns (objects, front_point)."""
    ab = anodised_black()
    M = _AXIS_ROT[axis]
    d = (M @ Vector((0, 0, 1))).xyz
    body = revolve(name, [(0.0025, 0), (r - 0.0008, 0), (r, 0.0008), (r, length - 0.004), (r - 0.0005, length - 0.004),
                          (r - 0.0005, length - 0.0015), (r, length - 0.0015), (r, length - 0.0005), (r - 0.0005, length),
                          (0.004, length), (0.004, length - 0.0025), (0.0025, length - 0.0025)],
                   at=at, axis=axis, seg=40, mat=ab, uv_scale=0.03)
    objs = [body]
    # lens inside the front
    lens = disc(name + "_Lens", 0.0038, at=Vector(at) + d * (length - 0.0026), axis=axis, seg=24, mat=ar_coated_glass())
    objs.append(lens)
    # engraved part number
    objs.append(curved_label(name + "_Label", "F220APC-405", Vector(at) + d * (length / 2), 0.016, r,
                             ang_span=70, ang_centre=180, lines=["F220APC"], fg="#dddddd", bg="#060606",
                             px=(256, 120), pt=40, seg=8))
    if with_fc:
        # FC/PC connector: stainless knurled nut + black boot behind the rear
        objs.append(revolve(name + "_FCNut", [(0.0015, 0), (0.0045, 0), (0.0045, 0.0105), (0.0015, 0.0105)],
                            at=Vector(at) - d * 0.0105, axis=axis, seg=24, mat=knurled_steel(), uv_scale=0.01))
        objs.append(revolve(name + "_Boot", [(0.0012, 0), (0.0032, 0), (0.0032, 0.012), (0.0018, 0.022), (0.0012, 0.022)],
                            at=Vector(at) - d * 0.0325, axis=axis, seg=16, mat=rubber(), uv_scale=0.01))
    return objs, Vector(at) + d * length


def cable(name, points, radius=0.0015, mat=None):
    return curve_tube(name, points, radius=radius, mat=mat or rubber())


# ----------------------------------------------------------------------------
# Finalise / export
# ----------------------------------------------------------------------------
class Part:
    """A named moving part: `objects` are joined into one mesh named `name`,
    with its origin at `origin` and parented to `parent` (part name or None
    for the root)."""
    def __init__(self, name, objects, origin=(0, 0, 0), parent="Body"):
        self.name = name
        self.objects = list(objects)
        self.origin = Vector(origin)
        self.parent = parent


def _join(objects, name):
    objs = [o for o in objects if o is not None]
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    # apply modifiers / convert curves before joining
    bpy.ops.object.convert(target="MESH")
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    if len(objs) > 1:
        bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    obj.name = name
    obj.data.name = name
    return obj


def _set_origin(obj, point):
    p = Vector(point)
    obj.data.transform(Matrix.Translation(-p))
    obj.matrix_world = Matrix.Translation(p)


def tri_count(obj):
    return sum(len(p.vertices) - 2 for p in obj.data.polygons)


def finalize_and_export(name, objects, outdir=MODELS_OUT, parts=(), root=True):
    """Join `objects` into "Body", build the moving `parts`, parent everything
    under an empty called `name`, and export <outdir>/<name>.glb.
    Returns the glb path."""
    os.makedirs(outdir, exist_ok=True)
    part_objs = set()
    for p in parts:
        part_objs.update(id(o) for o in p.objects)
    body_src = [o for o in objects if id(o) not in part_objs]
    built = {}
    if body_src:
        body = _join(body_src, "Body")
        built["Body"] = body
    for p in parts:
        obj = _join(p.objects, p.name)
        _set_origin(obj, p.origin)
        built[p.name] = obj
    # hierarchy
    root_obj = None
    if root:
        root_obj = bpy.data.objects.new(name, None)
        bpy.context.scene.collection.objects.link(root_obj)
    for pname, obj in built.items():
        parent_name = None
        for p in parts:
            if p.name == pname:
                parent_name = p.parent
        parent = built.get(parent_name) if parent_name else root_obj
        if parent is None:
            parent = root_obj
        if parent is not None:
            mw = obj.matrix_world.copy()
            obj.parent = parent
            obj.matrix_parent_inverse = Matrix.Identity(4)
            obj.matrix_world = mw
    # stats
    total = 0
    print("---- %s" % name)
    for pname, obj in built.items():
        t = tri_count(obj)
        total += t
        mats = [m.name for m in obj.data.materials if m]
        print("  %-10s tris=%6d  materials=%d (%s)" % (pname, t, len(mats), ", ".join(mats)))
    print("  TOTAL tris=%d" % total)
    # export
    bpy.ops.object.select_all(action="DESELECT")
    if root_obj:
        root_obj.select_set(True)
    for obj in built.values():
        obj.select_set(True)
    path = os.path.join(outdir, name + ".glb")
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_materials="EXPORT",
        export_image_format="AUTO",
        export_yup=True,
        export_normals=True,
        export_texcoords=True,
        export_animations=False,
        export_skins=False,
        export_morph=False,
        export_cameras=False,
        export_lights=False,
    )
    print("  wrote %s (%.1f kB)" % (path, os.path.getsize(path) / 1024))
    return path


def begin(defaults=None):
    """Standard prologue for a model script: textures, empty scene, parsed args."""
    ensure_textures()
    reset_scene()
    return args(defaults)
