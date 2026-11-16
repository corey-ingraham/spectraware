# RM-001 — one-command SpectraWare installer · in-progress (2026-11-16)

**Goal:** anyone with an Ubuntu amd64 machine runs
`git clone https://github.com/corey-ingraham/spectraware && cd spectraware && ./install.sh` and ends with a
working, verified SpectraWare install for an R6000 on USB. Re-running is safe.

## Decisions (2026-11-16)

| Question | Decision |
|---|---|
| Where the `.deb` comes from | thinkRF's own public URLs; the repo pins URL + sha256 and points to thinkRF's downloads page. Never rehosted. |
| Connection | USB is the primary path. Ethernet supported via `--ethernet`. |
| System changes | installer makes them, but lists each with its exact command first and asks; `--print-commands` lets users do it themselves. |
| Scope | SpectraWare only. Nothing user- or host-specific in the repo. |

## Facts it rests on

| Fact | Source |
|---|---|
| 1.4.0.4 ships `noble` (24.04) and `jammy` (22.04) builds at public S3 URLs, no login | thinkRF support article 36000616184 |
| `noble` build installs on 26.04: apt resolves `libqt5*` / `libasound2` via `*t64` Provides | installed on a 26.04 desktop; smoke test |
| `postinst` installs `99-thinkrf.rules` (USB `3830:5301` → 0666 + `uaccess`), setuid sandbox, udev reload | package `postinst` |
| R6000 USB exposes USBTMC + CDC-ACM; ModemManager grabs `ttyACM0` on plug | `lsusb -t`, ModemManager journal |
| `spectraware-server` must answer on 3010/3011; is Qt, needs `QT_QPA_PLATFORM=offscreen` headless | launcher script; container test |
| USB 3 streams 1550 Mbps vs 720 Mbps on 1 GigE | app note 74-0142 |
| Discovery: UDP broadcast to 18331 | Programmer's Guide |

## Phases

| # | Deliverable | Verification | Status |
|---|---|---|---|
| 1 | `install.sh`, `uninstall.sh`, `versions.tsv`, `lib/common.sh`, ModemManager rule, `--check` | `--check` on a desktop with an R6000 on USB 3: package, udev, sandbox, device r/w at 5 Gb/s | ✅ |
| 2 | `--ethernet`: ufw rule for discovery replies | discovery finds an R6000 over Ethernet with ufw enabled | ⬜ needs Ethernet setup |
| 3 | `tests/smoke.sh` | install → re-run says "Nothing to change" → uninstall, on 22.04 / 24.04 / 26.04; download path on 26.04 | ✅ |
| 4 | CI: shellcheck on push | green run on GitHub | ⬜ |

## Open

- The ufw rule assumes the R6000 replies from source port 18331 — unverified until Phase 2.
- The ModemManager rule is installed and lint-clean but not yet confirmed effective with a replug on a real host.
