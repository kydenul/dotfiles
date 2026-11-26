#!/usr/bin/env bash
# Shared CLI dispatch for the tclaude and tcodex gateways.

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


need() {
    command -v "$1" >/dev/null 2>&1 || {
        error "Required command not found: $1"
        exit 1
    }
}

TCODEX_HELPER="$PROXY_LIB_DIR/tcodex.py"
tcodex_proxy() { python3 "$TCODEX_HELPER" "$@"; }

# shellcheck source=tclaude.sh
source "$PROXY_LIB_DIR/tclaude.sh"

# Keep the original tclaude commands usable explicitly; launchd's default
# ensure now maintains both installed gateways, with independent failures.
cmd_gateways() {
    local command="$1" target="${2:-all}" rc=0
    case "$target" in
    tclaude) "cmd_$command" ;;
    tcodex) tcodex_proxy "$command" ;;
    all)
        section "tclaude"
        "cmd_$command" || rc=1
        if command -v tcodex >/dev/null 2>&1; then
            section "tcodex"
            tcodex_proxy "$command" || rc=1
        fi
        return "$rc"
        ;;
    *) error "expected tclaude or tcodex, got '$target'"; return 1 ;;
    esac
}

# Ports drift, so both sync paths key off the live daemon metadata rather than any
# stored value. See sync_claude / sync_pi for the per-app semantics.
cmd_sync_ccswitch() {
    need python3

    local apply=0 app="" arg
    for arg in "$@"; do
        case "$arg" in
        --apply) apply=1 ;;
        claude | pi)
            # Reject a second app rather than silently letting the last one win:
            # `sync-ccswitch claude pi --apply` must not leave claude unwritten
            # while looking like it succeeded.
            if [ -n "$app" ] && [ "$app" != "$arg" ]; then
                error "sync-ccswitch: pick one app, or none for both (got '$app' and '$arg')"
                return 1
            fi
            app="$arg"
            ;;
        "") ;;
        *)
            error "sync-ccswitch: unexpected argument '$arg'"
            echo ""
            usage
            return 1
            ;;
        esac
    done
    [ -n "$app" ] || app="all"

    [ "$apply" -eq 1 ] || warn "dry run — re-run with --apply to write changes"

    local rc=0
    case "$app" in
    claude) sync_claude "$apply" || rc=1 ;;
    pi) sync_pi "$apply" || rc=1 ;;
    all)
        sync_claude "$apply" || rc=1
        sync_pi "$apply" || rc=1
        ;;
    esac
    return "$rc"
}

usage() {
    # Bounded by line count as well as the END-USAGE sentinel: if that marker is
    # ever lost, print nothing extra rather than dumping the whole script.
    sed -n '/^# Usage:/,/^# END-USAGE/p' "$PROXY_BIN" | sed '$d; s/^# \{0,1\}//' | head -40
}

main() {
    need curl
    need python3

    case "${1:-status}" in
    status) cmd_gateways status "${2:-all}" ;;
    port) cmd_port ;;
    url)
        case "${2:-tclaude}" in
        tclaude) cmd_url ;;
        tcodex) tcodex_proxy url ;;
        *) error "url: expected tclaude or tcodex"; return 1 ;;
        esac
        ;;
    env) cmd_env ;;
    ensure) cmd_gateways ensure "${2:-all}" ;;
    doctor) cmd_doctor ;;
    sync-ccswitch)
        shift
        cmd_sync_ccswitch "$@"
        ;;
    -h | --help | help) usage ;;
    *)
        error "Unknown command: $1"
        echo ""
        usage
        exit 1
        ;;
    esac
}
