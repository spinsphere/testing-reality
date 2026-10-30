"""Stand-alone beam dump on a post: entrance faces -X (stops a beam travelling
along +X).  Parts: Body.

    blender -b -P blender/models/beam_dump.py -- [--name beam_dump] [--beam-height 0.10]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "beam_dump", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
h = 0.025
body = qlab.beam_dump((0.020, 0.0, H - h / 2), facing="-X", name="BeamDump", size=(0.025, 0.040, h))
stack, _ = qlab.post_stack(H - h / 2, at=(0.020, 0), name="Stack")
body += stack
qlab.finalize_and_export(a["name"], body)
