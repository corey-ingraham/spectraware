# Changelog

Newest first. `## YYYY-MM-DD — title [RM-NNN / ISSUE-NNN]`

## 2026-11-16 — signal profiles beyond Wi-Fi [RM-006]

- [profiles/](../profiles/): 13 new profiles (FM, 315/433 remotes, 868/915 IoT, ADS-B, DECT EU/US, Zigbee,
  cellular low/mid/C-band, FPV 5.8). Naming `<signal>-<band>[-<region>]`; `bluetooth.json` renamed
  `bluetooth-2g4.json`.
- [tools/make-profiles.py](../tools/make-profiles.py): generates them from `wifi-2g4.json`;
  [tests/check-profiles.py](../tests/check-profiles.py) validates all profiles (CI + smoke test).
- [signals.md](signals.md): profile table, what each signal looks like, antenna fit, direction finding,
  active-antenna overload limits.

## 2026-11-16 — ready-made profiles: Wi-Fi 2.4/5/6/all + Bluetooth

- [profiles/](../profiles/): SpectraWare Save Settings files, load with File → Load Settings on any R6000.
- [wifi.md](wifi.md): Bluetooth section (classic vs BLE, advertising channels), profile list.

## 2026-11-16 — Wi-Fi monitoring guide

- [wifi.md](wifi.md): Save/Load Settings profiles for 2.4, 5, 6 GHz and all bands, display settings,
  channel tables. Linked from README and CLAUDE.md.

## 2026-11-16 — `--check` warns when the R6000 is behind a USB hub [ISSUE-005]

- [lib/common.sh](../lib/common.sh): hub detected from the sysfs device name (`2-1.1` vs `2-3`).
- [ISSUE-005](issues.md): crashes traced to an adapter with a hub chip; README troubleshooting entry.

## 2026-11-16 — taskbar shows the thinkRF logo on the open window [ISSUE-004]

- [desktop/](../desktop/): `spectraware-window-icon` login helper (python3 stdlib + libX11, event-driven) sets
  the logo on SpectraWare windows; autostart entry; menu entry with `StartupWMClass=S1000_Client`.
- [install.sh](../install.sh) installs them (always, listed like every step); `--check` reports them;
  [uninstall.sh](../uninstall.sh) removes them and stops the helper.

## 2026-11-16 — `--check` no longer fails a running SpectraWare [ISSUE-003]

- [lib/common.sh](../lib/common.sh): server ports count as served when listening on IPv4/IPv6 or already connected.
- [ISSUE-003](issues.md) closed as a misdiagnosis: one-client-per-port and high CPU are normal.
- [README.md](../README.md) troubleshooting: dead taskbar launcher, high CPU.

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
