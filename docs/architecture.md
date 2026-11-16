# Architecture

> Scaffold — fill in as the installer is designed (RM-001).

## Goal

Fresh Ubuntu machine → working SpectraWare install with one clone and one command, repeatable on
any number of machines.

## Intended layout

```
spectraware/
├─ CLAUDE.md, docs/      reference + registers
├─ .claude/              repo-scoped Claude Code settings
└─ (installer)           not written yet — entry point, per-component steps, verify step (RM-001)
```

## Install flow

TBD (RM-001). Constraints already fixed by `CLAUDE.md` Critical Rules: idempotent, `set -euo pipefail`,
pinned + checksummed downloads, a verify step that proves the result on the host.

## Vendor reference

Device setup, networking and specs: [User Guide](manuals/R6000-user-guide-75-0054.txt).
SCPI control and VRT data streaming: [Programmer's Guide](manuals/R6000-programmers-guide-75-0055.txt).
Index: [manuals/README.md](manuals/README.md).

## Trust model

- Root is needed for package installs; scripts are run by the operator with `sudo`, not by Claude.
- Nothing secret lives in the repo. Licence keys / credentials are read from a location documented in
  [config.md](config.md).
- Downloads are verified against a pinned checksum before they are executed or installed.
