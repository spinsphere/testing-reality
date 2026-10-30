"""Berek polarisation compensator: a tiltable MgF2 plate inside a rotation
mount.  Retardance is set by tilting the plate (knob on the rotor rim with a
vernier), the fast axis by rotating the rotor.

Parts: Body, Rotor (rotate about local X), Tilt (child of Rotor; rotate about
local Z = the tilt pivot), Optic (plate, child of Tilt).

    blender -b -P blender/models/berek_compensator.py -- [--name berek_compensator] [--beam-height 0.10]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "berek_compensator", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
centre = (0.0, 0.0, H)
ab = qlab.anodised_black()
st = qlab.stainless()

mount = qlab.rotation_mount_1in(centre, angle_scale=True)
body = list(mount["objects"])
stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(0, 0), name="Stack")
body += stack
body.append(qlab.label_decal("PartNo", "BEREK COMPENSATOR", at=(0.0, -0.028, H - 0.012), size_m=(0.020, 0.0035),
                             axis="-Y", px=(640, 100), pt=60, fg="#d8d8d8"))

rotor = list(mount["rotor"])
# tilt drive on the rotor: a graduated drum at 3 o'clock with a stainless knob
drum = qlab.revolve("Drum", [(0, 0), (0.006, 0), (0.0065, 0.0005), (0.0065, 0.010), (0.006, 0.0105), (0, 0.0105)],
                    at=(0.0, 0.0245, H), axis="Y", seg=32, mat=ab, uv_scale=0.01)
drum_scale = qlab.label_decal("DrumScale", "tilt", at=(0.0, 0.0245 + 0.0066, H), size_m=(0.010, 0.006), axis="Y",
                              lines=["0  10  20  30", "| | | | | | |"], px=(300, 180), pt=34, fg="#eeeeee",
                              bg="#101010", transparent=False, font="DejaVu-Sans-Mono")
knob = qlab.revolve("TiltKnob", [(0, 0), (0.004, 0), (0.0045, 0.0005), (0.0045, 0.008), (0.004, 0.0085), (0, 0.0085)],
                    at=(0.0, 0.035, H), axis="Y", seg=24, mat=qlab.knurled_steel(), uv_scale=0.008)
rotor += [drum, drum_scale, knob]

# tilt frame: ring on two pivots (along Z), carrying the plate
r_frame = qlab.OPTIC_DIA / 2 - 0.0004
frame = qlab.tube("Tilt_Frame", r_frame, r_frame - 0.0022, 0.0035, at=(-0.00175, 0, H), axis="X", seg=64, mat=ab)
piv1 = qlab.cylinder("Tilt_Pivot", 0.001, 0.003, at=(0, 0, H + r_frame - 0.0005), seg=10, mat=st)
piv2 = qlab.cylinder("Tilt_Pivot2", 0.001, 0.003, at=(0, 0, H - r_frame - 0.0025), seg=10, mat=st)
tilt = [frame, piv1, piv2]

# the MgF2 plate
plate = qlab.cylinder("Optic_Plate", r_frame - 0.0022, 0.002, at=(-0.001, 0, H), axis="X", seg=64,
                      mat=qlab.glass(ior=1.38, tint=(0.96, 0.97, 1.0), alpha=0.18, roughness=0.02, name="MgF2"))
optic = [plate]

parts = [qlab.Part("Rotor", rotor, origin=centre, parent="Body"),
         qlab.Part("Tilt", tilt, origin=centre, parent="Rotor"),
         qlab.Part("Optic", optic, origin=centre, parent="Tilt")]
qlab.finalize_and_export(a["name"], body + rotor + tilt + optic, parts=parts)
