# Issues

Newest first. `### ISSUE-NNN — title · status (date)` · status ∈ {planned, in-progress, done, deferred}.
`ISSUE-NNN` and `RM-NNN` share one counter — next free: **004**. (002 was withdrawn: not a SpectraWare issue.)

### ISSUE-003 — "server hangs after unplug" was a misdiagnosis; `--check` fixed · done (2026-11-16)

Reported as a hang: `spectraware-server` at ~100% CPU, no listener on 3010/3011. Re-examined with a fresh
launch: that is **normal**. The server accepts one client connection per port and then stops listening, it
binds `localhost` (IPv4 or IPv6 depending on the machine), and it runs near 100% CPU in normal use.
`--check` probed only `127.0.0.1` listeners, so it reported a healthy running app as broken. Fixed in
`lib/common.sh`: a port counts as served if it answers on IPv4 or IPv6 **or** has an established connection.
