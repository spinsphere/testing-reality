"""Compact diode laser module (Ø19 mm x 95 mm, black anodised) held in a
kinematic mount on a post, 35 mm of the labelled barrel protruding in front.  The emitting aperture is at the model origin
plane (x = 0) on the optical axis; the beam itself is drawn by Godot.

    blender -b -P blender/models/laser_module.py -- [--wavelength 405|808] [--name laser_405]
                                                     [--beam-height 0.10]
Without --wavelength both laser_405 and laser_808 are exported.
Parts: Body only (the aperture disc is named "Aperture" so Godot can find
the beam origin).
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402


def build(wl, name, H):
    qlab.reset_scene()
    ab = qlab.anodised_black()
    r = 0.0095
    L = 0.095
    x_front = 0.0
    x_back = x_front - L
    body = []

    # --- kinematic mount with a Ø19 mm adapter, 30 mm behind the aperture
    mount = qlab.kinematic_mirror_mount((x_front - 0.075, 0, H), bore=2 * r + 0.0004, back_bore=0.023,
                                        name="KinMount")
    body += mount["objects"]
    stack, _ = qlab.post_stack(H - mount["optic_offset"], at=(mount["front_x"] + 0.005, 0), name="Stack")
    body += stack

    # --- laser housing: tube with front bezel and rear cap
    housing = qlab.revolve("Housing", [(0, x_back + 0.004), (r - 0.001, x_back + 0.004), (r, x_back + 0.005),
                                       (r, x_front - 0.009), (r - 0.0008, x_front - 0.008), (r - 0.0008, x_front - 0.004),
                                       (0.0065, x_front - 0.004), (0.0065, x_front - 0.0005), (0.006, x_front),
                                       (0, x_front)],
                           at=(0, 0, H), axis="X", seg=56, mat=ab, uv_scale=0.04)
    body.append(housing)
    # front bezel ring (stainless) and the aperture
    body.append(qlab.tube("Bezel", 0.0066, 0.0045, 0.0035, at=(x_front - 0.0035, 0, H), axis="X", seg=40,
                          mat=qlab.stainless()))
    glow = qlab.wavelength_rgb(wl)
    if 380 <= wl <= 700:
        ap_mat = qlab.emissive(glow, strength=2.5, name="Aperture_%d" % wl)
    else:
        ap_mat = qlab.matte_black(name="ApertureIR", base=(0.05, 0.01, 0.01), rough=0.6)
    body.append(qlab.cylinder("Aperture", 0.0012, 0.0004, at=(x_front - 0.0025, 0, H), axis="X", seg=16, mat=ap_mat))
    body.append(qlab.disc("ApertureWindow", 0.0044, at=(x_front - 0.0012, 0, H), axis="X", seg=24,
                          mat=qlab.ar_coated_glass()))
    # grip grooves at the rear of the housing
    for k in range(4):
        body.append(qlab.tube("Groove%d" % k, r + 0.0001, r - 0.0006, 0.0012,
                              at=(x_back + 0.0045 + k * 0.0022, 0, H), axis="X", seg=56, mat=qlab.matte_black()))
    # rear cap with strain relief and cable
    body.append(qlab.revolve("RearCap", [(0, 0), (0.0045, 0), (0.0045, 0.004), (0.0035, 0.012), (0.003, 0.018),
                                         (0, 0.018)],
                             at=(x_back + 0.004, 0, H), axis="-X", seg=24, mat=qlab.rubber()))
    pts = [(x_back - 0.014, 0, H), (x_back - 0.035, 0, H - 0.002), (x_back - 0.055, 0.004, H - 0.03),
           (x_back - 0.06, 0.012, H - 0.07), (x_back - 0.05, 0.03, 0.0025), (x_back + 0.02, 0.06, 0.0025)]
    body.append(qlab.cable("Cable", pts, radius=0.0019, mat=qlab.abs_plastic((0.02, 0.02, 0.025), 0.6, name="CableJacket")))
    # status LED on the rear cap rim
    body.append(qlab.cylinder("LED", 0.0012, 0.0008, at=(x_back + 0.0041, 0.0062, H + 0.0045), axis="-X", seg=12,
                              mat=qlab.emissive((0.1, 1.0, 0.2), 3.0, name="LEDGreen")))

    # --- labels: IEC yellow warning (wraps the top/-Y side) and a model label
    power = "<5 mW" if wl == 405 else "<30 mW"
    cls = "CLASS 3R" if wl == 405 else "CLASS 3B"
    warn_lines = ["LASER RADIATION", "AVOID DIRECT EYE EXPOSURE" if wl == 405 else "INVISIBLE LASER RADIATION",
                  "%d nm  %s  %s" % (wl, power, cls)]
    body.append(qlab.curved_label("Warning", "warn%d" % wl, (x_front - 0.018, 0, H), 0.028, r, ang_span=110,
                                  ang_centre=135, lines=warn_lines, fg="#111111", bg="#f3c514", px=(720, 430),
                                  pt=46, xoff=70, bg_image=os.path.join(qlab.TEXDIR, "laser_warning_bg.png")))
    body.append(qlab.curved_label("ModelLabel", "model%d" % wl, (x_back + 0.011, 0, H), 0.012, r, ang_span=70,
                                  ang_centre=200, lines=["CPS%d" % wl, "%d nm DIODE" % wl], fg="#dddddd",
                                  bg="#060606", px=(360, 220), pt=56))
    qlab.finalize_and_export(name, body)


a = qlab.begin({"wavelength": 0, "name": "", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
if int(a["wavelength"]) > 0:
    wl = int(a["wavelength"])
    build(wl, a["name"] or "laser_%d" % wl, H)
else:
    build(405, "laser_405", H)
    build(808, "laser_808", H)
