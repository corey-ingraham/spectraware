# Signal profiles beyond Wi-Fi

Ready-made SpectraWare profiles for common signals besides Wi-Fi, which the R6000 (9 kHz–8 GHz,
100 MHz instantaneous bandwidth) can see. Load one with **File → Load Settings** → `<repo>/profiles/`,
the same way as the [Wi-Fi profiles](wifi.md). The display settings (traces, persistence, spectrogram
colors) are the same as in [wifi.md](wifi.md#settings-for-every-profile).

## Naming: `<signal>-<band>[-<region>].json`

| Part | Meaning | Examples |
|---|---|---|
| `<signal>` | what you are looking for, in plain words | `wifi`, `bluetooth`, `zigbee`, `remotes`, `iot`, `adsb`, `dect`, `cellular`, `fpv`, `fm` |
| `<band>` | the band as people say it: MHz below 1 GHz, `XgY` for GHz, or a band name | `433`, `915`, `2g4`, `5g8`, `low`, `cband` |
| `-<region>` | only when the band plan differs by region | `-us` (North America), `-eu` (Europe) |

No region suffix means the profile is the same everywhere. A profile with a suffix is useless in the
other region: those frequencies belong to something else there.

## The profiles

**One** capture = span ≤ 100 MHz, the whole range is captured at once, and short bursts are never
missed. **Swept** = the R6000 steps across the range, so a burst can fall between steps; leave
Max Hold running longer.

| File | Start → Stop (MHz) | Capture | Detects | Markers (MHz) | Antenna |
|---|---|---|---|---|---|
| `fm-broadcast.json` | 87.5 → 108 | one | FM radio stations: always on, so it's the first test of a new antenna | continuous peak | whip ≈ 75 cm |
| `remotes-315-us.json` | 310 → 320 | one | car key fobs, garage remotes, tire-pressure sensors (North America) | 315 | whip ≈ 24 cm |
| `remotes-433.json` | 430 → 440 | one | key fobs, weather stations, doorbells, cheap sensors (worldwide) | 433.92 | whip ≈ 17 cm |
| `iot-868-eu.json` | 863 → 870 | one | LoRa, Z-Wave, smart meters, alarms (Europe) | 868.1 / 868.42 / 869.85 | whip ≈ 8.6 cm, or log-periodic |
| `iot-915-us.json` | 902 → 928 | one | LoRa, Z-Wave, smart meters (North America) | 908.42 / 916 | whip ≈ 8.2 cm, or log-periodic |
| `adsb-1090.json` | 1085 → 1095 | one | aircraft transponders (ADS-B / Mode S) | 1090 | log-periodic toward the sky |
| `dect-1900-eu.json` | 1880 → 1900 | one | DECT cordless phones, baby monitors (Europe) | continuous peak | log-periodic |
| `dect-1920-us.json` | 1920 → 1930 | one | DECT 6.0 cordless phones (North America) | continuous peak | log-periodic |
| `zigbee-2g4.json` | 2400 → 2485 | one | Zigbee, Thread and Matter smart-home devices | 2425 / 2450 / 2475 / 2480 (ch 15 / 20 / 25 / 26) | 2.4 GHz antenna, or log-periodic |
| `cellular-low.json` | 600 → 960 | swept | 4G/5G downlinks: 600, 700, 800, 850, 900 MHz | continuous peak | log-periodic (from 700) |
| `cellular-mid.json` | 1700 → 2700 | swept | 4G/5G downlinks: 1800, 1900 (PCS), 2100 (AWS), 2600 / n41 | continuous peak | log-periodic |
| `cellular-cband.json` | 3300 → 4200 | swept | 5G n77 / n78 (C-band, CBRS) | continuous peak | log-periodic |
| `fpv-5g8.json` | 5645 → 5945 | swept | analog FPV drone video | continuous peak | 5.8 GHz antenna, or log-periodic |

Every profile has Trace 1 **Normal** and Trace 2 **Max Hold**. The FM and cellular profiles also have
Trace 3 **Average**, because those signals are continuous. Markers sit on Trace 2. The reference level
is -50 dBm; use -30 near a cell tower or an FM transmitter. The `wifi-*` and `bluetooth-2g4` profiles
are described in [wifi.md](wifi.md).

## What each one looks like

- **FM broadcast:** steady ~200 kHz-wide humps, one per station, on a 200 kHz raster in North America
  (88.1, 88.3 …) and 100 kHz in Europe. Nothing at all here means the antenna, not the radio.
- **Remotes (315 / 433):** nothing until a button is pressed, then a short narrow spike; Max Hold keeps
  it. Weather stations and sensors repeat every 30–60 s, so leave the profile running for a few minutes.
- **IoT (868 / 915):** short bursts. LoRa is ~125 kHz wide (wider in some modes), and in North America it
  hops across 902–928. Z-Wave is narrow, at 868.42 / 869.85 (EU) or 908.42 / 916 (US). Smart meters
  send periodic bursts.
- **ADS-B (1090):** short pulses at 1090 MHz, several per second wherever aircraft are in line of sight.
  Max Hold shows a spike centered at 1090. Hold the antenna's elements vertical and point it at the sky.
- **DECT:** a base station transmits a beacon even when idle. Europe has 10 channels of 1.728 MHz in
  1880–1900; DECT 6.0 has 5 channels in 1920–1930. Calls make the bursts denser.
- **Zigbee / Thread / Matter:** bursts 2 MHz wide. Channel *k* (11–26) is at 2405 + 5(*k* − 11) MHz.
  Channels 15 / 20 / 25 sit between Wi-Fi channels 1 / 6 / 11, which is why they are the usual choice; 26
  is often limited to low power. Thread uses the same channels.
- **Cellular:** downlinks are continuous flat blocks 5–20 MHz wide (4G) or up to 100 MHz wide (5G). The
  Average trace shows them clearly. Phone uplinks are bursty and much weaker. The band plan differs by
  country and operator; these ranges cover both North America and Europe. SpectraWare shows energy, not
  operators.
- **FPV video (5.8 GHz):** analog video is a continuous ~20 MHz-wide hump on one channel (Raceband
  R1–R8 = 5658–5917 MHz). Digital FPV systems are wider and bursty. This range overlaps the top of
  `wifi-5g`, so check `wifi-5g` before blaming a drone.

## Antennas

The R6000 itself covers 9 kHz–8 GHz; the antenna decides what it actually hears. An antenna far from
its design band loses tens of dB, and on screen that looks exactly like "no signal".

| Antenna type | Good for | Notes |
|---|---|---|
| **Receiver antenna in the R6000 box** | (no published range) | thinkRF: "only intended to perform adequately across a limited frequency range". Test it: load `fm-broadcast`, `iot-915-us` or `iot-868-eu`, `wifi-2g4` and `wifi-5g`, and note which ones show signals. |
| **Whip / dipole cut to the band** | one sub-GHz band | each element ¼ wavelength (table below); a telescopic whip adjusts to any of them |
| **Log-periodic, 700 MHz–6 GHz** (e.g. Aaronia HyperLOG 7060) | everything from `iot-868` to `wifi-5g` and `fpv-5g8` | directional, so point it at the source. Much weaker below 700 MHz (FM, 315, 433, 600 MHz cellular) and above 6 GHz (`wifi-6g`, UWB). |

**¼ wavelength** (a whip, or each half of a dipole) = 75 / f(MHz) in metres:

| Band | 100 MHz (FM) | 315 | 433.92 | 868 | 915 | 1090 |
|---|---|---|---|---|---|---|
| ¼ λ | 75 cm | 23.8 cm | 17.3 cm | 8.6 cm | 8.2 cm | 6.9 cm |

### Finding a transmitter with a directional antenna

1. Load the profile for the signal and turn Max Hold off (or **Reset Trace** often), so you see the live level.
2. Put a marker on the signal, or turn on continuous peak.
3. Turn slowly through 360° and watch the marker's level. The source is where it is highest; the back
   of the antenna gives a sharper minimum, which helps confirm the direction.
4. Hold the elements in the same orientation as the transmitter's antenna, which is usually vertical.
   With the wrong orientation the signal can drop by 20 dB.
5. Walk toward it and lower the gain (raise the reference level) as the signal gets stronger.

### Active (amplified) antennas

Models marked **X** (e.g. HyperLOG 7060X) add a 35–40 dB amplifier. With one:

- Turn the R6000's preamplifier **off** and raise the reference level to about -20 to -10 dBm.
- The R6000 tolerates +20 dBm at most (datasheet) and compresses from +12 dBm with its preamp on.
  Keep it, and an active antenna, **at least 60 cm from any transmitter above +15 dBm** (user guide):
  routers, phones mid-call, radios.
- Signals that look too strong to be real, or a noise floor that jumps when a phone transmits nearby,
  mean overload: back off or switch the amplifier off.

## Not worth a profile

| Signal | Why not |
|---|---|
| GNSS (GPS L1 1575.42) | below the noise floor without an active GNSS antenna and LNA; the R6000's GNSS port is for timing, not display |
| UWB (AirTags, digital car keys; ch 5 6.24–6.74 GHz, ch 9 7.74–8.24 GHz) | very weak; ch 9 is partly above the R6000's 8 GHz limit; needs a 6–8 GHz antenna |
| Airband, amateur bands, UHF TV / wireless microphones | specialist use; make one with the recipe below |

## Making another profile

Run `tools/make-profiles.py`: add a row (name, start, stop, markers, average), run
`python3 -I tools/make-profiles.py`, then `python3 -I tests/check-profiles.py`. The script derives
everything from `wifi-2g4.json`, a real SpectraWare save, so the result loads the same way. Name it with
the convention above. Note: the profiles' frequency axis is labelled in GHz, the same as the Wi-Fi saves,
even below 1 GHz.
