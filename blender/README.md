# Blender apparatus pipeline

Procedural, headless Blender 4.3 scripts that build the lab apparatus of
*Testing Reality* as glTF binaries for the Godot app. Nothing is modelled by
hand: every model is a Python script in `models/` built on the shared
`lib/qlab.py` library, so a change to the post/mount family or a material
propagates to every instrument on the next rebuild.

```
blender/
  lib/qlab.py        shared library: materials, mesh builders, mounts, export
  lib/texgen.py      texture generator (system python3 + numpy + ImageMagick)
  lib/preview.py     re-imports a .glb, prints its inventory, renders a preview
  models/*.py        one script per instrument -> app/assets/models/<name>.glb
  textures/          generated PBR textures (+ textures/labels/ text decals)
tools/build-models.sh    rebuild everything (or the named models)
tools/preview-model.sh   render a check image of one .glb
```

## Requirements

* Blender 4.3 (`blender` on PATH or `BLENDER=/path/to/blender`), run headless.
* ImageMagick (`convert`) and a system `python3` with numpy for `texgen.py`.
  Blender's own interpreter has no numpy on Debian, but the glTF exporter
  needs it; `qlab.py` therefore appends the user site-packages
  (`pip install --user numpy`) to `sys.path` when numpy is missing.
* `xvfb-run` for the EEVEE preview renders (Mesa llvmpipe, no GPU needed).
  Cycles is not available on the build server, so nothing is baked: all
  texture maps are generated analytically by `texgen.py`.

## Building and checking

```sh
tools/build-models.sh                 # all models
tools/build-models.sh laser_module    # one script (may export several variants)
tools/preview-model.sh laser_405 [--view iso|front|side|top|back] [--zoom 1.4] [--engine WORKBENCH]
```

`build-models.sh` regenerates textures when missing (`FORCE_TEXTURES=1` to
redo them), runs every `models/*.py`, and prints per-part triangle counts and
material lists. `preview-model.sh` re-imports the .glb with Blender's glTF
importer (this doubles as the load validation: object names, parents,
material counts and the bounding box are printed), lights it and renders a
3/4 view to `$PREVIEW_DIR` (default `$CLAUDE_SCRATCHPAD/blender/previews`
or `/tmp/blender/previews`). EEVEE Next takes about a minute per image on
llvmpipe; if it fails the script retries with Workbench.

## Conventions

* **Units**: Blender metres; `qlab.IN = 0.0254`. Real catalogue sizes are
  used throughout: Ø1" optics, Ø1/2" stainless posts, Ø1" black post
  holders, 1" x 3" x 3/8" slotted bases, 25 mm M6 breadboard grid.
* **Origin**: the table surface directly under the optical axis. The beam
  runs along **+X** at `BEAM_HEIGHT` (0.10 m by default; every script takes
  `--beam-height`). +Z is up in Blender; the exporter converts to glTF/Godot
  Y-up, so in Godot the beam still runs along +X and up is +Y.
* **Facing**: optics face the beam (mount dials and labels on the -Y / +X
  sides, which is where the preview camera looks from). Detectors and
  collimators point upstream (-X); the laser emits from its aperture at
  x = 0 towards +X.
* **Materials** (`qlab.*`): `anodised_black()` (base 0.022, metallic 0.9,
  roughness ~0.45 with a brushed ORM + normal map), `stainless()`,
  `knurled()` / `knurled_steel()`, `glass(ior, tint, alpha)` (transmission +
  alpha-blend fallback, exported with KHR_materials_transmission/ior),
  `ar_coated_glass()`, `polarizer_film()`, `mirror()`, `abs_plastic(rgb)`,
  `rubber()`, `pcb()`, `breadboard()`, `scale_ring()`, `decal(image)`,
  `emissive(rgb)`. Materials are cached by name so joined meshes share
  slots. Roughness/metallic travel as packed ORM textures (G = roughness,
  B = metallic) wired through a Separate Color node, which is what the glTF
  exporter expects.
* **Textures**: `lib/texgen.py all` writes deterministic tileable maps to
  `textures/` (brushed anodised and stainless ORM/normal, straight knurl,
  the breadboard colour/ORM/normal tile of 2 x 2 countersunk holes per
  50 mm, a 360 degree engraved dial, a red PCB, the IEC laser-warning
  backdrop). Text labels are rendered on demand by `qlab.label_image()` into
  `textures/labels/` (content-hashed, so rebuilding is a no-op).
* **Polygon budget**: under ~30k triangles per model, the table under 10k.
  The breadboard's hole grid lives in the texture; only the row(s) under
  the optical axis get real countersunk holes (`--real-rows 1|3`).

## Moving-part naming contract

`qlab.finalize_and_export(name, objects, parts=[qlab.Part(...)])` joins all
static geometry into one mesh called **`Body`**, builds each `Part` as its
own mesh, parents everything under an empty named after the model and
writes the .glb. Godot code relies on these node names:

| Node       | Found in                                            | Motion                                                      |
|------------|-----------------------------------------------------|-------------------------------------------------------------|
| `Body`     | every model                                         | static                                                      |
| `Rotor`    | polarizer_rotation_mount, half_wave_plate, bbo_crystal, berek_compensator | rotate about its local X (the optical axis); origin on the axis. The engraved scale rotates with it, the index mark stays on `Body` |
| `Optic`    | all optic holders (child of `Rotor` where one exists, else of `Body`) | the glass itself (polarizer, waveplate, lens, mirror, PBS cube, crystal, filter, slit mask); swap/hide/tint freely |
| `Tilt`     | berek_compensator (child of `Rotor`, parent of `Optic`) | rotate about its local Z (the plate's tilt pivot)         |
| `Cover`    | double_slit_mask                                    | translate along local Y; -0.0004 m covers the +Y slit        |
| `JawA`/`JawB` | single_slit_adjustable                           | translate along local Y symmetrically to set the slit width |
| `Carriage` | spcm_detector                                       | translate along local Y (across the beam); carries the SPCM box, collimator and slit plate |
| `Aperture` | laser_405 / laser_808 (joined into `Body`; the beam origin is x = 0 on the axis) | - |

All part origins sit on the optical axis (except `Carriage`: carriage top
centre under the axis), so a plain `rotation.x = angle` or
`position.y = offset` in Godot moves them correctly. Children move with
their parents (the optic rotates with the rotor; the plate tilts inside the
rotating Berek frame).

## Adding a model

1. Copy the skeleton of an existing script in `models/` (e.g.
   `lens_mount.py`). Start with `a = qlab.begin({...defaults...})` which
   regenerates missing textures, wipes the scene and parses `-- --key value`
   arguments.
2. Build the mount with the library builders (`post_stack`, `lens_mount_1in`,
   `rotation_mount_1in`, `kinematic_mirror_mount`, `cube_mount`,
   `fibre_collimator`, `beam_dump`, `pbs_cube`, ...) or from primitives
   (`box`, `cylinder`, `tube`, `revolve`, `disc`, `plate_with_hole`,
   `lens_planoconvex`, `cable`, `label_decal`, `curved_label`). Every
   builder works in world coordinates and returns objects with identity
   transforms; mounts return `optic_offset` (optical centre to the face
   that sits on the post) so `post_stack(H - optic_offset)` sizes the post
   and picks a standard holder length.
3. Put moving pieces into `qlab.Part("Rotor", objs, origin=centre,
   parent="Body")` entries and call
   `qlab.finalize_and_export(name, all_objects, parts=parts)`.
4. `tools/build-models.sh <script>` then `tools/preview-model.sh <name>` and
   look at the image. Proportions should match the catalogue part you are
   imitating; the label decals should read; glass should be visibly
   transparent; metals should show the brushed sheen.

Scripts may export several variants (`laser_module.py` writes `laser_405`
and `laser_808`, `lens_mount.py` writes `lens_mount_f500` and
`lens_mount_f50`); a `--name`/`--wavelength`/`--focal` argument selects one.
