"""Small polarizer film glued over one slit of the double-slit mask (PA / PB in
Experiments 3 and 5-7): a 7 mm dichroic film disc in a 1 mm black ring, held
by a thin tab that is stuck to the mask plate above the aperture.

Parts: Body (tab + pad), Rotor (ring + film + axis mark; rotates about local X).

    blender -b -P blender/models/polarizer_film.py -- [--name polarizer_film] [--beam-height 0.10]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "polarizer_film", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
centre = (0.0, 0.0, H)
R_OUT = 0.0045
R_IN = 0.0035

# the tab glued to the mask: a thin vertical strip above the ring and a pad at its top
body = [
    qlab.box("Tab", (0.0012, 0.0024, 0.0075), at=(0.0, 0.0, H + R_OUT + 0.00375), mat=qlab.matte_black()),
    qlab.box("Pad", (0.0012, 0.006, 0.002), at=(0.0, 0.0, H + R_OUT + 0.0085), mat=qlab.matte_black()),
]
rotor = [
    qlab.tube("Ring", R_OUT, R_IN, 0.0015, at=(0.0, 0.0, H), axis="X", seg=48, mat=qlab.anodised_black()),
    qlab.cylinder("Film", R_IN + 0.0002, 0.0005, at=(0.0, 0.0, H), axis="X", seg=48, mat=qlab.polarizer_film()),
    # transmission-axis mark on the ring rim
    qlab.label_decal("AxisMark", "", at=(0.0008, 0.0, H + R_OUT - 0.0005), size_m=(0.0016, 0.0006), axis="X",
                     lines=["|"], px=(64, 32), pt=28, fg="#ffffff"),
]
parts = [qlab.Part("Rotor", rotor, origin=centre, parent="Body")]
qlab.finalize_and_export(a["name"], body + rotor, parts=parts)
