# Roadmap

Newest first. `### RM-NNN — title · status (date)`. Shares a counter with `issues.md` — next free: **006**.

## Resume here

RM-001 Phase 2 (Ethernet) is open — see [plans/rm-001-installer.md](plans/rm-001-installer.md).

### RM-001 — one-command SpectraWare installer · in-progress (2026-11-16)

**Goal:** fresh Ubuntu box → working SpectraWare with one clone + one command; idempotent; usable by anyone.

- ✅ Phase 1: `install.sh`, `uninstall.sh`, `versions.tsv`, `--check` (USB, udev, server). Fresh-clone install on a 26.04 desktop with R6000 on USB passed 2026-11-16.
- ✅ Phase 3: `tests/smoke.sh` passes on 22.04, 24.04, 26.04.
- ⬜ Phase 2: verify `--ethernet` (ufw rule for UDP 18331 replies) against an R6000 on a LAN / direct cable.
- ✅ Phase 4: GitHub Actions `lint` (bash -n, shellcheck, versions.tsv format, `--print-commands`) green on `d6e03c0`.
