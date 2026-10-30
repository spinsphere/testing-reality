#!/usr/bin/env python3
"""Summarise the lab CSV files under app/data/lab.

Run with:  python3 -I tools/labdata/summarise.py [path ...]

Each site CSV has one free-text description line, one header line, then
numeric rows.  For every file this prints the description, the header, the
number of data rows and the min/max of each numeric column.  For scan files
(those with a detector-position column) it also prints the position range and
step, the number of distinct positions, and the peak count rate per detector
column, converted to counts per second using the acquisition time stated in
the description line.

Only the standard library is used; the CSVs are treated as untrusted data.
"""
from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DIR = ROOT / "app" / "data" / "lab"

POSITION_NAMES = ("pos", "position", "all distance")
RATE_HINT = re.compile(r"per\s+se", re.IGNORECASE)          # "per second(s)" (and the site's typos)
COUNT_HINT = re.compile(r"count|coin|\bd1|\bd2|d1d2", re.IGNORECASE)
ACQ_RE = re.compile(r"(\d+(?:\.\d+)?)\s*second", re.IGNORECASE)
SWEEP_COL = re.compile(r"^Sweep_\d+\s+(D1D2|D1|D2)\b", re.IGNORECASE)


def to_float(cell: str) -> float | None:
    cell = cell.strip()
    if not cell:
        return None
    try:
        return float(cell)
    except ValueError:
        return None


def load(path: Path):
    with path.open(newline="", encoding="utf-8", errors="replace") as fh:
        rows = list(csv.reader(fh))
    rows = [r for r in rows if any(c.strip() for c in r)]
    description = " ".join(c for c in rows[0] if c.strip()).strip()
    header = [h.strip().lstrip("#").strip() for h in rows[1]]
    # Some site files have more data columns than header names (trailing
    # commas in the header line); give those columns a visible placeholder.
    for i, h in enumerate(header):
        if h:
            continue
        prev = SWEEP_COL.match(header[i - 3]) if i >= 3 else None
        if prev:   # continue the "Sweep_n D1 / D2 / D1D2" triplet pattern
            n = int(re.search(r"\d+", header[i - 3]).group()) + 1
            header[i] = f"Sweep_{n} {prev.group(1)} (unnamed in file)"
        else:
            header[i] = f"col{i + 1} (unnamed)"
    data = []
    for r in rows[2:]:
        vals = [to_float(c) for c in r[: len(header)]]
        if any(v is not None for v in vals):
            data.append(vals + [None] * (len(header) - len(vals)))
    return description, header, data


def column(data, i):
    return [row[i] for row in data if row[i] is not None]


def fmt(x: float) -> str:
    return f"{x:g}"


def summarise(path: Path) -> None:
    description, header, data = load(path)
    acq = ACQ_RE.search(description)
    acq_s = float(acq.group(1)) if acq else None

    print(f"\n### {path.relative_to(ROOT)}")
    print(f"description : {description}")
    print(f"acquisition : {fmt(acq_s) + ' s per point' if acq_s else 'not stated'}")
    print(f"columns     : {len(header)}   data rows: {len(data)}")
    print("| column | min | max |")
    print("|---|---|---|")
    for i, name in enumerate(header):
        col = column(data, i)
        if col:
            print(f"| {name} | {fmt(min(col))} | {fmt(max(col))} |")
        else:
            print(f"| {name} | (empty) | (empty) |")

    pos_idx = [i for i, h in enumerate(header) if h.lower() in POSITION_NAMES
               or h.lower().startswith("position")]
    if not pos_idx:
        return
    pos = sorted(set(column(data, pos_idx[0])))
    if len(pos) < 2:
        return
    steps = sorted({round(b - a, 3) for a, b in zip(pos, pos[1:])})
    print(f"scan        : {header[pos_idx[0]]} from {fmt(pos[0])} to {fmt(pos[-1])} um, "
          f"{len(pos)} distinct positions, step {', '.join(fmt(s) for s in steps[:4])}"
          f"{' ...' if len(steps) > 4 else ''}, "
          f"{len(data) / len(pos):.1f} rows per position")

    # Count columns, grouped by detector so that wide "Sweep_n D1" files
    # report one figure per detector instead of one per sweep.
    groups: dict[str, list[int]] = {}
    for i, name in enumerate(header):
        if i in pos_idx or not COUNT_HINT.search(name):
            continue
        m = SWEEP_COL.match(name)
        key = m.group(1) + " (all sweeps)" if m else name
        groups.setdefault(key, []).append(i)
    if not groups:
        return

    def rate(x: float, name: str) -> str:
        if RATE_HINT.search(name):
            return f"{x:.3g} /s"
        if acq_s:
            return f"{x:.3g} in {fmt(acq_s)} s = {x / acq_s:.3g} /s"
        return f"{x:.3g} (raw)"

    single, averaged = [], []
    for key, idxs in groups.items():
        samples = [v for i in idxs for v in column(data, i)]
        if not samples:
            continue
        single.append(f"{key}: {rate(max(samples), key)}")
        # Mean per position over every sample/sweep, then take the peak.
        per_pos: dict[float, list[float]] = {}
        for row in data:
            p = row[pos_idx[0]]
            if p is None:
                continue
            for i in idxs:
                if row[i] is not None:
                    per_pos.setdefault(p, []).append(row[i])
        best = max((sum(v) / len(v), p) for p, v in per_pos.items())
        averaged.append(f"{key}: {rate(best[0], key)} at {fmt(best[1])} um")
    print("peak sample : " + "; ".join(single))
    print("peak of mean profile : " + "; ".join(averaged))


def main(argv: list[str]) -> int:
    targets = [Path(a) for a in argv] or [DEFAULT_DIR]
    files: list[Path] = []
    for t in targets:
        files += sorted(t.rglob("*.csv")) if t.is_dir() else [t]
    if not files:
        print("no CSV files found", file=sys.stderr)
        return 1
    print(f"# Lab CSV summary ({len(files)} files)")
    for f in files:
        summarise(f)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
