"""Adjustable mechanical slit (VA100 style): two knife-edge stainless jaws in a
square black housing, width set by a micrometer knob on top.

Parts: Body, JawA / JawB (translate along local Y, symmetric about the axis;
origins at the slit centre; the default opening is `--width`).

    blender -b -P blender/models/single_slit_adjustable.py -- [--name single_slit_adjustable]
                                                               [--beam-height 0.10] [--width 0.0005]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "single_slit_adjustable", "beam_height": qlab.BEAM_HEIGHT, "width": 0.0005})
H = float(a["beam_height"])
WIDTH = float(a["width"])
centre = (0.0, 0.0, H)
ab = qlab.anodised_black()
st = qlab.stainless()

S = 0.050
T = 0.012
# housing with a 12 x 12 mm square aperture
housing = qlab.plate_with_hole("Housing", S, S, T, slot=(0.012, 0.012), at=centre, axis="X", mat=ab)
body = [housing]
# four cover-plate screws on the downstream face
for sy, sz in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
    body += qlab.cap_screw("Screw", (T / 2, sy * 0.020, H + sz * 0.020), dia=0.0025, axis="X", head_h=0.0018)
# mounting tab below and post stack
tab = qlab.box("Tab", (T, 0.016, 0.010), at=(0, 0, H - S / 2 - 0.005 + 0.001), mat=ab, bevel=0.0005)
body.append(tab)
stack, _ = qlab.post_stack(H - S / 2 - 0.009, at=(0, 0), name="Stack")
body += stack
# micrometer drive on top: barrel + thimble (knurled) + vernier scale decal
mz = H + S / 2
body.append(qlab.cylinder("MicBarrel", 0.0045, 0.014, at=(0, 0, mz), seg=24, mat=st, chamfer=0.0005))
body.append(qlab.revolve("Thimble", [(0, 0), (0.0055, 0), (0.006, 0.0005), (0.006, 0.015), (0.0055, 0.0155), (0, 0.0155)],
                         at=(0, 0, mz + 0.014), seg=28, mat=qlab.knurled_steel(), uv_scale=0.012))
body.append(qlab.cylinder("Ratchet", 0.0035, 0.006, at=(0, 0, mz + 0.0295), seg=20, mat=st, chamfer=0.0005))
body.append(qlab.label_decal("MicScale", "", at=(0, -0.0046, mz + 0.007), size_m=(0.006, 0.012), axis="-Y",
                             lines=["0 -", "5 -", "10-", "15-"], px=(120, 240), pt=36, fg="#111111",
                             bg="#dddddd", transparent=False, font="DejaVu-Sans-Mono"))
body.append(qlab.label_decal("PartNo", "VA100  0-6 mm", at=(-T / 2, 0.0, H - 0.020), size_m=(0.022, 0.004), axis="-X",
                             px=(560, 100), pt=56, fg="#d8d8d8"))
body.append(qlab.label_decal("Side", "slit", at=(0.0, -S / 2, H - 0.019), size_m=(0.014, 0.003), axis="-Y",
                             lines=["ADJ. SLIT"], px=(400, 90), pt=56, fg="#d8d8d8"))

# jaws: knife-edge blades meeting at the axis, visible through the aperture
def jaw(name, sign):
    w = 0.009
    yc = sign * (WIDTH / 2 + w / 2)
    b = qlab.box(name + "_Blade", (0.0008, w, 0.014), at=(-0.0004, yc, H), mat=st)
    # bevel edge: a dark thin strip at the knife edge
    e = qlab.box(name + "_Edge", (0.0009, 0.0002, 0.014), at=(-0.0004, sign * (WIDTH / 2 + 0.0001), H),
                 mat=qlab.matte_black(name="EdgeDark", base=(0.2, 0.2, 0.2), rough=0.3))
    return [b, e]


jaw_a = jaw("JawA", -1)
jaw_b = jaw("JawB", 1)

parts = [qlab.Part("JawA", jaw_a, origin=centre, parent="Body"),
         qlab.Part("JawB", jaw_b, origin=centre, parent="Body")]
qlab.finalize_and_export(a["name"], body + jaw_a + jaw_b, parts=parts)
