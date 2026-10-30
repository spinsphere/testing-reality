"""Single-photon counting module on a motorised linear translation stage.

The SPCM box and a fibre collimator (with a 200 um slit plate in front)
ride on the stage carriage, which translates across the beam (local Y).
Parts: Body (stage base, motor), Carriage (everything that moves; origin
at the carriage top centre under the optical axis).

    blender -b -P blender/models/spcm_detector.py -- [--name spcm_detector] [--beam-height 0.10]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
import qlab  # noqa: E402
from mathutils import Vector  # noqa: E402

a = qlab.begin({"name": "spcm_detector", "beam_height": qlab.BEAM_HEIGHT})
H = float(a["beam_height"])
ab = qlab.anodised_black()
st = qlab.stainless()
mb = qlab.matte_black()

# ---------------------------------------------------------------- stage (fixed)
base_sz = (0.110, 0.125, 0.018)
body = [qlab.box("StageBase", base_sz, at=(0, 0, 0), mat=ab, bevel=0.0008, anchor="bottom")]
for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
    p = (sx * (base_sz[0] / 2 - 0.008), sy * (base_sz[1] / 2 - 0.008), base_sz[2])
    body.append(qlab.tube("Cbore", 0.0055, 0.0032, 0.0003, at=(p[0], p[1], p[2] - 0.0002), seg=20, mat=mb))
    body += qlab.cap_screw("StageScrew", (p[0], p[1], p[2] - 0.003), dia=0.006, axis="Z", head_h=0.0045)
# dovetail rail along Y
body.append(qlab.box("Rail", (0.030, base_sz[1] - 0.006, 0.006), at=(0, 0, base_sz[2]), mat=st, bevel=0.0006,
                     anchor="bottom"))
# stepper motor on the +Y end with its leadscrew housing and connector
my = base_sz[1] / 2
body.append(qlab.box("MotorFlange", (0.042, 0.004, 0.042), at=(0, my + 0.002, 0.024), mat=mb, bevel=0.0008))
body.append(qlab.revolve("MotorBody", [(0, 0), (0.019, 0), (0.021, 0.002), (0.021, 0.036), (0.019, 0.038), (0, 0.038)],
                         at=(0, my + 0.004, 0.024), axis="Y", seg=40, mat=mb, uv_scale=0.03))
body.append(qlab.box("MotorConnector", (0.014, 0.010, 0.008), at=(0.012, my + 0.040, 0.013), mat=mb, bevel=0.0005))
body.append(qlab.cable("MotorCable", [(0.012, my + 0.046, 0.013), (0.012, my + 0.07, 0.006), (0.0, my + 0.11, 0.003),
                                      (-0.05, my + 0.14, 0.003)], radius=0.0025,
                       mat=qlab.abs_plastic((0.55, 0.55, 0.5), 0.6, name="GreyCable")))
body.append(qlab.label_decal("StageLabel", "MTS50-Z8  50 mm", at=(-0.03, -base_sz[1] / 2, 0.009), size_m=(0.03, 0.005),
                             axis="-Y", px=(600, 100), pt=56, fg="#cfcfcf"))
# limit switch block and leadscrew on the -Y end
body.append(qlab.box("EndBlock", (0.030, 0.006, 0.014), at=(0, -my + 0.003, base_sz[2] + 0.007), mat=ab, bevel=0.0006))

# ------------------------------------------------------------ carriage (moves)
cz0 = base_sz[2] + 0.006
car_sz = (0.100, 0.060, 0.012)
car_top = cz0 + car_sz[2]
car = [qlab.box("Carriage", car_sz, at=(0, 0, cz0), mat=ab, bevel=0.0008, anchor="bottom")]
for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1), (0, -1), (0, 1)):
    car.append(qlab.cylinder("CarHole", 0.0022, 0.0004, at=(sx * 0.0375, sy * 0.0225, car_top - 0.0003), seg=14, mat=mb))
# a 1 mm step: the carriage straddles the rail (visual relief at the sides)
car.append(qlab.box("CarSkirt", (0.100, 0.064, 0.003), at=(0, 0, cz0 - 0.003), mat=ab, bevel=0.0005, anchor="bottom"))

# SPCM box on a short post from the carriage
box_sz = (0.060, 0.060, 0.036)
box_x = 0.030
box_z0 = H - box_sz[2] / 2
post_top = box_z0
car += qlab.post_holder(1 * qlab.IN, at=(box_x, 0, car_top), name="BoxHolder")
car += qlab.post(post_top - (car_top + 0.004), at=(box_x, 0, car_top + 0.004), name="BoxPost")
car.append(qlab.box("SPCMBox", box_sz, at=(box_x, 0, box_z0), mat=ab, bevel=0.001, anchor="bottom"))
# lid screws
for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
    car += qlab.cap_screw("LidScrew", (box_x + sx * 0.025, sy * 0.025, box_z0 + box_sz[2]), dia=0.003, axis="Z",
                          head_h=0.002)
# front label (facing the beam, -X) and side label
car.append(qlab.label_decal("BoxLabel", "spcm", at=(box_x - box_sz[0] / 2, 0, H + 0.006), size_m=(0.044, 0.014),
                            axis="-X", lines=["SPCM-AQRH-14-FC", "SINGLE PHOTON COUNTING MODULE"], px=(640, 200),
                            pt=40, fg="#e8e8e8"))
car.append(qlab.label_decal("SideLabel", "spcmside", at=(box_x, -box_sz[1] / 2, H - 0.004), size_m=(0.040, 0.010),
                            axis="-Y", lines=["S/N 2023-04471", "FIBER INPUT: FC/PC   OUT: TTL"], px=(640, 160),
                            pt=36, fg="#bdbdbd"))
# FC/PC fibre input on the box top
fc_at = (box_x - 0.015, 0.0, box_z0 + box_sz[2])
car.append(qlab.revolve("FCReceptacle", [(0, 0), (0.0055, 0), (0.0055, 0.006), (0.0045, 0.006), (0.0045, 0.009),
                                         (0.0025, 0.009), (0.0025, 0.002), (0, 0.002)],
                        at=fc_at, axis="Z", seg=24, mat=st, uv_scale=0.01))
car.append(qlab.revolve("FCPlug", [(0.0012, 0), (0.0045, 0), (0.0045, 0.010), (0.0012, 0.010)], at=(fc_at[0], fc_at[1], fc_at[2] + 0.009),
                        axis="Z", seg=24, mat=qlab.knurled_steel(), uv_scale=0.01))
car.append(qlab.revolve("FCBoot", [(0.0012, 0), (0.0032, 0), (0.0032, 0.010), (0.0018, 0.020), (0.0012, 0.020)],
                        at=(fc_at[0], fc_at[1], fc_at[2] + 0.019), axis="Z", seg=16, mat=qlab.rubber()))
# rear interface PCB (red) with BNC, DC jack and status LED
bx = box_x + box_sz[0] / 2
car.append(qlab.box("InterfacePCB", (0.0016, 0.050, 0.028), at=(bx + 0.0008, 0, H), mat=qlab.pcb()))
car.append(qlab.revolve("BNC", [(0, 0), (0.0045, 0), (0.0045, 0.004), (0.0048, 0.004), (0.0048, 0.012), (0.0042, 0.012),
                                (0.0042, 0.0135), (0.002, 0.0135), (0.002, 0.004), (0, 0.004)],
                        at=(bx + 0.0016, -0.012, H - 0.004), axis="X", seg=28, mat=st, uv_scale=0.01))
car.append(qlab.revolve("BNCPin", [(0, 0), (0.0007, 0), (0.0007, 0.012), (0, 0.012)], at=(bx + 0.0016, -0.012, H - 0.004),
                        axis="X", seg=10, mat=qlab.brass()))
car.append(qlab.revolve("DCJack", [(0, 0), (0.004, 0), (0.004, 0.009), (0.002, 0.009), (0.002, 0.003), (0, 0.003)],
                        at=(bx + 0.0016, 0.010, H - 0.004), axis="X", seg=20, mat=mb, uv_scale=0.01))
car.append(qlab.cylinder("StatusLED", 0.0015, 0.001, at=(bx + 0.0016, 0.020, H + 0.008), axis="X", seg=12,
                         mat=qlab.emissive((0.1, 1.0, 0.2), 3.0, name="LEDGreen")))
car.append(qlab.cylinder("GateLED", 0.0015, 0.001, at=(bx + 0.0016, 0.014, H + 0.008), axis="X", seg=12,
                         mat=qlab.emissive((1.0, 0.25, 0.05), 2.0, name="LEDAmber")))
car.append(qlab.label_decal("PCBText", "pcbtxt", at=(bx + 0.0017, -0.012, H + 0.009), size_m=(0.016, 0.004), axis="X",
                            lines=["TTL OUT   +5V"], px=(400, 100), pt=48, fg="#f0f0f0"))
# cables from the rear: coax (black) and power (grey)
car.append(qlab.cable("CoaxCable", [(bx + 0.016, -0.012, H - 0.004), (bx + 0.04, -0.014, H - 0.01), (bx + 0.06, -0.02, 0.05),
                                    (bx + 0.07, -0.03, 0.0025), (bx + 0.10, -0.06, 0.0025)], radius=0.0025))
car.append(qlab.cable("PowerCable", [(bx + 0.010, 0.010, H - 0.004), (bx + 0.035, 0.012, H - 0.012), (bx + 0.055, 0.02, 0.04),
                                     (bx + 0.065, 0.04, 0.0025), (bx + 0.09, 0.08, 0.0025)], radius=0.0018,
                      mat=qlab.abs_plastic((0.55, 0.55, 0.5), 0.6, name="GreyCable")))

# fibre collimator on its own short post, looking upstream (-X)
col_x = -0.030
col_rear = Vector((col_x, 0, H))
col_objs, col_front = qlab.fibre_collimator(col_rear, axis="-X", length=0.034, name="Collimator")
car += col_objs
# clamp holding the collimator tube: a split ring with a tab down to the post
car.append(qlab.tube("ColClamp", 0.0095, 0.0061, 0.010, at=(col_x - 0.022, 0, H), axis="X", seg=40, mat=ab))
car.append(qlab.box("ColClampTab", (0.010, 0.012, 0.012), at=(col_x - 0.017, 0, H - 0.012), mat=ab, bevel=0.0005))
car.append(qlab.cylinder("ColClampScrew", 0.0018, 0.004, at=(col_x - 0.017, 0, H + 0.0092), seg=12, mat=st))
col_post_top = H - 0.018
car += qlab.post_holder(1 * qlab.IN, at=(col_x - 0.017, 0, car_top), name="ColHolder")
car += qlab.post(col_post_top - (car_top + 0.004), at=(col_x - 0.017, 0, car_top + 0.004), name="ColPost")
# fibre: from the collimator's rear boot, looping up and over into the FC plug on the box
fibre_pts = [(col_x + 0.0325, 0, H), (col_x + 0.055, 0.0, H + 0.004), (col_x + 0.075, 0.004, H + 0.040),
             (box_x - 0.030, 0.006, H + 0.065), (fc_at[0], 0.002, fc_at[2] + 0.050), (fc_at[0], 0, fc_at[2] + 0.029)]
car.append(qlab.cable("Fibre", fibre_pts, radius=0.0015, mat=qlab.abs_plastic((0.95, 0.75, 0.05), 0.5, name="FibreJacket")))

# 200 um slit plate in a small square holder on the collimator front
sx = col_front.x - 0.003
car.append(qlab.box("SlitHolder", (0.004, 0.016, 0.016), at=(col_front.x - 0.001, 0, H), mat=ab, bevel=0.0004))
car.append(qlab.plate_with_hole("SlitPlate", 0.0254, 0.0254, 0.0010, slot=(0.0002, 0.003), at=(sx - 0.0025, 0, H),
                                axis="X", mat=qlab.matte_black(name="SlitBlack", base=(0.02, 0.02, 0.02), rough=0.6)))
car.append(qlab.label_decal("SlitLabel", "slit", at=(sx - 0.0031, 0, H - 0.0085), size_m=(0.012, 0.003), axis="-X",
                            lines=["S200R  200 µm"], px=(400, 100), pt=48, fg="#d0d0d0"))

parts = [qlab.Part("Carriage", car, origin=(0, 0, car_top), parent="Body")]
qlab.finalize_and_export(a["name"], body + car, parts=parts)
