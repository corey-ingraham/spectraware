#!/usr/bin/env bash
# uninstall.sh - remove SpectraWare and everything install.sh added.
# Lists the changes and asks first, like install.sh.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$HERE/lib/common.sh"

YES=0; PRINT=0
while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes)         YES=1; shift ;;
        --print-commands) PRINT=1; shift ;;
        -h|--help)        say "Usage: ./uninstall.sh [-y|--yes] [--print-commands]"; exit 0 ;;
        *)                die "unknown option: $1" ;;
    esac
done

[ -n "$(installed_version)" ] && add_root_step "Remove SpectraWare (purge; also removes thinkRF's USB rule)" apt-get purge -y "$PKG"
if [ -f "$MM_RULE_DST" ]; then
    add_root_step "Remove the ModemManager rule" rm -f "$MM_RULE_DST"
    add_root_step "Reload udev rules" udevadm control --reload-rules
fi
for entry in "${DESKTOP_FILES[@]}"; do
    IFS='|' read -r _ dst _ <<<"$entry"
    if [ -e "$dst" ]; then add_root_step "Remove $dst (taskbar icon fix)" rm -f "$dst"; fi
done
[ -d "$(dirname "$ICON_HELPER")" ] && add_root_step "Remove $(dirname "$ICON_HELPER") if empty" rmdir --ignore-fail-on-non-empty "$(dirname "$ICON_HELPER")"
if pgrep -u "$(id -u)" -x "$ICON_HELPER_PROC" >/dev/null 2>&1; then
    add_raw_step "Stop the running window icon helper" "pkill -u $(id -u) -x $ICON_HELPER_PROC || true"
fi
if command -v ufw >/dev/null 2>&1 && ufw_enabled; then
    # Harmless if the rule was never added (ufw reports a non-existent rule and exits 0).
    add_root_step "Remove the R6000 discovery firewall rule, if present" ufw delete allow "${UFW_RULE[@]}"
fi

if [ "${#STEP_CMD[@]}" -eq 0 ]; then say "Nothing to remove."; exit 0; fi
say "${C_B}These changes will be made:${C_0}"; show_steps; say ""
[ -d "$CACHE_DIR" ] && say "Downloaded packages are kept in $CACHE_DIR (delete it yourself if you like)."
if [ "$PRINT" = 1 ]; then exit 0; fi
confirm "Remove SpectraWare?" || { say "Nothing changed."; exit 0; }
run_steps
say "SpectraWare removed."
