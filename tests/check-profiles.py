#!/usr/bin/env python3
"""tests/check-profiles.py - sanity-check every SpectraWare profile in profiles/ (or the files given).

    python3 -I tests/check-profiles.py [file.json ...]

Checks: valid JSON; name is <signal>-<band>[-<region>].json; start < stop inside the R6000's
9 kHz - 8 GHz; span and center agree with start/stop; the frequency axis stays inside the range; every
marker (on or off) is inside the range. Tolerances allow for the float noise in real SpectraWare saves.
"""
import json
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
NAME = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*\.json$")
REGIONS = {"us", "eu"}  # a trailing 2-letter part must be one of these
F_MIN, F_MAX = 0.009, 8000  # MHz, datasheet
TOL = 0.001  # MHz (1 kHz)
AXIS_TOL = 0.05  # MHz; real saves store the axis as float32, ~20 kHz off at 7 GHz


def problems(path):
    out = []
    if not NAME.match(path.name):
        out.append("name is not <signal>-<band>[-<region>].json, lowercase")
    last = path.stem.split("-")[-1]
    if len(last) == 2 and last.isalpha() and last not in REGIONS:
        out.append(f"unknown region suffix '{last}' (known: {', '.join(sorted(REGIONS))})")
    try:
        d = json.loads(path.read_text())
        s = d["specSettings"]
        start, stop, span, center = s["start"], s["stop"], s["span"], s["center"]
        ax = d["freqAxisInfo"]
        markers = d["markersOptions"].values()
    except (ValueError, KeyError, TypeError) as e:
        return out + [f"not a SpectraWare settings file: {e!r}"]
    if not F_MIN <= start < stop <= F_MAX:
        out.append(f"range {start}-{stop} MHz not inside {F_MIN}-{F_MAX} MHz")
    if abs(span - (stop - start)) > TOL:
        out.append(f"span {span} != stop - start ({stop - start})")
    if abs(center - (start + stop) / 2) > TOL:
        out.append(f"center {center} != middle of range ({(start + stop) / 2})")
    lo, hi = ax["min"] / 1e6, ax["max"] / 1e6
    if not (start - AXIS_TOL <= lo < hi <= stop + AXIS_TOL):
        out.append(f"frequency axis {lo}-{hi} MHz outside range {start}-{stop}")
    for m in markers:  # off markers too: turning one on must not jump off-screen
        if not start <= m["freq"] <= stop:
            out.append(f"{'off' if m['mode'] == 'off' else 'active'} marker at {m['freq']} MHz outside range")
    return out


def main():
    files = [pathlib.Path(a) for a in sys.argv[1:]] or sorted((REPO / "profiles").glob("*.json"))
    if not files:
        print("no profiles found")
        return 1
    bad = 0
    for f in files:
        for p in problems(f):
            print(f"{f.name}: {p}")
            bad += 1
    print(f"{len(files)} profiles, {bad} problems")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
