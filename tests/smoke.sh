#!/usr/bin/env bash
# tests/smoke.sh - install SpectraWare with install.sh inside clean Ubuntu containers, then --check.
#
#   tests/smoke.sh [--debs DIR] [image ...]
#
# Default images: ubuntu:22.04 ubuntu:24.04 ubuntu:26.04. With --debs, DIR is mounted as the
# container's ~/Downloads, so install.sh's "find it in Downloads" path is tested and nothing is
# downloaded; without it, each container downloads the package from thinkRF (~100 MB each).
# Needs podman (or docker). No USB device or desktop is needed: the check skips those.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE="$(command -v podman || command -v docker || true)"
[ -n "$ENGINE" ] || { echo "needs podman or docker" >&2; exit 2; }

MOUNTS=(-v "$REPO:/repo:ro")
if [ "${1:-}" = --debs ]; then
    MOUNTS+=(-v "$(cd "${2:?--debs needs a directory}" && pwd):/root/Downloads:ro"); shift 2
fi
[ $# -gt 0 ] || set -- ubuntu:22.04 ubuntu:24.04 ubuntu:26.04

pass=(); failed=()
for img in "$@"; do
    echo "=== $img"
    # apt-get update first: base images ship with empty package lists.
    # shellcheck disable=SC2016  # the script runs inside the container, not here
    if "$ENGINE" run --rm "${MOUNTS[@]}" -e DEBIAN_FRONTEND=noninteractive "$img" bash -c '
            set -e
            apt-get update -qq
            /repo/install.sh --yes
            echo "--- re-run (must change nothing)"
            /repo/install.sh --yes | tee /tmp/rerun
            grep -q "Nothing to change" /tmp/rerun
            /repo/uninstall.sh --yes
            ! dpkg-query -W -f="\${Status}" spectraware 2>/dev/null | grep -q "ok installed"
        '; then pass+=("$img"); else failed+=("$img"); fi
done
echo; echo "passed: ${pass[*]:-none}"; echo "failed: ${failed[*]:-none}"
[ "${#failed[@]}" -eq 0 ]
