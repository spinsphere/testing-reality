//! # Quagmire Engine — core
//!
//! A small, deterministic quantum-state engine for games and educational simulations.
//!
//! The model is a register of **labelled qudits** ("properties") — e.g. a photon's
//! polarization with basis `["H", "V"]`, or its path with basis `["S", "A", "B"]` — and a
//! **sparse state vector** over tuples of labels. Operators act on one or two properties
//! with identity elsewhere. Non-unitary optical elements such as polarizers keep the state
//! normalised by moving blocked amplitude into orthogonal *sink* labels (`|lost⟩`), exactly
//! as the pedagogical derivations on testing-reality.webflow.io do.
//!
//! A separate [`screen`] module turns a path property into a continuous detector profile
//! `I(y) = Σ_env |Σ_path c · φ_path(y)|²`, which reproduces single/double-slit diffraction,
//! which-path marking, quantum erasure and coincidence post-selection.
//!
//! Everything is `f64`, the RNG is a seedable PCG32, and iteration order is deterministic.

pub mod key;
pub mod ops;
pub mod optics;
pub mod pretty;
pub mod screen;
pub mod system;

pub use key::Key;
pub use num_complex::Complex64 as C;
pub use ops::{Matrix, Pred, PredTerm};
pub use screen::{Profile, ScreenGeometry, ScreenMode};
pub use system::{Property, QuagmireError, System};

/// `1/√2`, used everywhere in two-level optics.
pub const INV_SQRT2: f64 = std::f64::consts::FRAC_1_SQRT_2;

/// The engine version (the crate version), for hosts to display and log.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
