//! Golden tests: every number the Testing Reality site derives or measures.

use approx::assert_abs_diff_eq;
use quagmire_core::screen::linspace;
use quagmire_core::{Pred, ScreenGeometry, System, C, INV_SQRT2};
use std::f64::consts::{FRAC_PI_2, FRAC_PI_4, PI};

const H: &str = "↔";
const V: &str = "↕";
const POL: [&str; 2] = [H, V];

/// A photon prepared diagonally (the site's `|↗↙⟩`).
fn diagonal_photon() -> System {
    let mut s = System::new();
    s.add_property("pol", &POL).unwrap();
    s.set_state(&[
        (&[H], C::new(INV_SQRT2, 0.0)),
        (&[V], C::new(INV_SQRT2, 0.0)),
    ])
    .unwrap();
    s
}

fn transmitted(s: &System, _sinks: &[&str]) -> f64 {
    s.probability(&Pred::alive("pol")).unwrap()
}

// ------------------------------------------------------------------ Experiment 1

#[test]
fn exp1_no_polarizer_100_percent() {
    let s = diagonal_photon();
    assert_abs_diff_eq!(s.norm(), 1.0, epsilon = 1e-12);
}

#[test]
fn exp1_one_horizontal_polarizer_50_percent() {
    let mut s = diagonal_photon();
    s.polarizer("pol", POL, 0.0, "lost@P1", None).unwrap();
    assert_abs_diff_eq!(transmitted(&s, &["lost@P1"]), 0.5, epsilon = 1e-12);
    assert_abs_diff_eq!(s.norm(), 1.0, epsilon = 1e-12);
    assert_eq!(s.ket_text(), "1/√2 |↔⟩ + 1/√2 |lost@P1⟩");
}

#[test]
fn exp1_malus_law_table() {
    // site table: 45° → 100 %, 22.5° → ~85 %, 0° → 50 %, −45° → 0 %
    for (deg, expect) in [(45.0_f64, 1.0_f64), (22.5, 0.853553), (0.0, 0.5), (-45.0, 0.0)] {
        let mut s = diagonal_photon();
        s.polarizer("pol", POL, deg.to_radians(), "lost", None)
            .unwrap();
        assert_abs_diff_eq!(transmitted(&s, &["lost"]), expect, epsilon = 1e-5);
    }
}

#[test]
fn exp1_two_crossed_polarizers_0_percent() {
    let mut s = diagonal_photon();
    s.polarizer("pol", POL, 0.0, "lost@P1", None).unwrap();
    s.polarizer("pol", POL, FRAC_PI_2, "lost@P2", None).unwrap();
    assert_abs_diff_eq!(
        transmitted(&s, &["lost@P1", "lost@P2"]),
        0.0,
        epsilon = 1e-12
    );
    assert_abs_diff_eq!(
        s.probability(&Pred::is("pol", "lost@P1")).unwrap(),
        0.5,
        epsilon = 1e-12
    );
    assert_abs_diff_eq!(
        s.probability(&Pred::is("pol", "lost@P2")).unwrap(),
        0.5,
        epsilon = 1e-12
    );
}

#[test]
fn exp1_three_polarizer_paradox_12_5_percent() {
    let mut s = diagonal_photon();
    s.polarizer("pol", POL, 0.0, "lost@P1", None).unwrap();
    s.polarizer("pol", POL, FRAC_PI_4, "lost@P2", None).unwrap();
    s.polarizer("pol", POL, FRAC_PI_2, "lost@P3", None).unwrap();
    assert_abs_diff_eq!(
        transmitted(&s, &["lost@P1", "lost@P2", "lost@P3"]),
        0.125,
        epsilon = 1e-12
    );
    // |ψ3⟩ = 1/(2√2)|↕⟩ + 1/(2√2)|lost_P3⟩ + 1/2|lost_P2⟩ + 1/√2|lost_P1⟩
    assert_abs_diff_eq!(
        s.probability(&Pred::is("pol", "lost@P1")).unwrap(),
        0.5,
        epsilon = 1e-12
    );
    assert_abs_diff_eq!(
        s.probability(&Pred::is("pol", "lost@P2")).unwrap(),
        0.25,
        epsilon = 1e-12
    );
    assert_abs_diff_eq!(
        s.probability(&Pred::is("pol", "lost@P3")).unwrap(),
        0.125,
        epsilon = 1e-12
    );
    assert_abs_diff_eq!(s.norm(), 1.0, epsilon = 1e-12);
    assert_eq!(
        s.ket_text(),
        "1/(2√2) |↕⟩ + 1/√2 |lost@P1⟩ + 1/2 |lost@P2⟩ + 1/(2√2) |lost@P3⟩"
    );
}

#[test]
fn intro_r45_interference_example() {
    // R45|φ1⟩ = |A⟩ with R45|A⟩ = (|A⟩−|B⟩)/√2, R45|B⟩ = (|A⟩+|B⟩)/√2.
    let mut s = System::new();
    s.add_property("q", &["A", "B"]).unwrap();
    s.set_state(&[
        (&["A"], C::new(INV_SQRT2, 0.0)),
        (&["B"], C::new(INV_SQRT2, 0.0)),
    ])
    .unwrap();
    s.rotate_polarization("q", ["A", "B"], -FRAC_PI_4).unwrap();
    assert_eq!(s.ket_text(), "|A⟩");
}

// ------------------------------------------------------------------ Experiment 2

fn slit_geometry() -> ScreenGeometry {
    // 808 nm, w = 200 µm, d = 400 µm centre-to-centre, L = 0.5 m
    ScreenGeometry::double_slit(808e-9, 200e-6, 400e-6, 0.5, "A", "B")
}

#[test]
fn exp2_double_slit_pattern_matches_formula() {
    let mut s = System::new();
    s.add_property("path", &["S"]).unwrap();
    s.slits("path", "S", &["A", "B"], 1.0, 0.0, None).unwrap();
    let geom = slit_geometry();
    let ys = linspace(3e-3, 601);
    let prof = s.screen_profile("path", &geom, &ys, None).unwrap();
    // I(θ) = 2 I0 (1 + cos(2π d sinθ/λ)) sinc², with I0 = 1/2 per slit here → max 2.
    for (y, i) in ys.iter().zip(&prof.intensity) {
        let sin_t = y / (y * y + 0.25).sqrt();
        let fringe = 1.0 + (2.0 * PI * 400e-6 * sin_t / 808e-9).cos();
        let alpha = PI * 200e-6 * sin_t / 808e-9;
        let env = if alpha.abs() < 1e-12 {
            1.0
        } else {
            (alpha.sin() / alpha).powi(2)
        };
        assert_abs_diff_eq!(*i, fringe * env, epsilon = 1e-9);
    }
    assert_abs_diff_eq!(prof.max(), 2.0, epsilon = 1e-9);
    assert!(prof.visibility() > 0.999);
}

#[test]
fn exp2_single_slit_has_no_fringes() {
    let mut s = System::new();
    s.add_property("path", &["S"]).unwrap();
    s.slits("path", "S", &["A"], 0.5, 0.0, Some("lost"))
        .unwrap();
    let geom = ScreenGeometry::double_slit(808e-9, 200e-6, 400e-6, 0.5, "A", "B");
    // "B" does not exist as a label on `path`: add it so the geometry resolves.
    s.add_label("path", "B").unwrap();
    let ys = linspace(3e-3, 601);
    let prof = s.screen_profile("path", &geom, &ys, None).unwrap();
    assert_abs_diff_eq!(prof.max(), 0.5, epsilon = 1e-9);
    // smooth envelope: monotone decreasing away from the slit centre for small |y|
    let mid = 300;
    assert!(prof.intensity[mid] >= prof.intensity[mid + 20]);
    assert!(prof.intensity[mid + 20] >= prof.intensity[mid + 40]);
}

// ------------------------------------------------------------------ Experiment 3

/// Diagonal photon through the marked double slit (PA = 0° on A, PB = 90° on B).
fn exp3_after_slits() -> System {
    let mut s = diagonal_photon();
    s.add_property("path", &["S"]).unwrap();
    s.slits("path", "S", &["A", "B"], 1.0, 0.0, None).unwrap();
    s.polarizer("pol", POL, 0.0, "lost@PA", Some(&Pred::is("path", "A")))
        .unwrap();
    s.polarizer(
        "pol",
        POL,
        FRAC_PI_2,
        "lost@PB",
        Some(&Pred::is("path", "B")),
    )
    .unwrap();
    s
}

fn exp3_geometry() -> ScreenGeometry {
    ScreenGeometry::double_slit(405e-9, 200e-6, 400e-6, 0.7, "A", "B")
}

#[test]
fn exp3_state_after_slit_polarizers() {
    let s = exp3_after_slits();
    // ½(|↔⟩|A⟩ + |↕⟩|B⟩ + |lost_PA⟩|A⟩ + |lost_PB⟩|B⟩)
    assert_eq!(
        s.ket_text(),
        "1/2 |↔⟩|A⟩ + 1/2 |↕⟩|B⟩ + 1/2 |lost@PA⟩|A⟩ + 1/2 |lost@PB⟩|B⟩"
    );
    let ys = linspace(2e-3, 401);
    let prof = s
        .screen_profile("path", &exp3_geometry(), &ys, Some(&Pred::alive("pol")))
        .unwrap();
    // flat ½ × envelope: no interference
    assert!(prof.visibility() < 1e-9);
    assert_abs_diff_eq!(prof.intensity[200], 0.5, epsilon = 1e-9);
}

#[test]
fn exp3_third_polarizer_table() {
    // P1 angle → (centre intensity, visibility, sign of cos term at centre)
    for (deg, centre, vis) in [
        (0.0_f64, 0.25_f64, 0.0_f64),
        (90.0, 0.25, 0.0),
        (45.0, 0.5, 1.0),
        (-45.0, 0.0, 1.0),
    ] {
        let mut s = exp3_after_slits();
        s.polarizer("pol", POL, deg.to_radians(), "lost@P1", None)
            .unwrap();
        let alive = Pred::alive("pol");
        let ys = linspace(2e-3, 401);
        let prof = s
            .screen_profile("path", &exp3_geometry(), &ys, Some(&alive))
            .unwrap();
        assert_abs_diff_eq!(prof.intensity[200], centre, epsilon = 1e-9);
        assert_abs_diff_eq!(prof.visibility(), vis, epsilon = 1e-3); // grid-limited
    }
}

#[test]
fn exp3_complementary_pairs_sum_to_envelope() {
    let ys = linspace(2e-3, 401);
    let alive = |_extra: &str| Pred::alive("pol");
    let run = |deg: f64| {
        let mut s = exp3_after_slits();
        s.polarizer("pol", POL, deg.to_radians(), "lost@P1", None)
            .unwrap();
        s.screen_profile("path", &exp3_geometry(), &ys, Some(&alive("lost@P1")))
            .unwrap()
    };
    let (p45, m45, p0, p90) = (run(45.0), run(-45.0), run(0.0), run(90.0));
    let base = exp3_after_slits()
        .screen_profile("path", &exp3_geometry(), &ys, Some(&Pred::alive("pol")))
        .unwrap();
    for i in 0..ys.len() {
        assert_abs_diff_eq!(
            p45.intensity[i] + m45.intensity[i],
            base.intensity[i],
            epsilon = 1e-9
        );
        assert_abs_diff_eq!(
            p0.intensity[i] + p90.intensity[i],
            base.intensity[i],
            epsilon = 1e-9
        );
    }
}

// ------------------------------------------------------------------ Experiment 4

/// Pump at 45° through crossed BBOs → |Φ⁺⟩ on (signal, idler).
fn bell_pair(pump_angle: f64, phase: f64) -> System {
    let mut s = System::new();
    s.add_property("pump", &POL).unwrap();
    s.set_state(&[
        (&[H], C::new(pump_angle.cos(), 0.0)),
        (&[V], C::new(pump_angle.sin(), 0.0)),
    ])
    .unwrap();
    s.spdc("pump", POL, "pol1", "pol2", POL, phase).unwrap();
    s
}

#[test]
fn exp4_spdc_makes_phi_plus() {
    let s = bell_pair(FRAC_PI_4, 0.0);
    assert_eq!(s.ket_text(), "1/√2 |↔⟩|↔⟩ + 1/√2 |↕⟩|↕⟩");
    assert_abs_diff_eq!(s.norm(), 1.0, epsilon = 1e-12);
}

#[test]
fn exp4_coincidence_is_half_cos_squared() {
    let table: [(f64, f64, f64); 5] = [
        (0.0, 0.0, 0.5),
        (0.0, 45.0, 0.25),
        (0.0, 90.0, 0.0),
        (45.0, 45.0, 0.5),
        (30.0, 60.0, 0.375),
    ];
    for (alpha, beta, expect) in table {
        let mut s = bell_pair(FRAC_PI_4, 0.0);
        s.polarizer("pol1", POL, beta.to_radians(), "lost", None)
            .unwrap();
        s.polarizer("pol2", POL, alpha.to_radians(), "lost", None)
            .unwrap();
        let both = Pred::alive("pol1").and_alive("pol2");
        assert_abs_diff_eq!(s.probability(&both).unwrap(), expect, epsilon = 1e-12);
    }
    // general law over a sweep
    for a in (0..=180).step_by(15) {
        for b in (0..=180).step_by(15) {
            let (alpha, beta) = ((a as f64).to_radians(), (b as f64).to_radians());
            let mut s = bell_pair(FRAC_PI_4, 0.0);
            s.polarizer("pol1", POL, beta, "lost", None).unwrap();
            s.polarizer("pol2", POL, alpha, "lost", None).unwrap();
            let both = Pred::alive("pol1").and_alive("pol2");
            assert_abs_diff_eq!(
                s.probability(&both).unwrap(),
                0.5 * (alpha - beta).cos().powi(2),
                epsilon = 1e-12
            );
        }
    }
}

#[test]
fn exp4_unbalanced_pump_gives_more_vv() {
    // pump closer to H → more |VV⟩ (crystal 1 converts H → VV)
    let s = bell_pair(30f64.to_radians(), 0.0);
    assert_abs_diff_eq!(
        s.probability(&Pred::is("pol1", V)).unwrap(),
        0.75,
        epsilon = 1e-12
    );
    assert_abs_diff_eq!(
        s.probability(&Pred::is("pol1", H)).unwrap(),
        0.25,
        epsilon = 1e-12
    );
}

// ------------------------------------------------------------------ Experiments 5–7

fn exp5_geometry() -> ScreenGeometry {
    ScreenGeometry::double_slit(810e-9, 200e-6, 400e-6, 0.5, "A", "B")
}

fn alive_signal() -> Pred {
    Pred::alive("pol1")
}

/// Entangled pair; signal through the (optionally marked) double slit.
fn exp5(marked: bool, p1_45: bool) -> System {
    let mut s = bell_pair(FRAC_PI_4, 0.0);
    s.add_property("path", &["S"]).unwrap();
    s.slits("path", "S", &["A", "B"], 1.0, 0.0, None).unwrap();
    if marked {
        s.polarizer(
            "pol1",
            POL,
            FRAC_PI_2,
            "lost@PA",
            Some(&Pred::is("path", "A")),
        )
        .unwrap();
        s.polarizer("pol1", POL, 0.0, "lost@PB", Some(&Pred::is("path", "B")))
            .unwrap();
    }
    if p1_45 {
        s.polarizer("pol1", POL, FRAC_PI_4, "lost@P1", None)
            .unwrap();
    }
    s
}

#[test]
fn exp5_1_entangled_bare_slit_interferes() {
    let s = exp5(false, false);
    let ys = linspace(2e-3, 401);
    let prof = s
        .screen_profile("path", &exp5_geometry(), &ys, None)
        .unwrap();
    assert!(prof.visibility() > 0.999);
    assert_abs_diff_eq!(prof.intensity[200], 2.0, epsilon = 1e-9);
}

#[test]
fn exp5_2_marked_slits_no_interference() {
    let s = exp5(true, false);
    let ys = linspace(2e-3, 401);
    let prof = s
        .screen_profile("path", &exp5_geometry(), &ys, Some(&alive_signal()))
        .unwrap();
    assert!(prof.visibility() < 1e-9);
    assert_abs_diff_eq!(prof.intensity[200], 0.5, epsilon = 1e-9); // ¼ + ¼
}

#[test]
fn exp5_3_local_eraser_fails_with_entanglement() {
    let s = exp5(true, true);
    let ys = linspace(2e-3, 401);
    let prof = s
        .screen_profile("path", &exp5_geometry(), &ys, Some(&alive_signal()))
        .unwrap();
    assert!(prof.visibility() < 1e-9);
    assert_abs_diff_eq!(prof.intensity[200], 0.25, epsilon = 1e-9); // ⅛ + ⅛
}

#[test]
fn exp6_idler_polarizer_selects_fringes() {
    // I(γ) ∝ 1 + sin(2γ) cos kΔ  → visibility |sin 2γ|
    for (deg, vis, sign) in [
        (0.0_f64, 0.0_f64, 0.0_f64),
        (90.0, 0.0, 0.0),
        (45.0, 1.0, 1.0),
        (-45.0, 1.0, -1.0),
        (22.5, INV_SQRT2, 1.0),
    ] {
        let mut s = exp5(true, true);
        s.polarizer("pol2", POL, deg.to_radians(), "lost@P2", None)
            .unwrap();
        let coincidence = alive_signal().and_alive("pol2");
        let ys = linspace(2e-3, 401);
        let prof = s
            .screen_profile("path", &exp5_geometry(), &ys, Some(&coincidence))
            .unwrap();
        assert_abs_diff_eq!(prof.visibility(), vis, epsilon = 1e-3); // grid-limited
                                                                     // centre is a maximum for +45°, a minimum for −45°
        let centre = prof.intensity[200];
        let expect = 0.125 * (1.0 + (2.0 * deg.to_radians()).sin());
        assert_abs_diff_eq!(centre, expect, epsilon = 1e-9);
        if sign != 0.0 {
            assert!((centre - 0.125) * sign > 0.0);
        }
        // singles never interfere, whatever γ
        let singles = s
            .screen_profile("path", &exp5_geometry(), &ys, Some(&alive_signal()))
            .unwrap();
        assert!(singles.visibility() < 1e-9);
    }
}

#[test]
fn exp7_wall_and_unplugged() {
    let mut s = exp5(true, true);
    s.add_property("idler_path", &["D2"]).unwrap();
    // wall: idler absorbed before D2
    s.relabel("idler_path", "D2", "wall", None).unwrap();
    s.mark_sink("idler_path", "wall").unwrap();
    let ys = linspace(2e-3, 401);
    let coinc = alive_signal().and_is("idler_path", "D2");
    let prof = s
        .screen_profile("path", &exp5_geometry(), &ys, Some(&coinc))
        .unwrap();
    assert_abs_diff_eq!(prof.max(), 0.0, epsilon = 1e-12);
    let singles = s
        .screen_profile("path", &exp5_geometry(), &ys, Some(&alive_signal()))
        .unwrap();
    assert!(singles.visibility() < 1e-9);
    assert_abs_diff_eq!(singles.intensity[200], 0.25, epsilon = 1e-9);
}

#[test]
fn photon_sampling_follows_profile() {
    let mut s = System::with_seed(42);
    s.add_property("path", &["S"]).unwrap();
    s.slits("path", "S", &["A", "B"], 1.0, 0.0, None).unwrap();
    let ys = linspace(2e-3, 401);
    let prof = s
        .screen_profile("path", &exp5_geometry(), &ys, None)
        .unwrap();
    let pts = prof.sample_positions(&mut s, 20000);
    assert_eq!(pts.len(), 20000);
    // the first dark fringe at y = λL/(2d) ≈ 0.506 mm should be nearly empty
    let dark = 810e-9 * 0.5 / (2.0 * 400e-6);
    let near_dark = pts
        .iter()
        .filter(|y| (y.abs() - dark).abs() < 0.03e-3)
        .count();
    let near_bright = pts.iter().filter(|y| y.abs() < 0.03e-3).count();
    assert!(
        near_dark * 10 < near_bright,
        "dark {near_dark} bright {near_bright}"
    );
}

#[test]
fn profile_rates_and_geometry_helpers() {
    // Experiment 2 geometry: 808 nm, w = 200 µm, d = 400 µm, L = 0.5 m
    let g = ScreenGeometry::double_slit(808e-9, 200e-6, 400e-6, 0.5, "A", "B");
    assert_abs_diff_eq!(g.fringe_spacing(), 1.01e-3, epsilon = 1e-12);
    assert_abs_diff_eq!(g.envelope_zero(), 2.02e-3, epsilon = 1e-12);
    let mut s = System::new();
    s.add_property("path", &["S", "A", "B"]).unwrap();
    s.slits("path", "S", &["A", "B"], 1.0, 0.0, None).unwrap();
    let ys = linspace(3e-3, 601);
    let prof = s.screen_profile("path", &g, &ys, None).unwrap().box_convolve(200e-6);
    // interpolation hits the grid exactly and is clamped outside it
    assert_abs_diff_eq!(prof.intensity_at(ys[300]), prof.intensity[300], epsilon = 1e-12);
    assert_abs_diff_eq!(prof.intensity_at(1.0), prof.intensity[600], epsilon = 1e-12);
    // the detector rates summed over the scan (slit-sized steps) give back the flux
    let flux = 3000.0;
    let slit = 200e-6;
    let dy = ys[1] - ys[0];
    let total: f64 = ys.iter().map(|&y| prof.rate_at(y, slit, flux) * dy / slit).sum();
    assert_abs_diff_eq!(total, flux, epsilon = 0.02 * flux);
    assert_abs_diff_eq!(prof.rate_at(0.0, slit, flux), prof.intensity_at(0.0) * prof.rate_scale(slit, flux), epsilon = 1e-9);
    assert_eq!(prof.rate_scale(0.0, flux), 0.0);
}
