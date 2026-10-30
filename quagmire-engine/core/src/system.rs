//! The [`System`]: properties plus a sparse state vector.

use std::collections::BTreeMap;

use rand_core::{RngCore, SeedableRng};
use rand_pcg::Pcg32;
use thiserror::Error;

use crate::key::Key;
use crate::ops::{Clause, Matrix, Pred};
use crate::C;

/// A labelled qudit. Labels may be any string (Unicode arrows are fine).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Property {
    pub name: String,
    pub labels: Vec<String>,
    /// `sinks[i]` is true when `labels[i]` is a `|lost⟩`-type sink.
    pub sinks: Vec<bool>,
}

impl Property {
    pub fn index_of(&self, label: &str) -> Option<usize> {
        self.labels.iter().position(|l| l == label)
    }

    /// Labels that are not sinks.
    pub fn live_labels(&self) -> Vec<&str> {
        self.labels
            .iter()
            .zip(&self.sinks)
            .filter(|(_, s)| !**s)
            .map(|(l, _)| l.as_str())
            .collect()
    }
}

/// A predicate clause resolved to indices.
#[derive(Clone, Debug)]
pub(crate) enum ResolvedClause {
    Eq(usize),
    Ne(usize),
    NotSink(Vec<bool>),
}

#[derive(Error, Debug, Clone, PartialEq)]
pub enum QuagmireError {
    #[error("unknown property `{0}`")]
    UnknownProperty(String),
    #[error("property `{0}` already exists")]
    DuplicateProperty(String),
    #[error("unknown label `{label}` on property `{prop}`")]
    UnknownLabel { prop: String, label: String },
    #[error("label `{label}` already exists on property `{prop}`")]
    DuplicateLabel { prop: String, label: String },
    #[error("too many properties (max {0})")]
    TooManyProperties(usize),
    #[error("too many labels on `{0}` (max {1})")]
    TooManyLabels(String, usize),
    #[error("matrix dimension {got} does not match {expected} labels")]
    DimensionMismatch { got: usize, expected: usize },
    #[error("state has zero norm; nothing to condition or measure")]
    ZeroNorm,
    #[error("{0}")]
    Invalid(String),
}

pub type Result<T> = std::result::Result<T, QuagmireError>;

/// Minimum |amplitude| kept in the sparse state.
pub const PRUNE_EPS: f64 = 1e-14;

/// A register of labelled qudits with a sparse pure state.
#[derive(Clone, Debug)]
pub struct System {
    props: Vec<Property>,
    state: BTreeMap<Key, C>,
    rng: Pcg32,
    seed: u64,
    log: Vec<String>,
}

impl Default for System {
    fn default() -> Self {
        Self::new()
    }
}

impl System {
    /// Empty system with the default seed. The state is the scalar `1` until a
    /// property is added (then `|label0⟩`).
    pub fn new() -> Self {
        Self::with_seed(0x5EED_CAFE_F00D_0001)
    }

    pub fn with_seed(seed: u64) -> Self {
        let mut state = BTreeMap::new();
        state.insert(Key::ZERO, C::new(1.0, 0.0));
        System {
            props: Vec::new(),
            state,
            rng: Pcg32::seed_from_u64(seed),
            seed,
            log: Vec::new(),
        }
    }

    pub fn seed(&self) -> u64 {
        self.seed
    }

    pub fn reseed(&mut self, seed: u64) {
        self.seed = seed;
        self.rng = Pcg32::seed_from_u64(seed);
    }

    /// Human-readable record of every operation applied so far.
    pub fn log(&self) -> &[String] {
        &self.log
    }

    // ------------------------------------------------------------------ properties

    pub fn properties(&self) -> &[Property] {
        &self.props
    }

    pub fn property(&self, name: &str) -> Result<&Property> {
        self.props
            .iter()
            .find(|p| p.name == name)
            .ok_or_else(|| QuagmireError::UnknownProperty(name.into()))
    }

    pub fn prop_index(&self, name: &str) -> Result<usize> {
        self.props
            .iter()
            .position(|p| p.name == name)
            .ok_or_else(|| QuagmireError::UnknownProperty(name.into()))
    }

    pub fn label_index(&self, prop: &str, label: &str) -> Result<usize> {
        self.property(prop)?
            .index_of(label)
            .ok_or_else(|| QuagmireError::UnknownLabel {
                prop: prop.into(),
                label: label.into(),
            })
    }

    /// Add a property initialised to its first label (tensor with `|labels[0]⟩`).
    pub fn add_property(&mut self, name: &str, labels: &[&str]) -> Result<usize> {
        if self.props.iter().any(|p| p.name == name) {
            return Err(QuagmireError::DuplicateProperty(name.into()));
        }
        if self.props.len() >= Key::MAX_PROPS {
            return Err(QuagmireError::TooManyProperties(Key::MAX_PROPS));
        }
        if labels.is_empty() {
            return Err(QuagmireError::Invalid("a property needs ≥ 1 label".into()));
        }
        if labels.len() > Key::MAX_LABELS {
            return Err(QuagmireError::TooManyLabels(name.into(), Key::MAX_LABELS));
        }
        self.props.push(Property {
            name: name.into(),
            labels: labels.iter().map(|s| s.to_string()).collect(),
            sinks: vec![false; labels.len()],
        });
        self.log.push(format!("add_property {name} {labels:?}"));
        Ok(self.props.len() - 1)
    }

    /// Add a label (e.g. a `lost` sink) to an existing property; returns its index.
    pub fn add_label(&mut self, prop: &str, label: &str) -> Result<usize> {
        let pi = self.prop_index(prop)?;
        if self.props[pi].labels.iter().any(|l| l == label) {
            return Err(QuagmireError::DuplicateLabel {
                prop: prop.into(),
                label: label.into(),
            });
        }
        if self.props[pi].labels.len() >= Key::MAX_LABELS {
            return Err(QuagmireError::TooManyLabels(prop.into(), Key::MAX_LABELS));
        }
        self.props[pi].labels.push(label.into());
        self.props[pi].sinks.push(false);
        Ok(self.props[pi].labels.len() - 1)
    }

    /// Mark a label of `prop` as a sink (`|lost⟩`-type). Sinks are excluded by
    /// [`Pred::alive`].
    pub fn mark_sink(&mut self, prop: &str, label: &str) -> Result<()> {
        let pi = self.prop_index(prop)?;
        let li = self.label_index(prop, label)?;
        self.props[pi].sinks[li] = true;
        Ok(())
    }

    /// Add (if missing) and mark a sink label; returns its index.
    pub fn ensure_sink(&mut self, prop: &str, label: &str) -> Result<usize> {
        let li = self.ensure_label(prop, label)?;
        self.mark_sink(prop, label)?;
        Ok(li)
    }

    pub fn is_sink(&self, prop: &str, label: &str) -> Result<bool> {
        let pi = self.prop_index(prop)?;
        let li = self.label_index(prop, label)?;
        Ok(self.props[pi].sinks[li])
    }

    /// Add the label if missing; returns its index either way.
    pub fn ensure_label(&mut self, prop: &str, label: &str) -> Result<usize> {
        match self.label_index(prop, label) {
            Ok(i) => Ok(i),
            Err(_) => self.add_label(prop, label),
        }
    }

    /// Remove a property. Amplitudes that differ only in that property are summed
    /// coherently — only meaningful when the property is in a product state (e.g. a pump
    /// photon that has been converted), which the caller must guarantee.
    pub fn remove_property(&mut self, name: &str) -> Result<()> {
        let pi = self.prop_index(name)?;
        let mut next = BTreeMap::new();
        for (k, a) in &self.state {
            *next.entry(k.remove_slot(pi)).or_insert(C::new(0.0, 0.0)) += *a;
        }
        self.state = next;
        self.props.remove(pi);
        self.log.push(format!("remove_property {name}"));
        Ok(())
    }

    // ------------------------------------------------------------------ state access

    /// Replace the state with explicit amplitudes over label tuples (one label per
    /// property, in property order). Not normalised automatically.
    pub fn set_state(&mut self, entries: &[(&[&str], C)]) -> Result<()> {
        let mut next = BTreeMap::new();
        for (labels, amp) in entries {
            if labels.len() != self.props.len() {
                return Err(QuagmireError::Invalid(format!(
                    "expected {} labels, got {}",
                    self.props.len(),
                    labels.len()
                )));
            }
            let mut k = Key::ZERO;
            for (p, l) in labels.iter().enumerate() {
                k = k.with(p, self.label_index(&self.props[p].name, l)?);
            }
            *next.entry(k).or_insert(C::new(0.0, 0.0)) += *amp;
        }
        self.state = next;
        self.prune();
        Ok(())
    }

    /// Normalise the state to unit norm.
    pub fn normalize(&mut self) -> Result<()> {
        let n = self.norm();
        if n <= 0.0 {
            return Err(QuagmireError::ZeroNorm);
        }
        for a in self.state.values_mut() {
            *a /= n;
        }
        Ok(())
    }

    /// `√(Σ|a|²)`.
    pub fn norm(&self) -> f64 {
        self.state
            .values()
            .map(|a| a.norm_sqr())
            .sum::<f64>()
            .sqrt()
    }

    /// Number of non-zero amplitudes.
    pub fn len(&self) -> usize {
        self.state.len()
    }

    pub fn is_empty(&self) -> bool {
        self.state.is_empty()
    }

    /// Raw sparse state in deterministic (key) order.
    pub fn raw_state(&self) -> &BTreeMap<Key, C> {
        &self.state
    }

    /// Amplitudes as `(labels, amplitude)` pairs in deterministic order.
    pub fn amplitudes(&self) -> Vec<(Vec<String>, C)> {
        let n = self.props.len();
        let mut entries: Vec<(Vec<usize>, Key, C)> = self
            .state
            .iter()
            .map(|(k, a)| (k.to_indices(n), *k, *a))
            .collect();
        entries.sort_by(|a, b| a.0.cmp(&b.0));
        entries
            .into_iter()
            .map(|(_, k, a)| (self.labels_of(k), a))
            .collect()
    }

    /// Labels of a key, in property order.
    pub fn labels_of(&self, k: Key) -> Vec<String> {
        self.props
            .iter()
            .enumerate()
            .map(|(p, prop)| prop.labels[k.get(p)].clone())
            .collect()
    }

    fn prune(&mut self) {
        self.state.retain(|_, a| a.norm() > PRUNE_EPS);
    }

    // ------------------------------------------------------------------ predicates

    /// Resolve a predicate to property indices and index-level clauses.
    pub(crate) fn resolve_pred(&self, pred: &Pred) -> Result<Vec<(usize, ResolvedClause)>> {
        pred.terms
            .iter()
            .map(|t| {
                let pi = self.prop_index(&t.prop)?;
                let clause = match &t.clause {
                    Clause::Is(l) => ResolvedClause::Eq(self.label_index(&t.prop, l)?),
                    Clause::IsNot(l) => ResolvedClause::Ne(self.label_index(&t.prop, l)?),
                    Clause::NotLost => ResolvedClause::NotSink(self.props[pi].sinks.clone()),
                };
                Ok((pi, clause))
            })
            .collect()
    }

    #[inline]
    pub(crate) fn key_matches(k: Key, resolved: &[(usize, ResolvedClause)]) -> bool {
        resolved.iter().all(|(p, c)| match c {
            ResolvedClause::Eq(l) => k.get(*p) == *l,
            ResolvedClause::Ne(l) => k.get(*p) != *l,
            ResolvedClause::NotSink(sinks) => !sinks[k.get(*p)],
        })
    }

    // ------------------------------------------------------------------ operators

    /// Apply a matrix to the given labels of one property (identity on other labels),
    /// optionally only on components satisfying `when`.
    pub fn apply_matrix(
        &mut self,
        prop: &str,
        labels: &[&str],
        m: &Matrix,
        when: Option<&Pred>,
    ) -> Result<()> {
        let pi = self.prop_index(prop)?;
        if m.dim != labels.len() {
            return Err(QuagmireError::DimensionMismatch {
                got: m.dim,
                expected: labels.len(),
            });
        }
        let idx: Vec<usize> = labels
            .iter()
            .map(|l| self.label_index(prop, l))
            .collect::<Result<_>>()?;
        let resolved = match when {
            Some(p) => self.resolve_pred(p)?,
            None => Vec::new(),
        };
        let mut next: BTreeMap<Key, C> = BTreeMap::new();
        for (k, a) in &self.state {
            let li = k.get(pi);
            let col = idx.iter().position(|&i| i == li);
            match col {
                Some(col) if Self::key_matches(*k, &resolved) => {
                    for (row, &out_label) in idx.iter().enumerate() {
                        let v = m.get(row, col);
                        if v.norm() > 0.0 {
                            *next
                                .entry(k.with(pi, out_label))
                                .or_insert(C::new(0.0, 0.0)) += v * a;
                        }
                    }
                }
                _ => {
                    *next.entry(*k).or_insert(C::new(0.0, 0.0)) += *a;
                }
            }
        }
        self.state = next;
        self.prune();
        self.log.push(format!("apply_matrix {prop} {labels:?}"));
        Ok(())
    }

    /// Apply a `(dA·dB)×(dA·dB)` matrix to two properties (row index = `a*dB + b`).
    pub fn apply_matrix2(
        &mut self,
        prop_a: &str,
        labels_a: &[&str],
        prop_b: &str,
        labels_b: &[&str],
        m: &Matrix,
    ) -> Result<()> {
        let pa = self.prop_index(prop_a)?;
        let pb = self.prop_index(prop_b)?;
        if pa == pb {
            return Err(QuagmireError::Invalid(
                "two-property op needs two properties".into(),
            ));
        }
        let da = labels_a.len();
        let db = labels_b.len();
        if m.dim != da * db {
            return Err(QuagmireError::DimensionMismatch {
                got: m.dim,
                expected: da * db,
            });
        }
        let ia: Vec<usize> = labels_a
            .iter()
            .map(|l| self.label_index(prop_a, l))
            .collect::<Result<_>>()?;
        let ib: Vec<usize> = labels_b
            .iter()
            .map(|l| self.label_index(prop_b, l))
            .collect::<Result<_>>()?;
        let mut next: BTreeMap<Key, C> = BTreeMap::new();
        for (k, a) in &self.state {
            let ca = ia.iter().position(|&i| i == k.get(pa));
            let cb = ib.iter().position(|&i| i == k.get(pb));
            match (ca, cb) {
                (Some(ca), Some(cb)) => {
                    let col = ca * db + cb;
                    for (ra, &out_a) in ia.iter().enumerate() {
                        for (rb, &out_b) in ib.iter().enumerate() {
                            let v = m.get(ra * db + rb, col);
                            if v.norm() > 0.0 {
                                let nk = k.with(pa, out_a).with(pb, out_b);
                                *next.entry(nk).or_insert(C::new(0.0, 0.0)) += v * a;
                            }
                        }
                    }
                }
                _ => {
                    *next.entry(*k).or_insert(C::new(0.0, 0.0)) += *a;
                }
            }
        }
        self.state = next;
        self.prune();
        self.log.push(format!("apply_matrix2 {prop_a}×{prop_b}"));
        Ok(())
    }

    /// Multiply the amplitude of every component with `prop == label` by `phase`.
    pub fn apply_phase(&mut self, prop: &str, label: &str, phase: C) -> Result<()> {
        let pi = self.prop_index(prop)?;
        let li = self.label_index(prop, label)?;
        for (k, a) in self.state.iter_mut() {
            if k.get(pi) == li {
                *a *= phase;
            }
        }
        self.prune();
        self.log.push(format!("phase {prop}={label}"));
        Ok(())
    }

    /// Multiply every component matching `pred` by a complex factor.
    pub fn scale_where(&mut self, pred: &Pred, factor: C) -> Result<()> {
        let resolved = self.resolve_pred(pred)?;
        for (k, a) in self.state.iter_mut() {
            if Self::key_matches(*k, &resolved) {
                *a *= factor;
            }
        }
        self.prune();
        Ok(())
    }

    /// Move amplitude from `prop == from` to `prop == to` on components matching `when`
    /// (a conditional relabel; `to` is created if missing). Used for beam splitters,
    /// mirrors and detectors that route a path.
    pub fn relabel(&mut self, prop: &str, from: &str, to: &str, when: Option<&Pred>) -> Result<()> {
        let pi = self.prop_index(prop)?;
        let fi = self.label_index(prop, from)?;
        let ti = self.ensure_label(prop, to)?;
        let resolved = match when {
            Some(p) => self.resolve_pred(p)?,
            None => Vec::new(),
        };
        let mut next: BTreeMap<Key, C> = BTreeMap::new();
        for (k, a) in &self.state {
            let nk = if k.get(pi) == fi && Self::key_matches(*k, &resolved) {
                k.with(pi, ti)
            } else {
                *k
            };
            *next.entry(nk).or_insert(C::new(0.0, 0.0)) += *a;
        }
        self.state = next;
        self.prune();
        self.log.push(format!("relabel {prop} {from}→{to}"));
        Ok(())
    }

    /// Split `prop == from` into several branches: `|from⟩ ↦ Σ amp_i |to_i⟩`.
    /// If `Σ|amp|² < 1` and `lost` is given, the remainder goes to that sink label.
    pub fn split(
        &mut self,
        prop: &str,
        from: &str,
        branches: &[(&str, C)],
        lost: Option<&str>,
    ) -> Result<()> {
        let pi = self.prop_index(prop)?;
        let fi = self.label_index(prop, from)?;
        let mut targets = Vec::new();
        for (l, a) in branches {
            targets.push((self.ensure_label(prop, l)?, *a));
        }
        let total: f64 = branches.iter().map(|(_, a)| a.norm_sqr()).sum();
        if total > 1.0 + 1e-9 {
            return Err(QuagmireError::Invalid(format!(
                "split amplitudes have total probability {total} > 1"
            )));
        }
        if let Some(l) = lost {
            let rem = (1.0 - total).max(0.0).sqrt();
            let li = self.ensure_sink(prop, l)?;
            if rem > 0.0 {
                targets.push((li, C::new(rem, 0.0)));
            }
        }
        let mut next: BTreeMap<Key, C> = BTreeMap::new();
        for (k, a) in &self.state {
            if k.get(pi) == fi {
                for (ti, amp) in &targets {
                    *next.entry(k.with(pi, *ti)).or_insert(C::new(0.0, 0.0)) += amp * a;
                }
            } else {
                *next.entry(*k).or_insert(C::new(0.0, 0.0)) += *a;
            }
        }
        self.state = next;
        self.prune();
        self.log.push(format!("split {prop} {from}→{branches:?}"));
        Ok(())
    }

    /// Project the two live labels of a property onto the unit vector `axis`
    /// (components over `live[0]`, `live[1]`) and send the orthogonal component to the
    /// `sink` label. Norm is preserved. This is a polarizer in the site's `|lost⟩` form.
    ///
    /// `sink_axis` fixes the (physically irrelevant) phase of the sink amplitude: the sink
    /// receives `⟨sink_axis|ψ⟩`. It must be a unit vector orthogonal to `axis`; `None`
    /// uses `(-conj(axis[1]), conj(axis[0]))`.
    pub fn project_or_sink(
        &mut self,
        prop: &str,
        live: [&str; 2],
        axis: [C; 2],
        sink_axis: Option<[C; 2]>,
        sink: &str,
        when: Option<&Pred>,
    ) -> Result<()> {
        let n = (axis[0].norm_sqr() + axis[1].norm_sqr()).sqrt();
        if (n - 1.0).abs() > 1e-9 {
            return Err(QuagmireError::Invalid(
                "projection axis must be a unit vector".into(),
            ));
        }
        let (u0, u1) = (axis[0], axis[1]);
        let w = sink_axis.unwrap_or([-u1.conj(), u0.conj()]);
        let wn = (w[0].norm_sqr() + w[1].norm_sqr()).sqrt();
        let dot = u0.conj() * w[0] + u1.conj() * w[1];
        if (wn - 1.0).abs() > 1e-9 || dot.norm() > 1e-9 {
            return Err(QuagmireError::Invalid(
                "sink axis must be a unit vector orthogonal to the projection axis".into(),
            ));
        }
        self.ensure_sink(prop, sink)?;
        // output along u: u ⟨u|ψ⟩ ; sink: ⟨w|ψ⟩
        let zero = C::new(0.0, 0.0);
        let m = Matrix::from_complex(&[
            &[u0 * u0.conj(), u0 * u1.conj(), zero],
            &[u1 * u0.conj(), u1 * u1.conj(), zero],
            &[w[0].conj(), w[1].conj(), zero],
        ]);
        self.apply_matrix(prop, &[live[0], live[1], sink], &m, when)
    }

    /// Keep only the components whose key satisfies `f` (no renormalisation).
    pub(crate) fn retain_keys(&mut self, f: impl Fn(Key) -> bool) {
        self.state.retain(|k, _| f(*k));
    }

    // ------------------------------------------------------------------ queries

    /// Total probability of components matching `pred`.
    pub fn probability(&self, pred: &Pred) -> Result<f64> {
        let resolved = self.resolve_pred(pred)?;
        Ok(self
            .state
            .iter()
            .filter(|(k, _)| Self::key_matches(**k, &resolved))
            .map(|(_, a)| a.norm_sqr())
            .sum())
    }

    /// Probability of each label of `prop` (in label order).
    pub fn marginals(&self, prop: &str) -> Result<Vec<(String, f64)>> {
        let pi = self.prop_index(prop)?;
        let labels = &self.props[pi].labels;
        let mut out = vec![0.0; labels.len()];
        for (k, a) in &self.state {
            out[k.get(pi)] += a.norm_sqr();
        }
        Ok(labels.iter().cloned().zip(out).collect())
    }

    /// Zero every component that does not match `pred` (no renormalisation).
    pub fn project(&mut self, pred: &Pred) -> Result<()> {
        let resolved = self.resolve_pred(pred)?;
        self.state.retain(|k, _| Self::key_matches(*k, &resolved));
        self.log.push(format!("project {pred:?}"));
        Ok(())
    }

    /// Post-select on `pred` and renormalise; returns the conditional system.
    pub fn conditional(&self, pred: &Pred) -> Result<System> {
        let mut s = self.clone();
        s.project(pred)?;
        s.normalize()?;
        Ok(s)
    }

    /// Group amplitudes by "everything except `prop`": returns, for each environment
    /// key (with `prop` cleared), the amplitudes indexed by label of `prop`.
    pub fn group_by_environment(&self, prop: &str) -> Result<Vec<(Key, Vec<C>)>> {
        let pi = self.prop_index(prop)?;
        let d = self.props[pi].labels.len();
        let mut groups: BTreeMap<Key, Vec<C>> = BTreeMap::new();
        for (k, a) in &self.state {
            let env = k.without(pi);
            let row = groups
                .entry(env)
                .or_insert_with(|| vec![C::new(0.0, 0.0); d]);
            row[k.get(pi)] += *a;
        }
        Ok(groups.into_iter().collect())
    }

    // ------------------------------------------------------------------ measurement

    /// Uniform `f64` in `[0, 1)` from the system's RNG.
    pub fn uniform(&mut self) -> f64 {
        (self.rng.next_u64() >> 11) as f64 / (1u64 << 53) as f64
    }

    /// Born-rule measurement of `prop`: samples a label, collapses and renormalises.
    pub fn measure(&mut self, prop: &str) -> Result<String> {
        let marg = self.marginals(prop)?;
        let total: f64 = marg.iter().map(|(_, p)| p).sum();
        if total <= 0.0 {
            return Err(QuagmireError::ZeroNorm);
        }
        let r = self.uniform() * total;
        let mut acc = 0.0;
        let mut chosen = marg.len() - 1;
        for (i, (_, p)) in marg.iter().enumerate() {
            acc += p;
            if r < acc {
                chosen = i;
                break;
            }
        }
        let label = marg[chosen].0.clone();
        self.force(prop, &label)?;
        Ok(label)
    }

    /// Collapse `prop` onto `label` (forced outcome) and renormalise.
    pub fn force(&mut self, prop: &str, label: &str) -> Result<()> {
        self.project(&Pred::is(prop, label))?;
        self.normalize()?;
        self.log.push(format!("measure {prop} -> {label}"));
        Ok(())
    }

    /// Sample `n` outcomes of `prop` without collapsing the state.
    pub fn sample(&mut self, prop: &str, n: usize) -> Result<Vec<String>> {
        let marg = self.marginals(prop)?;
        let total: f64 = marg.iter().map(|(_, p)| p).sum();
        if total <= 0.0 {
            return Err(QuagmireError::ZeroNorm);
        }
        let mut out = Vec::with_capacity(n);
        for _ in 0..n {
            let r = self.uniform() * total;
            let mut acc = 0.0;
            let mut chosen = marg.len() - 1;
            for (i, (_, p)) in marg.iter().enumerate() {
                acc += p;
                if r < acc {
                    chosen = i;
                    break;
                }
            }
            out.push(marg[chosen].0.clone());
        }
        Ok(out)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use approx::assert_abs_diff_eq;

    #[test]
    fn add_property_tensors_with_first_label() {
        let mut s = System::new();
        s.add_property("pol", &["H", "V"]).unwrap();
        s.add_property("path", &["S", "A", "B"]).unwrap();
        let amps = s.amplitudes();
        assert_eq!(amps.len(), 1);
        assert_eq!(amps[0].0, vec!["H", "S"]);
        assert_abs_diff_eq!(s.norm(), 1.0);
    }

    #[test]
    fn split_and_marginals() {
        let mut s = System::new();
        s.add_property("path", &["S"]).unwrap();
        let a = C::new(crate::INV_SQRT2, 0.0);
        s.split("path", "S", &[("A", a), ("B", a)], None).unwrap();
        let m = s.marginals("path").unwrap();
        assert_abs_diff_eq!(m[1].1, 0.5, epsilon = 1e-12);
        assert_abs_diff_eq!(m[2].1, 0.5, epsilon = 1e-12);
        assert_abs_diff_eq!(s.probability(&Pred::is("path", "S")).unwrap(), 0.0);
    }

    #[test]
    fn measurement_is_deterministic_for_a_seed() {
        let mut a = System::with_seed(7);
        a.add_property("q", &["0", "1"]).unwrap();
        a.apply_matrix(
            "q",
            &["0", "1"],
            &Matrix::from_real(&[
                &[crate::INV_SQRT2, crate::INV_SQRT2],
                &[crate::INV_SQRT2, -crate::INV_SQRT2],
            ]),
            None,
        )
        .unwrap();
        let mut b = a.clone();
        assert_eq!(a.sample("q", 50).unwrap(), b.sample("q", 50).unwrap());
    }
}
