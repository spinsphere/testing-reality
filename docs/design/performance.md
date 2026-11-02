# Performance — targets and measurements

Goal (Phase 9): the app must run well on a mid-range machine (integrated or entry-level
discrete graphics, 4 cores, 8 GB RAM), not only on a gaming PC.

## What makes it cheap by construction

- **GL Compatibility renderer** (OpenGL 3.3 / ES 3.0): no Vulkan requirement, works on
  integrated GPUs and in VMs; forward rendering with one directional shadow cascade.
- **Small scenes**: the heaviest bench has 21 instruments, ~110 k triangles and ~750 draw
  calls a frame. Every model is a few thousand triangles (the SPCM is the largest at 15 k).
- **Textures stay embedded and VRAM-compressed** (Basis Universal inside the imported
  scenes): 139 images, 51 unique, ~27 Mpx, under 100 MB of VRAM for a whole bench.
- **The physics is not on the frame budget**: the Quagmire Engine recomputes a bench only
  when a parameter changes (a few hundred microseconds in Rust), and the acquisition and
  photon animation are O(channels) and O(photons) per frame.
- **No per-frame allocation in the HUD**: the counting panel updates label texts in place;
  the state panel and results are rebuilt only on a parameter change.
- **Plots**: long curves are decimated to about one vertex per two pixels and drawn without
  per-segment antialiasing; dashes are one multiline. A slit lab went from 10.5 k to 2.2 k
  canvas objects a frame.
- **Lighting**: one orthogonal shadow cascade (2048 px) covering 4 m instead of four
  cascades over 100 m; glow keeps only its two finest blur levels.

## Quality presets (Settings)

| Preset | MSAA | Shadows | Glow | 3D render scale | Meant for |
|---|---|---|---|---|---|
| Low | off | off | off | 75 % | integrated graphics, old laptops, VMs |
| Medium (default) | 2× | one cascade, 2048 | on | 100 % | any discrete GPU, recent integrated GPUs |
| High | 4× | one cascade, 2048 | on | 100 % | desktop GPUs |

The preset is applied when a lab opens (`LabBase._build_world`, `AppState.quality()`).

## Measuring

```bash
xvfb-run -a godot --path app -- --go=lab:exp7 --perf      # one PERF line, then quits
tools/test.sh                                            # "perf lab:*" steps enforce the budget
```

`--perf` averages Godot's renderer counters over 60 frames after a 20-frame warm-up. The
counters (objects, primitives, draw calls, VRAM) do not depend on the GPU, so they are the
regression metric; the frame time printed alongside is only meaningful on real hardware
(the CI machine renders with llvmpipe, a software rasteriser).

Budget enforced by `tools/test.sh`: ≤ 1500 draw calls and ≤ 2 000 000 primitives a frame on
the three heaviest routes.

## Measured (2026-10-31, Medium preset, 1600×900)

| Route | objects | primitives | draw calls | VRAM |
|---|---|---|---|---|
| Hub | 1 006 | 6 k | 100 | 19 MB |
| Chapter page (Exp. 2, p. 4) | 464 | 2 k | 25 | 61 MB |
| Lab 1 (polarizers) | 1 065 | 47 k | 249 | 68 MB |
| Lab 2 (double slit) | 1 549 | 60 k | 412 | 73 MB |
| Lab 4 (Bell state) | 1 524 | 101 k | 648 | 86 MB |
| Lab 7 (heaviest) | 2 182 | 108 k | 752 | 90 MB |

For scale: a mid-range laptop GPU of 2015 (Intel HD 520) draws well over 500 M triangles/s
and several thousand draw calls a frame at 60 fps; these benches use under 7 M
triangles/s at 60 fps.

## Web build (WebGL 2)

The same scenes through Godot's single-threaded web template, measured with
`tools/check-web.sh lab:exp1` / `lab:exp7` (headless Chromium, SwiftShader software
rasteriser, so only the counters are meaningful):

| Route | objects | primitives | draw calls | VRAM |
|---|---|---|---|---|
| Lab 1 (web) | 1 065 | 43 k | 249 | 54 MB |
| Lab 7 (web) | 2 183 | 96 k | 754 | 76 MB |

Identical draw calls to the native build; fewer primitives and less VRAM because the web
export ships S3TC-only textures and no MSAA resolve buffers at 1280×720. On a real browser
with a GPU the web build is CPU-bound by WebAssembly (single-threaded, no SIMD in the
official templates): expect roughly half the native frame rate; the *Low* preset applies.

## If it is ever slow

1. Choose *Low* in Settings (no shadows, no glow, 75 % render scale).
2. Check `--perf` for a regression in draw calls (Label3D and HUD panels are the usual
   suspects) or primitives (a new model that is too dense: keep models under ~15 k
   triangles, see `blender/README.md`).
3. The photon animation spawns one mesh per photon; it is capped by the spawn interval
   (0.12 s single beam, 0.7 s pairs) and each photon is freed on arrival.
