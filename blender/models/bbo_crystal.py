"""Two thin type-I BBO crystals (5 x 5 x 0.5 mm, optic axes crossed) for SPDC
405 nm -> 810 nm pairs, held in a square-aperture cell inside a rotation
mount.  Parts: Body, Rotor, Optic (cell + crystals, child of Rotor).

    blender -b -P blender/models/bbo_crystal.py -- [--name bbo_crystal] [--beam-height 0.10]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "bbo_crystal", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
centre = (0.0, 0.0, H)
ab = qlab.anodised_black()

mount = qlab.rotation_mount_1in(centre, angle_scale=True)
body = list(mount["objects"])
stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(0, 0), name="Stack")
body += stack
body.append(qlab.label_decal("PartNo", "BBO  TYPE I  405>810", at=(0.0, -0.028, H - 0.012), size_m=(0.020, 0.0035),
                             axis="-Y", px=(640, 100), pt=60, fg="#d8d8d8"))

# cell: Ø1" black ring with a 6 mm square aperture, crystals stacked inside
r = qlab.OPTIC_DIA / 2
cell = qlab.plate_with_hole("Optic_Cell", 2 * r - 0.004, 2 * r - 0.004, 0.004, slot=(0.0062, 0.0062), at=(0, 0, H),
                            axis="X", mat=ab)
rim = qlab.tube("Optic_Rim", r, r - 0.002, 0.004, at=(-0.002, 0, H), axis="X", seg=64, mat=ab)
bbo = qlab.glass(ior=1.66, tint=(0.90, 0.94, 1.0), alpha=0.3, roughness=0.02, name="BBO")
c1 = qlab.box("Optic_BBO1", (0.0005, 0.005, 0.005), at=(-0.0003, 0, H), mat=bbo)
c2 = qlab.box("Optic_BBO2", (0.0005, 0.005, 0.005), at=(0.0003, 0, H), mat=bbo)
# optic-axis marks on the cell face (crossed)
m1 = qlab.label_decal("Optic_Mark", "", at=(0.00205, 0.0, H + 0.0055), size_m=(0.004, 0.0015), axis="X",
                      lines=["↔"], px=(128, 48), pt=40, fg="#ffffff")
m2 = qlab.label_decal("Optic_Mark2", "", at=(0.00205, 0.0055, H), size_m=(0.0015, 0.004), axis="X",
                      lines=["↕"], px=(48, 128), pt=40, fg="#ffffff")
optic = [cell, rim, c1, c2, m1, m2]

parts = [qlab.Part("Rotor", mount["rotor"], origin=centre, parent="Body"),
         qlab.Part("Optic", optic, origin=centre, parent="Rotor")]
qlab.finalize_and_export(a["name"], body + mount["rotor"] + optic, parts=parts)
