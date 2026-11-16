# Config

Package versions, supported systems, ports and files. No secrets are needed: thinkRF's packages
download without a login.

## SpectraWare packages

Canonical list: [`versions.tsv`](../versions.tsv) (version · build · sha256 · URL). Release notes and
older versions: thinkRF support → [Spectraware Downloads](https://support.thinkrf.com/support/solutions/folders/36000272741).

| Version | Build | Size | sha256 |
|---|---|---|---|
| 1.4.0.4 | noble (24.04) | 100.9 MB | `9624d279cfe6c4baad00840e5fe69bf71e605f240058f17bd79cdd8677f5db7b` |
| 1.4.0.4 | jammy (22.04) | 101.7 MB | `c20e6e06440df7255dacf7dbbc3b31b2dd8af8c9ca458e237c6458d57d00aea8` |

`Depends:` ffmpeg, libfontconfig1, libopengl0, libegl1, libxcb-cursor0, libx11-6, libxkbcommon0, libnss3,
libasound2, libportaudio2, libqt5core5a, libqt5widgets5, libqt5gui5, libqt5dbus5, libqt5network5,
xdg-utils, libusb-1.0-0. On 24.04+ apt satisfies `libqt5*5` and `libasound2` with the `*t64` packages.

## Supported Ubuntu (amd64 only)

| Release | Codename | Build used | Tested |
|---|---|---|---|
| 22.04 | jammy | jammy | container smoke test 2026-11-16 |
| 24.04 | noble | noble | container smoke test 2026-11-16 |
| 26.04 | resolute | noble | container smoke test + desktop with R6000 on USB 2026-11-16 |

Derivatives (Mint, Pop!_OS…) are mapped by `UBUNTU_CODENAME`. Other releases need `--force`.

## R6000

| Item | Value |
|---|---|
| USB ID | `3830:5301` (thinkRF R6000-408 seen); interfaces: USBTMC, CDC-ACM serial, CDC data |
| USB link | needs USB 3 (5 Gb/s) for full rate: 1550 Mbps vs 720 Mbps on 1 GigE ([app note](manuals/R6000-app-note-streaming-bandwidth-74-0142.txt)) |
| Firmware | tested with the latest firmware available 2026-11-16; update via the device's web Administration Console ([User Guide](manuals/R6000-user-guide-75-0054.txt)) |
| Network | DHCP by default, link-local Auto-IP (169.254/16) on a direct cable |

## Ports

| Port | Proto | Where | What |
|---|---|---|---|
| 3010, 3011 | TCP | localhost (IPv4 or IPv6) | `spectraware-server` ↔ client; one client per port, the listener closes once connected |
| 37001 / 37000 | TCP | R6000 | SCPI control / VRT data |
| 4880 / 4881 | TCP | R6000 | HiSLIP control / data |
| 18331 | UDP | broadcast | device discovery ([Programmer's Guide](manuals/R6000-programmers-guide-75-0055.txt) "Discovery Using Broadcast UDP") |

## Files on the system

| Path | Put there by | Purpose |
|---|---|---|
| `/usr/lib/spectraware/`, `/usr/bin/Spectraware` | thinkRF package | app (Electron client + Qt server) |
| `/etc/udev/rules.d/99-thinkrf.rules` | thinkRF package | USB `3830:5301` → mode 0666 + `uaccess` |
| `/etc/udev/rules.d/70-thinkrf-modemmanager.rules` | `install.sh` (if ModemManager present) | ModemManager ignores the R6000's serial port |
| ufw rule `allow proto udp from any port 18331` | `install.sh --ethernet` | lets discovery replies in |
| `~/.cache/spectraware/` | `install.sh` | downloaded `.deb` (kept for re-runs) |

Hardware and protocol reference: [manuals/README.md](manuals/README.md).
