#!/usr/bin/env bash
# ============================================================================
# rex-tunnel-agent — launchd 守护，用 SSH 把远程 Rex server 的 Unix socket 转发到本机
# Docs: ~/.dotfiles/docs/rex-remote.md
#
# Usage:
#   bash ~/.dotfiles/script/rex-tunnel-agent.sh install     安装并启动
#   bash ~/.dotfiles/script/rex-tunnel-agent.sh uninstall    卸载
#   bash ~/.dotfiles/script/rex-tunnel-agent.sh status       查看状态
#   bash ~/.dotfiles/script/rex-tunnel-agent.sh logs         查看日志
#
# Env (install 时生效):
#   REX_TUNNEL_HOST         ~/.ssh/config 里的 Host 别名        (default: DevCloud)
#   REX_TUNNEL_REMOTE_SOCK  远程 Rex server socket             (default: /run/user/0/rex/server.sock)
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

SSH_HOST="${REX_TUNNEL_HOST:-DevCloud}"
REMOTE_SOCK="${REX_TUNNEL_REMOTE_SOCK:-/run/user/0/rex/server.sock}"
HOST_SLUG="$(echo "$SSH_HOST" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9.\n-' '-')"

LABEL="com.kyden.rex-tunnel.$HOST_SLUG"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
# ~/.ssh is 0700, so only this user can reach the forwarded socket — unlike a
# loopback TCP port, which every local process could connect to.
LOCAL_SOCK="$HOME/.ssh/rex-$HOST_SLUG.sock"
LOG_DIR="$HOME/Library/Logs/rex-tunnel"
LOG_ERR="$LOG_DIR/$HOST_SLUG.log"

cmd_install() {
    section "Installing $LABEL"

    # BatchMode: launchd can't answer a password or passphrase prompt, so fail
    # fast here instead of looping on auth errors in the background.
    info "checking non-interactive ssh to $SSH_HOST"
    if ! ssh -o BatchMode=yes -o ConnectTimeout=10 "$SSH_HOST" "test -S '$REMOTE_SOCK'"; then
        error "cannot reach $REMOTE_SOCK on $SSH_HOST without a prompt"
        error "check ssh keys, and that the Rex server is running there (rex server status)"
        exit 1
    fi
    success "remote socket present"

    mkdir -p "$LOG_DIR" "$(dirname "$PLIST")"

    # ServerAlive 15s x 3: a dead link is noticed in ~45s, ssh exits, and
    # KeepAlive redials. Sessions live on the server, so a redial loses nothing.
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
        <string>/usr/bin/ssh</string>
        <string>-N</string>
        <string>-o</string><string>BatchMode=yes</string>
        <string>-o</string><string>ConnectTimeout=10</string>
        <string>-o</string><string>ServerAliveInterval=15</string>
        <string>-o</string><string>ServerAliveCountMax=3</string>
        <string>-o</string><string>ExitOnForwardFailure=yes</string>
        <string>-o</string><string>StreamLocalBindUnlink=yes</string>
        <string>-L</string>
        <string>$LOCAL_SOCK:$REMOTE_SOCK</string>
        <string>$SSH_HOST</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <!-- Seconds between redials while the network is down. -->
    <key>ThrottleInterval</key>
    <integer>10</integer>

    <key>StandardErrorPath</key>
    <string>$LOG_ERR</string>
</dict>
</plist>
EOF

    # bootout first so re-running install picks up plist changes.
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST"

    success "installed — tunnel $LOCAL_SOCK -> $SSH_HOST:$REMOTE_SOCK"
    echo ""
    info "Rex for Mac: Add Remote Host… -> $LOCAL_SOCK"
    info "CLI:         rex -S unix://$LOCAL_SOCK ls"
    info "verify with: bash $0 status"
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

    rm -f "$LOCAL_SOCK"
    info "the remote Rex server is untouched and still running"
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
            grep -E "state|pid|last exit code|runs" | sed 's/^[[:space:]]*/         /' || true
    else
        warn "not loaded"
    fi

    section "tunnel"

    if [ -S "$LOCAL_SOCK" ]; then
        success "socket present: $LOCAL_SOCK"
    else
        warn "socket missing: $LOCAL_SOCK"
    fi

    if command -v rex >/dev/null 2>&1; then
        rex -S "unix://$LOCAL_SOCK" --timeout 5s server status 2>&1 |
            grep -E "^(you|version|sessions|error)" || warn "Rex server not reachable through the tunnel"
    else
        info "rex CLI not in PATH — skipping server check"
    fi
}

cmd_logs() {
    section "tunnel log"

    if [ -s "$LOG_ERR" ]; then
        echo -e "${BOLD}── $LOG_ERR ──${NC}"
        tail -30 "$LOG_ERR"
    else
        info "no ssh output yet"
    fi
}

usage() {
    sed -n '3,14p' "$0" | sed 's/^# \{0,1\}//'
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
