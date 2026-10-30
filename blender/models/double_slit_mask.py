"""In-house double slit: a chrome-on-glass mask (two 200 um slits separated by
200 um, 3 mm tall) on a Ø1" clear substrate in a fixed lens mount, with a
small sliding shutter that can cover one slit.

Parts: Body, Optic (substrate + chrome mask, child of Body),
       Cover (shutter blade; origin at the slit centre, slides along its local
       Y: -0.0004 m covers the +Y slit).

    blender -b -P blender/models/double_slit_mask.py -- [--name double_slit_mask] [--beam-height 0.10]
                                                         [--slit 0.0002] [--gap 0.0002]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402

a = qlab.begin({"name": "double_slit_mask", "beam_height": qlab.BEAM_HEIGHT, "slit": 0.0002, "gap": 0.0002})
H = float(a["beam_height"])
SW, GAP = float(a["slit"]), float(a["gap"])
SLIT_H = 0.003
centre = (0.0, 0.0, H)

mount = qlab.lens_mount_1in(centre)
body = list(mount["objects"])
stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(0, 0), name="Stack")
body += stack
body.append(qlab.label_decal("PartNo", "DOUBLE SLIT  %d/%d/%d µm" % (round(SW * 1e6), round(GAP * 1e6), round(SW * 1e6)),
                             at=(0.0, -0.0192, H - 0.0105), size_m=(0.016, 0.0025), axis="-Y",
                             px=(700, 100), pt=56, fg="#d8d8d8"))

# --- optic: 1.5 mm fused-silica substrate, chrome layer on the upstream face
r = qlab.OPTIC_DIA / 2
sub = qlab.cylinder("Optic_Substrate", r, 0.0015, at=(-0.00075, 0, H), axis="X", seg=64,
                    mat=qlab.glass(ior=1.46, tint=(0.95, 0.96, 1.0), alpha=0.18, name="Silica"))
chrome_mat = qlab.anodised_colour((0.35, 0.35, 0.36), name="ChromeMask")
chrome = qlab.cylinder("Optic_Chrome", r - 0.0003, 0.00008, at=(-0.00083, 0, H), axis="X", seg=64, mat=chrome_mat)
window_w = 2 * SW + GAP
cut = qlab.box("cut", (0.001, window_w, SLIT_H), at=(-0.00083, 0, H))
qlab.boolean_cut(chrome, cut)
bar = qlab.box("Optic_Bar", (0.00008, GAP, SLIT_H), at=(-0.00079, 0, H), mat=chrome_mat)
# faint etched legend in the chrome
legend = qlab.label_decal("Optic_Legend", "", at=(-0.00092, 0, H - 0.006), size_m=(0.008, 0.0015), axis="-X",
                          lines=["200-200-200"], px=(400, 75), pt=48, fg="#d0d0d0")
optic = [sub, chrome, bar, legend]

# --- shutter: thin blackened blade in a tiny guide on the mount's upstream face
guide_x = -0.0055
body.append(qlab.box("Guide", (0.0015, 0.014, 0.002), at=(guide_x, 0.0, H + 0.0045), mat=qlab.anodised_black(), bevel=0.0002))
body.append(qlab.box("Guide2", (0.0015, 0.014, 0.002), at=(guide_x, 0.0, H - 0.0045), mat=qlab.anodised_black(), bevel=0.0002))
blade_y = window_w / 2 + 0.0003 + 0.0025   # blade centre; its -Y edge sits 0.3 mm clear of the window
cover = [qlab.box("Cover_Blade", (0.0003, 0.005, 0.0105), at=(guide_x, blade_y, H),
                  mat=qlab.matte_black(name="BladeBlack", base=(0.015, 0.015, 0.015), rough=0.6)),
         qlab.box("Cover_Tab", (0.0012, 0.003, 0.003), at=(guide_x - 0.0005, blade_y + 0.002, H + 0.0065),
                  mat=qlab.stainless())]

parts = [qlab.Part("Optic", optic, origin=centre, parent="Body"),
         qlab.Part("Cover", cover, origin=(guide_x, 0.0, H), parent="Body")]
qlab.finalize_and_export(a["name"], body + optic + cover, parts=parts)
