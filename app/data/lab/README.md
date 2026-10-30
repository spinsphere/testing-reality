# Lab data from the Testing Reality site

Raw single-photon counting data published on https://testing-reality.webflow.io
(experiment pages 1-7), fetched on 2026-10-30. One directory per page slug; file
names are the site's originals with the Webflow hash prefix removed and spaces
replaced by `_`. Source URLs and the matching content specs are listed in
`docs/site-assets/MANIFEST.md`.

The files are untrusted downloads: parse them, never execute anything from
here. `tools/labdata/summarise.py` (run with `python3 -I`) regenerates the
summary at the bottom of this file.

## Common layout

Every file is plain ASCII CSV with:

1. one free-text description line (sometimes starting with `#`, sometimes
   quoted), stating the acquisition window and, where relevant, the
   coincidence window;
2. one header line;
3. numeric rows.

Column-name spelling is the site's own (`Conts per seocnd`, `coincidance`,
`All distance`); keep it when parsing, or match by position.

### Units

| quantity | unit | notes |
|---|---|---|
| detector position (`Position`, `Pos`, `All distance`, `Position on the sceen`) | um | absolute position of the motorised linear actuator carrying the detector, 12 500-23 500 um; the site's plots use a centred axis "Distance on the screen (um)", i.e. position minus the scan mid-point (see table below) |
| polarizer angles (`Pol 1`, `PolA`, `Angle of P1`, `Polarisation P1`, ...) | degrees | rotation-mount readings; a few are offset by a fraction of a degree (e.g. 44.88, -0.33) |
| `Counts`, `CountsA/B/AB`, `CountsD1`, `Sweep_n D1/D2/D1D2`, `Counts of D1/D2`, `Coincidence D1D2` | raw counts in one acquisition window | window = 1 s, 2 s or 20 s as stated in the description line; divide by it to get counts per second |
| `Counts per second(s)` | counts / s | already normalised |
| `Sweep` | integer | repeat index of the whole scan (1-based); the Exp 6 files put sweeps side by side as column groups instead (`Sweep_0 ...`, 0-based) |

Coincidence window: 10 ns wherever stated (Exp 3-7). Detector names: D1 =
signal-arm detector (the one on the actuator, behind the slit / P1), D2 =
idler-arm detector; the Exp 4/5 files call them A and B.

### Scan geometry

| page | files | position range (um) | step | points | screen-centre estimate | window |
|---|---|---|---|---|---|---|
| experiment-1 | Data1_1pol, Data1_2pol, Data1_3pol | 12 500-20 500 | 100 | 81 | ~16 400 (beam centre, where 1pol peaks) | 1 s (3pol: 2 s, already per second) |
| experiment-2 | Single_slit_-_left/right_slit | 17 500-22 500 | 100 | 51 | 20 000 | 2 s |
| experiment-2 | double_slit_-_calib_123_(1) | 17 500-23 500 | 50 | 121 | 20 500 | 2 s |
| experiment-3 | Data_exp3_-_data_{-45,0,45,90} | 17 000-23 000 | 50 | 121 | 20 000 | 2 s |
| experiment-4 | Acquisition_-_Feuille_1 | no scan: 19 x 19 grid of PolA, PolB in -90..90 deg, 10 deg steps | | 361 | | 1 s |
| experiment-5 | Data4_1 (5.1, bare slit) | 16 600-20 600 | 50 | 81 x 30 samples | 18 600 | 20 s |
| experiment-5 | Data4_2 (5.2, PA + PB) | 17 000-21 000 | 50 | 81 x 24 | 19 000 | 20 s |
| experiment-5 | Data4_3 (5.3, PA + PB + P1) | 16 450-20 450 | 50 | 81 x 36 | 18 450 | 20 s |
| experiment-6 | Data_0deg, Data_90deg | 16 450-20 450 | 50 | 81 x 7 rows x 6 sweeps | 18 450 | 20 s |
| experiment-6 | Data_45degre | 16 300-20 300 | 50 | 81 x 7 x 5 | 18 300 | 20 s |
| experiment-6 | Data_135deg | 16 300-20 600 | 50 | 87 x 7 x 6 | ~18 450 | 20 s |
| experiment-7 | 6.1_wall, 6.2_unplugged | 16 600-20 600 | 50 | 81 x 30 / 81 x 36 | 18 600 | 20 s |

"Screen-centre estimate" is the scan mid-point; it reproduces the +/-2000,
+/-2500 or +/-3000 um axes of the site's plots. It is an inference, not stated
on the site.

## Per-experiment formats

### experiment-1 (polarizers, Malus's law)

Site: "3 columns: the position of the detector, the angle of the polarizers
and the number of photons detected".

- `Data1_1pol.csv` (9 columns): `Position on the sceen`, then four pairs
  (`Angle of P1`, counts per second) for P1 = 45, 22.5, 0, -45 deg sharing the
  same positions. Peaks 1159, 881, 614, 354 counts/s. The site's results table
  (1159 = 100 %, background 322) is built from these peaks.
- `Data1_2pol.csv` (4): `Position`, `Pol 1` (0), `Pol 2` (90), `Counts per seconds`
  (crossed polarizers; peak 361/s, i.e. background).
- `Data1_3pol.csv` (5): `Position`, `Polarizer 1` (0), `Polarizer 2` (45),
  `Polarizer 3` (90), `Counts per seocnds` (three-polarizer paradox; 2 s
  windows but the column is already per second; peak 600/s).

### experiment-2 (single / double slit)

Site: column 1 = actuator position in um, column 2 = counts in 2 s, column 3 =
counts per second (= column 2 / 2). Note the CSV peaks (5 600/s left slit,
2 900/s right slit, 21 500/s double slit) are about 2.5x the values plotted on
the page (2 200/s and 8 700/s); the published plots were evidently made from a
different run or scaled. The double-slit file is named `calib_123`.

### experiment-3 (polarized double slit, one-photon eraser)

Site: 4 columns: angle of polarizer 1, angle of polarizer 2 ("only P1 is
used"), actuator position in um, counts on D1 in a 2 s window. Files: `Pol 1`,
`Pol B`, `Pos`, `CountsD1`. One file per P1 setting (-45.33, -0.33, 44.67,
-99.33 deg for the -45 / 0 / 45 / 90 files; `Pol B` is ~0 everywhere).
Converted to per second the peaks are 3 400-3 800/s, half of the page's plot
values (6 700-7 700), so the plots appear to show counts per 2 s window.

### experiment-4 (entanglement, polarization correlations)

Site: 5 columns: PolA, PolB (-90..90 deg), D1 singles, D2 singles, D1-D2
coincidences, 1 s windows. File `Acquisition_-_Feuille_1.csv`: `PolA`, `PolB`,
`CountsA`, `CountsB`, `CountsAB`; 361 rows = full 19 x 19 grid in 10 deg steps.
Singles 10 600-39 900/s (A) and 4 100-30 800/s (B); coincidences 1-1 267/s.

### experiment-5 (entangled source + slits, no eraser on the idler)

Site: 7 columns: polarizer angle 1, polarizer angle 2, actuator position,
sweep number, counts at D1, counts at D2, coincidences, 20 s windows. Files:
`Pol A`/`Pol B` (or `Pol 1`/`Pol 2` in 4_3), `Pos`, `Sweep`, `CountsA`,
`CountsB`, `CountsAB`. Each position is sampled 6 times per sweep and the
scan is swept 4-6 times, so there are 24-36 rows per position; average them
per position to reproduce the plots (D1 ~410 / 323 / 200 counts/s and
coincidences ~7.6 / 1.0 / 0.37 /s for 5.1 / 5.2 / 5.3).

### experiment-6 (delayed-choice quantum eraser)

Site says 7 columns like Exp 5/7, but the files are wide: `Polarisation P1`,
`Polarization P2`, `All distance` (position, um), then one
(`Sweep_n D1`, `Sweep_n D2`, `Sweep_n D1D2`) triplet per sweep (5 or 6
sweeps; the header of `Data_90deg` and `Data_135deg` omits the names of the
sixth sweep's three columns, see the summary). Seven sample rows per position.
Recorded angles: `Data_0deg` P1 = 45.47, P2 = 0.02; `Data_90deg` P1 = 45.47,
P2 = -90.01; `Data_45degre` P1 = 45.48, P2 = 45.01; `Data_135deg` P1 = 135.48,
P2 = 45.01 (the file's own description calls this "the data at -45 degrees";
P1 = 135 with P2 = 45 is the complementary diagonal case). Position-averaged
peaks: D1 ~200/s (0, 90) and ~370/s (45, 135); coincidences ~0.3-0.6 /s,
matching the page's plots.

### experiment-7 (detecting is not recording)

Site: 7 columns: P1, P2, actuator position (um), sweep, counts at D1, counts
at D2, coincidences; 20 s windows. Files: `Polarisation P1`,
`Polarization P2`, `All distance`, `Sweep`, `Counts of  D1` (two spaces),
`Counts of D2`, `Coincidence D1D2`. `6.1_wall`: P1 = 44.88, P2 = -0.4, D2 sees
only ~180/s behind the wall and coincidences are 0 or 1 per 20 s. `6.2_unplugged`:
P1 = 89.88, P2 = -0.4, the D2 and coincidence columns are all zero. (The page
text calls these P1 = 45 deg, P2 = 90 deg.)

## Summary (output of `python3 -I tools/labdata/summarise.py`)

# Lab CSV summary (20 files)

### app/data/lab/experiment-1/Data1_1pol.csv
description : #The acquisition time is 1 second
acquisition : 1 s per point
columns     : 9   data rows: 81
| column | min | max |
|---|---|---|
| Position on the sceen | 12500 | 20500 |
| Angle of P1 | 45 | 45 |
| Count per seconds | 355.3 | 1159.4 |
| Angle of P1 | 22.5 | 22.5 |
| Conts per seocnd | 251 | 881 |
| Angle of P1 | 0 | 0 |
| conts per seconds | 303 | 614 |
| Angle of P1 | -45 | -45 |
| Counts per seconds | 242 | 354 |
scan        : Position on the sceen from 12500 to 20500 um, 81 distinct positions, step 100, 1.0 rows per position
peak sample : Count per seconds: 1.16e+03 /s; Counts per seconds: 354 /s
peak of mean profile : Count per seconds: 1.16e+03 /s at 16400 um; Counts per seconds: 354 /s at 12800 um

### app/data/lab/experiment-1/Data1_2pol.csv
description : #The acquisition time is 1 second, the two polarizer are perpendicular
acquisition : 1 s per point
columns     : 4   data rows: 81
| column | min | max |
|---|---|---|
| Position | 12500 | 20500 |
| Pol 1 | 0 | 0 |
| Pol 2 | 90 | 90 |
| Counts per seconds | 246 | 361 |
scan        : Position from 12500 to 20500 um, 81 distinct positions, step 100, 1.0 rows per position
peak sample : Counts per seconds: 361 /s
peak of mean profile : Counts per seconds: 361 /s at 12800 um

### app/data/lab/experiment-1/Data1_3pol.csv
description : The acquisition time was 2 seconds. the polarizers are place as the three polarizer paradox
acquisition : 2 s per point
columns     : 5   data rows: 81
| column | min | max |
|---|---|---|
| Position | 12500 | 20500 |
| Polarizer 1 | 0 | 0 |
| Polarizer 2 | 45 | 45 |
| Polarizer 3 | 90 | 90 |
| Counts per seocnds | 301 | 599.5 |
scan        : Position from 12500 to 20500 um, 81 distinct positions, step 100, 1.0 rows per position
peak sample : Counts per seocnds: 600 /s
peak of mean profile : Counts per seocnds: 600 /s at 17100 um

### app/data/lab/experiment-2/Single_slit_-_left_slit.csv
description : Acquisition time of 2 seconds.
acquisition : 2 s per point
columns     : 3   data rows: 51
| column | min | max |
|---|---|---|
| Pos | 17500 | 22500 |
| Counts | 947 | 11255 |
| Counts per seconds | 473.5 | 5627.5 |
scan        : Pos from 17500 to 22500 um, 51 distinct positions, step 100, 1.0 rows per position
peak sample : Counts: 1.13e+04 in 2 s = 5.63e+03 /s; Counts per seconds: 5.63e+03 /s
peak of mean profile : Counts: 1.13e+04 in 2 s = 5.63e+03 /s at 19400 um; Counts per seconds: 5.63e+03 /s at 19400 um

### app/data/lab/experiment-2/Single_slit_-_right_slit.csv
description : Acquisition time of 2 seconds
acquisition : 2 s per point
columns     : 3   data rows: 51
| column | min | max |
|---|---|---|
| Pos | 17500 | 22500 |
| Counts | 818 | 5825 |
| Counts per seconds | 409 | 2912.5 |
scan        : Pos from 17500 to 22500 um, 51 distinct positions, step 100, 1.0 rows per position
peak sample : Counts: 5.82e+03 in 2 s = 2.91e+03 /s; Counts per seconds: 2.91e+03 /s
peak of mean profile : Counts: 5.82e+03 in 2 s = 2.91e+03 /s at 19100 um; Counts per seconds: 2.91e+03 /s at 19100 um

### app/data/lab/experiment-2/double_slit_-_calib_123_(1).csv
description : Aquisition of 2 seconds.
acquisition : 2 s per point
columns     : 3   data rows: 121
| column | min | max |
|---|---|---|
| Pos | 17500 | 23500 |
| Counts | 2331 | 43007 |
| Counts per second | 1165.5 | 21503.5 |
scan        : Pos from 17500 to 23500 um, 121 distinct positions, step 50, 1.0 rows per position
peak sample : Counts: 4.3e+04 in 2 s = 2.15e+04 /s; Counts per second: 2.15e+04 /s
peak of mean profile : Counts: 4.3e+04 in 2 s = 2.15e+04 /s at 20550 um; Counts per second: 2.15e+04 /s at 20550 um

### app/data/lab/experiment-3/Data_exp3_-_data_-45.csv
description : Acquisition of 2 seconds, coincidance window at 10 ns.
acquisition : 2 s per point
columns     : 4   data rows: 121
| column | min | max |
|---|---|---|
| Pol 1 | -45.33 | -45.33 |
| Pol B | 0.01 | 0.01 |
| Pos | 17000 | 23000 |
| CountsD1 | 1338 | 6728 |
scan        : Pos from 17000 to 23000 um, 121 distinct positions, step 50, 1.0 rows per position
peak sample : CountsD1: 6.73e+03 in 2 s = 3.36e+03 /s
peak of mean profile : CountsD1: 6.73e+03 in 2 s = 3.36e+03 /s at 20500 um

### app/data/lab/experiment-3/Data_exp3_-_data_0.csv
description : Acquisition of 2 seconds, coincidance window at 10 ns.
acquisition : 2 s per point
columns     : 4   data rows: 121
| column | min | max |
|---|---|---|
| Pol 1 | -0.33 | -0.33 |
| Pol B | -0.47 | -0.47 |
| Pos | 17000 | 23000 |
| CountsD1 | 1125 | 6810 |
scan        : Pos from 17000 to 23000 um, 121 distinct positions, step 50, 1.0 rows per position
peak sample : CountsD1: 6.81e+03 in 2 s = 3.4e+03 /s
peak of mean profile : CountsD1: 6.81e+03 in 2 s = 3.4e+03 /s at 19900 um

### app/data/lab/experiment-3/Data_exp3_-_data_45.csv
description : Acquisition of 2 seconds, coincidance window at 10 ns.
acquisition : 2 s per point
columns     : 4   data rows: 121
| column | min | max |
|---|---|---|
| Pol 1 | 44.67 | 44.67 |
| Pol B | 0.3 | 0.3 |
| Pos | 17000 | 23000 |
| CountsD1 | 1118 | 7656 |
scan        : Pos from 17000 to 23000 um, 121 distinct positions, step 50, 1.0 rows per position
peak sample : CountsD1: 7.66e+03 in 2 s = 3.83e+03 /s
peak of mean profile : CountsD1: 7.66e+03 in 2 s = 3.83e+03 /s at 20150 um

### app/data/lab/experiment-3/Data_exp3_-_data_90.csv
description : Acquisition of 2 seconds, coincidance window at 10 ns.
acquisition : 2 s per point
columns     : 4   data rows: 121
| column | min | max |
|---|---|---|
| Pol 1 | -99.33 | -99.33 |
| Pol B | 0.28 | 0.28 |
| Pos | 17000 | 23000 |
| CountsD1 | 1148 | 3351 |
scan        : Pos from 17000 to 23000 um, 121 distinct positions, step 50, 1.0 rows per position
peak sample : CountsD1: 3.35e+03 in 2 s = 1.68e+03 /s
peak of mean profile : CountsD1: 3.35e+03 in 2 s = 1.68e+03 /s at 21200 um

### app/data/lab/experiment-4/Acquisition_-_Feuille_1.csv
description : #The acquisition time is of 1 second. with Coincidence window at 10ns.
acquisition : 1 s per point
columns     : 5   data rows: 361
| column | min | max |
|---|---|---|
| PolA | -90 | 90 |
| PolB | -90 | 90 |
| CountsA | 10576 | 39904 |
| CountsB | 4120 | 30840 |
| CountsAB | 1 | 1267 |

### app/data/lab/experiment-5/Data4_1_-_Feuille_1.csv
description : Acquisition with only the double slit and no polarizer. Acquisition time of 20 seconds
acquisition : 20 s per point
columns     : 7   data rows: 2430
| column | min | max |
|---|---|---|
| Pol A | 0 | 0 |
| Pol B | 0 | 0 |
| Pos | 16600 | 20600 |
| Sweep | 1 | 5 |
| CountsA | 3346 | 8526 |
| CountsB | 235460 | 254909 |
| CountsAB | 0 | 184 |
scan        : Pos from 16600 to 20600 um, 81 distinct positions, step 50, 30.0 rows per position
peak sample : CountsA: 8.53e+03 in 20 s = 426 /s; CountsB: 2.55e+05 in 20 s = 1.27e+04 /s; CountsAB: 184 in 20 s = 9.2 /s
peak of mean profile : CountsA: 8.2e+03 in 20 s = 410 /s at 18650 um; CountsB: 2.47e+05 in 20 s = 1.24e+04 /s at 19650 um; CountsAB: 153 in 20 s = 7.64 /s at 18650 um

### app/data/lab/experiment-5/Data4_2_-_Feuille_1.csv
description : Acquisition with the double slit, and PA and PB. P1 and P2 are not there. Acquisition of 20 seconds.
acquisition : 20 s per point
columns     : 7   data rows: 1944
| column | min | max |
|---|---|---|
| Pol A | 0 | 0 |
| Pol B | 0 | 0 |
| Pos | 17000 | 21000 |
| Sweep | 1 | 4 |
| CountsA | 3963 | 6678 |
| CountsB | 393243 | 411822 |
| CountsAB | 0 | 37 |
scan        : Pos from 17000 to 21000 um, 81 distinct positions, step 50, 24.0 rows per position
peak sample : CountsA: 6.68e+03 in 20 s = 334 /s; CountsB: 4.12e+05 in 20 s = 2.06e+04 /s; CountsAB: 37 in 20 s = 1.85 /s
peak of mean profile : CountsA: 6.46e+03 in 20 s = 323 /s at 18950 um; CountsB: 4.06e+05 in 20 s = 2.03e+04 /s at 17000 um; CountsAB: 20.9 in 20 s = 1.05 /s at 19150 um

### app/data/lab/experiment-5/Data4_3_-_Feuille_1_(1).csv
description : Acquisition eith the double slit, Pa, Pb and P1. Acquisition of 20 seconds
acquisition : 20 s per point
columns     : 7   data rows: 2916
| column | min | max |
|---|---|---|
| Pol 1 | 44.88 | 44.88 |
| Pol 2 | 0 | 0 |
| Pos | 16450 | 20450 |
| Sweep | 1 | 6 |
| CountsA | 319 | 4379 |
| CountsB | 42492 | 431658 |
| CountsAB | 0 | 15 |
scan        : Pos from 16450 to 20450 um, 81 distinct positions, step 50, 36.0 rows per position
peak sample : CountsA: 4.38e+03 in 20 s = 219 /s; CountsB: 4.32e+05 in 20 s = 2.16e+04 /s; CountsAB: 15 in 20 s = 0.75 /s
peak of mean profile : CountsA: 4e+03 in 20 s = 200 /s at 19100 um; CountsB: 4.18e+05 in 20 s = 2.09e+04 /s at 16450 um; CountsAB: 7.33 in 20 s = 0.367 /s at 18650 um

### app/data/lab/experiment-6/Data_0deg.csv
description : #These are the data at 0 degrees. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns.
acquisition : 20 s per point
columns     : 21   data rows: 567
| column | min | max |
|---|---|---|
| Polarisation P1 | 45.47 | 45.47 |
| Polarization P2 | 0.02 | 0.02 |
| All distance | 16450 | 20450 |
| Sweep_0  D1 | 3401 | 4390 |
| Sweep_0 D2 | 302854 | 308031 |
| Sweep_0 D1D2 | 0 | 17 |
| Sweep_1  D1 | 3266 | 4256 |
| Sweep_1 D2 | 289064 | 295508 |
| Sweep_1 D1D2 | 0 | 18 |
| Sweep_2  D1 | 3236 | 4126 |
| Sweep_2 D2 | 278938 | 285171 |
| Sweep_2 D1D2 | 0 | 16 |
| Sweep_3  D1 | 3253 | 4165 |
| Sweep_3 D2 | 267834 | 275499 |
| Sweep_3 D1D2 | 0 | 14 |
| Sweep_4  D1 | 3161 | 4143 |
| Sweep_4 D2 | 255875 | 261129 |
| Sweep_4 D1D2 | 0 | 11 |
| Sweep_5  D1 | 3072 | 3937 |
| Sweep_5 D2 | 245256 | 249851 |
| Sweep_5 D1D2 | 0 | 13 |
scan        : All distance from 16450 to 20450 um, 81 distinct positions, step 50, 7.0 rows per position
peak sample : D1 (all sweeps): 4.39e+03 in 20 s = 220 /s; D2 (all sweeps): 3.08e+05 in 20 s = 1.54e+04 /s; D1D2 (all sweeps): 18 in 20 s = 0.9 /s
peak of mean profile : D1 (all sweeps): 4.02e+03 in 20 s = 201 /s at 18000 um; D2 (all sweeps): 2.78e+05 in 20 s = 1.39e+04 /s at 16700 um; D1D2 (all sweeps): 7.9 in 20 s = 0.395 /s at 18600 um

### app/data/lab/experiment-6/Data_135deg.csv
description : #These are the data at -45 degrees. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns.
acquisition : 20 s per point
columns     : 21   data rows: 609
| column | min | max |
|---|---|---|
| Polarisation P1 | 135.48 | 135.48 |
| Polarization P2 | 45.01 | 45.01 |
| All distance | 16300 | 20600 |
| Sweep_0  D1 | 6383 | 7444 |
| Sweep_0 D2 | 381797 | 392761 |
| Sweep_0 D1D2 | 0 | 16 |
| Sweep_1  D1 | 6384 | 7479 |
| Sweep_1 D2 | 375912 | 384248 |
| Sweep_1 D1D2 | 0 | 16 |
| Sweep_2  D1 | 6419 | 7558 |
| Sweep_2 D2 | 371710 | 378842 |
| Sweep_2 D1D2 | 0 | 15 |
| Sweep_3  D1 | 6484 | 7633 |
| Sweep_3 D2 | 365428 | 374762 |
| Sweep_3 D1D2 | 0 | 20 |
| Sweep_4  D1 | 6421 | 7663 |
| Sweep_4 D2 | 361722 | 368580 |
| Sweep_4 D1D2 | 0 | 17 |
| Sweep_5 D1 (unnamed in file) | 6383 | 7675 |
| Sweep_5 D2 (unnamed in file) | 360409 | 366294 |
| Sweep_5 D1D2 (unnamed in file) | 0 | 16 |
scan        : All distance from 16300 to 20600 um, 87 distinct positions, step 50, 7.0 rows per position
peak sample : D1 (all sweeps): 7.68e+03 in 20 s = 384 /s; D2 (all sweeps): 3.93e+05 in 20 s = 1.96e+04 /s; D1D2 (all sweeps): 20 in 20 s = 1 /s
peak of mean profile : D1 (all sweeps): 7.41e+03 in 20 s = 370 /s at 18450 um; D2 (all sweeps): 3.76e+05 in 20 s = 1.88e+04 /s at 16300 um; D1D2 (all sweeps): 8.76 in 20 s = 0.438 /s at 18700 um

### app/data/lab/experiment-6/Data_45degre.csv
description : #These are the data at 45 degrees. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns.
acquisition : 20 s per point
columns     : 18   data rows: 567
| column | min | max |
|---|---|---|
| Polarisation P1 | 45.48 | 45.48 |
| Polarization P2 | 45.01 | 45.01 |
| All distance | 16300 | 20300 |
| Sweep_0  D1 | 6516 | 8045 |
| Sweep_0 D2 | 366893 | 373918 |
| Sweep_0 D1D2 | 0 | 21 |
| Sweep_1  D1 | 6444 | 7523 |
| Sweep_1 D2 | 364548 | 369253 |
| Sweep_1 D1D2 | 0 | 23 |
| Sweep_2  D1 | 6531 | 7496 |
| Sweep_2 D2 | 359069 | 367472 |
| Sweep_2 D1D2 | 0 | 25 |
| Sweep_3  D1 | 6308 | 7578 |
| Sweep_3 D2 | 354425 | 362399 |
| Sweep_3 D1D2 | 0 | 17 |
| Sweep_4  D1 | 6280 | 7448 |
| Sweep_4 D2 | 351271 | 359647 |
| Sweep_4 D1D2 | 0 | 21 |
scan        : All distance from 16300 to 20300 um, 81 distinct positions, step 50, 7.0 rows per position
peak sample : D1 (all sweeps): 8.04e+03 in 20 s = 402 /s; D2 (all sweeps): 3.74e+05 in 20 s = 1.87e+04 /s; D1D2 (all sweeps): 25 in 20 s = 1.25 /s
peak of mean profile : D1 (all sweeps): 7.43e+03 in 20 s = 371 /s at 18350 um; D2 (all sweeps): 3.64e+05 in 20 s = 1.82e+04 /s at 16300 um; D1D2 (all sweeps): 12.7 in 20 s = 0.636 /s at 18200 um

### app/data/lab/experiment-6/Data_90deg.csv
description : #These are the data at 90 degrees. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns.
acquisition : 20 s per point
columns     : 21   data rows: 567
| column | min | max |
|---|---|---|
| Polarisation P1 | 45.47 | 45.47 |
| Polarization P2 | -90.01 | -90.01 |
| All distance | 16450 | 20450 |
| Sweep_0  D1 | 3446 | 4389 |
| Sweep_0 D2 | 301760 | 308081 |
| Sweep_0 D1D2 | 0 | 12 |
| Sweep_1  D1 | 3349 | 4295 |
| Sweep_1 D2 | 289452 | 297754 |
| Sweep_1 D1D2 | 0 | 11 |
| Sweep_2  D1 | 3197 | 4139 |
| Sweep_2 D2 | 279577 | 285106 |
| Sweep_2 D1D2 | 0 | 11 |
| Sweep_3  D1 | 3289 | 4101 |
| Sweep_3 D2 | 270048 | 276121 |
| Sweep_3 D1D2 | 0 | 11 |
| Sweep_4  D1 | 3180 | 4091 |
| Sweep_4 D2 | 255718 | 262304 |
| Sweep_4 D1D2 | 0 | 13 |
| Sweep_5 D1 (unnamed in file) | 3155 | 3970 |
| Sweep_5 D2 (unnamed in file) | 244979 | 250953 |
| Sweep_5 D1D2 (unnamed in file) | 0 | 11 |
scan        : All distance from 16450 to 20450 um, 81 distinct positions, step 50, 7.0 rows per position
peak sample : D1 (all sweeps): 4.39e+03 in 20 s = 219 /s; D2 (all sweeps): 3.08e+05 in 20 s = 1.54e+04 /s; D1D2 (all sweeps): 13 in 20 s = 0.65 /s
peak of mean profile : D1 (all sweeps): 4.04e+03 in 20 s = 202 /s at 18150 um; D2 (all sweeps): 2.79e+05 in 20 s = 1.4e+04 /s at 16450 um; D1D2 (all sweeps): 5.67 in 20 s = 0.283 /s at 18100 um

### app/data/lab/experiment-7/6.1_wall_-_Feuille_1_(2).csv
description : #These are the data with a wall in front of D2. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns.
acquisition : 20 s per point
columns     : 7   data rows: 2430
| column | min | max |
|---|---|---|
| Polarisation P1 | 44.88 | 44.88 |
| Polarization P2 | -0.4 | -0.4 |
| All distance | 16600 | 20600 |
| Sweep | 1 | 5 |
| Counts of  D1 | 3069 | 4306 |
| Counts of D2 | 3050 | 3861 |
| Coincidence D1D2 | 0 | 1 |
scan        : All distance from 16600 to 20600 um, 81 distinct positions, step 50, 30.0 rows per position
peak sample : Counts of  D1: 4.31e+03 in 20 s = 215 /s; Counts of D2: 3.86e+03 in 20 s = 193 /s; Coincidence D1D2: 1 in 20 s = 0.05 /s
peak of mean profile : Counts of  D1: 4.03e+03 in 20 s = 202 /s at 18600 um; Counts of D2: 3.54e+03 in 20 s = 177 /s at 16700 um; Coincidence D1D2: 0.0667 in 20 s = 0.00333 /s at 20550 um

### app/data/lab/experiment-7/6.2_unplugged_-_Feuille_1_(1).csv
description : #These are the data with D2 unplugged. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns.
acquisition : 20 s per point
columns     : 7   data rows: 2916
| column | min | max |
|---|---|---|
| Polarisation P1 | 89.88 | 89.88 |
| Polarization P2 | -0.4 | -0.4 |
| All distance | 16600 | 20600 |
| Sweep | 1 | 6 |
| Counts of  D1 | 3159 | 4603 |
| Counts of D2 | 0 | 0 |
| Coincidence D1D2 | 0 | 0 |
scan        : All distance from 16600 to 20600 um, 81 distinct positions, step 50, 36.0 rows per position
peak sample : Counts of  D1: 4.6e+03 in 20 s = 230 /s; Counts of D2: 0 in 20 s = 0 /s; Coincidence D1D2: 0 in 20 s = 0 /s
peak of mean profile : Counts of  D1: 4.21e+03 in 20 s = 210 /s at 18650 um; Counts of D2: 0 in 20 s = 0 /s at 20600 um; Coincidence D1D2: 0 in 20 s = 0 /s at 20600 um
