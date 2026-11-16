# Roadmap

Newest first. `### RM-NNN — title · status (date)`. Shares a counter with `issues.md` — next free: **004**.

## Resume here

RM-001 Phases 2 (Ethernet) and 4 (CI) are open — see [plans/rm-001-installer.md](plans/rm-001-installer.md).
After a reboot or replug on a host with ModemManager, confirm `ID_MM_DEVICE_IGNORE=1` on the R6000.

### RM-001 — one-command SpectraWare installer · in-progress (2026-11-16)

**Goal:** fresh Ubuntu box → working SpectraWare with one clone + one command; idempotent; usable by anyone.

- ✅ Phase 1: `install.sh`, `uninstall.sh`, `versions.tsv`, `--check` (USB, udev, server).
- ✅ Phase 3: `tests/smoke.sh` passes on 22.04, 24.04, 26.04.
- ⬜ Phase 2: verify `--ethernet` (ufw rule for UDP 18331 replies) against an R6000 on a LAN / direct cable.
- ⬜ Phase 4: GitHub Actions — shellcheck on push (the `.deb` download makes a full smoke test slow but possible).
