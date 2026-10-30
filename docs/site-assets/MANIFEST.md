# Site asset manifest

Reference assets fetched from https://testing-reality.webflow.io (curl, user agent `testing-reality-build`) on 2026-10-30.

- Images live under `docs/site-assets/<page-slug>/`; CSV data under `app/data/lab/<page-slug>/` (see `app/data/lab/README.md`).
- File names are the originals with the Webflow hash prefix removed, `%20` decoded and spaces replaced by `_`.
- Site chrome (logos, CC/BY/NC badges, list/close icons, the download-file icon) was not downloaded. The three navigation thumbnails repeated on every page (`Introduction.png`, `exp1_Diagram.png`, `exp2.png`) are kept once, under `home/`.
- Skipped as under 5 KB: `quantum_superposition_clean.svg` (home, 4018 B, https://cdn.prod.website-files.com/62f169875514947cce769885/69c3e1fc1d64ba006535be01_quantum_superposition_clean.svg) and `Intro fig1.png` (introduction, 2620 B, https://cdn.prod.website-files.com/62f169875514947cce769885/69c1f1cdecd10972310b833f_Intro%20fig1.png).

- Image descriptions were written after viewing each file.

Totals: 20 CSV files, 98 images, 0 download failures.


## Home (`/`)

Page URL: https://testing-reality.webflow.io/  
Content spec: `docs/content/00-home.md`

### Images (`docs/site-assets/home/`)

| file | source URL | what it shows |
|---|---|---|
| `quantum_entanglement_no_bracket.svg` | https://cdn.prod.website-files.com/62f169875514947cce769885/69c3e20a0d8d58aecbb4c5bd_quantum_entanglement_no_bracket.svg | Mystery-card illustration (Entanglement): two circles labelled 'particle A' and 'particle B' linked by lines on a pale blue-grey background. (SVG; described from the source text.) |
| `many_worlds_diagram.svg` | https://cdn.prod.website-files.com/62f169875514947cce769885/69c3e2156164a611488ba226_many_worlds_diagram.svg | Mystery-card illustration (Many-Worlds): a branching tree of seven circles joined by lines on a pale blue-grey background, labelled World 1..World 4. (SVG; described from the source text, ImageMagick could not rasterise it.) |
| `Introduction.png` | https://cdn.prod.website-files.com/62f575de7ff2ddfcee0aec3f/6706e3c6d4089ceef79e13a1_Introduction.png | Card thumbnail for the Introduction: the word OVERVIEW in large bold black text on a pale blue-grey panel. |
| `exp1_Diagram.png` | https://cdn.prod.website-files.com/62f575de7ff2ddfcee0aec3f/66faf93cc2992ce4e1f4c59a_exp1_Diagram.png | Card thumbnail, Experiment 1: four stacked beam lines LASER -> grey disc -> purple polarizers (P1 90; P1 90 + P2 0; P1 90 + P2 45 + P3 0) -> D1, state planes Psi0..Psi3. |
| `exp2.png` | https://cdn.prod.website-files.com/62f575de7ff2ddfcee0aec3f/6711629484433cabd2e4ba71_exp2.png | Card thumbnail, Experiment 2: top row straight beam through a single slit to D1, bottom row two red rays through a double slit converging on D1; planes Psi0, Psi1 Psi2, Psi3. |
| `exp3.png` | https://cdn.prod.website-files.com/62f575de7ff2ddfcee0aec3f/6711628b3ddeb6defea02cd1_exp3.png | Card thumbnail, Experiment 3: double slit with PA 0 deg / PB 90 deg on the slits and a rotatable P1 at 45 deg before D1; planes Psi0..Psi3. |
| `exp4.0_Diagram_(4).png` | https://cdn.prod.website-files.com/62f575de7ff2ddfcee0aec3f/66fadedc4a20b4c3dcd7a78f_exp4.0_Diagram%20(4).png | Card thumbnail, Experiment 4: LASER -> BB crystal pair, two dashed beams (one via a mirror) to rotatable polarizers alpha (P2) and beta (P1) before D2 / D1, both wired to a 'coin' counter; planes Psi0..Psi2. |
| `exp4.3_Diagram_(1).png` | https://cdn.prod.website-files.com/62f575de7ff2ddfcee0aec3f/66faded44db4829e86589681_exp4.3_Diagram%20(1).png | Card thumbnail, Experiment 5: BB source, idler via mirror to D2, signal through the PA/PB double slit and P1 45 deg to D1, coincidence counter; planes Psi0..Psi6. |
| `exp5.4_Diagram_(1).png` | https://cdn.prod.website-files.com/62f575de7ff2ddfcee0aec3f/66fadecc480fc8ed61444273_exp5.4_Diagram%20(1).png | Card thumbnail, Experiment 6: same as Exp 5 plus a rotatable P2 at 45 deg on the idler arm before D2; planes Psi0..Psi7 (Psi5-6 merged). |
| `expWall_Diagram_(1).png` | https://cdn.prod.website-files.com/62f575de7ff2ddfcee0aec3f/66fadec27b45628fd1f3d256_expWall_Diagram%20(1).png | Card thumbnail, Experiment 7: eraser layout with P2 at 90 deg and a black wall blocking the idler in front of D2; planes Psi0..Psi7. |


## Introduction: The quantum formalism (`/introduction`)

Page URL: https://testing-reality.webflow.io/introduction  
Content spec: `docs/content/01-introduction.md`

### Images (`docs/site-assets/introduction/`)

| file | source URL | what it shows |
|---|---|---|
| `Intro_1.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69c1f1f430d660fdaf77e1f2_Intro_1.png | 2-D basis diagram: orthogonal unit arrows |A> (red, horizontal) and |B> (purple, vertical) on a pale blue-grey panel. |
| `Intro_2.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69c1f2262fc9dffa3e54f38b_Intro_2.png | Basis |A>, |B> plus three black unit vectors |phi1> (about 30 deg), |phi3> (about 60 deg) and |phi2> (about -45 deg, fourth quadrant): the superposition family figure. |
| `Intro_fig4.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69c1f276455c38dcdbabbbff_Intro%20fig4.png | |phi3> drawn with its components: dashed projections 1/2 on |A> and sqrt(3)/2 on |B>. |


## Experiment 1: Polarizers (`/experiment-1`)

Page URL: https://testing-reality.webflow.io/experiment-1  
Content spec: `docs/content/02-experiment-1-polarizers.md`

StackBlitz simulator embed(s): https://react-vazdln-h798ez.stackblitz.io

YouTube video(s): https://www.youtube.com/watch?v=0-8tQlOhCBA (3 Polarizing Filters); https://www.youtube.com/watch?v=5SIxEiL8ujA (Three polarizing filters: a simple demo of a creepy quantum effect)

### Data files (`app/data/lab/experiment-1/`)

Site text: "They all have 3 columns: the position of the detector, the angle of the polarizers and the number of photons detected" (docs/content/02-experiment-1-polarizers.md, Links/downloads). Actual files: `Data1_1pol.csv` has one shared detector-position column (stage position, um) followed by four (angle of P1, counts per second) pairs for P1 = 45, 22.5, 0 and -45 deg; `Data1_2pol.csv` = position, Pol 1 angle, Pol 2 angle, counts per second; `Data1_3pol.csv` = position, Polarizer 1/2/3 angles, counts per second (2 s acquisition, already normalised).

| file | source URL | header row | data rows | description line in file |
|---|---|---|---|---|
| `Data1_1pol.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67c3220962d9bc846f9a44df_e4290dd9b7f32c70cac13c78f7052027_Data1_1pol.csv | `Position on the sceen,Angle of P1,Count per seconds,Angle of P1,Conts per seocnd,Angle of P1,conts per seconds,Angle of P1,Counts per seconds` | 81 | #The acquisition time is 1 second |
| `Data1_2pol.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67c32209a53da7ec0839dc26_90b99f91a87e41e7cff4c7688aa61df2_Data1_2pol.csv | `Position,Pol 1,Pol 2,Counts per seconds` | 81 | #The acquisition time is 1 second, the two polarizer are perpendicular |
| `Data1_3pol.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67c32209176ea57a01fa179d_762f665b4449f571bd8ab7894fd5540b_Data1_3pol.csv | `Position,Polarizer 1,Polarizer 2,Polarizer 3,Counts per seocnds` | 81 | The acquisition time was 2 seconds. the polarizers are place as the three polarizer paradox |

### Images (`docs/site-assets/experiment-1/`)

| file | source URL | what it shows |
|---|---|---|
| `exp1_fig1_(3).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69b9cb5e5eac4ba81bebd285_exp1%20fig1%20(3).png | Polarization basis diagram: |updown> (purple vertical), |leftright> (red horizontal) and the diagonal |NE> (black) unit vectors. |
| `exp1_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66faf91c624ce90262217e66_705da8ce88899db0314a31259ebb090e_exp1_Diagram.png | Results schematic: four rows (no polarizer; P1 0; P1 0 + P2 90; P1 0 + P2 45 + P3 90) with theoretical transmission 100 %, 50 %, 0 %, 12.5 %; planes Psi0..Psi3. |
| `vue_exp1.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/677d8971898f15948fdfde85_vue_exp1.png | Lab photo looking along the beam: labelled Laser, Beam splitter, Lens, P1, P2, Lens, P3 and Detector (red PCB single-photon module) on the breadboard. |
| `laser_exp1.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/677d896afda28a26cfe3c9ff_laser_exp1.png | Lab photo: the laser head (black heat-sinked module) with labelled LASER, Beam splitter cube and Wave plate in rotation mounts on the optical breadboard. |
| `setup_exp1.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/677d89752222b706bfe05e9a_setup_exp1.png | Overhead photo of the whole Experiment 1 table with a purple beam-line overlay and labels P3, P2, P1. |
| `lens_exp1.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/677d897323ba5cb96ecd06f3_lens_exp1.png | Lab photo at table height: a lens, P1 in a rotation mount, a black beam block, P3 and the red detector board. |
| `exp1_MontageT.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/677d8bd0629ba078d1020e73_exp1_MontageT.png | Technical setup drawing: LASER -> BS (beam splitter, BD beam dump) -> lambda/2 -> L1 = 50 cm lens -> P1, P2, P3 -> D1, with legend. |
| `Single_slit.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69b9d048b5c257cefd9b008a_Single%20slit.png | Illustration of polarizer-as-slit analogy: a red/purple sinusoidal wave meets a horizontal slit (top) and a vertical slit (bottom); only the matching oscillation component continues. |
| `exp1_PolariseurVariable_(1).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69b9d0d899992f7a49701b88_exp1_PolariseurVariable%20(1).png | Minimal schematic: LASER -> grey disc -> D1, single plane Psi0 (no-polarizer reference case). |
| `exp1_pol6.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69b9d125306b5b863be2668f_exp1_pol6.png | Schematic: LASER -> disc -> P1 (0 deg) -> D1, planes Psi0, Psi1 (one polarizer). |
| `exp1_pol7.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69b9d1847a674e07a098b175_exp1_pol7.png | Schematic: LASER -> P1 0 deg -> P2 90 deg -> D1, planes Psi0..Psi2 (crossed polarizers). |
| `exp1_pol8.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69b9d1e7f4412e741b7681e8_exp1_pol8.png | Schematic: LASER -> P1 0 deg -> P2 45 -> P3 90 deg -> D1, planes Psi0..Psi3 (three-polarizer paradox). |
| `pol3.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69b9d2355c9b56cd7d24aefd_pol3.png | Vector triangle: |leftright> as the sum of |NE> and |SE> components, with the equation |leftright> = (|NE> + |SE>) / sqrt 2. |


## Experiment 2: Single and double slit (`/experiment-2`)

Page URL: https://testing-reality.webflow.io/experiment-2  
Content spec: `docs/content/03-experiment-2-double-slit.md`

StackBlitz simulator embed(s): https://react-vazdln-zpjxg8.stackblitz.io

YouTube video(s): https://www.youtube.com/watch?v=A9tKncAdlHQ (Double Slit Experiment explained! by Jim Al-Khalili); https://www.youtube.com/watch?v=I9Ab8BLW3kA (Young's interference experiment with single photons (Hamamatsu Photonics, 1982))

### Data files (`app/data/lab/experiment-2/`)

Site text: "The files have 3 columns. The first one is the distance travelled by the actuator in um. The second column is the number of counts seen by the detector, in a range of 2 seconds. The last column is the same number of counts, but per seconds" (docs/content/03-experiment-2-double-slit.md).

| file | source URL | header row | data rows | description line in file |
|---|---|---|---|---|
| `Single_slit_-_left_slit.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67085b11b76c8ce529168921_9ee32ace0f9299163977ec3f8dbb1006_Single%20slit%20-%20left%20slit.csv | `Pos,Counts,Counts per seconds` | 51 | Acquisition time of 2 seconds. |
| `Single_slit_-_right_slit.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67085b1292fe953a99b373f8_23b323c6e590837b1fbf112034e6013b_Single_slit%20-%20right%20slit.csv | `Pos,Counts,Counts per seconds` | 51 | Acquisition time of 2 seconds |
| `double_slit_-_calib_123_(1).csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67085c634193483ccc3a53f7_7b32708c5e656e231269758c5002bf01_double%20slit%20-%20calib_123%20%281%29.csv | `Pos,Counts,Counts per second` | 121 | Aquisition of 2 seconds. |

### Images (`docs/site-assets/experiment-2/`)

| file | source URL | what it shows |
|---|---|---|
| `exp2_single.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/67083e8aad6180fa8816649a_exp2_single.png | Plot 'Number of counts on D1 per seconds [single slit]': left-slit (red) and right-slit (blue) bell curves with data points, peak ~2200/s, x from -2500 to 2500 um. |
| `exp2_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/67083eff322092408699f7b0_exp2_A.png | Plot 'Number of counts on D1 per seconds [double slit]': data points, blue fit, grey theoretical curve; central peak ~8700/s, side peaks ~3900 and ~3650/s at +/-1000 um, x from -3000 to 3000 um. |
| `setup_exp2.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/67083b18ed0e50d9674cfb5d_setup_exp2.png | Overhead photo of the Experiment 2 table with purple beam overlay: LASER, Half-wave plate, Beam splitter, Lens, Double slit, Lens, Detection stage. |
| `laser_exp2.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/67083b185c4560fe8267e84f_laser_exp2.png | Lab photo close-up: LASER, Beam splitter, Beam dump and Half-wave plate in a rotation mount, labelled. |
| `detector_exp2.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/67083b189bc38cee1def64cc_detector_exp2.png | Lab photo of the detection stage: Detector, Collimator, Motor (unused), Filters (ND stack) on a Linear actuator, labelled. |
| `slit_exp2.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/67083b197878c8b67f8bc8e4_slit_exp2.png | Lab photo of the double-slit mask (square metal plate in a mount) with a magnified inset of the two slits. |
| `exp2_MontageT.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/67001047a73bf2aa75eafa38_exp2_MontageT.png | Technical setup drawing: LASER -> BS / BD -> lambda/2 -> L1 = 50 cm -> slit (dashed bar) -> D1, with legend. |
| `Diffraction_1.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66c7579857700072bc6a1f14_Diffraction_1.png | Plot: normalised single-slit diffraction intensity (sinc^2) vs distance on the screen; central maximum 1 at 0, zeros at +/-0.01, 0.02, 0.03 (axis labelled um but in arbitrary units). |
| `imageDavid_2a.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69baec0bf03d58b2db0ce9a7_imageDavid%202a.png | Sketch: source S, slits A/B, screen point X with detector D0 and planes 1-2-3, beside a faint fringe plot and the note 'I_0 = diffraction, I_0 = I_left + I_right'. |
| `DoubleSlit_(1).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69baec582102132ad6846ce1_DoubleSlit%20(1).png | Geometry schematic: LASER -> double slit (paths l) -> screen point y with path lengths a, b (faint a', b' to y'), detector D. |
| `Exp2Addition.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69baeca8e6a87516842a69c8_Exp2Addition.png | Screenshot of a Desmos graph: y = (sin x / x)^2 envelope (red) and (sin x / x)^2 cos^2(10x) fringes (blue). |


## Experiment 3: Polarized double slit (quantum eraser) (`/experiment-3`)

Page URL: https://testing-reality.webflow.io/experiment-3  
Content spec: `docs/content/04-experiment-3-polarized-double-slit.md`

StackBlitz simulator embed(s): https://react-vazdln-ns7pyb.stackblitz.io

### Data files (`app/data/lab/experiment-3/`)

Site text: "All data files have four columns. The first two are the angles of the polarizers, but only P1 is used. The third is the distance the actuator has travelled in um. The last column is the number of counts on D1, the detector. All acquisitions are for a two-second window" (docs/content/04-experiment-3-polarized-double-slit.md). Column 2 is named `Pol B` in the files and is ~0 in every file.

| file | source URL | header row | data rows | description line in file |
|---|---|---|---|---|
| `Data_exp3_-_data_90.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67086bafa5dd10fa8768c84a_Data_exp3%20-%20data_90.csv | `Pol 1,Pol B,Pos,CountsD1` | 121 | Acquisition of 2 seconds, coincidance window at 10 ns. |
| `Data_exp3_-_data_0.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67086bb3f79ac7299c4dcff7_Data_exp3%20-%20data_0.csv | `Pol 1,Pol B,Pos,CountsD1` | 121 | Acquisition of 2 seconds, coincidance window at 10 ns. |
| `Data_exp3_-_data_-45.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67086bb57373c1a1cdb9a0a1_Data_exp3%20-%20data_-45.csv | `Pol 1,Pol B,Pos,CountsD1` | 121 | Acquisition of 2 seconds, coincidance window at 10 ns. |
| `Data_exp3_-_data_45.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/67086bb37ad02c23b51134ac_Data_exp3%20-%20data_45.csv | `Pol 1,Pol B,Pos,CountsD1` | 121 | Acquisition of 2 seconds, coincidance window at 10 ns. |

### Images (`docs/site-assets/experiment-3/`)

| file | source URL | what it shows |
|---|---|---|
| `exp3_Diagram_(5).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69bdfd9dcca1c7c66ba45e35_exp3_Diagram%20(5).png | Schematic: as above with a rotatable P1 at 45 deg added before D1. |
| `photo_exp3.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/6708430da7af59cf80661b04_photo_exp3.png | Overhead photo of the Experiment 3 table with purple beam overlay: LASER, Beam splitter, Half-wave plate, Lens, Double slit, Lens, Polarizer P1, Detection stage. |
| `pol_exp3.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/6708430c81cdb1256aa44e07_pol_exp3.png | Lab photo: polarizer P1 in a motorised rotation mount (red PCB board) in front of the detector; caption 'The polarizer P1 is added, mounted on a motor'. |
| `slit_exp3.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/6708430c6ac1c63b763ba8b8_slit_exp3.png | Lab photo: double slit with polarizers (polarizer film taped over the mask) with a magnified inset of the slit. |
| `exp3_MontageT.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/670010402e46c9412d065513_exp3_MontageT.png | Technical setup drawing: LASER -> BS / BD -> lambda/2 -> L1 = 50 cm -> PA / PB slit -> P1 on motor M1 -> D1, with legend. |
| `exp3_45.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/670845a5ae5589a6f7ac501d_exp3_45.png | Plot: P1 = 45 deg: fringes restored, central peak ~7700/s, shoulders at +/-1000 um. |
| `exp3_-45.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/670845a5afba451047d13a36_exp3_-45.png | Plot: D1 counts/s vs screen position with P1 = -45 deg: four fringe peaks up to ~7000/s (anti-fringe phase), with fit and theory curves. |
| `exp3_0.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/6708305da77abf1564f4204e_exp3_0.png | Plot: P1 = 0 deg: single smooth diffraction envelope, peak ~6700/s, no fringes. |
| `exp3_90.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/6708305cf617ee3621f5b47d_exp3_90.png | Plot: P1 = 90 deg: smooth envelope shifted to about +600 um, peak ~6300/s, no fringes. |
| `exp3_Diagram_(4).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69bdfd78efcafdb1a748fdaa_exp3_Diagram%20(4).png | Schematic: LASER -> double slit with PA 0 deg / PB 90 deg -> screen y / D1, planes Psi0..Psi3 (no P1). |
| `exp3_Diagram_(6).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69bdfd3fb49a0a72720c6a94_exp3_Diagram%20(6).png | Tall explainer infographic (1306 x 2584): Step 1 double slit, no polarizers (fringes); Step 2 perpendicular slit polarizers (no interference, I = 1/2 envelope); Step 3 third polarizer at 45 deg (interference back, I = 1/4 (1 + cos)); 'going further' 45 / -45 deg complementary patterns summing to Step 2; includes the ket algebra. |


## Experiment 4: Entanglement (`/experiment-4`)

Page URL: https://testing-reality.webflow.io/experiment-4  
Content spec: `docs/content/05-experiment-4-entanglement.md`

StackBlitz simulator embed(s): https://react-vazdln-wqy5mw.stackblitz.io

### Data files (`app/data/lab/experiment-4/`)

Site text: "The data file contains five columns. The first two are the polarizer angles, ranging from -90 to 90. The remaining three columns are detector counts: D1 singles, D2 singles, and D1-D2 coincidences. All counts were recorded in one-second acquisition windows" (docs/content/05-experiment-4-entanglement.md). 361 rows = 19 x 19 grid of (PolA, PolB) in 10 deg steps.

| file | source URL | header row | data rows | description line in file |
|---|---|---|---|---|
| `Acquisition_-_Feuille_1.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1c33bcc6eda12d40fabae_Acquisition%20-%20Feuille%201.csv | `PolA,PolB,CountsA,CountsB,CountsAB` | 361 | #The acquisition time is of 1 second. with Coincidence window at 10ns. |

### Images (`docs/site-assets/experiment-4/`)

| file | source URL | what it shows |
|---|---|---|
| `Exp5_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e43fe039df38147b2e944b_Exp5_Diagram.png | Schematic of the Exp 5/6 eraser layout (BB, PA/PB double slit, P1 45 deg, P2 45 deg, D1 / D2, coin), planes Psi0..Psi6; shown on this page as the related-experiment preview. |
| `photo_exp4_(1).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f42a9a1822b2e48345d647_photo_exp4%20(1).png | Overhead photo of the Experiment 4 table with purple beam overlay: Lens, LASER, BBO, Berek, Lens, D1 + P1, D2 + P2. |
| `preBBO_exp4.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f42a9ba9cf3f9d88577fe2_preBBO_exp4.png | Lab photo of the pump-preparation line: LASER, lambda/2, Beam splitter, Lens, Lens, Miror, Miror, lambda/2, Berek, BBO labelled. |
| `berek_exp4.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f42a9c6919ccafb627c0ce_berek_exp4.png | Lab photo: lambda/2 wave plate, Berek compensator, Iris and BBO crystal mount in a row on the table, labelled. |
| `detector_exp4.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f42a9b6e4ef911a7b084db_detector_exp4.png | Lab photo of one detector arm: Rotation motor (red PCB), Long pass filter, Polarizer, Collimator, on a Linear actuator (unused), labelled. |
| `exp4_MontageT_(3).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1c9b2ec38d2d99b67cf48_exp4_MontageT%20(3).png | Technical layout drawing of the entanglement source: LASER -> lambda/2 -> BS / BD -> L1 = 10 cm, L2 = 2.5 cm -> mirrors -> L3 = 25 cm -> lambda/2 -> Berek -> BBO -> BD; two dashed down-converted beams through L4 / L5 = 50 cm and polarizers P1 / P2 on motors M1 / M2 to D1 / D2; legend. |
| `3d_experiemental.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66edc6373ad17588332e9865_3d_experiemental.png | 3-D surface plot of measured normalised coincidence intensity vs P1 and P2 angle (-90..90 deg), rainbow colormap, ridge along the diagonal. |
| `3d_theoric.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66edc5ec200f70d2ec387aed_3d_theoric.png | 3-D surface of the theoretical cos^2(alpha - beta) coincidence intensity vs P1 / P2 angle. |
| `exp_2D.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1808d02462992cd140af5_exp_2D.png | Heatmap of measured coincidence intensity vs P1 angle (x) and P2 angle (y), -90..90 deg; blue minima and red maxima along the diagonal on a blocky 10 deg grid. |
| `theo_2D.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1808d00ed2f6bcd684941_theo_2D.png | Heatmap of the theoretical cos^2(alpha - beta): smooth diagonal stripes vs P1 / P2 angle. |
| `Exp4Fig7.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69bea3045488358c49e64dad_Exp4Fig7.png | Schematic: LASER -> BB -> two beams (one via mirror) to rotatable polarizers alpha (P2) / beta (P1) -> D2 / D1 -> coin; planes Psi0..Psi2. |


## Experiment 5: Putting it all together (`/experiment-5`)

Page URL: https://testing-reality.webflow.io/experiment-5  
Content spec: `docs/content/06-experiment-5-putting-it-all-together.md`

StackBlitz simulator embed(s): https://react-vazdln-kpdd3a.stackblitz.io

### Data files (`app/data/lab/experiment-5/`)

Site text (same format for 5.1, 5.2, 5.3): polarizer angle 1, polarizer angle 2, actuator position, sweep number, counts at D1, counts at D2, D1-D2 coincidences; 20-second windows (docs/content/06-experiment-5-putting-it-all-together.md). Files name the count columns CountsA / CountsB / CountsAB; each position is sampled several times per sweep (6 samples x 4-6 sweeps).

| file | source URL | header row | data rows | description line in file |
|---|---|---|---|---|
| `Data4_1_-_Feuille_1.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f5838c9fd0db216da8a7a9_Data4_1%20-%20Feuille%201.csv | `Pol A,Pol B,Pos,Sweep,CountsA,CountsB,CountsAB` | 2430 | Acquisition with only the double slit and no polarizer. Acquisition time of 20 seconds |
| `Data4_2_-_Feuille_1.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f5838a3a5b47f568368d1c_Data4_2%20-%20Feuille%201.csv | `Pol A,Pol B,Pos,Sweep,CountsA,CountsB,CountsAB` | 1944 | Acquisition with the double slit, and PA and PB. P1 and P2 are not there. Acquisition of 20 seconds. |
| `Data4_3_-_Feuille_1_(1).csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f584c73174fa02d047582d_Data4_3%20-%20Feuille%201%20(1).csv | `Pol 1,Pol 2,Pos,Sweep,CountsA,CountsB,CountsAB` | 2916 | Acquisition eith the double slit, Pa, Pb and P1. Acquisition of 20 seconds |

### Images (`docs/site-assets/experiment-5/`)

| file | source URL | what it shows |
|---|---|---|
| `Exp5_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e43fe039df38147b2e944b_Exp5_Diagram.png | Page hero schematic: full layout with P2 45 deg on the idler and P1 45 deg on the signal, coin; planes Psi0..Psi6. |
| `exp4.1_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1d5b972901f2a305038a3_exp4.1_Diagram.png | Schematic: BB -> idler to D2 / signal through a bare double slit to D1, coin; planes Psi0..Psi3 (same content as Exp5Img1). |
| `P1.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66fadc85ba6e03e3898ae0f8_P1.png | Lab photo 'The addition of P1 after the double slit': the double slit (hidden) and P1 on a rotatable mount on the table. |
| `slit_exp4.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f42a9a7acd9c38ddb6d782_slit_exp4.png | Lab photo: close-up of the bare double-slit mask (square plate) in its mount. |
| `double_slit.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f426eebd94f7970ff63154_double_slit.png | Lab photo: the double slit covered by two polarizers (film taped on the mount) with a magnified inset of the polarizers' boundary. |
| `nolpol_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1d74e7c55163bc3f09281_nolpol_A.png | Plot: D1 counts/s with the bare double slit (no polarizer): three-peak interference pattern, centre ~410/s, sides ~280/s. |
| `nolpol_AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1d74e7c55163bc3f092a5_nolpol_AB.png | Plot: coincidences/s, no polarizer: interference pattern, centre ~7.7/s, sides ~3.6/s. |
| `exp4.2_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1d5bafb84317515ebd93a_exp4.2_Diagram.png | Schematic: with PA / PB polarizers on the slits; planes Psi0..Psi4 (same content as Exp5Img4). |
| `4.2_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f58ff07caffad9cea4064c_4.2_A.png | Plot: D1 counts/s with PA + PB (no P1): smooth envelope, peak ~322/s, x +/-2000 um. |
| `4.2_AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f58ff0fd3b54f8b5e6ce59_4.2_AB.png | Plot: D1-D2 coincidences/s with PA + PB: smooth envelope, peak ~1.0/s. |
| `exp4.3_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1d5be12d3e58e032ed035_exp4.3_Diagram.png | Schematic: with PA / PB and P1 45 deg; planes Psi0..Psi6 (same content as Exp5Img6). |
| `4.3A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f58ff079920d6110c485f2_4.3A.png | Plot: D1 counts/s with PA + PB + P1: smooth envelope, peak ~199/s (no fringes). |
| `4.3AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f58ff1fc1e75a39a5c001a_4.3AB.png | Plot: coincidences/s with PA + PB + P1: smooth envelope, peak ~0.34/s (no fringes in coincidence without P2). |
| `Exp5Img1.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69beb4f2cb5b8eaa4cc8b032_Exp5Img1.png | Schematic (Exp 5.1): BB source, idler to D2, signal through a bare double slit to D1, coin; planes Psi0..Psi3. |
| `Exp5Img4.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69beb4e2be87c527d81fa512_Exp5Img4.png | Schematic (Exp 5.2): as above with PA 0 deg / PB 90 deg on the slits; planes Psi0..Psi4. |
| `Exp5Img6.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69beb4cda088c4b5e6eafc75_Exp5Img6.png | Schematic (Exp 5.3): PA / PB slits plus P1 45 deg before D1, D2 bare; planes Psi0..Psi6. |


## Experiment 6: Delayed-choice quantum eraser (`/experiment-6`)

Page URL: https://testing-reality.webflow.io/experiment-6  
Content spec: `docs/content/07-experiment-6-delayed-choice-eraser.md`

StackBlitz simulator embed(s): https://react-vazdln-scmwpz.stackblitz.io

YouTube video(s): https://www.youtube.com/watch?v=RQv5CVELG3U (The Delayed Choice Quantum Eraser, Debunked)

### Data files (`app/data/lab/experiment-6/`)

Site text: "Each file contains 7 columns: polarizer angle 1 (fixed), polarizer angle 2 (fixed), actuator position (um), sweep number, counts at D1 (signal), counts at D2 (idler), coincidences" (docs/content/07-experiment-6-delayed-choice-eraser.md). The actual files are WIDE: P1, P2, `All distance` (position, um), then one (D1, D2, D1D2) triplet per sweep (5-6 sweeps), 7 sample rows per position; 20 s windows, 10 ns coincidence window. `Data_90deg.csv` and `Data_135deg.csv` have a sixth sweep whose three columns are unnamed in the header.

| file | source URL | header row | data rows | description line in file |
|---|---|---|---|---|
| `Data_90deg.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66d8a4ee2153c381a8883d6f_Data_90deg.csv | `#Polarisation P1,Polarization P2,All distance,Sweep_0  D1,Sweep_0 D2,Sweep_0 D1D2,Sweep_1  D1,Sweep_1 D2,Sweep_1 D1D2,Sweep_2  D1,Sweep_2 D2,Sweep_2 D1D2,Sweep_3  D1,Sweep_3 D2,Sweep_3 D1D2,Sweep_4  D1,Sweep_4 D2,Sweep_4 D1D2` | 567 | #These are the data at 90 degrees. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns. |
| `Data_0deg.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66d8a4ee12a998255ac67290_Data_0deg.csv | `#Polarisation P1,Polarization P2,All distance,Sweep_0  D1,Sweep_0 D2,Sweep_0 D1D2,Sweep_1  D1,Sweep_1 D2,Sweep_1 D1D2,Sweep_2  D1,Sweep_2 D2,Sweep_2 D1D2,Sweep_3  D1,Sweep_3 D2,Sweep_3 D1D2,Sweep_4  D1,Sweep_4 D2,Sweep_4 D1D2,Sweep_5  D1,Sweep_5 D2,Sweep_5 D1D2` | 567 | #These are the data at 0 degrees. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns. |
| `Data_135deg.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66d8a4eea1ab69f9e507dbb1_Data_135deg.csv | `#Polarisation P1,Polarization P2,All distance,Sweep_0  D1,Sweep_0 D2,Sweep_0 D1D2,Sweep_1  D1,Sweep_1 D2,Sweep_1 D1D2,Sweep_2  D1,Sweep_2 D2,Sweep_2 D1D2,Sweep_3  D1,Sweep_3 D2,Sweep_3 D1D2,Sweep_4  D1,Sweep_4 D2,Sweep_4 D1D2` | 609 | #These are the data at -45 degrees. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns. |
| `Data_45degre.csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66d8a4ee3fe69c8c63d973bf_Data_45degre.csv | `#Polarisation P1,Polarization P2,All distance,Sweep_0  D1,Sweep_0 D2,Sweep_0 D1D2,Sweep_1  D1,Sweep_1 D2,Sweep_1 D1D2,Sweep_2  D1,Sweep_2 D2,Sweep_2 D1D2,Sweep_3  D1,Sweep_3 D2,Sweep_3 D1D2,Sweep_4  D1,Sweep_4 D2,Sweep_4 D1D2` | 567 | #These are the data at 45 degrees. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns. |

### Images (`docs/site-assets/experiment-6/`)

| file | source URL | what it shows |
|---|---|---|
| `optical_table.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f426ee8087b5d474b42c88_optical_table.png | Overhead photo of the whole Experiment 6 table with purple beam overlay: LASER, BBO, Double slit, P1, D1, D2 + P2. |
| `double_slit.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f426eebd94f7970ff63154_double_slit.png | Same photo as experiment-5/double_slit.png: the double slit covered by two polarizers, with inset. |
| `detectors.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f426ef4802b2998a6a0c70_detectors.png | Lab photo: detector assembly with Rotation motor (unused), Long pass filter, Single slit, Collimator, on a Linear actuator, labelled. |
| `exp6_MontageT.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66fad97b91220afdab1f7942_exp6_MontageT.png | Technical layout drawing of the full delayed-choice setup: pump line (LASER, lambda/2, BS / BD, L1 = 10 cm, L2 = 2.5 cm, mirrors, L3 = 25 cm, lambda/2, Berek, BBO), signal arm L4 = 50 cm -> slit -> P1 -> D1 (translatable), idler arm L5 = 50 cm -> P2 -> D2; legend. |
| `45_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e0521d9d08b49350eff756_45_A.png | Plot: D1 counts/s with P2 = 45 deg: smooth envelope, peak ~370/s. |
| `45_AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e0521df45a3b89dfdf8742_45_AB.png | Plot: coincidences/s with P2 = 45 deg: fringes, centre ~0.60/s, sides ~0.42 and ~0.48/s. |
| `-45_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e0521c5833eb8f996c0d8d_-45_A.png | Plot: D1 counts/s with P2 = -45 deg: smooth envelope, peak ~369/s. |
| `-45_AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e0521d78608f2e9ba0b201_-45_AB.png | Plot: coincidences/s with P2 = -45 deg: fringes (anti-fringe phase), peaks ~0.39/s near -500 and +300 um. |
| `0_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e0521c38dc512bea7ae2fa_0_A.png | Plot: D1 counts/s with P2 = 0 deg: smooth envelope, peak ~201/s. |
| `0_AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e0521c4dfe7db80eaa75d2_0_AB.png | Plot: coincidences/s with P2 = 0 deg: smooth envelope shifted to about -500 um, peak ~0.25/s. |
| `90_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e0521c1d91a5342dba26ae_90_A.png | Plot: D1 counts/s with P2 = 90 deg: smooth envelope, peak ~200/s. |
| `90_AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e0521ccd789f85f8698a7f_90_AB.png | Plot: coincidences/s with P2 = 90 deg: smooth envelope, peak ~0.33/s, no fringes. |
| `exp6-photo_(1).png` | https://cdn.prod.website-files.com/62f169875514947cce769885/69c09f560f9a530ad34eb8a6_exp6-photo%20(1).png | Tall explainer infographic (1158 x 1946) 'Delayed-Choice Quantum Eraser Setup': D1 singles are always a diffraction envelope; P2 chooses the basis (H/V vs diagonal); coincidence patterns for P2 = 0 and 90 deg (shifted envelopes), 45 deg (fringes), -45 deg (anti-fringes); closing 'The Delayed Choice' note. |
| `scully.PNG` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e30f6bf063b66d98e9fd69_scully.PNG | Screenshot of the arXiv title and abstract of 'A Delayed Choice Quantum Eraser' (Kim, Yu, Kulik, Shih, Scully; Mar 1999). |
| `walborn.PNG` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e31000ad3f0315c2470d6a_walborn.PNG | Screenshot of the arXiv title and abstract of 'A double-slit quantum eraser' (Walborn, Terra Cunha, Padua, Monken; Jun 2001). |


## Experiment 7: Detecting is not recording (`/experiment-7`)

Page URL: https://testing-reality.webflow.io/experiment-7  
Content spec: `docs/content/08-experiment-7-detecting-not-recording.md`

### Data files (`app/data/lab/experiment-7/`)

Site text: "Each file contains 7 columns: polarizer angle P1, polarizer angle P2, actuator position (um), sweep number, counts at D1 (signal), counts at D2 (idler), coincidences between D1 and D2"; 20 s windows, several sweeps (docs/content/08-experiment-7-detecting-not-recording.md). In `6.2_unplugged` the D2 and coincidence columns are all zero.

| file | source URL | header row | data rows | description line in file |
|---|---|---|---|---|
| `6.1_wall_-_Feuille_1_(2).csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66ed8dc6cbefcb7735fce043_6.1_wall%20-%20Feuille%201%20(2).csv | `#Polarisation P1,Polarization P2,All distance,Sweep,Counts of  D1,Counts of D2,Coincidence D1D2` | 2430 | #These are the data with a wall in front of D2. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns. |
| `6.2_unplugged_-_Feuille_1_(1).csv` | https://cdn.prod.website-files.com/62f169875514947cce769885/66ed8dc94b5f64d927dacb5f_6.2_unplugged%20-%20Feuille%201%20(1).csv | `#Polarisation P1,Polarization P2,All distance,Sweep,Counts of  D1,Counts of D2,Coincidence D1D2` | 2916 | #These are the data with D2 unplugged. For each data, the acquisition was of 20 seconds and the coincidence window of 10ns. |

### Images (`docs/site-assets/experiment-7/`)

| file | source URL | what it shows |
|---|---|---|
| `Exp5_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66e43fe039df38147b2e944b_Exp5_Diagram.png | Same file as experiment-5/Exp5_Diagram.png: the reference eraser layout (P1 45 deg, P2 45 deg). |
| `expWall_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1ce28ffdaa4e4ba4f3d81_expWall_Diagram.png | Schematic: eraser layout with P2 at 90 deg and a black wall blocking the idler before D2; planes Psi0..Psi7. |
| `Wall_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66ed8c3b3466094e209c3f20_Wall_A.png | Plot: D1 counts/s with a wall in front of D2: smooth envelope, peak ~201/s. |
| `Wall_AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66ed8c3b819d33690f9a8fb4_Wall_AB.png | Plot: coincidences/s with the wall: essentially zero; a few points at 0.0017 and 0.0033/s (1-2 accidental counts). |
| `expUnplug_Diagram.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66f1ce2ff8c0cc8c6b58a75f_expUnplug_Diagram.png | Schematic: eraser layout with P2 at 90 deg and D2 not wired to the coincidence counter (unplugged); planes Psi0..Psi7. |
| `Unplugged_A.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66ed8c3bd6a431043c2bf474_Unplugged_A.png | Plot: D1 counts/s with D2 unplugged (title says P2 = 90 deg): smooth envelope, peak ~209/s. |
| `Unplugged_AB.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66ed8c3be0117f40c6d8557e_Unplugged_AB.png | Plot: coincidences/s with D2 unplugged: every point exactly zero (flat line). |


## About (`/about`)

Page URL: https://testing-reality.webflow.io/about

### Images (`docs/site-assets/about/`)

| file | source URL | what it shows |
|---|---|---|
| `IMG-2.png` | https://cdn.prod.website-files.com/62f169875514947cce769885/66db5af6fb45a9f1d39cf369_IMG-2.png | Decorative abstract 3-D render: a ribbon of stacked teal / violet / yellow-green petals curving across a blue-teal gradient (About-page hero image, 2.8 MB). |

