"""Linear polarizer in a manual rotation mount with an engraved 360 deg scale.

    blender -b -P blender/models/polarizer_rotation_mount.py -- [--name polarizer_rotation_mount]
                                                                [--beam-height 0.10]
Parts:  Body (post stack + housing), Rotor (dial ring; rotate about local X),
        Optic (polarizer, child of Rotor).
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "polarizer_rotation_mount", "beam_height": qlab.BEAM_HEIGHT,
                "label": "LPVISB050", "optic": "polarizer"})
H = float(a["beam_height"])
centre = (0.0, 0.0, H)

mount = qlab.rotation_mount_1in(centre, angle_scale=True)
body = list(mount["objects"])
stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(0, 0), name="Stack")
body += stack

# part-number engraving on the housing rim side
body.append(qlab.label_decal("PartNo", a["label"], at=(0.0, -0.028, H - 0.012), size_m=(0.014, 0.0035),
                             axis="-Y", px=(400, 100), pt=64, fg="#d8d8d8"))

# the optic: Ø1" dichroic film polarizer (dark glass) with a tiny arrow decal
# marking the transmission axis
if a["optic"] == "waveplate":
    optic = [qlab.cylinder("Optic_Glass", qlab.OPTIC_DIA / 2, 0.002, at=(-0.001, 0, H), axis="X", seg=64,
                           mat=qlab.waveplate_quartz())]
else:
    optic = [qlab.cylinder("Optic_Glass", qlab.OPTIC_DIA / 2, 0.002, at=(-0.001, 0, H), axis="X", seg=64,
                           mat=qlab.polarizer_film())]
optic.append(qlab.label_decal("Optic_Axis", "", at=(0.0011, 0.0, H + 0.0105), size_m=(0.004, 0.0015), axis="X",
                              lines=["↔"], px=(128, 48), pt=40, fg="#ffffff"))

parts = [
    qlab.Part("Rotor", mount["rotor"], origin=centre, parent="Body"),
    qlab.Part("Optic", optic, origin=centre, parent="Rotor"),
]
qlab.finalize_and_export(a["name"], body + mount["rotor"] + optic, parts=parts)
