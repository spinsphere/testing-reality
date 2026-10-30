//! Human-readable ket strings (Unicode and LaTeX), with "nice" amplitudes such as `1/√2`.

use crate::system::System;
use crate::C;

/// Output flavour for [`System::ket_string`].
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum KetStyle {
    /// `1/√2 |H⟩|A⟩ + …`
    Unicode,
    /// `\frac{1}{\sqrt{2}}\ket{H}\ket{A} + …`
    Latex,
}

/// Try to write `x ≥ 0` as `√(p/q)` with small integers; returns (p, q) if found.
fn nice_sqrt_fraction(x: f64) -> Option<(u32, u32)> {
    let x2 = x * x;
    for q in 1..=64u32 {
        let p = (x2 * q as f64).round();
        if p >= 0.0 && ((p / q as f64) - x2).abs() < 1e-9 {
            return Some((p as u32, q));
        }
    }
    None
}

/// Split `n = b²·r` with `r` square-free; returns `(b, r)`.
fn sqrt_factor(n: u32) -> (u32, u32) {
    let mut b = 1;
    let mut r = n;
    let mut d = 2;
    while d * d <= r {
        while r.is_multiple_of(d * d) {
            r /= d * d;
            b *= d;
        }
        d += 1;
    }
    (b, r)
}

/// `√n` as a string: `"2√2"`, `"√3"`, `"2"`, or `""` for 1.
fn sqrt_str(n: u32, style: KetStyle) -> String {
    let (b, r) = sqrt_factor(n);
    let root = match (r, style) {
        (1, _) => String::new(),
        (_, KetStyle::Unicode) => format!("√{r}"),
        (_, KetStyle::Latex) => format!("\\sqrt{{{r}}}"),
    };
    match (b, root.is_empty()) {
        (1, true) => String::new(),
        (1, false) => root,
        (_, true) => format!("{b}"),
        (_, false) => format!("{b}{root}"),
    }
}

/// Format a non-negative magnitude nicely (`1/√2`, `1/(2√2)`, `√3/2`, `√(2/3)`…).
pub fn format_magnitude(x: f64, style: KetStyle) -> String {
    if (x - 1.0).abs() < 1e-9 {
        return String::new();
    }
    if let Some((p, q)) = nice_sqrt_fraction(x) {
        let num = sqrt_str(p, style);
        let den = sqrt_str(q, style);
        let (bn, rn) = sqrt_factor(p);
        let (bd, rd) = sqrt_factor(q);
        // Both square-free parts present and different: write √(p/q).
        if rn != 1 && rd != 1 && rn != rd {
            return match style {
                KetStyle::Unicode => format!("√({p}/{q})"),
                KetStyle::Latex => format!("\\sqrt{{\\tfrac{{{p}}}{{{q}}}}}"),
            };
        }
        if rn != 1 && rd != 1 {
            // same radical top and bottom: cancels to bn/bd
            return format_magnitude(bn as f64 / bd as f64, style);
        }
        let num = if num.is_empty() { "1".to_string() } else { num };
        if den.is_empty() {
            return num;
        }
        return match style {
            KetStyle::Unicode => {
                if bd > 1 && rd != 1 {
                    format!("{num}/({den})")
                } else {
                    format!("{num}/{den}")
                }
            }
            KetStyle::Latex => format!("\\tfrac{{{num}}}{{{den}}}"),
        };
    }
    format!("{x:.3}")
}

/// Format a complex amplitude as `[sign][magnitude][phase]`; `leading` controls whether a
/// positive sign is omitted.
pub fn format_amplitude(a: C, style: KetStyle, leading: bool) -> String {
    let mag = a.norm();
    let phase = a.arg();
    let deg = phase.to_degrees();
    let (sign, phase_str) = if deg.abs() < 1e-6 {
        ("+", String::new())
    } else if (deg.abs() - 180.0).abs() < 1e-6 {
        ("-", String::new())
    } else if (deg - 90.0).abs() < 1e-6 {
        ("+", "i".to_string())
    } else if (deg + 90.0).abs() < 1e-6 {
        ("-", "i".to_string())
    } else {
        let p = match style {
            KetStyle::Unicode => format!("e^(i{:.0}°)", deg),
            KetStyle::Latex => format!("e^{{i{:.0}^\\circ}}", deg),
        };
        ("+", p)
    };
    let m = format_magnitude(mag, style);
    let body = match (m.is_empty(), phase_str.is_empty()) {
        (true, true) => String::new(),
        (true, false) => phase_str,
        (false, true) => m,
        (false, false) => format!("{m}{phase_str}"),
    };
    let sign_str = match (leading, sign) {
        (true, "+") => "".to_string(),
        (true, "-") => "−".to_string(),
        (false, "+") => " + ".to_string(),
        _ => " − ".to_string(),
    };
    if style == KetStyle::Latex && !leading {
        let s = if sign == "+" { " + " } else { " - " };
        return format!("{s}{body}");
    }
    if style == KetStyle::Latex && sign == "-" {
        return format!("-{body}");
    }
    format!("{sign_str}{body}")
}

impl System {
    /// Render the state as a sum of kets. `label_map` can translate labels (e.g. `"H"`
    /// → `"\\leftrightarrow"` for LaTeX); properties are shown in order, one ket each.
    pub fn ket_string(&self, style: KetStyle, label_map: &dyn Fn(&str, &str) -> String) -> String {
        let mut out = String::new();
        let mut first = true;
        for (labels, amp) in self.amplitudes() {
            out.push_str(&format_amplitude(amp, style, first));
            let needs_space = !out.is_empty() && !out.ends_with(' ');
            if needs_space && style == KetStyle::Unicode {
                out.push(' ');
            }
            for (p, l) in labels.iter().enumerate() {
                let name = &self.properties()[p].name;
                let text = label_map(name, l);
                match style {
                    KetStyle::Unicode => out.push_str(&format!("|{text}⟩")),
                    KetStyle::Latex => out.push_str(&format!("\\ket{{{text}}}")),
                }
            }
            first = false;
        }
        if out.is_empty() {
            "0".into()
        } else {
            out
        }
    }

    /// Unicode ket string with raw labels.
    pub fn ket_text(&self) -> String {
        self.ket_string(KetStyle::Unicode, &|_, l| l.to_string())
    }

    /// LaTeX ket string with raw labels.
    pub fn ket_latex(&self) -> String {
        self.ket_string(KetStyle::Latex, &|_, l| l.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn nice_magnitudes() {
        assert_eq!(
            format_magnitude(std::f64::consts::FRAC_1_SQRT_2, KetStyle::Unicode),
            "1/√2"
        );
        assert_eq!(format_magnitude(0.5, KetStyle::Unicode), "1/2");
        assert_eq!(
            format_magnitude(3f64.sqrt() / 2.0, KetStyle::Unicode),
            "√3/2"
        );
        assert_eq!(
            format_magnitude(1.0 / (2.0 * 2f64.sqrt()), KetStyle::Unicode),
            "1/(2√2)"
        );
        assert_eq!(format_magnitude(0.25, KetStyle::Unicode), "1/4");
        assert_eq!(format_magnitude(2f64.sqrt(), KetStyle::Unicode), "√2");
        assert_eq!(
            format_magnitude(1.0 / (2.0 * 2f64.sqrt()), KetStyle::Latex),
            "\\tfrac{1}{2\\sqrt{2}}"
        );
        assert_eq!(
            format_magnitude((2.0f64 / 3.0).sqrt(), KetStyle::Unicode),
            "√(2/3)"
        );
        assert_eq!(format_magnitude(0.5, KetStyle::Latex), "\\tfrac{1}{2}");
    }

    #[test]
    fn ket_text_three_polarizer_state() {
        let mut s = System::new();
        s.add_property("pol", &["↔", "↕"]).unwrap();
        s.half_wave_plate("pol", ["↔", "↕"], std::f64::consts::FRAC_PI_8)
            .unwrap();
        assert_eq!(s.ket_text(), "1/√2 |↔⟩ + 1/√2 |↕⟩");
    }
}
