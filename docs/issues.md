# Issues

Newest first. `### ISSUE-NNN — title · status (date)` · status ∈ {planned, in-progress, done, deferred}.
`ISSUE-NNN` and `RM-NNN` share one counter — next free: **004**. (002 was withdrawn: not a SpectraWare issue.)

### ISSUE-003 — SpectraWare server hangs after the R6000 is unplugged while open · open (2026-11-16)

Seen on 26.04 with SpectraWare 1.4.0.4: the R6000 was moved to another USB port while SpectraWare was
running. Afterwards `spectraware-server` sat at 100% CPU with no listening sockets (3010/3011 closed)
while still holding the USB device. Cause is a guess (the unplug); not yet reproduced.
`./install.sh --check` reports it ("running but not answering … quit SpectraWare and start it again").
Workaround: quit SpectraWare and relaunch. To do: reproduce, then report to support@thinkrf.com.
