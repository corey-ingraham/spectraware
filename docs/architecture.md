# Architecture

## Layout

```
install.sh              entry point: plan → confirm → run → --check
uninstall.sh            reverses install.sh (purge package, remove our rule, remove ufw rule)
lib/common.sh           shared helpers: OS detection, manifest, checks, the step list
versions.tsv            thinkRF builds this installer knows: version, build, sha256, URL
rules/                  udev rule(s) install.sh adds
desktop/                taskbar icon fix: window-icon helper, its autostart entry, corrected menu entry
tests/smoke.sh          clean-container install → re-run → uninstall, on 22.04 / 24.04 / 26.04
docs/                   reference, registers, thinkRF manuals
```

## Install flow

1. **Detect:** Ubuntu (or derivative via `UBUNTU_CODENAME`), amd64; map codename → thinkRF build.
2. **Pick package:** newest `versions.tsv` row for that build.
3. **Find it:** `--deb PATH`, else `~/Downloads/<file>`, else `~/.cache/spectraware/<file>`; any candidate
   must match the pinned sha256. Nothing found → plan a download from thinkRF's URL + `sha256sum -c`.
4. **Plan:** each needed change becomes a step (description + exact command). Steps already done are skipped:
   same package version installed, identical rule file present.
   - `apt-get install -y ./<deb>` — apt resolves dependencies; the package's `postinst` installs thinkRF's
     udev rule, makes `chrome-sandbox` setuid, reloads udev.
   - ModemManager rule (only if ModemManager is installed; `--no-modemmanager` skips it).
   - Taskbar icon fix (always): the client (Electron) sets no window icon, so icon-from-window taskbars
     (LXQt, XFCE) show a blank box, and it reports `WM_CLASS` `S1000_Client` while thinkRF's `.desktop` says
     `StartupWMClass=spectraware-client`. Installs `desktop/spectraware-window-icon` (python3 + libX11 via
     ctypes, stdlib only) started at login from `/etc/xdg/autostart`; it blocks on `_NET_CLIENT_LIST` changes and
     sets `_NET_WM_ICON` (64 px thinkRF logo from the package) on matching windows. Works however the app is
     launched (pins point at a `.desktop` path, so a wrapper launcher would be bypassed). Plus a copy of thinkRF's
     menu entry with the right `StartupWMClass` in `/usr/local/share/applications/` (shadows the packaged one).
   - ufw rule for UDP 18331 replies (only with `--ethernet` and ufw enabled).
5. **Confirm:** print the list; `[Y/n]`. `--yes` accepts, `--print-commands` prints and exits, no TTY → refuse.
6. **Run** the steps, then **`--check`** (read-only): package version, udev rule, sandbox mode, ModemManager
   rule, R6000 on USB read/write by the user and on a 5 Gb/s link, server answers on 3010/3011 (starts a
   short headless test run if SpectraWare isn't open).

## Trust model

- Only thinkRF's package runs code as root (its `postinst`). The installer's own root actions are
  `apt-get install`, copying one udev rule and the three taskbar-icon files, `udevadm control --reload-rules`,
  and the optional ufw rule. The icon helper runs as the desktop user, never as root.
- The script never runs as root as a whole unless the user starts it that way; root steps go through `sudo`.
- Downloads are HTTPS-only and checked against a sha256 pinned in this repo before apt sees them.
- No credentials are needed or stored.

## Vendor reference

Device setup, networking and firmware: [User Guide](manuals/R6000-user-guide-75-0054.txt).
SCPI control, VRT streaming, discovery: [Programmer's Guide](manuals/R6000-programmers-guide-75-0055.txt).
Specs: [Datasheet](manuals/R6000-datasheet-74-0141.txt). Throughput: [streaming app note](manuals/R6000-app-note-streaming-bandwidth-74-0142.txt).
Index: [manuals/README.md](manuals/README.md).
