#!/usr/bin/env bash
# ============================================================================
# tclaude-proxy-agent — launchd 守护，保证 tclaude daemon 常驻
# Docs: ~/.dotfiles/docs/tclaude-proxy.md
#
# Usage:
#   bash ~/.dotfiles/script/tclaude-proxy-agent.sh install     安装并启动
#   bash ~/.dotfiles/script/tclaude-proxy-agent.sh uninstall    卸载
#   bash ~/.dotfiles/script/tclaude-proxy-agent.sh status       查看状态
#   bash ~/.dotfiles/script/tclaude-proxy-agent.sh logs         查看日志
# ============================================================================

set -euo pipefail

# ── Colors & helpers ────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
error() { echo -e "${RED}[ERR]${NC}  $*" >&2; }

section() {
    echo ""
    echo -e "${CYAN}${BOLD}━━━ $* ━━━${NC}"
    echo ""
}

DOTFILES="$HOME/.dotfiles"
LABEL="com.kyden.tclaude-proxy"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
PROXY_BIN="$DOTFILES/script/tclaude-proxy"
LOG_DIR="$HOME/.tclaude/logs/agent"
LOG_OUT="$LOG_DIR/agent.log"
LOG_ERR="$LOG_DIR/agent.err.log"

# Check every 5 minutes. The daemon is long-lived; this only needs to catch
# crashes and reboots, not react instantly.
INTERVAL=300

cmd_install() {
    section "Installing $LABEL"

    if [ ! -x "$PROXY_BIN" ]; then
        if [ -f "$PROXY_BIN" ]; then
            info "making tclaude-proxy executable"
            chmod +x "$PROXY_BIN"
        else
            error "not found: $PROXY_BIN"
            exit 1
        fi
    fi

    if ! command -v tclaude >/dev/null 2>&1; then
        error "tclaude not installed — nothing to guard"
        exit 1
    fi

    mkdir -p "$LOG_DIR" "$(dirname "$PLIST")"

    # PATH must be explicit: launchd agents get a minimal environment, and
    # tclaude-proxy shells out to tclaude/node/sqlite3 from Homebrew.
    local brew_prefix
    brew_prefix="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"

    info "writing $PLIST"
    cat >"$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>$PROXY_BIN</string>
        <string>ensure</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$brew_prefix/bin:$brew_prefix/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>StartInterval</key>
    <integer>$INTERVAL</integer>

    <key>StandardOutPath</key>
    <string>$LOG_OUT</string>

    <key>StandardErrorPath</key>
    <string>$LOG_ERR</string>

    <key>ProcessType</key>
    <string>Background</string>

    <key>LowPriorityIO</key>
    <true/>
</dict>
</plist>
EOF

    # bootout first so re-running install picks up plist changes.
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST"

    success "installed — checks every ${INTERVAL}s and at login"
    echo ""
    info "verify with:  bash $0 status"
    info "logs:         bash $0 logs"
}

cmd_uninstall() {
    section "Uninstalling $LABEL"

    if launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null; then
        success "unloaded"
    else
        warn "was not loaded"
    fi

    if [ -f "$PLIST" ]; then
        rm -f "$PLIST"
        success "removed $PLIST"
    else
        warn "$PLIST not present"
    fi

    info "the tclaude daemon itself is untouched and still running"
    info "logs kept at $LOG_DIR"
}

cmd_status() {
    section "launchd agent"

    if [ ! -f "$PLIST" ]; then
        warn "not installed — run: bash $0 install"
    else
        success "plist present: $PLIST"
    fi

    if launchctl print "gui/$(id -u)/$LABEL" >/dev/null 2>&1; then
        success "loaded"
        launchctl print "gui/$(id -u)/$LABEL" 2>/dev/null |
            grep -E "state|last exit code|runs" | sed 's/^[[:space:]]*/         /' || true
    else
        warn "not loaded"
    fi

    section "tclaude daemon"
    "$PROXY_BIN" status || true
}

cmd_logs() {
    section "agent logs"

    local found=0
    for f in "$LOG_OUT" "$LOG_ERR"; do
        if [ -s "$f" ]; then
            found=1
            echo -e "${BOLD}── $f ──${NC}"
            tail -30 "$f"
            echo ""
        fi
    done

    [ "$found" -eq 1 ] || info "no agent output yet"

    section "tclaude daemon logs (today)"
    local day_dir="$HOME/.tclaude/logs/$(date +%F)"
    if [ -d "$day_dir" ]; then
        local latest
        latest="$(ls -t "$day_dir"/*.log 2>/dev/null | head -1 || true)"
        if [ -n "$latest" ]; then
            echo -e "${BOLD}── $latest ──${NC}"
            # Errors are what matter here; the rest is model-list chatter.
            grep -E "\[Error\]|\[Warning\]" "$latest" | tail -20 ||
                info "no errors or warnings today"
        else
            info "no log files in $day_dir"
        fi
    else
        info "$day_dir not present"
    fi
}

usage() {
    sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'
}

case "${1:-status}" in
install) cmd_install ;;
uninstall) cmd_uninstall ;;
status) cmd_status ;;
logs) cmd_logs ;;
-h | --help | help) usage ;;
*)
    error "Unknown command: $1"
    echo ""
    usage
    exit 1
    ;;
esac
