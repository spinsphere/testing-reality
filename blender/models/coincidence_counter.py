"""Coincidence counting unit: a small bench-top electronics box with four BNC
inputs, a count display, status LEDs and a USB port.  Sits on the table on
rubber feet; its front panel faces -Y.  Parts: Body.

    blender -b -P blender/models/coincidence_counter.py -- [--name coincidence_counter]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "coincidence_counter"})
W, D, Hh = 0.150, 0.110, 0.045
ab = qlab.anodised_black()
st = qlab.stainless()
z0 = 0.004
body = [qlab.box("Case", (W, D, Hh), at=(0, 0, z0), mat=ab, bevel=0.0012, anchor="bottom")]
for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
    body.append(qlab.cylinder("Foot", 0.005, z0, at=(sx * (W / 2 - 0.012), sy * (D / 2 - 0.012), 0), seg=16,
                              mat=qlab.rubber()))
# front panel (slightly proud, darker grey) with silkscreen
fy = -D / 2
panel = qlab.box("Panel", (W - 0.004, 0.0015, Hh - 0.004), at=(0, fy - 0.00075, z0 + Hh / 2),
                 mat=qlab.anodised_colour((0.09, 0.09, 0.095), name="PanelGrey"))
body.append(panel)
py = fy - 0.0015
zc = z0 + Hh / 2
# four BNC inputs
for i, lbl in enumerate(("A", "B", "C", "D")):
    x = -W / 2 + 0.018 + i * 0.016
    body.append(qlab.revolve("BNC%d" % i, [(0, 0), (0.0045, 0), (0.0045, 0.004), (0.0048, 0.004), (0.0048, 0.012),
                                            (0.0042, 0.012), (0.0042, 0.0135), (0.002, 0.0135), (0.002, 0.004), (0, 0.004)],
                             at=(x, py, zc - 0.008), axis="-Y", seg=28, mat=st, uv_scale=0.01))
    body.append(qlab.revolve("BNCPin%d" % i, [(0, 0), (0.0007, 0), (0.0007, 0.012), (0, 0.012)], at=(x, py, zc - 0.008),
                             axis="-Y", seg=10, mat=qlab.brass()))
    body.append(qlab.label_decal("In%d" % i, lbl, at=(x, py, zc + 0.0045), size_m=(0.006, 0.004), axis="-Y",
                                 px=(120, 80), pt=60, fg="#e8e8e8"))
    body.append(qlab.cylinder("LED%d" % i, 0.0012, 0.0008, at=(x + 0.005, py, zc + 0.0045), axis="-Y", seg=10,
                              mat=qlab.emissive((0.1, 1.0, 0.2), 2.5, name="LEDGreen")))
# display: dark window with glowing 7-segment style readout
dx = W / 2 - 0.040
body.append(qlab.box("DisplayWindow", (0.056, 0.0012, 0.020), at=(dx, py - 0.0003, zc + 0.003),
                     mat=qlab.glass(ior=1.5, tint=(0.05, 0.06, 0.05), alpha=0.9, roughness=0.1, name="DisplayGlass")))
body.append(qlab.label_decal("Readout", "readout", at=(dx, py - 0.001, zc + 0.003), size_m=(0.052, 0.016), axis="-Y",
                             lines=["AB  000234 /s", "A 001159  B 001143"], px=(650, 200), pt=50, fg="#40ff70",
                             bg="#061006", transparent=False, font="DejaVu-Sans-Mono"))
body.append(qlab.label_decal("Title", "title", at=(dx, py, zc - 0.0145), size_m=(0.056, 0.005), axis="-Y",
                             lines=["COINCIDENCE COUNTER   window 8 ns"], px=(700, 64), pt=44, fg="#e8e8e8"))
body.append(qlab.label_decal("Brand", "brand", at=(-W / 2 + 0.04, py, zc + 0.016), size_m=(0.060, 0.005), axis="-Y",
                             lines=["INPUTS  (TTL, 50 Ω)"], px=(700, 64), pt=44, fg="#bdbdbd"))
# power switch and USB on the rear
by = D / 2
body.append(qlab.box("Switch", (0.012, 0.004, 0.008), at=(W / 2 - 0.02, by + 0.002, zc - 0.006), mat=qlab.matte_black(), bevel=0.0004))
body.append(qlab.box("USB", (0.012, 0.004, 0.0055), at=(W / 2 - 0.04, by + 0.002, zc - 0.006), mat=st))
body.append(qlab.revolve("DCJack", [(0, 0), (0.004, 0), (0.004, 0.006), (0.002, 0.006), (0.002, 0.002), (0, 0.002)],
                         at=(W / 2 - 0.06, by, zc - 0.006), axis="Y", seg=20, mat=qlab.matte_black(), uv_scale=0.01))
body.append(qlab.cable("PowerCable", [(W / 2 - 0.06, by + 0.006, zc - 0.006), (W / 2 - 0.06, by + 0.03, zc - 0.02),
                                      (W / 2 - 0.05, by + 0.06, 0.0025), (W / 2 + 0.02, by + 0.10, 0.0025)], radius=0.002))
body.append(qlab.cable("USBCable", [(W / 2 - 0.04, by + 0.004, zc - 0.006), (W / 2 - 0.04, by + 0.03, zc - 0.015),
                                    (W / 2 - 0.02, by + 0.06, 0.0025), (W / 2 + 0.05, by + 0.09, 0.0025)], radius=0.0018,
                       mat=qlab.abs_plastic((0.85, 0.85, 0.82), 0.6, name="WhiteCable")))
# lid screws
for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
    body += qlab.cap_screw("LidScrew", (sx * (W / 2 - 0.008), sy * (D / 2 - 0.008), z0 + Hh), dia=0.003, axis="Z",
                           head_h=0.002)
qlab.finalize_and_export(a["name"], body)
