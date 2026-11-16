# Issues

Newest first. `### ISSUE-NNN — title · status (date)` · status ∈ {planned, in-progress, done, deferred}.
`ISSUE-NNN` and `RM-NNN` share one counter — next free: **003**.

### ISSUE-002 — notification sounds silent: `paplay` not installed · planned (2026-11-16)

`setup-on-linux.sh check` warns `paplay not found`. Hooks exit 0 silently. Fix (needs root):
`sudo apt install pulseaudio-utils`. Candidate for the installer's prerequisites step (RM-001).
