# lib/common.sh - shared helpers for install.sh and uninstall.sh. Sourced, not executed.
# shellcheck shell=bash
# Variables set here are used by the scripts that source this file.
# shellcheck disable=SC2034

PKG=spectraware
VENDOR_ID=3830
PRODUCT_ID=5301
PKG_RULE=/etc/udev/rules.d/99-thinkrf.rules            # shipped by the thinkRF package
MM_RULE_SRC="$HERE/rules/70-thinkrf-modemmanager.rules"
MM_RULE_DST=/etc/udev/rules.d/70-thinkrf-modemmanager.rules
SANDBOX=/usr/lib/spectraware/chrome-sandbox
UFW_RULE=(proto udp from any port 18331 to any)       # R6000 broadcast-discovery replies

# Taskbar icon fix: the client sets no window icon and reports WM_CLASS S1000_Client, which
# thinkRF's .desktop doesn't name. Repo file -> installed path, mode. See docs/architecture.md.
ICON_HELPER=/usr/local/lib/spectraware/spectraware-window-icon
ICON_HELPER_PROC=spectraware-win                      # its process name (comm, 15 chars)
DESKTOP_FILES=(
    "$HERE/desktop/spectraware-window-icon|$ICON_HELPER|0755"
    "$HERE/desktop/spectraware-window-icon.desktop|/etc/xdg/autostart/spectraware-window-icon.desktop|0644"
    "$HERE/desktop/spectraware.desktop|/usr/local/share/applications/spectraware.desktop|0644"
)

if [ -t 1 ]; then C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_FAIL=$'\033[31m'; C_B=$'\033[1m'; C_0=$'\033[0m'
else C_OK=""; C_WARN=""; C_FAIL=""; C_B=""; C_0=""; fi
say()  { printf '%s\n' "$*"; }
ok()   { printf '  %sok%s    %s\n' "$C_OK" "$C_0" "$*"; }
warn() { printf '  %sWARN%s  %s\n' "$C_WARN" "$C_0" "$*"; }
fail() { printf '  %sFAIL%s  %s\n' "$C_FAIL" "$C_0" "$*"; }
die()  { printf '%serror:%s %s\n' "$C_FAIL" "$C_0" "$*" >&2; exit 1; }

# Root commands go through sudo unless we already are root.
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

# The invoking user's home, even under sudo (for ~/Downloads and the download cache).
USER_HOME="$(getent passwd "${SUDO_USER:-$(id -un)}" | cut -d: -f6)"
CACHE_DIR="$USER_HOME/.cache/spectraware"

# detect_os: sets OS_NAME, CODENAME, BUILD (which thinkRF build to use) or dies.
detect_os() {
    [ -r /etc/os-release ] || die "cannot read /etc/os-release - is this Ubuntu?"
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_NAME="${PRETTY_NAME:-unknown}"
    CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
    if [ "${ID:-}" != ubuntu ] && [ -z "${UBUNTU_CODENAME:-}" ]; then
        die "$OS_NAME is not Ubuntu or an Ubuntu derivative"
    fi
    [ "$(dpkg --print-architecture)" = amd64 ] || die "SpectraWare is amd64-only; this machine is $(dpkg --print-architecture)"
    case "$CODENAME" in
        jammy)    BUILD=jammy ;;                 # 22.04 - thinkRF jammy build
        noble)    BUILD=noble ;;                 # 24.04 - thinkRF noble build
        resolute) BUILD=noble ;;                 # 26.04 - noble build, verified working
        *)
            [ "${FORCE:-0}" = 1 ] || die "Ubuntu '$CODENAME' is untested; supported: 22.04, 24.04, 26.04 (--force uses the noble build)"
            BUILD=noble ;;
    esac
}

# select_version: newest manifest row for $BUILD -> VERSION, SHA256, URL, FILE.
select_version() {
    local row
    row="$(grep -v '^#' "$HERE/versions.tsv" | awk -F'\t' -v b="$BUILD" '$2==b {print; exit}')"
    [ -n "$row" ] || die "versions.tsv has no entry for build '$BUILD'"
    IFS=$'\t' read -r VERSION _ SHA256 URL <<<"$row"
    FILE="$(basename "$URL")"
}

# Prints the installed version, or nothing. Never fails: dpkg-query exits 1 for an unknown package.
installed_version() { { dpkg-query -W -f='${Status} ${Version}\n' "$PKG" 2>/dev/null || true; } | awk '$3=="installed"{print $4}'; }
sha_of()            { sha256sum "$1" | awk '{print $1}'; }
mm_present()        { systemctl list-unit-files ModemManager.service >/dev/null 2>&1 && [ -x /usr/sbin/ModemManager ]; }
ufw_enabled()       { [ -r /etc/ufw/ufw.conf ] && grep -qi '^ENABLED=yes' /etc/ufw/ufw.conf; }

# r6000_devices: sysfs paths of attached R6000s (USB).
r6000_devices() {
    local d
    for d in /sys/bus/usb/devices/*; do
        [ -f "$d/idVendor" ] || continue
        if [ "$(cat "$d/idVendor")" = "$VENDOR_ID" ] && [ "$(cat "$d/idProduct")" = "$PRODUCT_ID" ]; then
            printf '%s\n' "$d"
        fi
    done
    return 0
}

# run_check: read-only verification. Returns non-zero if anything is wrong.
run_check() {
    local bad=0 v d node
    say "${C_B}check:${C_0}"
    v="$(installed_version)"
    if [ -n "$v" ]; then ok "$PKG $v installed"; else fail "$PKG is not installed"; bad=1; fi

    if [ -f "$PKG_RULE" ] && grep -q "$VENDOR_ID" "$PKG_RULE"; then ok "USB permission rule present ($PKG_RULE)"
    else fail "USB permission rule missing: $PKG_RULE (reinstall the package)"; bad=1; fi

    if [ -n "$v" ]; then
        if [ "$(stat -c '%U %a' "$SANDBOX" 2>/dev/null)" = "root 4755" ]; then ok "chrome-sandbox is root-owned 4755"
        else fail "chrome-sandbox permissions wrong - the client will not start (reinstall the package)"; bad=1; fi
    fi

    if mm_present; then
        if cmp -s "$MM_RULE_SRC" "$MM_RULE_DST"; then ok "ModemManager ignores the R6000 ($MM_RULE_DST)"
        else warn "ModemManager may probe the R6000's serial port - run ./install.sh to add the rule"; fi
    fi

    local entry src dst missing=0
    for entry in "${DESKTOP_FILES[@]}"; do
        IFS='|' read -r src dst _ <<<"$entry"
        cmp -s "$src" "$dst" || missing=1
    done
    if [ "$missing" = 0 ]; then ok "taskbar icon fix installed (window icon helper + menu entry)"
    else warn "taskbar icon fix missing or outdated - run ./install.sh to add it"; fi

    if ufw_enabled; then
        say "  info  ufw firewall is enabled - USB needs nothing; for Ethernet discovery see ./install.sh --ethernet"
    fi

    d="$(r6000_devices | head -1)"
    if [ -z "$d" ]; then
        say "  info  no R6000 on USB right now (plug it into a USB 3 port and power it on to test access)"
    else
        node="/dev/bus/usb/$(printf %03d "$(cat "$d/busnum")")/$(printf %03d "$(cat "$d/devnum")")"
        if [ ! -e "$node" ]; then
            say "  info  R6000 visible in /sys but $node does not exist here (container?) - skipping access test"
        elif [ -r "$node" ] && [ -w "$node" ]; then ok "$(cat "$d/product" 2>/dev/null || echo R6000) on USB, readable+writable by $(id -un) ($(cat "$d/speed") Mb/s)"
        else fail "R6000 found but $node is not read/write for $(id -un) - unplug and replug it"; bad=1; fi
        [ "$(cat "$d/speed")" -ge 5000 ] || warn "R6000 is on a USB 2 link ($(cat "$d/speed") Mb/s) - use a USB 3 port for full data rate"
    fi

    if [ -n "$v" ]; then check_server || bad=1; fi
    if [ "$bad" = 0 ]; then say "${C_OK}All checks passed.${C_0}"; else say "${C_FAIL}Some checks failed (see above).${C_0}"; fi
    return "$bad"
}

# "localhost" may resolve to 127.0.0.1 or ::1 depending on the machine; the server binds whichever.
port_open() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null || (exec 3<>"/dev/tcp/::1/$1") 2>/dev/null; }
# The server accepts ONE client per port, then stops listening - so a healthy running app has
# no listener on 3010/3011, only an established connection. Count that as serving.
port_connected() { command -v ss >/dev/null 2>&1 && [ -n "$(ss -Htn state established "( sport = :$1 )" 2>/dev/null)" ]; }
port_served() { port_open "$1" || port_connected "$1"; }

# check_server: the launcher needs spectraware-server answering on 3010 and 3011.
# If SpectraWare is already running, check its ports; otherwise start the server
# briefly on its own, probe, and stop it again. High CPU from the server is normal.
check_server() {
    local pid i
    if pgrep -x spectraware-ser >/dev/null 2>&1 || pgrep -f 'spectraware-server --standalone' >/dev/null 2>&1; then
        if port_served 3010 && port_served 3011; then ok "SpectraWare is running; server is serving 3010 and 3011"; return 0; fi
        fail "spectraware-server is running but neither listening nor connected on 3010/3011 - quit SpectraWare and start it again"; return 1
    fi
    if port_open 3010 || port_open 3011; then
        fail "another program is using port 3010 or 3011 - SpectraWare's server needs both"; return 1
    fi
    # The server is a Qt program: offscreen lets the test run without a display (SSH, containers).
    ( cd /usr/lib/spectraware && QT_QPA_PLATFORM=offscreen LD_LIBRARY_PATH=/usr/lib/spectraware \
        exec ./spectraware-server --standalone ) >/dev/null 2>&1 &
    pid=$!
    for i in $(seq 1 30); do
        if port_open 3010 && port_open 3011; then break; fi
        kill -0 "$pid" 2>/dev/null || break
        sleep 0.5
    done
    if port_open 3010 && port_open 3011; then ok "server starts and answers on 3010 and 3011 (test run stopped)"; i=0
    else fail "spectraware-server did not answer on 3010/3011 within 15 s"; i=1; fi
    kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true
    return "$i"
}

# Planned-change list: every step is shown (description + exact command) before
# anything runs, so the user can approve, opt out, or run the commands themselves.
STEP_DESC=(); STEP_CMD=()
add_step()      { STEP_DESC+=("$1"); shift; STEP_CMD+=("$(printf '%q ' "$@")"); }
add_root_step() { local d="$1"; shift; if [ -n "$SUDO" ]; then add_step "$d" "$SUDO" "$@"; else add_step "$d" "$@"; fi; }
add_raw_step()  { STEP_DESC+=("$1"); STEP_CMD+=("$2"); }   # caller quotes; for pipelines

show_steps() {
    local i
    for i in "${!STEP_DESC[@]}"; do
        printf '  %d. %s\n       %s\n' "$((i + 1))" "${STEP_DESC[$i]}" "${STEP_CMD[$i]% }"
    done
}

# confirm "question": default yes; refuses to guess when there is no terminal.
confirm() {
    [ "${YES:-0}" = 1 ] && return 0
    [ -t 0 ] || die "no terminal to ask on - re-run with --yes to accept, or --print-commands to do it yourself"
    local a; read -r -p "$1 [Y/n] " a
    case "$a" in ""|y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

run_steps() {
    local i
    for i in "${!STEP_CMD[@]}"; do
        say "${C_B}[$((i + 1))/${#STEP_CMD[@]}]${C_0} ${STEP_DESC[$i]}"
        eval "${STEP_CMD[$i]}"
    done
}
