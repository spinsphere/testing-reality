//! Quagmire Engine SDK for Godot 4.7.
//!
//! Exposes `QuagmireSystem`, `QuagmireScreen` and `QuagmireProfile` to GDScript.
//! Angles at this boundary are in **degrees**; the core works in radians.
//!
//! Predicates are plain dictionaries:
//! `{"is": {"pol": "↔"}, "is_not": {"path": "S"}, "alive": ["pol1", "pol2"]}`.
//! Errors are reported with `godot_error!` and a neutral return value.

use godot::prelude::*;
use quagmire_core::pretty::KetStyle;
use quagmire_core::screen::{linspace, Profile, ScreenGeometry, ScreenMode};
use quagmire_core::{Pred, System, C};

struct QuagmireExtension;

#[gdextension]
unsafe impl ExtensionLibrary for QuagmireExtension {}

fn pred_from_dict(d: &VarDictionary) -> Pred {
    let mut p = Pred::all();
    if let Some(is) = d.get(&"is".to_variant()) {
        if let Ok(m) = is.try_to::<VarDictionary>() {
            for (k, v) in m.iter_shared() {
                p = p.and_is(&k.to_string(), &v.to_string());
            }
        }
    }
    if let Some(is_not) = d.get(&"is_not".to_variant()) {
        if let Ok(m) = is_not.try_to::<VarDictionary>() {
            for (k, v) in m.iter_shared() {
                p = p.and_is_not(&k.to_string(), &v.to_string());
            }
        }
    }
    if let Some(alive) = d.get(&"alive".to_variant()) {
        if let Ok(a) = alive.try_to::<PackedStringArray>() {
            for s in a.as_slice() {
                p = p.and_alive(&s.to_string());
            }
        } else if let Ok(a) = alive.try_to::<VarArray>() {
            for s in a.iter_shared() {
                p = p.and_alive(&s.to_string());
            }
        }
    }
    p
}

fn opt_pred(d: &VarDictionary) -> Option<Pred> {
    if d.is_empty() {
        None
    } else {
        Some(pred_from_dict(d))
    }
}

fn strings(a: &PackedStringArray) -> Vec<String> {
    a.as_slice().iter().map(|s| s.to_string()).collect()
}

fn two(a: &PackedStringArray, what: &str) -> Option<[String; 2]> {
    let v = strings(a);
    if v.len() == 2 {
        Some([v[0].clone(), v[1].clone()])
    } else {
        godot_error!("Quagmire: {what} needs exactly two labels, got {}", v.len());
        None
    }
}

macro_rules! check {
    ($e:expr) => {
        match $e {
            Ok(v) => v,
            Err(err) => {
                godot_error!("Quagmire: {err}");
                return Default::default();
            }
        }
    };
}

/// A register of labelled qudits with a sparse quantum state.
#[derive(GodotClass)]
#[class(base = RefCounted)]
pub struct QuagmireSystem {
    sys: System,
    base: Base<RefCounted>,
}

#[godot_api]
impl IRefCounted for QuagmireSystem {
    fn init(base: Base<RefCounted>) -> Self {
        Self {
            sys: System::new(),
            base,
        }
    }
}

impl QuagmireSystem {
    fn from_system(sys: System) -> Gd<Self> {
        Gd::from_init_fn(|base| Self { sys, base })
    }

    pub fn inner(&self) -> &System {
        &self.sys
    }

    pub fn inner_mut(&mut self) -> &mut System {
        &mut self.sys
    }
}

#[godot_api]
impl QuagmireSystem {
    /// New system with a specific RNG seed.
    #[func]
    fn with_seed(seed: i64) -> Gd<Self> {
        Self::from_system(System::with_seed(seed as u64))
    }

    #[func]
    fn reseed(&mut self, seed: i64) {
        self.sys.reseed(seed as u64);
    }

    #[func]
    fn get_seed(&self) -> i64 {
        self.sys.seed() as i64
    }

    /// Deep copy.
    #[func]
    fn duplicate(&self) -> Gd<Self> {
        Self::from_system(self.sys.clone())
    }

    // ---------------------------------------------------------------- properties

    /// Add a property initialised to its first label. Returns its index or -1.
    #[func]
    fn add_property(&mut self, name: GString, labels: PackedStringArray) -> i64 {
        let v = strings(&labels);
        let refs: Vec<&str> = v.iter().map(String::as_str).collect();
        match self.sys.add_property(&name.to_string(), &refs) {
            Ok(i) => i as i64,
            Err(e) => {
                godot_error!("Quagmire: {e}");
                -1
            }
        }
    }

    #[func]
    fn add_label(&mut self, prop: GString, label: GString) -> i64 {
        match self.sys.ensure_label(&prop.to_string(), &label.to_string()) {
            Ok(i) => i as i64,
            Err(e) => {
                godot_error!("Quagmire: {e}");
                -1
            }
        }
    }

    #[func]
    fn add_sink(&mut self, prop: GString, label: GString) -> i64 {
        match self.sys.ensure_sink(&prop.to_string(), &label.to_string()) {
            Ok(i) => i as i64,
            Err(e) => {
                godot_error!("Quagmire: {e}");
                -1
            }
        }
    }

    #[func]
    fn remove_property(&mut self, name: GString) -> bool {
        check!(self.sys.remove_property(&name.to_string()));
        true
    }

    /// `[{name, labels: PackedStringArray, sinks: PackedByteArray}]`
    #[func]
    fn get_properties(&self) -> VarArray {
        let mut out = VarArray::new();
        for p in self.sys.properties() {
            let mut d = VarDictionary::new();
            d.set("name", &p.name.to_variant());
            d.set(
                "labels",
                &PackedStringArray::from_iter(p.labels.iter().map(GString::from)).to_variant(),
            );
            d.set(
                "sinks",
                &PackedByteArray::from_iter(p.sinks.iter().map(|&s| s as u8)).to_variant(),
            );
            out.push(&d.to_variant());
        }
        out
    }

    #[func]
    fn labels(&self, prop: GString) -> PackedStringArray {
        match self.sys.property(&prop.to_string()) {
            Ok(p) => PackedStringArray::from_iter(p.labels.iter().map(|l| GString::from(l))),
            Err(e) => {
                godot_error!("Quagmire: {e}");
                PackedStringArray::new()
            }
        }
    }

    // ---------------------------------------------------------------- state

    /// Replace the state: `entries` is an Array of `{labels: PackedStringArray, re, im}`.
    #[func]
    fn set_state(&mut self, entries: VarArray) -> bool {
        let mut rows: Vec<(Vec<String>, C)> = Vec::new();
        for e in entries.iter_shared() {
            let d: VarDictionary = check!(e.try_to::<VarDictionary>().map_err(|_| {
                quagmire_core::QuagmireError::Invalid("state entry must be a VarDictionary".into())
            }));
            let labels = d
                .get(&"labels".to_variant())
                .and_then(|v| v.try_to::<PackedStringArray>().ok())
                .map(|a| strings(&a))
                .unwrap_or_default();
            let re = d.get(&"re".to_variant()).and_then(|v| v.try_to::<f64>().ok()).unwrap_or(0.0);
            let im = d.get(&"im".to_variant()).and_then(|v| v.try_to::<f64>().ok()).unwrap_or(0.0);
            rows.push((labels, C::new(re, im)));
        }
        let refs: Vec<(Vec<&str>, C)> = rows
            .iter()
            .map(|(l, a)| (l.iter().map(String::as_str).collect(), *a))
            .collect();
        let slices: Vec<(&[&str], C)> = refs.iter().map(|(l, a)| (l.as_slice(), *a)).collect();
        check!(self.sys.set_state(&slices));
        true
    }

    /// Set a two-label property to linear polarization at `angle_deg`
    /// (`cos θ |live[0]⟩ + sin θ |live[1]⟩`), leaving other properties as they are.
    /// Only valid when the property is currently in a product state with the rest.
    #[func]
    fn set_linear_polarization(&mut self, prop: GString, live: PackedStringArray, angle_deg: f64) -> bool {
        let Some(l) = two(&live, "set_linear_polarization") else { return false };
        let p = prop.to_string();
        // Rotate from |live[0]⟩ (assumed current) to the target angle: apply a rotation
        // after first collapsing onto live[0] — simpler: force then rotate.
        check!(self.sys.force(&p, &l[0]));
        check!(self.sys.rotate_polarization(&p, [&l[0], &l[1]], angle_deg.to_radians()));
        true
    }

    #[func]
    fn normalize(&mut self) -> bool {
        check!(self.sys.normalize());
        true
    }

    #[func]
    fn norm(&self) -> f64 {
        self.sys.norm()
    }

    /// `[{labels: PackedStringArray, re, im, prob}]` in deterministic order.
    #[func]
    fn amplitudes(&self) -> VarArray {
        let mut out = VarArray::new();
        for (labels, a) in self.sys.amplitudes() {
            let mut d = VarDictionary::new();
            d.set(
                "labels",
                &PackedStringArray::from_iter(labels.iter().map(GString::from)).to_variant(),
            );
            d.set("re", &a.re.to_variant());
            d.set("im", &a.im.to_variant());
            d.set("prob", &a.norm_sqr().to_variant());
            out.push(&d.to_variant());
        }
        out
    }

    // ---------------------------------------------------------------- optics

    #[func]
    fn polarizer(&mut self, prop: GString, live: PackedStringArray, angle_deg: f64, sink: GString, when: VarDictionary) -> bool {
        let Some(l) = two(&live, "polarizer") else { return false };
        let pred = opt_pred(&when);
        check!(self.sys.polarizer(
            &prop.to_string(),
            [&l[0], &l[1]],
            angle_deg.to_radians(),
            &sink.to_string(),
            pred.as_ref()
        ));
        true
    }

    #[func]
    fn half_wave_plate(&mut self, prop: GString, live: PackedStringArray, angle_deg: f64) -> bool {
        let Some(l) = two(&live, "half_wave_plate") else { return false };
        check!(self.sys.half_wave_plate(&prop.to_string(), [&l[0], &l[1]], angle_deg.to_radians()));
        true
    }

    /// General retarder: fast axis `angle_deg`, retardance `retardance_deg`
    /// (180 = half-wave, 90 = quarter-wave; a Berek compensator is variable).
    #[func]
    fn retarder(&mut self, prop: GString, live: PackedStringArray, angle_deg: f64, retardance_deg: f64) -> bool {
        let Some(l) = two(&live, "retarder") else { return false };
        check!(self.sys.retarder(
            &prop.to_string(),
            [&l[0], &l[1]],
            angle_deg.to_radians(),
            retardance_deg.to_radians()
        ));
        true
    }

    #[func]
    fn rotate_polarization(&mut self, prop: GString, live: PackedStringArray, angle_deg: f64) -> bool {
        let Some(l) = two(&live, "rotate_polarization") else { return false };
        check!(self.sys.rotate_polarization(&prop.to_string(), [&l[0], &l[1]], angle_deg.to_radians()));
        true
    }

    #[func]
    fn polarizing_beam_splitter(
        &mut self,
        pol: GString,
        live: PackedStringArray,
        path: GString,
        input: GString,
        transmitted: GString,
        reflected: GString,
    ) -> bool {
        let Some(l) = two(&live, "polarizing_beam_splitter") else { return false };
        check!(self.sys.polarizing_beam_splitter(
            &pol.to_string(),
            [&l[0], &l[1]],
            &path.to_string(),
            &input.to_string(),
            &transmitted.to_string(),
            &reflected.to_string()
        ));
        true
    }

    #[func]
    fn beam_splitter(&mut self, path: GString, a: GString, b: GString) -> bool {
        check!(self.sys.beam_splitter(&path.to_string(), &a.to_string(), &b.to_string()));
        true
    }

    /// Slits: `path == from` splits equally into `slits`; `lost` may be "" for none.
    #[func]
    fn slits(&mut self, path: GString, from: GString, slits: PackedStringArray, pass_fraction: f64, phase_rad: f64, lost: GString) -> bool {
        let v = strings(&slits);
        let refs: Vec<&str> = v.iter().map(String::as_str).collect();
        let lost_s = lost.to_string();
        let lost_opt = if lost_s.is_empty() { None } else { Some(lost_s.as_str()) };
        check!(self.sys.slits(&path.to_string(), &from.to_string(), &refs, pass_fraction, phase_rad, lost_opt));
        true
    }

    /// SPDC in crossed type-I crystals: consumes `pump`, creates `signal` and `idler`.
    #[func]
    fn spdc(&mut self, pump: GString, pump_live: PackedStringArray, signal: GString, idler: GString, pol_labels: PackedStringArray, phase_deg: f64) -> bool {
        let Some(pl) = two(&pump_live, "spdc pump_live") else { return false };
        let Some(ol) = two(&pol_labels, "spdc pol_labels") else { return false };
        check!(self.sys.spdc(
            &pump.to_string(),
            [&pl[0], &pl[1]],
            &signal.to_string(),
            &idler.to_string(),
            [&ol[0], &ol[1]],
            phase_deg.to_radians()
        ));
        true
    }

    #[func]
    fn relabel(&mut self, prop: GString, from: GString, to: GString, when: VarDictionary) -> bool {
        let pred = opt_pred(&when);
        check!(self.sys.relabel(&prop.to_string(), &from.to_string(), &to.to_string(), pred.as_ref()));
        true
    }

    #[func]
    fn mark_sink(&mut self, prop: GString, label: GString) -> bool {
        check!(self.sys.mark_sink(&prop.to_string(), &label.to_string()));
        true
    }

    #[func]
    fn phase(&mut self, prop: GString, label: GString, phase_rad: f64) -> bool {
        check!(self.sys.apply_phase(&prop.to_string(), &label.to_string(), C::from_polar(1.0, phase_rad)));
        true
    }

    // ---------------------------------------------------------------- queries

    #[func]
    fn probability(&self, pred: VarDictionary) -> f64 {
        check!(self.sys.probability(&pred_from_dict(&pred)))
    }

    /// `{label: probability}` for every label of `prop`.
    #[func]
    fn marginals(&self, prop: GString) -> VarDictionary {
        let mut d = VarDictionary::new();
        for (l, p) in check!(self.sys.marginals(&prop.to_string())) {
            d.set(&l.to_variant(), &p.to_variant());
        }
        d
    }

    /// Post-select on `pred` and renormalise, as a new system.
    #[func]
    fn conditional(&self, pred: VarDictionary) -> Option<Gd<Self>> {
        match self.sys.conditional(&pred_from_dict(&pred)) {
            Ok(s) => Some(Self::from_system(s)),
            Err(e) => {
                godot_error!("Quagmire: {e}");
                None
            }
        }
    }

    /// Zero non-matching components without renormalising.
    #[func]
    fn project(&mut self, pred: VarDictionary) -> bool {
        check!(self.sys.project(&pred_from_dict(&pred)));
        true
    }

    // ---------------------------------------------------------------- measurement

    #[func]
    fn measure(&mut self, prop: GString) -> GString {
        GString::from(&check!(self.sys.measure(&prop.to_string())))
    }

    #[func]
    fn force(&mut self, prop: GString, label: GString) -> bool {
        check!(self.sys.force(&prop.to_string(), &label.to_string()));
        true
    }

    #[func]
    fn sample(&mut self, prop: GString, n: i64) -> PackedStringArray {
        let v = check!(self.sys.sample(&prop.to_string(), n.max(0) as usize));
        PackedStringArray::from_iter(v.iter().map(|l| GString::from(l)))
    }

    #[func]
    fn uniform(&mut self) -> f64 {
        self.sys.uniform()
    }

    // ---------------------------------------------------------------- display

    /// Unicode ket string, e.g. `1/√2 |↔⟩|A⟩ + 1/√2 |↕⟩|B⟩`.
    #[func]
    fn ket_text(&self) -> GString {
        GString::from(&self.sys.ket_text())
    }

    /// LaTeX ket string. `label_map` optionally maps `"prop/label"` → LaTeX.
    #[func]
    fn ket_latex(&self, label_map: VarDictionary) -> GString {
        let s = self.sys.ket_string(KetStyle::Latex, &|p, l| {
            let key = format!("{p}/{l}");
            label_map
                .get(&key.to_variant())
                .map(|v| v.to_string())
                .unwrap_or_else(|| l.to_string())
        });
        GString::from(&s)
    }

    /// Unicode ket string with a `"prop/label"` → text map (e.g. hide property names).
    #[func]
    fn ket_text_mapped(&self, label_map: VarDictionary) -> GString {
        let s = self.sys.ket_string(KetStyle::Unicode, &|p, l| {
            let key = format!("{p}/{l}");
            label_map
                .get(&key.to_variant())
                .map(|v| v.to_string())
                .unwrap_or_else(|| l.to_string())
        });
        GString::from(&s)
    }

    #[func]
    fn op_log(&self) -> PackedStringArray {
        PackedStringArray::from_iter(self.sys.log().iter().map(|l| GString::from(l)))
    }

    // ---------------------------------------------------------------- screen

    /// Detector profile for `path_prop` on `screen`, optionally post-selected on `post`.
    #[func]
    fn screen_profile(&self, path_prop: GString, screen: Gd<QuagmireScreen>, ys: PackedFloat64Array, post: VarDictionary) -> Option<Gd<QuagmireProfile>> {
        let geom = screen.bind().geometry();
        let pred = opt_pred(&post);
        match self.sys.screen_profile(&path_prop.to_string(), &geom, ys.as_slice(), pred.as_ref()) {
            Ok(p) => Some(QuagmireProfile::from_profile(p)),
            Err(e) => {
                godot_error!("Quagmire: {e}");
                None
            }
        }
    }
}

/// Slit-mask and detector geometry (metres, degrees).
#[derive(GodotClass)]
#[class(base = RefCounted)]
pub struct QuagmireScreen {
    #[var]
    wavelength: f64,
    #[var]
    slit_width: f64,
    #[var]
    distance: f64,
    /// "far" (Fraunhofer, default) or "exact".
    #[var]
    mode: GString,
    slits: Vec<(String, f64)>,
    base: Base<RefCounted>,
}

#[godot_api]
impl IRefCounted for QuagmireScreen {
    fn init(base: Base<RefCounted>) -> Self {
        Self {
            wavelength: 405e-9,
            slit_width: 200e-6,
            distance: 0.5,
            mode: GString::from("far"),
            slits: Vec::new(),
            base,
        }
    }
}

impl QuagmireScreen {
    fn geometry(&self) -> ScreenGeometry {
        ScreenGeometry {
            wavelength: self.wavelength,
            slit_width: self.slit_width,
            slits: self.slits.clone(),
            distance: self.distance,
            mode: if self.mode.to_string() == "exact" {
                ScreenMode::Exact
            } else {
                ScreenMode::FarField
            },
        }
    }
}

#[godot_api]
impl QuagmireScreen {
    /// Symmetric double slit: `a` at `+separation/2`, `b` at `−separation/2`.
    #[func]
    fn set_double_slit(&mut self, wavelength: f64, slit_width: f64, separation: f64, distance: f64, a: GString, b: GString) {
        self.wavelength = wavelength;
        self.slit_width = slit_width;
        self.distance = distance;
        self.slits = vec![(a.to_string(), separation / 2.0), (b.to_string(), -separation / 2.0)];
    }

    #[func]
    fn set_single_slit(&mut self, wavelength: f64, slit_width: f64, distance: f64, a: GString) {
        self.wavelength = wavelength;
        self.slit_width = slit_width;
        self.distance = distance;
        self.slits = vec![(a.to_string(), 0.0)];
    }

    #[func]
    fn clear_slits(&mut self) {
        self.slits.clear();
    }

    /// Add a slit with path label `label` centred at transverse position `x`.
    #[func]
    fn add_slit(&mut self, label: GString, x: f64) {
        self.slits.push((label.to_string(), x));
    }

    /// Single-slit envelope `(sin α/α)²` at `sin θ`.
    #[func]
    fn envelope(&self, sin_theta: f64) -> f64 {
        self.geometry().envelope(sin_theta)
    }

    /// Uniform positions from `-half` to `+half`.
    #[func]
    fn linspace(half: f64, n: i64) -> PackedFloat64Array {
        PackedFloat64Array::from(linspace(half, n.max(0) as usize))
    }
}

/// A sampled detector profile.
#[derive(GodotClass)]
#[class(base = RefCounted)]
pub struct QuagmireProfile {
    profile: Profile,
    base: Base<RefCounted>,
}

#[godot_api]
impl IRefCounted for QuagmireProfile {
    fn init(base: Base<RefCounted>) -> Self {
        Self {
            profile: Profile {
                ys: Vec::new(),
                intensity: Vec::new(),
                incoherent: Vec::new(),
            },
            base,
        }
    }
}

impl QuagmireProfile {
    fn from_profile(profile: Profile) -> Gd<Self> {
        Gd::from_init_fn(|base| Self { profile, base })
    }
}

#[godot_api]
impl QuagmireProfile {
    #[func]
    fn ys(&self) -> PackedFloat64Array {
        PackedFloat64Array::from(self.profile.ys.clone())
    }

    /// Coherent intensity (what the detector sees).
    #[func]
    fn intensity(&self) -> PackedFloat64Array {
        PackedFloat64Array::from(self.profile.intensity.clone())
    }

    /// Incoherent reference (same photons, no interference).
    #[func]
    fn incoherent(&self) -> PackedFloat64Array {
        PackedFloat64Array::from(self.profile.incoherent.clone())
    }

    #[func]
    fn max(&self) -> f64 {
        self.profile.max()
    }

    /// Fringe visibility in [0, 1], independent of the envelope.
    #[func]
    fn visibility(&self) -> f64 {
        self.profile.visibility()
    }

    /// Convolve with a detector slit of `width` metres.
    #[func]
    fn box_convolve(&self, width: f64) -> Gd<QuagmireProfile> {
        Self::from_profile(self.profile.box_convolve(width))
    }

    /// Draw `n` photon positions distributed as this profile, using `system`'s RNG.
    #[func]
    fn sample_positions(&self, mut system: Gd<QuagmireSystem>, n: i64) -> PackedFloat64Array {
        let mut b = system.bind_mut();
        let v = self.profile.sample_positions(b.inner_mut(), n.max(0) as usize);
        PackedFloat64Array::from(v)
    }
}
