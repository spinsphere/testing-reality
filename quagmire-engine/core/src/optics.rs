//! Optical elements as operations on a [`System`].
//!
//! Conventions: polarization properties have two live labels (default `H`, `V`); angles
//! are in **radians** from the horizontal axis, counter-clockwise looking into the beam.
//! `|H⟩ = (1, 0)`, `|V⟩ = (0, 1)`, diagonal `= (|H⟩+|V⟩)/√2`, anti-diagonal `= (|H⟩−|V⟩)/√2`.

use crate::ops::{Matrix, Pred};
use crate::system::{Result, System};
use crate::C;

/// Jones matrix of a linear polarizer at `theta` (a projector, not unitary).
pub fn polarizer_matrix(theta: f64) -> Matrix {
    let (s, c) = theta.sin_cos();
    Matrix::from_real(&[&[c * c, c * s], &[c * s, s * s]])
}

/// Jones matrix of a rotation by `theta` (e.g. optical activity, or the site's `R45`).
pub fn rotation_matrix(theta: f64) -> Matrix {
    let (s, c) = theta.sin_cos();
    Matrix::from_real(&[&[c, -s], &[s, c]])
}

/// Jones matrix of a half-wave plate with fast axis at `theta`.
pub fn half_wave_plate_matrix(theta: f64) -> Matrix {
    let (s2, c2) = (2.0 * theta).sin_cos();
    Matrix::from_real(&[&[c2, s2], &[s2, -c2]])
}

/// Jones matrix of a general linear retarder: fast axis at `theta`, retardance `delta`
/// (phase lag of the slow axis). `delta = π` gives a half-wave plate (up to a global
/// phase), `π/2` a quarter-wave plate. A Berek compensator is a variable-`delta` retarder.
pub fn retarder_matrix(theta: f64, delta: f64) -> Matrix {
    let (s, c) = theta.sin_cos();
    let e = C::from_polar(1.0, -delta);
    let one = C::new(1.0, 0.0);
    // R(θ) · diag(1, e^{-iδ}) · R(-θ)
    let m00 = c * c * one + s * s * e;
    let m01 = c * s * (one - e);
    let m11 = s * s * one + c * c * e;
    Matrix::from_complex(&[&[m00, m01], &[m01, m11]])
}

/// Unit Jones vector of linear polarization at `theta`.
pub fn linear_axis(theta: f64) -> [C; 2] {
    let (s, c) = theta.sin_cos();
    [C::new(c, 0.0), C::new(s, 0.0)]
}

/// The blocked-direction vector used for a polarizer's `|lost⟩` amplitude.
///
/// Any unit vector orthogonal to the axis is physically equivalent; this choice
/// (`(|sin θ|, −sgn(sin θ cos θ)|cos θ|)`) makes the lost amplitudes come out with the
/// same signs as the site's derivations: `P_↔|↕⟩ = |lost⟩`, `P_↕|↔⟩ = |lost⟩`,
/// `P_↗↙|↘↖⟩ = |lost⟩` and `P_↘↖|↗↙⟩ = |lost⟩`.
pub fn blocked_axis(theta: f64) -> [C; 2] {
    let (s, c) = theta.sin_cos();
    let sign = if s * c > 0.0 { -1.0 } else { 1.0 };
    [C::new(s.abs(), 0.0), C::new(sign * c.abs(), 0.0)]
}

impl System {
    /// Linear polarizer at `theta` on `prop` (live labels `live`), blocked amplitude goes
    /// to `sink` (e.g. `"lost@P1"`), optionally only where `when` holds (a polarizer that
    /// covers a single slit uses `Pred::is("path", "A")`).
    pub fn polarizer(
        &mut self,
        prop: &str,
        live: [&str; 2],
        theta: f64,
        sink: &str,
        when: Option<&Pred>,
    ) -> Result<()> {
        self.project_or_sink(
            prop,
            live,
            linear_axis(theta),
            Some(blocked_axis(theta)),
            sink,
            when,
        )
    }

    /// Half-wave plate at `theta` on the live labels of `prop`.
    pub fn half_wave_plate(&mut self, prop: &str, live: [&str; 2], theta: f64) -> Result<()> {
        self.apply_matrix(prop, &live, &half_wave_plate_matrix(theta), None)
    }

    /// General retarder (QWP, Berek compensator…) on the live labels of `prop`.
    pub fn retarder(&mut self, prop: &str, live: [&str; 2], theta: f64, delta: f64) -> Result<()> {
        self.apply_matrix(prop, &live, &retarder_matrix(theta, delta), None)
    }

    /// Rotate polarization by `theta` (the Introduction's `R45` with `theta = -π/4`).
    pub fn rotate_polarization(&mut self, prop: &str, live: [&str; 2], theta: f64) -> Result<()> {
        self.apply_matrix(prop, &live, &rotation_matrix(theta), None)
    }

    /// Polarizing beam splitter: on `path == input`, the `live[0]` (H) component is
    /// transmitted to `path = transmitted` and `live[1]` (V) is reflected to
    /// `path = reflected`.
    pub fn polarizing_beam_splitter(
        &mut self,
        pol: &str,
        live: [&str; 2],
        path: &str,
        input: &str,
        transmitted: &str,
        reflected: &str,
    ) -> Result<()> {
        self.relabel(path, input, transmitted, Some(&Pred::is(pol, live[0])))?;
        self.relabel(path, input, reflected, Some(&Pred::is(pol, live[1])))
    }

    /// Non-polarizing 50/50 beam splitter on two path labels (symmetric convention:
    /// transmitted amplitude `1/√2`, reflected `i/√2`).
    pub fn beam_splitter(&mut self, path: &str, a: &str, b: &str) -> Result<()> {
        let t = C::new(crate::INV_SQRT2, 0.0);
        let r = C::new(0.0, crate::INV_SQRT2);
        self.apply_matrix(
            path,
            &[a, b],
            &Matrix::from_complex(&[&[t, r], &[r, t]]),
            None,
        )
    }

    /// Double (or N-) slit: `path == from` splits equally into `slits`, each with the
    /// propagation phase `e^{ikl}`; the fraction `1 - pass` of the beam hits the mask
    /// and goes to `lost` (if given).
    pub fn slits(
        &mut self,
        path: &str,
        from: &str,
        slits: &[&str],
        pass: f64,
        phase: f64,
        lost: Option<&str>,
    ) -> Result<()> {
        let n = slits.len() as f64;
        let amp = C::from_polar((pass / n).sqrt(), phase);
        let branches: Vec<(&str, C)> = slits.iter().map(|s| (*s, amp)).collect();
        self.split(path, from, &branches, lost)
    }

    /// Spontaneous parametric down-conversion in two crossed type-I BBO crystals.
    ///
    /// The pump property `pump` (live labels `pump_live`, H/V) is consumed and replaced by
    /// two new polarization properties `signal` and `idler`:
    /// `|H⟩_pump ↦ |V⟩|V⟩`, `|V⟩_pump ↦ e^{iφ}|H⟩|H⟩` (`phase` = relative phase set by the
    /// crystal + compensator). A diagonal pump therefore yields `|Φ⁺⟩`; a pump HWP away from
    /// 22.5° yields the unbalanced `cos χ|VV⟩ + e^{iφ} sin χ|HH⟩` seen in the lab.
    ///
    /// Note: only the pump's live-label amplitudes are converted; any other pump labels
    /// (e.g. a sink) are dropped — the caller should remove lost pump light first.
    pub fn spdc(
        &mut self,
        pump: &str,
        pump_live: [&str; 2],
        signal: &str,
        idler: &str,
        pol_labels: [&str; 2],
        phase: f64,
    ) -> Result<()> {
        let pi = self.prop_index(pump)?;
        let h = self.label_index(pump, pump_live[0])?;
        let v = self.label_index(pump, pump_live[1])?;
        // Drop pump light that is not live (e.g. lost at a polarizer before the crystal).
        self.retain_keys(|k| k.get(pi) == h || k.get(pi) == v);
        let keep_h = Pred::is(pump, pump_live[0]);
        let keep_v = Pred::is(pump, pump_live[1]);
        // Attach the daughter properties (initialised to label 0 = H).
        self.add_property(signal, &pol_labels)?;
        self.add_property(idler, &pol_labels)?;
        // pump H → signal V, idler V
        self.relabel(signal, pol_labels[0], pol_labels[1], Some(&keep_h))?;
        self.relabel(idler, pol_labels[0], pol_labels[1], Some(&keep_h))?;
        // pump V → signal H, idler H, with the relative phase
        self.scale_where(&keep_v, C::from_polar(1.0, phase))?;
        self.remove_property(pump)
    }
}
