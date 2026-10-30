"""Render a 3/4 preview of an exported .glb (re-imports it, so it also
validates the file) and print the object/material inventory.

    blender -b -P blender/lib/preview.py -- <model.glb> <out.png> [--view iso|front|top|side]
                                              [--res 1280x960] [--samples 32] [--engine EEVEE|WORKBENCH]
                                              [--zoom 1.0] [--no-ground]
"""
import math
import os
import sys

import bpy
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import qlab  # noqa: E402


def main():
    a = qlab.args({"view": "iso", "res": "1280x960", "samples": 32, "engine": "EEVEE",
                   "zoom": 1.0, "no_ground": False})
    rest = sys.argv[sys.argv.index("--") + 1:]
    positional = [r for r in rest if not r.startswith("--") and r not in map(str, a.values())]
    glb, out = positional[0], positional[1]

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=glb)
    objs = [o for o in bpy.context.scene.objects]
    meshes = [o for o in objs if o.type == "MESH"]
    print("==== %s" % os.path.basename(glb))
    total = 0
    for o in objs:
        if o.type == "MESH":
            t = qlab.tri_count(o)
            total += t
            mats = [m.name for m in o.data.materials if m]
            print("  %-12s parent=%-10s tris=%6d mats=%d %s" % (
                o.name, o.parent.name if o.parent else "-", t, len(mats), mats))
        else:
            print("  %-12s (%s) parent=%s" % (o.name, o.type, o.parent.name if o.parent else "-"))
    print("  total tris=%d, images=%d" % (total, len(bpy.data.images)))

    # bounding box in world space
    pts = []
    for o in meshes:
        for c in o.bound_box:
            pts.append(o.matrix_world @ Vector(c))
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    centre = (lo + hi) / 2
    size = max(hi - lo)
    print("  bbox min=%s max=%s" % (tuple(round(v, 4) for v in lo), tuple(round(v, 4) for v in hi)))

    sc = bpy.context.scene
    if a["engine"].upper().startswith("WORK"):
        sc.render.engine = "BLENDER_WORKBENCH"
        sc.display.shading.light = "STUDIO"
        sc.display.shading.color_type = "MATERIAL"
    else:
        sc.render.engine = "BLENDER_EEVEE_NEXT"
        sc.eevee.taa_render_samples = int(a["samples"])
        sc.eevee.use_raytracing = True
        sc.eevee.use_shadows = True
        sc.eevee.shadow_ray_count = 2
        sc.eevee.shadow_step_count = 4
    w, h = [int(v) for v in a["res"].split("x")]
    sc.render.resolution_x, sc.render.resolution_y = w, h
    sc.render.resolution_percentage = 100
    sc.render.film_transparent = False
    sc.view_settings.view_transform = "AgX"
    sc.view_settings.look = "AgX - Medium High Contrast"

    # world: soft grey-blue lab ambient
    world = bpy.data.worlds.new("Preview")
    sc.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs[0].default_value = (0.30, 0.32, 0.37, 1)
    bg.inputs[1].default_value = 0.35

    # ground plane (dark grey, like a table/bench) under the model
    if not a["no_ground"]:
        bpy.ops.mesh.primitive_plane_add(size=size * 12, location=(centre.x, centre.y, lo.z - 0.0002))
        g = bpy.context.object
        m = qlab.abs_plastic((0.045, 0.045, 0.05), roughness=0.7, name="PreviewGround")
        g.data.materials.append(m)

    # lights
    def light(kind, loc, energy, size_=None, color=(1, 1, 1)):
        bpy.ops.object.light_add(type=kind, location=loc)
        L = bpy.context.object
        L.data.energy = energy
        L.data.color = color
        if size_ is not None:
            L.data.size = size_
        d = centre - Vector(loc)
        L.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
        return L

    s = size
    light("AREA", centre + Vector((-1.2 * s, -1.8 * s, 2.2 * s)), 55 * s * s * 10, size_=s * 1.5, color=(1, 0.97, 0.92))
    light("AREA", centre + Vector((2.0 * s, -1.0 * s, 1.2 * s)), 22 * s * s * 10, size_=s * 2.0, color=(0.85, 0.9, 1.0))
    light("AREA", centre + Vector((0.5 * s, 2.5 * s, 1.5 * s)), 35 * s * s * 10, size_=s * 1.5)
    light("SUN", centre + Vector((1, -1, 2)), 1.0)

    # camera
    view = a["view"]
    zoom = float(a["zoom"])
    dist = size * 1.9 / zoom
    if view == "front":
        off = Vector((0.0, -1.0, 0.25))
    elif view == "top":
        off = Vector((0.001, -0.3, 1.0))
    elif view == "side":
        off = Vector((1.0, -0.3, 0.3))
    elif view == "back":
        off = Vector((-0.9, 0.8, 0.5))
    else:  # iso: 3/4 from the +X/-Y side, slightly above
        off = Vector((0.9, -1.0, 0.65))
    off.normalize()
    bpy.ops.object.camera_add(location=centre + off * dist)
    cam = bpy.context.object
    cam.rotation_euler = (centre - cam.location).to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = 50
    cam.data.clip_start = 0.001
    cam.data.clip_end = 100
    sc.camera = cam
    # frame the bbox
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes:
        o.select_set(True)
    # manual fit: pull the camera back until all corners are inside the frame
    import bpy_extras
    for _ in range(40):
        bpy.context.view_layer.update()
        ok = True
        for p in pts:
            cc = bpy_extras.object_utils.world_to_camera_view(sc, cam, p)
            if not (0.06 < cc.x < 0.94 and 0.06 < cc.y < 0.94 and cc.z > 0):
                ok = False
                break
        if ok:
            break
        cam.location = centre + (cam.location - centre) * 1.08

    sc.render.filepath = out
    sc.render.image_settings.file_format = "PNG"
    bpy.ops.render.render(write_still=True)
    print("  preview written to", out)


if __name__ == "__main__":
    main()
