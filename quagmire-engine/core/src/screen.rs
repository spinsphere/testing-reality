//! Continuous detector profiles from a discrete path property.
//!
//! `I(y) = Σ_env | Σ_p c[p, env] · φ_p(y) |²` where `φ_p(y) = √D_p(y) · e^{i k r_p(y)}`.
//! Environment states (every other property) add incoherently, paths add coherently.

use crate::ops::Pred;
use crate::system::{Result, System};
use crate::C;

/// How path phases and the diffraction envelope are evaluated.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ScreenMode {
    /// Fraunhofer (far field / lens focal plane): common angle `θ = atan(y/L)`, path phase
    /// `−k x_p sin θ`, envelope `sinc²(π w sin θ / λ)`. Reproduces the site's formulas.
    FarField,
    /// Exact point-source distances `r_p = √(L² + (y − x_p)²)` with per-slit envelope
    /// angle `θ_p = atan((y − x_p)/L)`.
    Exact,
}

/// Geometry of a slit mask and detector plane (all lengths in metres).
#[derive(Clone, Debug, PartialEq)]
pub struct ScreenGeometry {
    pub wavelength: f64,
    pub slit_width: f64,
    /// Path label and transverse slit-centre position for each slit.
    pub slits: Vec<(String, f64)>,
    /// Slit-to-detector distance (or lens focal length in far-field mode).
    pub distance: f64,
    pub mode: ScreenMode,
}

impl ScreenGeometry {
    /// Symmetric two-slit mask: slits `a` at `+sep/2` and `b` at `−sep/2`.
    pub fn double_slit(
        wavelength: f64,
        slit_width: f64,
        separation: f64,
        distance: f64,
        a: &str,
        b: &str,
    ) -> Self {
        ScreenGeometry {
            wavelength,
            slit_width,
            slits: vec![(a.into(), separation / 2.0), (b.into(), -separation / 2.0)],
            distance,
            mode: ScreenMode::FarField,
        }
    }

    pub fn single_slit(wavelength: f64, slit_width: f64, distance: f64, a: &str) -> Self {
        ScreenGeometry {
            wavelength,
            slit_width,
            slits: vec![(a.into(), 0.0)],
            distance,
            mode: ScreenMode::FarField,
        }
    }

    fn k(&self) -> f64 {
        2.0 * std::f64::consts::PI / self.wavelength
    }

    /// Single-slit envelope `(sin α / α)²`, `α = π w sin θ / λ`.
    pub fn envelope(&self, sin_theta: f64) -> f64 {
        let alpha = std::f64::consts::PI * self.slit_width * sin_theta / self.wavelength;
        if alpha.abs() < 1e-12 {
            1.0
        } else {
            let s = alpha.sin() / alpha;
            s * s
        }
    }

    /// Propagation kernel `φ_p(y)` for slit `p`.
    pub fn kernel(&self, slit: usize, y: f64) -> C {
        let x = self.slits[slit].1;
        match self.mode {
            ScreenMode::FarField => {
                let sin_t = y / (y * y + self.distance * self.distance).sqrt();
                C::from_polar(self.envelope(sin_t).sqrt(), -self.k() * x * sin_t)
            }
            ScreenMode::Exact => {
                let dy = y - x;
                let r = (dy * dy + self.distance * self.distance).sqrt();
                let sin_t = dy / r;
                C::from_polar(self.envelope(sin_t).sqrt(), self.k() * (r - self.distance))
            }
        }
    }
}

/// A sampled intensity profile.
#[derive(Clone, Debug, PartialEq)]
pub struct Profile {
    pub ys: Vec<f64>,
    /// Coherent intensity `Σ_env |Σ_p c φ_p|²` — what the detector sees.
    pub intensity: Vec<f64>,
    /// Incoherent reference `Σ_env Σ_p |c φ_p|²` — the same photons with no interference
    /// (the diffraction envelope). `intensity / incoherent` isolates the fringe factor.
    pub incoherent: Vec<f64>,
}

impl Profile {
    pub fn max(&self) -> f64 {
        self.intensity.iter().cloned().fold(0.0, f64::max)
    }

    /// Fringe visibility `(max − min)/(max + min)` of the fringe factor
    /// `intensity / incoherent`, evaluated where the envelope is at least 5 % of its peak.
    /// 1 = perfect fringes, 0 = no interference, independent of the envelope shape.
    pub fn visibility(&self) -> f64 {
        let peak = self.incoherent.iter().cloned().fold(0.0, f64::max);
        if peak <= 0.0 {
            return 0.0;
        }
        let mut lo = f64::INFINITY;
        let mut hi = f64::NEG_INFINITY;
        for (i, e) in self.intensity.iter().zip(&self.incoherent) {
            if *e >= 0.05 * peak {
                let f = i / e;
                lo = lo.min(f);
                hi = hi.max(f);
            }
        }
        if !hi.is_finite() || hi + lo <= 0.0 {
            0.0
        } else {
            (hi - lo) / (hi + lo)
        }
    }

    /// Convolve with a box of the given width (a detector slit), assuming uniform `ys`.
    pub fn box_convolve(&self, width: f64) -> Profile {
        let incoherent = Profile {
            ys: self.ys.clone(),
            intensity: self.incoherent.clone(),
            incoherent: Vec::new(),
        }
        .box_convolve_raw(width);
        Profile {
            ys: self.ys.clone(),
            intensity: self.box_convolve_raw(width),
            incoherent,
        }
    }

    fn box_convolve_raw(&self, width: f64) -> Vec<f64> {
        let n = self.ys.len();
        if n < 2 {
            return self.intensity.clone();
        }
        let dy = (self.ys[n - 1] - self.ys[0]) / (n as f64 - 1.0);
        let half = ((width / dy) / 2.0).round() as isize;
        let mut out = vec![0.0; n];
        for (i, slot) in out.iter_mut().enumerate() {
            let mut s = 0.0;
            let mut c = 0.0;
            for j in (i as isize - half)..=(i as isize + half) {
                if j >= 0 && (j as usize) < n {
                    s += self.intensity[j as usize];
                    c += 1.0;
                }
            }
            *slot = if c > 0.0 { s / c } else { 0.0 };
        }
        out
    }

    /// Draw `n` photon positions distributed as this profile (inverse CDF, linear
    /// interpolation inside bins) using the system's RNG.
    pub fn sample_positions(&self, sys: &mut System, n: usize) -> Vec<f64> {
        let m = self.ys.len();
        if m == 0 {
            return Vec::new();
        }
        let mut cdf = Vec::with_capacity(m);
        let mut acc = 0.0;
        for i in &self.intensity {
            acc += i.max(0.0);
            cdf.push(acc);
        }
        if acc <= 0.0 {
            return Vec::new();
        }
        let mut out = Vec::with_capacity(n);
        for _ in 0..n {
            let r = sys.uniform() * acc;
            let idx = cdf.partition_point(|&c| c < r).min(m - 1);
            let lo = if idx == 0 { 0.0 } else { cdf[idx - 1] };
            let frac = if cdf[idx] > lo {
                (r - lo) / (cdf[idx] - lo)
            } else {
                0.5
            };
            let y0 = self.ys[idx];
            let y1 = if idx + 1 < m { self.ys[idx + 1] } else { y0 };
            let y_prev = if idx > 0 { self.ys[idx - 1] } else { y0 };
            // centre each bin on its sample point
            let left = (y_prev + y0) / 2.0;
            let right = (y0 + y1) / 2.0;
            out.push(left + frac * (right - left));
        }
        out
    }
}

impl System {
    /// Intensity profile on a screen for `path_prop`, optionally post-selected on
    /// `post` (coincidence condition). Absolute scale: a single path with unit amplitude
    /// and no envelope gives intensity 1.
    pub fn screen_profile(
        &self,
        path_prop: &str,
        geom: &ScreenGeometry,
        ys: &[f64],
        post: Option<&Pred>,
    ) -> Result<Profile> {
        let sys = match post {
            Some(p) => {
                let mut s = self.clone();
                s.project(p)?;
                s
            }
            None => self.clone(),
        };
        let slit_idx: Vec<usize> = geom
            .slits
            .iter()
            .map(|(l, _)| sys.label_index(path_prop, l))
            .collect::<Result<_>>()?;
        let groups = sys.group_by_environment(path_prop)?;
        let mut intensity = Vec::with_capacity(ys.len());
        let mut incoherent = Vec::with_capacity(ys.len());
        for &y in ys {
            let kernels: Vec<C> = (0..geom.slits.len()).map(|p| geom.kernel(p, y)).collect();
            let mut total = 0.0;
            let mut total_inc = 0.0;
            for (_, row) in &groups {
                let mut s = C::new(0.0, 0.0);
                for (p, &li) in slit_idx.iter().enumerate() {
                    let term = row[li] * kernels[p];
                    s += term;
                    total_inc += term.norm_sqr();
                }
                total += s.norm_sqr();
            }
            intensity.push(total);
            incoherent.push(total_inc);
        }
        Ok(Profile {
            ys: ys.to_vec(),
            intensity,
            incoherent,
        })
    }
}

/// Uniformly spaced sample positions from `-half` to `+half`.
pub fn linspace(half: f64, n: usize) -> Vec<f64> {
    if n < 2 {
        return vec![0.0];
    }
    (0..n)
        .map(|i| -half + 2.0 * half * i as f64 / (n as f64 - 1.0))
        .collect()
}
