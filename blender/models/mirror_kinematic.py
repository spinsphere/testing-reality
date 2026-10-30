"""Ø1" protected-silver mirror in a two-adjuster kinematic mount on a post.
Mirror normal faces -X (upstream); rotate the whole model 45 degrees in Godot
to use it as a fold mirror.  Parts: Body, Optic (mirror).

    blender -b -P blender/models/mirror_kinematic.py -- [--name mirror_kinematic] [--beam-height 0.10]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "mirror_kinematic", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
centre = (0.0, 0.0, H)

mount = qlab.kinematic_mirror_mount(centre, bore=qlab.OPTIC_DIA)
body = list(mount["objects"])
stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(mount["front_x"] + 0.005, 0), name="Stack")
body += stack
body.append(qlab.label_decal("PartNo", "KM100", at=(0.0053, -0.0255, H - 0.019), size_m=(0.012, 0.003),
                             axis="-Y", px=(400, 100), pt=64, fg="#d8d8d8"))

# mirror substrate: 6 mm fused silica, reflective front face, set 2 mm into the bore
r = qlab.OPTIC_DIA / 2
sub = qlab.cylinder("Optic_Substrate", r, 0.006, at=(0.002, 0, H), axis="X", seg=64,
                    mat=qlab.glass(ior=1.46, tint=(0.9, 0.9, 0.9), alpha=0.5, name="Silica"))
face = qlab.disc("Optic_Coating", r - 0.0002, at=(0.00195, 0, H), axis="-X", seg=64, mat=qlab.mirror())
# retaining ring in front
rr = qlab.tube("Optic_RetRing", r + 0.0001, r - 0.0022, 0.0015, at=(0.0003, 0, H), axis="X", seg=48,
               mat=qlab.matte_black())
optic = [sub, face]
body.append(rr)

parts = [qlab.Part("Optic", optic, origin=centre, parent="Body")]
qlab.finalize_and_export(a["name"], body + optic, parts=parts)
