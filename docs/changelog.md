# Changelog

Newest first. `## YYYY-MM-DD — title [RM-NNN / ISSUE-NNN]`

## 2026-11-16 — installer plan drafted [RM-001]

- [plans/rm-001-installer.md](plans/rm-001-installer.md): facts from the `.deb` and manuals, 4 phases, 4 open questions.
- [config.md](config.md): `.deb` sha256, port table; noble package verified installed on 26.04.

## 2026-11-16 — thinkRF manuals added; public GitHub repo

- [docs/manuals/](manuals/README.md): R6000 User Guide (75-0054) and Programmer's Guide (75-0055), PDF + `pdftotext -layout` text.
- Linked from [CLAUDE.md](../CLAUDE.md), [architecture.md](architecture.md), [config.md](config.md).
- SpectraWare 1.4.0.4 package facts recorded in [config.md](config.md); `.deb` stays out of git.
- Published as public repo `corey-ingraham/spectraware`.

## 2026-11-16 — repo scaffolded

- Scaffold from `claude-config/repo-template.md`: [CLAUDE.md](../CLAUDE.md), `docs/` registers,
  [.gitignore](../.gitignore), [.claude/settings.json](../.claude/settings.json).
- `autoMemoryDirectory` wired to `~/OneDrive/claude-config/memory/spectraware`; bucket created.
- Host wired to claude-config (`linux/setup-on-linux.sh`): statusline, hooks, global `CLAUDE.md`,
  agents, skills, memory, docs.
