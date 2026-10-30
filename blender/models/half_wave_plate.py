"""Zero-order half-wave plate (lambda/2) in the same rotation-mount family as
the polarizers.  Parts: Body, Rotor (rotate about local X), Optic (child of Rotor).

    blender -b -P blender/models/half_wave_plate.py -- [--name half_wave_plate] [--beam-height 0.10]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "half_wave_plate", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
centre = (0.0, 0.0, H)

mount = qlab.rotation_mount_1in(centre, angle_scale=True)
body = list(mount["objects"])
stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(0, 0), name="Stack")
body += stack
body.append(qlab.label_decal("PartNo", "WPH05M-405", at=(0.0, -0.028, H - 0.012), size_m=(0.016, 0.0035),
                             axis="-Y", px=(460, 100), pt=64, fg="#d8d8d8"))
# the lambda/2 marking engraved on the housing front, below the dial
body.append(qlab.label_decal("Lambda", "λ/2", at=(0.0061, 0.0, H - 0.0268), size_m=(0.006, 0.003), axis="X",
                             px=(200, 100), pt=72, fg="#ffffff", font="DejaVu-Sans"))

# the optic: true zero-order quartz waveplate, Ø1", 1 mm thick, in a black cell
optic = [qlab.cylinder("Optic_Glass", qlab.OPTIC_DIA / 2 - 0.0025, 0.001, at=(-0.0005, 0, H), axis="X", seg=64,
                       mat=qlab.waveplate_quartz()),
         qlab.tube("Optic_Cell", qlab.OPTIC_DIA / 2, qlab.OPTIC_DIA / 2 - 0.0025, 0.004, at=(-0.002, 0, H),
                   axis="X", seg=64, mat=qlab.anodised_black()),
         # fast-axis mark on the cell
         qlab.label_decal("Optic_FastAxis", "", at=(0.0021, 0.0, H + 0.0115), size_m=(0.003, 0.0012), axis="X",
                          lines=["|"], px=(96, 48), pt=40, fg="#ffffff")]

parts = [
    qlab.Part("Rotor", mount["rotor"], origin=centre, parent="Body"),
    qlab.Part("Optic", optic, origin=centre, parent="Rotor"),
]
qlab.finalize_and_export(a["name"], body + mount["rotor"] + optic, parts=parts)
