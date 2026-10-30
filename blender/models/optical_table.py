"""Optical breadboard table: black anodised honeycomb breadboard with a 25 mm
M6 hole grid (holes in the textures, plus real countersunk holes along the
rows nearest the optical axis), on a steel frame.

Origin: table surface at z = 0 directly under the optical axis; hole rows run
along X with row 0 at y = 0 and columns at x = k * 25 mm.

    blender -b -P blender/models/optical_table.py -- [--length 1.2] [--width 0.6] [--thickness 0.06]
                                                      [--real-rows 1] [--height 0.80] [--name optical_table]
                                                      [--no-frame]
Parts: Body only.
"""
import math
import os
import sys

import bmesh

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"length": 1.2, "width": 0.6, "thickness": 0.06, "real_rows": 1, "height": 0.80,
                "name": "optical_table", "no_frame": False})
L, W, T = float(a["length"]), float(a["width"]), float(a["thickness"])
PITCH = 0.025
ROWS = int(a["real_rows"])
HEIGHT = float(a["height"])

# hole grid: columns/rows symmetric about the origin with >= 12.5 mm edge margin
nx = int((L - PITCH) // PITCH)
ny = int((W - PITCH) // PITCH)
if nx % 2 == 0:
    nx -= 1          # keep a column at x = 0
if ny % 2 == 0:
    ny -= 1          # keep a row at y = 0
xs = [(i - (nx - 1) / 2) * PITCH for i in range(nx)]
ys = [(j - (ny - 1) / 2) * PITCH for j in range(ny)]
real_rows = [y for y in ys if abs(y) <= (ROWS - 1) / 2 * PITCH + 1e-6]

R_CSK, R_BORE, CSK_D, BORE_D, SEG = 0.0040, 0.00325, 0.0015, 0.012, 12

bm = bmesh.new()
flat_uv = bm.loops.layers.uv.new("UVMap")


def V(x, y, z):
    return bm.verts.new((x, y, z))


# --- top surface: full-width strips between the real-hole bands, hole cells inside them
bands = sorted(real_rows)
y_edges = [-W / 2]
for y in bands:
    y_edges += [y - PITCH / 2, y + PITCH / 2]
y_edges.append(W / 2)
# strips (quads) between bands
for k in range(0, len(y_edges), 2):
    y0, y1 = y_edges[k], y_edges[k + 1]
    if y1 - y0 > 1e-6:
        bm.faces.new((V(-L / 2, y0, 0), V(L / 2, y0, 0), V(L / 2, y1, 0), V(-L / 2, y1, 0)))
hole_faces = []
for y in bands:
    y0, y1 = y - PITCH / 2, y + PITCH / 2
    # end strips outside the first/last column cell
    xe0, xe1 = xs[0] - PITCH / 2, xs[-1] + PITCH / 2
    bm.faces.new((V(-L / 2, y0, 0), V(xe0, y0, 0), V(xe0, y1, 0), V(-L / 2, y1, 0)))
    bm.faces.new((V(xe1, y0, 0), V(L / 2, y0, 0), V(L / 2, y1, 0), V(xe1, y1, 0)))
    for x in xs:
        cx0, cx1 = x - PITCH / 2, x + PITCH / 2
        # outer loop: square perimeter sampled at SEG points
        outer, csk, bore, bot = [], [], [], []
        for i in range(SEG):
            ang = qlab.TAU * i / SEG + math.pi / 4
            ca, sa = math.cos(ang), math.sin(ang)
            tt = min((PITCH / 2) / abs(ca), (PITCH / 2) / abs(sa))
            outer.append(V(x + ca * tt, y + sa * tt, 0))
            csk.append(V(x + ca * R_CSK, y + sa * R_CSK, 0))
            bore.append(V(x + ca * R_BORE, y + sa * R_BORE, -CSK_D))
            bot.append(V(x + ca * R_BORE, y + sa * R_BORE, -BORE_D))
        for i in range(SEG):
            j = (i + 1) % SEG
            bm.faces.new((outer[i], outer[j], csk[j], csk[i]))
            hole_faces.append(bm.faces.new((csk[i], csk[j], bore[j], bore[i])))
            hole_faces.append(bm.faces.new((bore[i], bore[j], bot[j], bot[i])))
        hole_faces.append(bm.faces.new(list(reversed(bot))))
# --- sides and bottom
c = [V(-L / 2, -W / 2, -T), V(L / 2, -W / 2, -T), V(L / 2, W / 2, -T), V(-L / 2, W / 2, -T)]
bm.faces.new(list(reversed(c)))
top_corners = {}
for v in bm.verts:
    if abs(v.co.z) < 1e-9 and abs(abs(v.co.x) - L / 2) < 1e-9 and abs(abs(v.co.y) - W / 2) < 1e-9:
        top_corners[(round(v.co.x, 6), round(v.co.y, 6))] = v
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-7)
# side walls: collect top boundary edges along each side and bridge to the bottom
side_faces = []
for sgn, axis in ((-1, "y"), (1, "y"), (-1, "x"), (1, "x")):
    edge_verts = sorted([v for v in bm.verts if abs(v.co.z) < 1e-9 and
                         abs((v.co.y if axis == "y" else v.co.x) - sgn * (W / 2 if axis == "y" else L / 2)) < 1e-9],
                        key=lambda v: (v.co.x if axis == "y" else v.co.y))
    for v0, v1 in zip(edge_verts[:-1], edge_verts[1:]):
        b0 = bm.verts.new((v0.co.x, v0.co.y, -T))
        b1 = bm.verts.new((v1.co.x, v1.co.y, -T))
        side_faces.append(bm.faces.new((v0, v1, b1, b0)))
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-7)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)

# UVs: top surface aligned to the texture tile (hole centre at tile (12.5, 12.5) mm);
# hole walls and sides map to flat, hole-free texture areas
TILE = 2 * PITCH
hole_ids = set(id(f) for f in hole_faces)
side_ids = set(id(f) for f in side_faces)
for f in bm.faces:
    for loop in f.loops:
        co = loop.vert.co
        if id(f) in hole_ids:
            loop[flat_uv].uv = (0.5, 0.5)
        elif id(f) in side_ids or f.normal.z < -0.5:
            # sides/bottom: brushed only -> map onto the flat centre area, stretched along the side
            u = (co.x if abs(f.normal.y) > 0.5 else co.y) / 0.05
            loop[flat_uv].uv = (u, 0.5 + (co.z + T / 2) / 0.05 * 0.02)
        else:
            loop[flat_uv].uv = ((co.x + PITCH / 2) / TILE, (co.y + PITCH / 2) / TILE)
top = qlab._finish_bm("Breadboard", bm, qlab.breadboard(), uv=None)
for p in top.data.polygons:
    p.use_smooth = False

body = [top]

# --- edge trim: a thin stainless-looking band around the top edge (honeycomb skin seam)
body.append(qlab.box("EdgeSeam", (L + 0.0004, W + 0.0004, 0.004), at=(0, 0, -T + 0.012), mat=qlab.matte_black(name="SeamPaint", base=(0.03, 0.03, 0.03), rough=0.5)))
# spec plate on the front (-Y) side
body.append(qlab.label_decal("SpecPlate", "spec", at=(-L / 2 + 0.14, -W / 2, -T / 2), size_m=(0.14, 0.03), axis="-Y",
                             lines=["OPTICAL BREADBOARD  %d x %d mm" % (round(L * 1000), round(W * 1000)),
                                    "M6 x 25 mm GRID  -  HONEYCOMB CORE"], px=(900, 200), pt=44, fg="#e0e0e0",
                             bg="#1a1a1a", transparent=False))

# --- frame: square-tube legs, aprons, levelling feet
if not a["no_frame"]:
    paint = qlab.matte_black(name="FramePaint", base=(0.04, 0.04, 0.045), rough=0.55)
    leg = 0.05
    z_floor = -HEIGHT
    inset = 0.06
    for sx in (-1, 1):
        for sy in (-1, 1):
            x, y = sx * (L / 2 - inset), sy * (W / 2 - inset)
            body.append(qlab.box("Leg", (leg, leg, HEIGHT - T - 0.03), at=(x, y, z_floor + 0.03), mat=paint,
                                 bevel=0.002, anchor="bottom"))
            body.append(qlab.cylinder("Foot", 0.03, 0.012, at=(x, y, z_floor), seg=24, mat=qlab.rubber()))
            body.append(qlab.cylinder("FootStem", 0.008, 0.02, at=(x, y, z_floor + 0.012), seg=16, mat=qlab.stainless()))
    # aprons just under the slab and a lower shelf rail
    for sy in (-1, 1):
        body.append(qlab.box("Apron", (L - 2 * inset + leg, leg * 0.6, 0.08), at=(0, sy * (W / 2 - inset), -T - 0.045),
                             mat=paint, bevel=0.002))
        body.append(qlab.box("LowerRail", (L - 2 * inset + leg, leg * 0.6, leg), at=(0, sy * (W / 2 - inset), z_floor + 0.15),
                             mat=paint, bevel=0.002))
    for sx in (-1, 1):
        body.append(qlab.box("Apron", (leg * 0.6, W - 2 * inset - leg, 0.08), at=(sx * (L / 2 - inset), 0, -T - 0.045),
                             mat=paint, bevel=0.002))
        body.append(qlab.box("LowerRail", (leg * 0.6, W - 2 * inset - leg, leg), at=(sx * (L / 2 - inset), 0, z_floor + 0.15),
                             mat=paint, bevel=0.002))

qlab.finalize_and_export(a["name"], body)
