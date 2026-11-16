# Changelog

Newest first. `## YYYY-MM-DD — title [RM-NNN / ISSUE-NNN]`

## 2026-11-16 — fresh-install test passed on a real desktop [RM-001]

- Clean 26.04 desktop, fresh clone of the public repo, no local `.deb`: `./install.sh` downloaded from thinkRF,
  verified sha256, installed, added the ModemManager rule; `--check` all green with the R6000 on USB 3 (5000 Mb/s).
- ModemManager rule confirmed effective: `ID_MM_DEVICE_IGNORE=1` on the device and `ttyACM0`, no ModemManager probe.

## 2026-11-16 — installer: install.sh, uninstall.sh, smoke test [RM-001]

- [install.sh](../install.sh) / [uninstall.sh](../uninstall.sh) / [lib/common.sh](../lib/common.sh): find or download
  thinkRF's package, verify sha256, list every change with its command, confirm, run, `--check`.
- [versions.tsv](../versions.tsv): 1.4.0.4 noble + jammy URLs and checksums.
- [rules/70-thinkrf-modemmanager.rules](../rules/70-thinkrf-modemmanager.rules): ModemManager ignores the R6000.
- [tests/smoke.sh](../tests/smoke.sh): passes on 22.04, 24.04, 26.04.
- Added the R6000 Datasheet (74-0141) and streaming app note (74-0142) to [manuals/](manuals/README.md).
- Removed user- and host-specific content; Claude memory wiring moved to the git-ignored `.claude/settings.local.json`.
- Logged [ISSUE-003](issues.md) (server hang after USB unplug).

## 2026-11-16 — installer plan drafted [RM-001]

- [plans/rm-001-installer.md](plans/rm-001-installer.md): facts from the `.deb` and manuals, phases, open questions.

## 2026-11-16 — thinkRF manuals added; public GitHub repo

- [docs/manuals/](manuals/README.md): R6000 User Guide (75-0054) and Programmer's Guide (75-0055), PDF + text.
- Published as public repo `corey-ingraham/spectraware`.

## 2026-11-16 — repo scaffolded

- [CLAUDE.md](../CLAUDE.md), `docs/` registers, [.gitignore](../.gitignore), [.claude/settings.json](../.claude/settings.json).
