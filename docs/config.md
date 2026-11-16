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
| SpectraWare | 1.4.0.4 (`-RTSA-noble`, amd64 `.deb`) | thinkRF support site; local copy `~/Downloads/spectraware-1.4.0.4-RTSA-noble.deb` | _TBD (RM-001)_ | not committed: ~101 MB, over GitHub's 100 MB limit |

`.deb` `Depends:` ffmpeg, libfontconfig1, libopengl0, libegl1, libxcb-cursor0, libx11-6, libxkbcommon0,
libnss3, libasound2, libportaudio2, libqt5core5a, libqt5widgets5, libqt5gui5, libqt5dbus5,
libqt5network5, xdg-utils, libusb-1.0-0.

Hardware and protocol reference: [manuals/README.md](manuals/README.md).

## Ports / services

_None yet._

## Secrets (locations only)

| Secret | Location |
|---|---|
| _none yet_ | |
