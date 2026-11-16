# spectraware

One-command setup of thinkRF **SpectraWare** on Ubuntu for the thinkRF R6000 real-time spectrum
analyzer on USB.

```bash
git clone https://github.com/corey-ingraham/spectraware.git
cd spectraware
./install.sh
```

The installer:

1. picks thinkRF's package for your Ubuntu release and finds it in `~/Downloads`, or downloads it from thinkRF;
2. checks its sha256 against the checksum pinned in [`versions.tsv`](versions.tsv);
3. **lists every change it will make, with the exact command, and asks before doing anything**;
4. installs it and checks the result: package, USB permissions, R6000 access, and that SpectraWare's server starts.

Then plug the R6000 into a **USB 3** port, power it on, and start **Spectraware** from the app menu.

## Requirements

- Ubuntu 22.04, 24.04 or 26.04 (or a derivative such as Mint), **amd64**, with a desktop.
- `sudo` rights, and internet access unless the `.deb` is already in `~/Downloads`.
- The software is thinkRF's: [Spectraware downloads](https://support.thinkrf.com/support/solutions/folders/36000272741).
  This repo does not redistribute it.

## What it changes on your system

| Change | Why | Skip it with |
|---|---|---|
| `apt-get install` the SpectraWare `.deb` | the app, its libraries, and thinkRF's USB permission rule `/etc/udev/rules.d/99-thinkrf.rules` | n/a (that's the point) |
| `/etc/udev/rules.d/70-thinkrf-modemmanager.rules` (only if ModemManager is installed) | stops ModemManager probing the R6000's USB serial port as if it were a modem | `--no-modemmanager` |
| ufw rule allowing UDP from port 18331 (only with `--ethernet`, if ufw is on) | lets device-discovery replies through the firewall | leave out `--ethernet` |

Prefer to run it yourself? `./install.sh --print-commands` prints the commands and changes nothing.

## Options

```
./install.sh                 plan, ask, install, verify
./install.sh --check         verify only; changes nothing
./install.sh --print-commands
./install.sh --yes           no prompt (scripted installs)
./install.sh --deb FILE      use a specific .deb
./install.sh --ethernet      also set up the firewall for an R6000 on the network
./uninstall.sh               remove everything install.sh added
```

## Troubleshooting

- **Taskbar / desktop icon does nothing:** a pinned launcher can point at a copy of `spectraware.desktop`
  that has since been deleted (e.g. the Desktop icon). Remove the pin and re-pin **Spectraware** from the
  application menu, which uses `/usr/share/applications/spectraware.desktop` and survives reinstalls.
- **High CPU from `spectraware-server`:** normal while SpectraWare is open.
- **`--check` says the server is "neither listening nor connected":** quit SpectraWare and start it again.
- **R6000 not found:** `lsusb -d 3830:5301` should list it. Use a USB 3 port directly on the computer and
  check that the device has finished booting (status LED, see the [User Guide](docs/manuals/R6000-user-guide-75-0054.pdf)).
- **"USB 2 link" warning:** move it to a USB 3 port. USB 3 carries 1550 Mbps against 720 Mbps on Gigabit
  Ethernet ([app note](docs/manuals/R6000-app-note-streaming-bandwidth-74-0142.pdf)).
- **Firmware:** update from the R6000's web Administration Console ([User Guide](docs/manuals/R6000-user-guide-75-0054.pdf)).

## Reference

- [docs/manuals/](docs/manuals/README.md): thinkRF R6000 User Guide, Programmer's Guide, Datasheet, streaming app note
- [docs/config.md](docs/config.md): versions, checksums, ports, files installed
- [docs/architecture.md](docs/architecture.md): how the installer works

## Testing

`tests/smoke.sh` installs, re-installs (which must change nothing) and uninstalls in clean Ubuntu
22.04 / 24.04 / 26.04 containers (needs podman or docker).

Not affiliated with or endorsed by thinkRF Corporation. SpectraWare and the documents in `docs/manuals/`
are © thinkRF Corporation.
