# Config

Paths, hosts, packages and secret **locations**. Never a secret value.

## Hosts

| Host | OS | User | Status |
|---|---|---|---|
| (first box) | Ubuntu 26.04.1 LTS | `toor` | repo scaffolded 2026-11-16; nothing installed |

## Paths

| What | Path |
|---|---|
| Repo | `~/repos/spectraware` |
| Claude config clone | `~/repos/claude-config` (wired into `~/.claude` by `linux/setup-on-linux.sh`) |
| Auto-memory bucket | `~/OneDrive/claude-config/memory/spectraware` → `~/repos/claude-config/memory/spectraware` |

## Software inventory

| Component | Version | Source | Checksum | Notes |
|---|---|---|---|---|
| SpectraWare | 1.4.0.4 (`-RTSA-noble`, amd64 `.deb`) | thinkRF support site; local copy `~/Downloads/spectraware-1.4.0.4-RTSA-noble.deb` | sha256 `9624d279cfe6c4baad00840e5fe69bf71e605f240058f17bd79cdd8677f5db7b` | not committed: ~101 MB, over GitHub's 100 MB limit. Installed + working on 26.04 (2026-11-16) |

## Ports

| Port | Proto | Where | What |
|---|---|---|---|
| 3010, 3011 | TCP | localhost | `spectraware-server` ↔ client (launcher checks both) |
| 37001 / 37000 | TCP | R6000 | SCPI control / VRT data |
| 4880 / 4881 | TCP | R6000 | HiSLIP control / data |
| 18331 | UDP | broadcast | device discovery |

`.deb` `Depends:` ffmpeg, libfontconfig1, libopengl0, libegl1, libxcb-cursor0, libx11-6, libxkbcommon0,
libnss3, libasound2, libportaudio2, libqt5core5a, libqt5widgets5, libqt5gui5, libqt5dbus5,
libqt5network5, xdg-utils, libusb-1.0-0.

Hardware and protocol reference: [manuals/README.md](manuals/README.md).

## Secrets (locations only)

| Secret | Location |
|---|---|
| _none yet_ | |
