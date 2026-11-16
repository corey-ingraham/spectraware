# spectraware — Claude Code Reference

Installer for thinkRF **SpectraWare** on Ubuntu, with the thinkRF R6000 on USB. Anyone clones the repo
and runs `./install.sh`; it fetches thinkRF's official package, verifies it, and sets up the machine.

## Reference Docs

| Doc | Holds |
|---|---|
| [README.md](README.md) | public front page: quick start, options, troubleshooting |
| [docs/architecture.md](docs/architecture.md) | repo layout, install flow, what runs as root, trust model |
| [docs/config.md](docs/config.md) | package versions + checksums, supported Ubuntu, ports, USB IDs, files installed |
| [docs/changelog.md](docs/changelog.md) | dated record of changes, newest first |
| [docs/issues.md](docs/issues.md) | problem log (`ISSUE-NNN`) |
| [docs/roadmap.md](docs/roadmap.md) | planned work (`RM-NNN`) — **resume here** |
| [docs/plans/README.md](docs/plans/README.md) | plan register (design artifacts) |
| [docs/manuals/README.md](docs/manuals/README.md) | thinkRF User Guide, Programmer's Guide, Datasheet, streaming app note (PDF + text) |

**Vendor manuals:** grep the `.txt` first, open the PDF for tables/figures —
[User Guide](docs/manuals/R6000-user-guide-75-0054.txt) (setup, network, LEDs, firmware) ·
[Programmer's Guide](docs/manuals/R6000-programmers-guide-75-0055.txt) (SCPI, VRT, ports, discovery) ·
[Datasheet](docs/manuals/R6000-datasheet-74-0141.txt) (specs) ·
[Streaming app note](docs/manuals/R6000-app-note-streaming-bandwidth-74-0142.txt) (USB vs Ethernet throughput).

## Quick Facts

| Item | Value |
|---|---|
| Hardware | thinkRF R6000 RTSA; USB 3 `3830:5301` (primary), Ethernet supported |
| Package | SpectraWare 1.4.0.4 amd64 `.deb`, from thinkRF's S3 (URLs + sha256 in `versions.tsv`) |
| Ubuntu | 22.04 → jammy build · 24.04 → noble · 26.04 → noble (all smoke-tested) |
| Remote | <https://github.com/corey-ingraham/spectraware> (public) |
| Language | bash (`set -euo pipefail`); no other runtime |
| Status | RM-001 Phases 1, 3, 4 done; Ethernet path (Phase 2) open |

## Critical Rules

1. **Public repo, generic installer:** nothing specific to one user, host, serial number, or network.
2. **Inform before changing:** every system change is listed with its exact command and confirmed; `--print-commands` opt-out.
3. **Idempotent:** a second `./install.sh` must report "Nothing to change" (the smoke test asserts it).
4. **thinkRF is the source:** never commit or rehost the `.deb`; pin version + sha256 in `versions.tsv`, verify before install.
5. **`set -euo pipefail` everywhere;** helpers sourced by scripts must not return non-zero by accident.
6. **`shellcheck -x` clean and `tests/smoke.sh` passing** before commit.
7. **Verify on a real host** with an R6000 for USB/udev changes; containers can't see `/dev/bus/usb`.
8. **Stage explicit paths** — never `git add -A`.
9. Docs: done → `changelog.md`, problems → `issues.md`, planned → `roadmap.md`; `ISSUE`/`RM` share one counter.

## Quick Reference

| Task | Command |
|---|---|
| Install / verify | `./install.sh` · `./install.sh --check` |
| Show commands only | `./install.sh --print-commands` |
| Remove | `./uninstall.sh` |
| Lint | `shellcheck -x install.sh uninstall.sh lib/common.sh tests/smoke.sh` |
| Container test | `tests/smoke.sh [--debs DIR] [ubuntu:24.04 ...]` (podman) |
| Device on USB? | `lsusb -d 3830:5301` |
| Add a SpectraWare release | new rows at top of `versions.tsv` (sha256 of thinkRF's file) → smoke test |

## Applied Learning

> Add a bullet when something fails repeatedly, the maintainer re-explains, a workaround is found, or a
> token-saving pattern emerges. Max 15 words per bullet. No explanations. Future-session value only.

- `dpkg-query` exits 1 for unknown packages — kills `pipefail` substitutions; guard with `|| true`.
- `spectraware-server` is Qt: headless runs need `QT_QPA_PLATFORM=offscreen`.
- Noble `.deb` installs on 26.04: apt resolves `libqt5*`/`libasound2` via `t64` Provides.
- Server takes one client per port then stops listening; ~100% CPU is normal.
- Probe localhost on both 127.0.0.1 and ::1 — binding varies by machine.
- Dead taskbar launcher = pin to a deleted `.desktop` copy; pin the `/usr/share` one.
- Containers see host `/sys` USB devices but not `/dev/bus/usb` nodes.
- `.deb` exceeds GitHub's 100 MB file limit — never commit it.

## Response Style

Terse; lead with the answer. Secrets by location only. Verify with a real command before saying "done".
