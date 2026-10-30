"""Polarizing beam-splitter cube (20 mm) on a platform mount with a clamp arm,
plus a small beam dump on the reflected (+Y) port.  Parts: Body, Optic (cube).

    blender -b -P blender/models/pbs_cube.py -- [--name pbs_cube] [--cube 0.020] [--beam-height 0.10]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "pbs_cube", "cube": 0.020, "beam_height": qlab.BEAM_HEIGHT, "dump": True})
H = float(a["beam_height"])
S = float(a["cube"])
centre = (0.0, 0.0, H)

mount = qlab.cube_mount(centre, cube=S)
body = list(mount["objects"])
stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(0, 0), name="Stack")
body += stack
body.append(qlab.label_decal("PartNo", "PBS201", at=(0.0, -S / 2 - 0.010, H - S / 2 - 0.004), size_m=(0.012, 0.003),
                             axis="-Y", px=(400, 100), pt=64, fg="#d8d8d8"))

optic = qlab.pbs_cube(centre, size=S)

if a["dump"]:
    dy = 0.055
    dump = qlab.beam_dump((0.0, dy + 0.020, H - 0.0125), facing="-Y", name="BeamDump")
    dstack, _ = qlab.post_stack(H - 0.0125, at=(0, dy + 0.020), name="DumpStack", along="Y", screw_side="X")
    body += dump + dstack

parts = [qlab.Part("Optic", optic, origin=centre, parent="Body")]
qlab.finalize_and_export(a["name"], body + optic, parts=parts)
