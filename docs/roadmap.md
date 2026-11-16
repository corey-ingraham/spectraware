# Roadmap

Newest first. `### RM-NNN — title · status (date)`. Shares a counter with `issues.md` — next free: **003**.

## Resume here

RM-001: answer the design questions, then plan the installer (plan mode, register it in `plans/README.md`).

### RM-001 — bootstrap installer for SpectraWare on Ubuntu · planned (2026-11-16)

**Goal:** fresh Ubuntu box → working SpectraWare with one clone + one command; idempotent.
**Audience:** anyone who clones the public repo, not just Corey's machines. No local paths or private assumptions.

**Prerequisites:** none.

**Design questions (Corey):**
- What exactly is installed — components, versions, where they come from (apt repo, `.deb`, tarball, git)?
- Licence keys / credentials needed? Where do they live (Bitwarden item name)?
- Which Ubuntu releases must be supported; desktop, server, or both?
- Hardware / driver / udev prerequisites (SDRs, USB devices, GPU)?
- What proves a good install — command, service, version string?
- Should the installer also wire claude-config on a new box, or stay SpectraWare-only?
