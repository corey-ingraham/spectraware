# spectraware

Quick, repeatable setup of thinkRF **SpectraWare** on Ubuntu, for use with the thinkRF R6000
real-time spectrum analyzer.

> **Status:** work in progress. The one-command installer is being planned
> ([roadmap RM-001](docs/roadmap.md)). Until it lands, follow thinkRF's own instructions.

## What you will need

- Ubuntu (amd64). The current package targets 24.04 "noble" (`spectraware-1.4.0.4-RTSA-noble.deb`).
- The SpectraWare `.deb` from thinkRF's support site. It is not in this repo (licensing, and it is
  over GitHub's 100 MB file limit).
- An R6000 reachable over Ethernet. See the [User Guide](docs/manuals/R6000-user-guide-75-0054.pdf).

## Reference

- [docs/manuals/](docs/manuals/README.md): thinkRF R6000 User Guide and Programmer's Guide (PDF + text)
- [docs/config.md](docs/config.md): package version and dependencies
- [docs/roadmap.md](docs/roadmap.md): planned work

Not affiliated with or endorsed by thinkRF Corporation. The manuals in `docs/manuals/` are © thinkRF
Corporation.
