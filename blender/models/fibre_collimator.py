"""Fibre collimation package in a clamp on a post, collecting light travelling
along +X, with a Ø1" bandpass filter in a lens mount in front of it and an
orange multimode fibre pigtail (FC/PC) trailing onto the table.

Parts: Body, Optic (the bandpass filter, child of Body).

    blender -b -P blender/models/fibre_collimator.py -- [--name fibre_collimator] [--beam-height 0.10]
                                                         [--filter "FBH810-10"]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402
from mathutils import Vector  # noqa: E402

a = qlab.begin({"name": "fibre_collimator", "beam_height": qlab.BEAM_HEIGHT, "filter": "FBH810-10"})
H = float(a["beam_height"])
ab = qlab.anodised_black()
st = qlab.stainless()

# collimator: front (lens) at x = 0.012, tube running downstream (+X)
rear = Vector((0.046, 0, H))
col, front = qlab.fibre_collimator(rear, axis="-X", length=0.034, name="Collimator")
body = list(col)
# clamp ring + tab + post under the tube
cx = 0.030
body.append(qlab.tube("Clamp", 0.0095, 0.0061, 0.010, at=(cx - 0.005, 0, H), axis="X", seg=40, mat=ab))
body.append(qlab.box("ClampTab", (0.010, 0.012, 0.012), at=(cx, 0, H - 0.012), mat=ab, bevel=0.0005))
body.append(qlab.cylinder("ClampScrew", 0.0018, 0.004, at=(cx, 0, H + 0.0092), seg=12, mat=st))
stack, _ = qlab.post_stack(H - 0.018, at=(cx, 0), name="Stack")
body += stack

# bandpass filter in a fixed lens mount 8 mm in front of the collimator
fx = front.x - 0.010
fmount = qlab.lens_mount_1in((fx, 0, H), name="FilterMount")
body += fmount["objects"]
fstack, _ = qlab.post_stack(H - fmount["optic_offset"], at=(fx, 0), name="FilterStack")
body += fstack
body.append(qlab.label_decal("FilterLabel", a["filter"], at=(fx, -0.0192, H - 0.0105), size_m=(0.014, 0.0025), axis="-Y",
                             px=(560, 100), pt=56, fg="#d8d8d8"))
r = qlab.OPTIC_DIA / 2
filt = [qlab.cylinder("Optic_Filter", r - 0.0025, 0.003, at=(fx - 0.0015, 0, H), axis="X", seg=64,
                      mat=qlab.glass(ior=1.5, tint=(0.95, 0.35, 0.25), alpha=0.75, roughness=0.03, name="BandpassFilter")),
        qlab.tube("Optic_Ring", r, r - 0.0025, 0.0045, at=(fx - 0.00225, 0, H), axis="X", seg=64, mat=ab)]

# orange fibre pigtail from the FC boot, looping down onto the table and away
boot_end = rear + Vector((0.0325, 0, 0))
pts = [tuple(boot_end), (boot_end.x + 0.02, 0.0, H - 0.004), (boot_end.x + 0.045, 0.012, H - 0.045),
       (boot_end.x + 0.05, 0.03, 0.0025), (boot_end.x + 0.02, 0.07, 0.0025), (boot_end.x - 0.03, 0.09, 0.0025)]
body.append(qlab.cable("Fibre", pts, radius=0.0015, mat=qlab.abs_plastic((0.95, 0.40, 0.05), 0.5, name="FibreOrange")))
# loose FC/PC connector at the far end
end = Vector(pts[-1])
body.append(qlab.revolve("FCEnd", [(0.0012, 0), (0.0045, 0), (0.0045, 0.010), (0.0012, 0.010)], at=end, axis="-X",
                         seg=24, mat=qlab.knurled_steel(), uv_scale=0.01))
body.append(qlab.cylinder("FCFerrule", 0.0013, 0.004, at=end + Vector((-0.010, 0, 0)), axis="-X", seg=12,
                          mat=qlab.abs_plastic((0.95, 0.95, 0.95), 0.4, name="Ceramic")))

parts = [qlab.Part("Optic", filt, origin=(fx, 0, H), parent="Body")]
qlab.finalize_and_export(a["name"], body + filt, parts=parts)
