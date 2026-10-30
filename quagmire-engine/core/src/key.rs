//! Packed basis-state keys.
//!
//! A [`Key`] stores one label index per property, 8 bits each, in a `u128`.
//! That allows up to [`Key::MAX_PROPS`] properties with up to 256 labels each, which is
//! far more than game-scale registers need, while keeping keys `Copy`, `Ord` and cheap.

/// Packed label indices for every property of a [`crate::System`].
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Debug, Default)]
pub struct Key(u128);

impl Key {
    /// Maximum number of properties a system can hold.
    pub const MAX_PROPS: usize = 16;
    /// Maximum number of labels per property (including sinks).
    pub const MAX_LABELS: usize = 256;

    /// A key with every property set to label index 0.
    pub const ZERO: Key = Key(0);

    /// Label index of property `prop`.
    #[inline]
    pub fn get(self, prop: usize) -> usize {
        ((self.0 >> (8 * prop)) & 0xff) as usize
    }

    /// Copy of this key with property `prop` set to `label`.
    #[inline]
    pub fn with(self, prop: usize, label: usize) -> Key {
        debug_assert!(prop < Self::MAX_PROPS && label < Self::MAX_LABELS);
        let shift = 8 * prop;
        Key((self.0 & !(0xffu128 << shift)) | ((label as u128) << shift))
    }

    /// Copy of this key with property `prop` cleared (index 0), used to group
    /// amplitudes by "everything except `prop`".
    #[inline]
    pub fn without(self, prop: usize) -> Key {
        self.with(prop, 0)
    }

    /// Remove property `prop` entirely, shifting higher properties down one slot.
    pub fn remove_slot(self, prop: usize) -> Key {
        let shift = 8 * prop;
        let low = self.0 & ((1u128 << shift) - 1);
        let high = (self.0 >> (shift + 8)) << shift;
        Key(low | high)
    }

    /// Build a key from explicit per-property indices.
    pub fn from_indices(idx: &[usize]) -> Key {
        idx.iter()
            .enumerate()
            .fold(Key::ZERO, |k, (p, &i)| k.with(p, i))
    }

    /// Per-property indices for the first `n` properties.
    pub fn to_indices(self, n: usize) -> Vec<usize> {
        (0..n).map(|p| self.get(p)).collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn roundtrip() {
        let k = Key::from_indices(&[3, 0, 255, 7]);
        assert_eq!(k.to_indices(4), vec![3, 0, 255, 7]);
        assert_eq!(k.with(1, 9).get(1), 9);
        assert_eq!(k.without(2).get(2), 0);
        assert_eq!(k.remove_slot(1).to_indices(3), vec![3, 255, 7]);
        assert_eq!(k.remove_slot(0).to_indices(3), vec![0, 255, 7]);
    }
}
