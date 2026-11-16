# Wi-Fi and Bluetooth monitoring with SpectraWare

How to set up SpectraWare (R6000, 9 kHz–8 GHz, 100 MHz instantaneous bandwidth) to watch the 2.4, 5 and
6 GHz Wi-Fi bands, and save each setup as a profile you can reload.

## Profiles: save once, load any time

- **File → Save Settings** writes the current Spectrum Viewer setup to a `.json` file (default name
  `spectraware-config-<model>-<date>.json`; rename it, e.g. `wifi-2g4.json`). It holds frequency/span, RBW,
  reference level, scale, open panels, trace modes, markers, Channel Power and Occupied Bandwidth setups.
  Not saved: the spectrogram color-bar slider positions.
- **File → Load Settings** restores one. Needs: device connected, **Spectrum Viewer** tab selected, a file
  saved from the same model.
- The orange **Preset** button resets to factory defaults; it does not load your profiles.
- **Ready-made profiles are in [`profiles/`](../profiles/)** in this repo: **File → Load Settings** → open
  `<repo>/profiles/` → pick one. They load on any R6000. Load one, then adjust and save your own copy.

## The profiles

| File | Start → Stop (MHz) | Center / Span (MHz) | Notes |
|---|---|---|---|
| `wifi-2g4.json` | 2390 → 2490 | 2440 / 100 | fits the 100 MHz IBW: one capture, no sweep, catches every burst |
| `wifi-5g.json` | 5150 → 5900 | 5525 / 750 | swept |
| `wifi-6g.json` | 5925 → 7125 | 6525 / 1200 | swept; only Wi-Fi 6E/7 devices transmit here |
| `wifi-all.json` | 2390 → 7125 | 4757.5 / 4735 | swept, slowest refresh; overview, then switch to one band |
| `bluetooth.json` | 2400 → 2484 | 2442 / 84 | one capture; markers on the BLE advertising channels — see [Bluetooth](#bluetooth) |

Build `wifi-2g4` first (below), save it, then change only Start/Stop and **Save Settings** under each new
name. Everything else carries over.

## Settings for every profile

Wi-Fi transmits in short bursts, so a plain live trace looks like noise. Set:

| Setting | Value | Why |
|---|---|---|
| Trace 1 | Active, **Normal** | live view |
| Trace 2 | Active, **Max. Hold** | builds up each channel's shape; **Reset Trace** to start over |
| Trace 3 | Active, **Average** | how *busy* each channel is: a loaded channel rises clearly, a beacon-only one barely moves — use it to pick a quiet channel |
| Markers (2.4 GHz) | Normal, on Trace 2, at **2412 / 2437 / 2462** (ch 1 / 6 / 11) | live power on the three usual channels |
| Marker (5, 6, all) | Normal, on Trace 2, **continuous peak** | jumps to the strongest AP; too many channels for 6 fixed markers |
| Persistence | on, decay 5 s | how often each level occurs; Wi-Fi channels stand out |
| Spectrogram | on; drag the 4 colored tabs on its color bar to ≈ red **-70**, yellow -80, green -90, blue **-105** | activity over time; the defaults leave weak bursts blue. **Not saved in profiles** — redo after loading |
| Reference Level | **-50 dBm** (-60 if no AP nearby, -30 only right next to a router) | lower = more gain, lower noise floor; change it with capture paused |
| RBW | Auto (2.4 GHz: 30–100 kHz manual is fine) | |
| Reference Clock | **Internal**, unless a GNSS antenna has a fix | an unlocked GNSS reference is worse than internal |

To size a channel: **Occupied Bandwidth** over the hump → ~20, 40, 80 or 160 MHz.

## Reading the display

- **Wi-Fi:** flat-topped humps 20 MHz wide (or 40/80/160 MHz blocks in 5 and 6 GHz), bursty in the spectrogram.
- **Bluetooth (2.4 GHz):** narrow 1–2 MHz spikes scattered over 2402–2480 MHz (frequency hopping).
- **Microwave oven (2.4 GHz):** broad, wandering energy near 2450–2460 MHz, pulsing at mains frequency.

## Bluetooth

Bluetooth shares the 2.4 GHz band with Wi-Fi, so `wifi-2g4` shows it too; `bluetooth.json` is the same
setup trimmed to Bluetooth's range (2402–2480 MHz) with three markers on the Max Hold trace at the
BLE advertising channels.

| Kind | Channels | Look for |
|---|---|---|
| Classic (BR/EDR: audio, keyboards) | 79 × 1 MHz, 2402–2480, hops 1600×/s | scattered short dots all over the spectrogram; Max Hold fills the whole band |
| Bluetooth Low Energy | 40 × 2 MHz, 2402–2480 | short repeating bursts |
| BLE advertising (beacons, discovery) | ch 37 / 38 / 39 = **2402 / 2426 / 2480 MHz** | steady spikes at exactly these three (the markers) |

Telling it from Wi-Fi: Wi-Fi is a wide (20+ MHz) block on a fixed channel; Bluetooth is narrow (1–2 MHz)
and moves. SpectraWare shows activity only — it cannot decode Bluetooth or name devices.

## Channel reference (20 MHz channels; center frequency in MHz)

Which channels are allowed depends on the country.

### 2.4 GHz — center = 2407 + 5 × ch

| Ch | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| MHz | 2412 | 2417 | 2422 | 2427 | 2432 | 2437 | 2442 | 2447 | 2452 | 2457 | 2462 | 2467 | 2472 | 2484 (JP, 11b) |

Channels overlap (each is ~20 MHz wide, spaced 5 MHz); networks normally use 1, 6 and 11.

### 5 GHz — center = 5000 + 5 × ch

| Sub-band | Channels | Centers (MHz) | Notes |
|---|---|---|---|
| UNII-1 | 36, 40, 44, 48 | 5180–5240 | |
| UNII-2A | 52, 56, 60, 64 | 5260–5320 | DFS (radar detection) |
| UNII-2C | 100, 104 … 144 | 5500–5720 | DFS |
| UNII-3 | 149, 153, 157, 161, 165 | 5745–5825 | |
| UNII-4 | 169, 173, 177 | 5845–5885 | newer; not everywhere |

### 6 GHz — center = 5950 + 5 × ch (ch 1, 5, 9 … 233)

| Sub-band | Range (MHz) | Channels |
|---|---|---|
| UNII-5 | 5925–6425 | 1–93 |
| UNII-6 | 6425–6525 | 97–113 |
| UNII-7 | 6525–6875 | 117–181 |
| UNII-8 | 6875–7125 | 185–233 |

Preferred Scanning Channels (where 6 GHz APs usually sit): 5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165,
181, 197, 213, 229 → 5975, 6055, 6135 … 7095 MHz (every 80 MHz).
