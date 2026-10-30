"""Plano-convex N-BK7 lens in a fixed Ø1" lens mount on a post.

    blender -b -P blender/models/lens_mount.py -- [--focal 0.5] [--name lens_mount_f500] [--beam-height 0.10]

Without --focal, two variants are exported: lens_mount_f500 (L1 = 50 cm in
the experiment) and lens_mount_f50 (the short focusing lens in front of the
detector).  Convex side faces +X (downstream).  Parts: Body, Optic.
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

N_BK7 = 1.5168


def build(focal, name, H):
    qlab.reset_scene()
    centre = (0.0, 0.0, H)
    mount = qlab.lens_mount_1in(centre)
    body = list(mount["objects"])
    stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(0, 0), name="Stack")
    body += stack
    R = focal * (N_BK7 - 1)
    body.append(qlab.label_decal("PartNo", "LA1908-A  f=%d mm" % round(focal * 1000),
                                 at=(0.0, -0.0192, H - 0.0105), size_m=(0.014, 0.0025), axis="-Y",
                                 px=(560, 100), pt=56, fg="#d8d8d8"))
    # the lens: flat face at x = -ct/2, convex bulging downstream
    ct = 0.0036 if focal < 0.1 else 0.0028
    lens = qlab.lens_planoconvex("Optic_Lens", dia=qlab.OPTIC_DIA, R=R, ct=ct, at=(-ct / 2, 0, H), axis="X",
                                 mat=qlab.ar_coated_glass(), seg=64, arc_steps=12 if focal < 0.1 else 6)
    parts = [qlab.Part("Optic", [lens], origin=centre, parent="Body")]
    qlab.finalize_and_export(name, body + [lens], parts=parts)


a = qlab.begin({"focal": 0.0, "name": "", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
if float(a["focal"]) > 0:
    f = float(a["focal"])
    build(f, a["name"] or "lens_mount_f%d" % round(f * 1000), H)
else:
    build(0.5, "lens_mount_f500", H)
    build(0.05, "lens_mount_f50", H)
