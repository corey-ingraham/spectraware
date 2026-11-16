# RM-001 — one-command SpectraWare installer · draft (2026-11-16)

**Goal:** anyone with an Ubuntu amd64 machine and the thinkRF `.deb` runs
`git clone https://github.com/corey-ingraham/spectraware && cd spectraware && ./install.sh` and ends with a
working, verified SpectraWare install. Re-running is safe.

## Facts established (2026-11-16, from the package and the manuals)

| Fact | Source |
|---|---|
| Package `spectraware 1.4.0.4` amd64, sha256 `9624d279cfe6c4baad00840e5fe69bf71e605f240058f17bd79cdd8677f5db7b`, 100.9 MB | `dpkg-deb -f`, `sha256sum` |
| Built for 24.04 "noble", but **installs on 26.04**: apt satisfies `libqt5*5` / `libasound2` via the `*t64` packages' `Provides` | installed on this host 2026-11-16 10:04 (`/var/log/dpkg.log`) |
| `postinst` does the root work itself: setuid `chrome-sandbox`, udev reload, desktop/icon cache | `deb-ctrl/postinst` |
| udev rule `99-thinkrf.rules`: USB `3830:5301`, `MODE=0666`, `uaccess` | package contents |
| `/usr/bin/Spectraware` = Electron client + `spectraware-server --standalone`, which must answer on localhost **3010** and **3011** | launcher script |
| Device: SCPI on TCP **37001**, VRT data on **37000** (HiSLIP **4880**/**4881**); discovery = UDP broadcast to **18331** | Programmer's Guide §"Simple 2-Port TCP/IP Connection" |
| R6000 defaults to DHCP and falls back to link-local Auto-IP (169.254/16) on a direct cable | User Guide §"IP address allocation" |

## The one real constraint: where the `.deb` comes from

It can't live in git: GitHub's per-file limit is 100 MB, and it is thinkRF's licensed software ("for
customers who hold a valid end-user license", User Guide). **Proposed:** the user downloads it from
thinkRF. `install.sh` finds it (argument → `$SPECTRAWARE_DEB` → newest `~/Downloads/spectraware-*.deb`) and
checks its sha256 against `versions.tsv` in the repo. An unknown hash stops the install unless
`--allow-unknown` is passed. A GitHub Release asset would allow a no-download install, but that means
redistributing licensed binaries — Corey's decision (Q1).

## Proposed layout

```
install.sh            entry point: preflight → locate+verify .deb → apt install → network (opt) → verify
uninstall.sh          apt purge spectraware; removes anything install.sh added (NM profile)
versions.tsv          version · filename · sha256 · tested-on Ubuntu releases
lib/*.sh              preflight, deb, network, verify (sourced; each step idempotent)
tests/smoke.sh        install + verify inside clean 24.04 / 26.04 containers (needs podman)
.github/workflows/    shellcheck + bash -n on push (CI can't hold the .deb)
```

## Steps `install.sh` performs

1. **Preflight:** Ubuntu, `amd64`, release in `versions.tsv`'s tested list (unknown → warn, continue);
   `sudo` available. Re-exec only the apt step under `sudo`, never the whole script.
2. **Locate + verify** the `.deb` (above).
3. **Install:** if `dpkg-query` already shows the same version, skip. Otherwise
   `sudo apt-get install -y ./<deb>` (apt, not `dpkg -i`, so dependencies resolve).
4. **Network (opt-in, `--direct <iface>`):** create a NetworkManager profile `thinkrf-direct` with
   `ipv4.method link-local` on that interface for a laptop-to-R6000 cable. Skip by default — on a DHCP LAN
   nothing is needed.
5. **Firewall check:** if ufw is active, warn that UDP 18331 discovery replies may be dropped and print the
   exact `ufw allow` line. Don't change the firewall automatically (Q3).
6. **Verify (also `./install.sh --check`):** package version matches; udev rule present;
   `chrome-sandbox` is root-owned 4755; server answers on 3010/3011 when launched headless, then stopped;
   optional `--device <ip>`: TCP 37001 open and `*IDN?` returns an R6000 string.

## Phases

| # | Deliverable | Verification |
|---|---|---|
| 1 | `install.sh` steps 1–3 + 6, `versions.tsv`, `uninstall.sh` | purge on this host → `./install.sh` → `--check` all green → re-run is a no-op |
| 2 | `--direct` NM profile, ufw advice, `--device` probe | against a real R6000 on a direct cable (needs the hardware) |
| 3 | `tests/smoke.sh` in podman 24.04 + 26.04 | both pass from clean images (`sudo apt install podman shellcheck` first) |
| 4 | README quick start, troubleshooting from the manuals, CI shellcheck | a fresh clone, following only the README, installs correctly |

## Open questions (Corey)

1. **Distribution:** user downloads the `.deb` from thinkRF (proposed), or attach it to GitHub Releases?
2. **Hardware path:** direct cable, LAN/DHCP, or both? Is USB `3830:5301` used, or Ethernet only?
3. **Firewall:** advise only (proposed), or have `install.sh` add the ufw rule?
4. **Scope:** also install claude-config, firmware-update helpers, or Python/SCPI tooling — or SpectraWare only?
