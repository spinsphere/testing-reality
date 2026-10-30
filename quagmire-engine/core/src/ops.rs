//! Operators and predicates.

use crate::C;

/// A dense square matrix in row-major order: `m[row][col]`.
///
/// Matrices act on a chosen subset of a property's labels (the *live* labels), with
/// identity on every other label of that property. They need not be unitary — the
/// polarizer-with-sink construction is an isometry onto a larger space.
#[derive(Clone, Debug, PartialEq)]
pub struct Matrix {
    pub dim: usize,
    pub data: Vec<C>,
}

impl Matrix {
    pub fn zeros(dim: usize) -> Self {
        Matrix {
            dim,
            data: vec![C::new(0.0, 0.0); dim * dim],
        }
    }

    pub fn identity(dim: usize) -> Self {
        let mut m = Self::zeros(dim);
        for i in 0..dim {
            m.set(i, i, C::new(1.0, 0.0));
        }
        m
    }

    /// Build from rows of real numbers.
    pub fn from_real(rows: &[&[f64]]) -> Self {
        let dim = rows.len();
        let mut m = Self::zeros(dim);
        for (r, row) in rows.iter().enumerate() {
            assert_eq!(row.len(), dim, "matrix must be square");
            for (c, v) in row.iter().enumerate() {
                m.set(r, c, C::new(*v, 0.0));
            }
        }
        m
    }

    /// Build from rows of complex numbers.
    pub fn from_complex(rows: &[&[C]]) -> Self {
        let dim = rows.len();
        let mut m = Self::zeros(dim);
        for (r, row) in rows.iter().enumerate() {
            assert_eq!(row.len(), dim, "matrix must be square");
            for (c, v) in row.iter().enumerate() {
                m.set(r, c, *v);
            }
        }
        m
    }

    #[inline]
    pub fn get(&self, row: usize, col: usize) -> C {
        self.data[row * self.dim + col]
    }

    #[inline]
    pub fn set(&mut self, row: usize, col: usize, v: C) {
        self.data[row * self.dim + col] = v;
    }

    /// Conjugate transpose.
    pub fn adjoint(&self) -> Matrix {
        let mut m = Matrix::zeros(self.dim);
        for r in 0..self.dim {
            for c in 0..self.dim {
                m.set(c, r, self.get(r, c).conj());
            }
        }
        m
    }

    /// `self * other`.
    pub fn mul(&self, other: &Matrix) -> Matrix {
        assert_eq!(self.dim, other.dim);
        let mut m = Matrix::zeros(self.dim);
        for r in 0..self.dim {
            for c in 0..self.dim {
                let mut s = C::new(0.0, 0.0);
                for k in 0..self.dim {
                    s += self.get(r, k) * other.get(k, c);
                }
                m.set(r, c, s);
            }
        }
        m
    }

    /// Largest deviation of `M†M` from the identity.
    pub fn unitarity_error(&self) -> f64 {
        let p = self.adjoint().mul(self);
        let mut err: f64 = 0.0;
        for r in 0..self.dim {
            for c in 0..self.dim {
                let expect = if r == c { 1.0 } else { 0.0 };
                err = err.max((p.get(r, c) - C::new(expect, 0.0)).norm());
            }
        }
        err
    }

    /// Kronecker product `self ⊗ other` (row-major, `self` is the slow index).
    pub fn kron(&self, other: &Matrix) -> Matrix {
        let d = self.dim * other.dim;
        let mut m = Matrix::zeros(d);
        for a in 0..self.dim {
            for b in 0..self.dim {
                for c in 0..other.dim {
                    for e in 0..other.dim {
                        m.set(
                            a * other.dim + c,
                            b * other.dim + e,
                            self.get(a, b) * other.get(c, e),
                        );
                    }
                }
            }
        }
        m
    }
}

/// One clause of a [`Pred`].
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Clause {
    /// `prop == label`
    Is(String),
    /// `prop != label`
    IsNot(String),
    /// `prop` is not in any sink (`|lost⟩`) label.
    NotLost,
}

/// A clause bound to a property name.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct PredTerm {
    pub prop: String,
    pub clause: Clause,
}

/// A conjunction of clauses over the properties of a system.
///
/// Used for post-selection (coincidence conditions), conditional operators
/// (polarizing beam splitters, a polarizer covering one slit) and probability queries.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Pred {
    pub terms: Vec<PredTerm>,
}

impl Pred {
    /// The always-true predicate.
    pub fn all() -> Self {
        Pred::default()
    }

    pub fn is(prop: &str, label: &str) -> Self {
        Pred::all().and_is(prop, label)
    }

    pub fn is_not(prop: &str, label: &str) -> Self {
        Pred::all().and_is_not(prop, label)
    }

    /// `prop` is not in a sink label (the photon was not lost on that property).
    pub fn alive(prop: &str) -> Self {
        Pred::all().and_alive(prop)
    }

    pub fn and_is(mut self, prop: &str, label: &str) -> Self {
        self.terms.push(PredTerm {
            prop: prop.into(),
            clause: Clause::Is(label.into()),
        });
        self
    }

    pub fn and_is_not(mut self, prop: &str, label: &str) -> Self {
        self.terms.push(PredTerm {
            prop: prop.into(),
            clause: Clause::IsNot(label.into()),
        });
        self
    }

    pub fn and_alive(mut self, prop: &str) -> Self {
        self.terms.push(PredTerm {
            prop: prop.into(),
            clause: Clause::NotLost,
        });
        self
    }

    pub fn is_empty(&self) -> bool {
        self.terms.is_empty()
    }
}
