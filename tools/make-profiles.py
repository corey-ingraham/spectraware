#!/usr/bin/env python3
"""tools/make-profiles.py - write the generated SpectraWare profiles in profiles/.

    python3 -I tools/make-profiles.py [--check]

Template: profiles/wifi-2g4.json (a real File -> Save Settings from SpectraWare). Each row below changes
only the frequency range, markers and traces; center, span, axis and Channel Power range are derived.
The wifi-* files are real saves and are not generated. --check writes nothing and exits 1 if any
generated file on disk differs from what this script would write.
Naming: <signal>-<band>[-<region>].json - see docs/signals.md.
"""
import copy
import json
import pathlib
import sys

PROFILES = pathlib.Path(__file__).resolve().parent.parent / "profiles"
TEMPLATE = PROFILES / "wifi-2g4.json"

# name, start MHz, stop MHz, markers (list of MHz, or "peak" = one continuous-peak marker), average trace on
ROWS = [
    ("bluetooth-2g4", 2400, 2484, [2402, 2426, 2480], False),
    ("zigbee-2g4", 2400, 2485, [2425, 2450, 2475, 2480], False),
    ("fm-broadcast", 87.5, 108, "peak", True),
    ("remotes-315-us", 310, 320, [315], False),
    ("remotes-433", 430, 440, [433.92], False),
    ("iot-868-eu", 863, 870, [868.1, 868.42, 869.85], False),
    ("iot-915-us", 902, 928, [908.42, 916], False),
    ("adsb-1090", 1085, 1095, [1090], False),
    ("dect-1900-eu", 1880, 1900, "peak", False),
    ("dect-1920-us", 1920, 1930, "peak", False),
    ("cellular-low", 600, 960, "peak", True),
    ("cellular-mid", 1700, 2700, "peak", True),
    ("cellular-cband", 3300, 4200, "peak", True),
    ("fpv-5g8", 5645, 5945, "peak", False),
]


def num(x):
    """5.0 -> 5, keep 87.5; matches how SpectraWare writes whole numbers."""
    return int(x) if float(x).is_integer() else x


def build(template, start, stop, markers, average):
    d = copy.deepcopy(template)
    center = num((start + stop) / 2)
    s = d["specSettings"]
    s.update(start=num(start), stop=num(stop), span=num(stop - start), center=center)
    t = d["tracesOptions"]["2"]  # Trace 3: Average when the signal is continuous, else off
    t["status"], t["type"] = ("active", 3) if average else ("off", 0)
    peak = markers == "peak"
    freqs = [center] if peak else markers
    if len(freqs) > len(d["markersOptions"]):
        raise SystemExit(f"too many markers: {freqs}")
    for i, m in d["markersOptions"].items():
        i = int(i)
        if i < len(freqs):
            m.update(mode="normal", trace=1, freq=num(freqs[i]), contPeakChecked=peak)
        else:
            # Unused: keep the template's frequency if it is in range (as bluetooth.json always had),
            # else park it at the center so turning it on doesn't jump off-screen.
            freq = m["freq"] if start <= m["freq"] <= stop else center
            m.update(mode="off", trace=0, freq=freq, contPeakChecked=False)
    d["channelPowerOptions"].update(startFreq=num(start), stopFreq=num(stop))
    d["freqAxisInfo"].update(min=int(start * 1e6), max=int(stop * 1e6))
    return json.dumps(d, separators=(",", ":"))  # SpectraWare's format: compact, no trailing newline


def main():
    check = sys.argv[1:] == ["--check"]
    template = json.loads(TEMPLATE.read_text())
    stale = []
    for name, start, stop, markers, average in ROWS:
        path = PROFILES / f"{name}.json"
        text = build(template, start, stop, markers, average)
        if check:
            if not path.exists() or path.read_text() != text:
                stale.append(path.name)
        else:
            path.write_text(text)
    if stale:
        print("out of date (run tools/make-profiles.py):", *stale)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
