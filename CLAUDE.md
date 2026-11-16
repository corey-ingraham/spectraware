# spectraware — Claude Code Reference

Provisioning repo: get SpectraWare software installed and configured on an Ubuntu machine quickly and
repeatably. One clone + one command should take a fresh box to a working install.

## Reference Docs

| Doc | Holds |
|---|---|
| [docs/architecture.md](docs/architecture.md) | repo layout, install flow, what runs as root, trust model |
| [docs/config.md](docs/config.md) | target hosts, paths, packages, ports, secret **locations** (never values) |
| [docs/changelog.md](docs/changelog.md) | dated record of changes, newest first |
| [docs/issues.md](docs/issues.md) | problem/incident log (`ISSUE-NNN`) |
| [docs/roadmap.md](docs/roadmap.md) | planned work (`RM-NNN`) — **resume here** |
| [docs/plans/README.md](docs/plans/README.md) | plan register (design artifacts) |

## Quick Facts

| Item | Value |
|---|---|
| Purpose | install + configure SpectraWare on Ubuntu |
| Target OS | Ubuntu (first host: 26.04.1 LTS, user `toor`) |
| Repo path | `~/repos/spectraware` |
| Remote | none yet — ask before creating/pushing |
| Language | bash (`set -euo pipefail`), no other runtime assumed |
| Memory bucket | `~/OneDrive/claude-config/memory/spectraware` (shim → claude-config clone) |
| Status | scaffold only; installer not written (RM-001) |

## Critical Rules

1. **Idempotent.** Every script is safe to re-run; check state before changing it.
2. **`set -euo pipefail`** in every script; `bash -n` + `shellcheck` clean before commit.
3. **Secrets by location only** — licence keys, tokens, passwords never in the repo or chat (global §9).
4. **Claude has no sudo here.** Root steps are run by Corey (`! sudo ...`); never embed a password.
5. **Verify on a real host** — package installed, service active, version printed — before "done".
6. **Pin what is installed** (version/URL/checksum) in `docs/config.md`; verify checksums on download.
7. **Stage explicit paths** — never `git add -A`; installers and downloads stay out of history.
8. **Ask before pushing** or creating a remote.
9. Docs: done → `changelog.md`, problems → `issues.md`, planned → `roadmap.md`; `ISSUE`/`RM` share one counter.

## Quick Reference

| Task | Command |
|---|---|
| Syntax-check a script | `bash -n <script>` |
| Lint | `shellcheck <script>` |
| Host facts | `lsb_release -ds` · `dpkg -s <pkg>` · `systemctl is-active <unit>` |
| Config wiring check | `~/repos/claude-config/linux/setup-on-linux.sh check` |
| Doc consistency | `/sync` after doc-touching work · `/checkup repos` |

## Applied Learning

> Add a bullet when something fails repeatedly, Corey re-explains, a workaround is found, or a
> token-saving pattern emerges. Max 15 words per bullet. No explanations. Future-session value only.

- No passwordless sudo on this host — hand root commands to Corey via `!`.
- `paplay` absent on fresh Ubuntu — sound hooks silent until `pulseaudio-utils` is installed.

## Response Style

Terse; lead with the answer. Secrets by location only. Verify with a real command before saying "done".
