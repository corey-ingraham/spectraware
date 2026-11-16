#!/usr/bin/env bash
# install.sh - install thinkRF SpectraWare on Ubuntu and set up the R6000 for USB.
#
# Shows every change it will make (with the exact command) and asks before running
# anything. Safe to re-run: steps that are already done are skipped.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$HERE/lib/common.sh"

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Installs thinkRF SpectraWare from thinkRF's official package and prepares this machine
for an R6000 on USB. Lists every change first and asks before making it.

  --deb PATH          use this SpectraWare .deb instead of finding/downloading one
  --ethernet          also allow R6000 network discovery replies through the ufw firewall
  --no-modemmanager   don't add the rule that stops ModemManager probing the R6000
  --print-commands    print the commands that would run, then exit (do it yourself)
  -y, --yes           don't ask; accept the listed changes
  --check             verify an existing install; changes nothing
  --allow-unknown     accept a .deb whose checksum is not in versions.tsv
  --force             continue on an untested Ubuntu release (uses the 24.04 build)
  -h, --help          this help

Without --deb, it looks for the right file in ~/Downloads and the download cache
(~/.cache/spectraware), then downloads it from thinkRF. The checksum is always verified.
EOF
}

DEB=""; ETHERNET=0; MM=1; PRINT=0; YES=0; CHECK=0; ALLOW_UNKNOWN=0; FORCE=0
while [ $# -gt 0 ]; do
    case "$1" in
        --deb)              DEB="${2:?--deb needs a path}"; shift 2 ;;
        --deb=*)            DEB="${1#*=}"; shift ;;
        --ethernet)         ETHERNET=1; shift ;;
        --no-modemmanager)  MM=0; shift ;;
        --print-commands)   PRINT=1; shift ;;
        -y|--yes)           YES=1; shift ;;
        --check)            CHECK=1; shift ;;
        --allow-unknown)    ALLOW_UNKNOWN=1; shift ;;
        --force)            FORCE=1; shift ;;
        -h|--help)          usage; exit 0 ;;
        *)                  die "unknown option: $1 (see --help)" ;;
    esac
done

if [ "$CHECK" = 1 ]; then run_check; exit $?; fi

detect_os
select_version
say "${C_B}SpectraWare installer${C_0} - $OS_NAME, using thinkRF's '$BUILD' build of SpectraWare $VERSION"

# --- 1. SpectraWare package ---------------------------------------------------
current="$(installed_version)"
if [ "$current" = "$VERSION" ]; then
    ok "SpectraWare $VERSION already installed"
else
    [ -n "$current" ] && say "  SpectraWare $current is installed; it will be upgraded to $VERSION"
    if [ -n "$DEB" ]; then
        [ -f "$DEB" ] || die "no such file: $DEB"
        DEB="$(cd "$(dirname "$DEB")" && pwd)/$(basename "$DEB")"
        if [ "$(sha_of "$DEB")" != "$SHA256" ]; then
            grep -q "$(sha_of "$DEB")" "$HERE/versions.tsv" \
                && die "$DEB is a known build, but not the one for this Ubuntu ($BUILD: $FILE)"
            [ "$ALLOW_UNKNOWN" = 1 ] || die "$DEB checksum is not one this installer knows (--allow-unknown to use it anyway)"
            warn "using $DEB with an unverified checksum (--allow-unknown)"
        fi
    else
        for cand in "$USER_HOME/Downloads/$FILE" "$CACHE_DIR/$FILE"; do
            if [ -f "$cand" ]; then
                if [ "$(sha_of "$cand")" = "$SHA256" ]; then DEB="$cand"; break; fi
                warn "ignoring $cand: checksum does not match thinkRF's file"
            fi
        done
    fi
    if [ -z "$DEB" ]; then
        DEB="$CACHE_DIR/$FILE"
        if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
            add_root_step "Install curl to download the package" apt-get install -y curl
        fi
        if command -v curl >/dev/null 2>&1 || ! command -v wget >/dev/null 2>&1; then
            add_raw_step "Download SpectraWare $VERSION from thinkRF (~100 MB)" \
                "mkdir -p $(printf %q "$CACHE_DIR") && curl --proto =https -fL --retry 3 -o $(printf %q "$DEB") $(printf %q "$URL")"
        else
            add_raw_step "Download SpectraWare $VERSION from thinkRF (~100 MB)" \
                "mkdir -p $(printf %q "$CACHE_DIR") && wget --https-only -O $(printf %q "$DEB") $(printf %q "$URL")"
        fi
        add_raw_step "Verify the download matches thinkRF's published file (sha256)" \
            "echo $(printf %q "$SHA256  $DEB") | sha256sum -c -"
    else
        ok "found verified package: $DEB"
    fi
    # apt (not dpkg -i) so dependencies are pulled in. The package itself installs
    # the USB permission rule (/etc/udev/rules.d/99-thinkrf.rules) and reloads udev.
    add_root_step "Install SpectraWare and its dependencies (adds thinkRF's USB permission rule)" \
        apt-get install -y "$DEB"
fi

# --- 2. ModemManager rule ------------------------------------------------------
if [ "$MM" = 1 ] && mm_present; then
    if cmp -s "$MM_RULE_SRC" "$MM_RULE_DST"; then
        ok "ModemManager rule already in place"
    else
        add_root_step "Stop ModemManager probing the R6000's USB serial port (udev rule)" \
            install -m 0644 "$MM_RULE_SRC" "$MM_RULE_DST"
        add_root_step "Reload udev rules (replug the R6000 afterwards if it is connected)" \
            udevadm control --reload-rules
    fi
fi

# --- 3. Taskbar icon ------------------------------------------------------------
# The client window has no icon of its own (blank box in the taskbar) and a WM_CLASS that
# thinkRF's menu entry doesn't match. A login helper sets the logo on its windows; a
# corrected menu entry in /usr/local/share overrides the packaged one.
icon_changed=0
for entry in "${DESKTOP_FILES[@]}"; do
    IFS='|' read -r src dst mode <<<"$entry"
    if ! cmp -s "$src" "$dst"; then
        add_root_step "Taskbar icon fix: install $(basename "$dst")" install -D -m "$mode" "$src" "$dst"
        icon_changed=1
    fi
done
if [ "$icon_changed" = 0 ]; then
    ok "taskbar icon fix already in place"
elif [ "$(id -u)" -ne 0 ] && [ -n "${DISPLAY:-}" ]; then
    # Otherwise it starts at the next login. A copy already running keeps the old code until then.
    add_step "Start the window icon helper now (it starts by itself at each login)" setsid -f "$ICON_HELPER"
fi

# --- 4. Firewall, Ethernet only --------------------------------------------------
if [ "$ETHERNET" = 1 ]; then
    if command -v ufw >/dev/null 2>&1 && ufw_enabled; then
        # ufw skips a rule that already exists, so this is safe to repeat.
        add_root_step "Allow R6000 discovery replies (UDP from port 18331) through ufw" \
            ufw allow "${UFW_RULE[@]}" comment 'thinkRF R6000 discovery'
    else
        ok "ufw not enabled - nothing to open for Ethernet"
    fi
fi

# --- Review, then run ---------------------------------------------------------
if [ "${#STEP_CMD[@]}" -eq 0 ]; then
    say "Nothing to change."
    run_check; exit $?
fi

say ""
say "${C_B}These changes will be made:${C_0}"
show_steps
say ""

if [ "$PRINT" = 1 ]; then
    say "(--print-commands: nothing was run. Run the commands above yourself, then ./install.sh --check)"
    exit 0
fi
if ! confirm "Make these changes?"; then
    say "Nothing changed. To do it yourself: ./install.sh --print-commands"
    exit 0
fi

run_steps
say ""
run_check
