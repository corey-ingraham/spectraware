# Issues

Newest first. `### ISSUE-NNN — title · status (date)` · status ∈ {planned, in-progress, done, deferred}.
`ISSUE-NNN` and `RM-NNN` share one counter — next free: **007**. (002 was withdrawn: not a SpectraWare issue.)

### ISSUE-005 — SpectraWare crashes when the R6000 is behind a USB hub chip · done (2026-11-16)

SpectraWare crashed repeatedly: when the reference level was changed, and right after pause → new centre/span
→ restart. Three `spectraware-server` crash reports (SIGSEGV in `libtrf.so` `SpikeReceiver::run` and
`SpectrumFrame` copy; SIGABRT). The server log, still in memory in the core dumps, showed the
same chain each time: `libusb_bulk_transfer ... LIBUSB_ERROR_TIMEOUT`, `*IDN?` no response, `*RST` failed,
"device not responding", then the crash. The kernel saw no USB disconnect. The R6000 was on a USB-A→C adapter
that enumerates as a 1-port VIA Labs USB 3.0 hub (`2109:0211`). With a passive adapter (R6000 directly on
the root port, `lsusb -t` shows no `Class=Hub` above it) the same steps ran without a crash.

- Cause: the hub chip stalls sustained high-rate bulk transfers. thinkRF bug, still present: the server
  crashes instead of reporting a lost device, and a stalled R6000 needs a power cycle.
- Fix: `--check` now warns when the R6000 is behind a hub; README troubleshooting entry.

### ISSUE-004 — open SpectraWare window shows a blank box in the taskbar · done (2026-11-16)

The pinned launcher showed the thinkRF logo, the running window a generic blank-window icon. Cause (thinkRF
package): the Electron client sets no `_NET_WM_ICON` of its own, and its `WM_CLASS` is `S1000_Client` while the
`.desktop` says `StartupWMClass=spectraware-client`, so no taskbar can match window to launcher. Confirmed
by setting the logo on the live window by hand (LXQt picked it up). Fixed in `install.sh` with a login helper
that sets the icon on SpectraWare windows plus a corrected menu entry — see [architecture](architecture.md).

### ISSUE-003 — "server hangs after unplug" was a misdiagnosis; `--check` fixed · done (2026-11-16)

Reported as a hang: `spectraware-server` at ~100% CPU, no listener on 3010/3011. Re-examined with a fresh
launch: that is **normal**. The server accepts one client connection per port and then stops listening, it
binds `localhost` (IPv4 or IPv6 depending on the machine), and it runs near 100% CPU in normal use.
`--check` probed only `127.0.0.1` listeners, so it reported a healthy running app as broken. Fixed in
`lib/common.sh`: a port counts as served if it answers on IPv4 or IPv6 **or** has an established connection.
