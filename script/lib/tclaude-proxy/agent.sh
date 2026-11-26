#!/usr/bin/env bash
# launchd management shared by the CLI and the compatibility entry point.

AGENT_LABEL="com.kyden.tclaude-proxy"
AGENT_PLIST="$HOME/Library/LaunchAgents/$AGENT_LABEL.plist"
AGENT_LOG_DIR="$HOME/.tclaude/logs/agent"
AGENT_LOG_OUT="$AGENT_LOG_DIR/agent.log"
AGENT_LOG_ERR="$AGENT_LOG_DIR/agent.err.log"

# Check every 5 minutes. The daemon is long-lived; this only needs to catch
# crashes and reboots, not react instantly.
AGENT_INTERVAL=300

cmd_agent_install() {
    section "Installing $AGENT_LABEL"

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

    mkdir -p "$AGENT_LOG_DIR" "$(dirname "$AGENT_PLIST")"

    # PATH must be explicit: launchd agents get a minimal environment, and
    # tclaude-proxy shells out to tclaude/node/sqlite3 from Homebrew.
    local brew_prefix
    brew_prefix="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"

    info "writing $AGENT_PLIST"
    cat >"$AGENT_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$AGENT_LABEL</string>

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
    <integer>$AGENT_INTERVAL</integer>

    <key>StandardOutPath</key>
    <string>$AGENT_LOG_OUT</string>

    <key>StandardErrorPath</key>
    <string>$AGENT_LOG_ERR</string>

    <!-- launchd tears down the rest of the job's process group when the job
         exits. A daemon started by "tclaude daemon restart" is meant to outlive
         us, so opt out. Verify with: ps -o ppid= -p DAEMON_PID  ->  expect 1. -->
    <key>AbandonProcessGroup</key>
    <true/>

    <key>ProcessType</key>
    <string>Background</string>

    <key>LowPriorityIO</key>
    <true/>
</dict>
</plist>
EOF

    # bootout first so re-running install picks up plist changes.
    launchctl bootout "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$AGENT_PLIST"

    success "installed — checks every ${AGENT_INTERVAL}s and at login"
    echo ""
    info "verify with:  tclaude-proxy agent status"
    info "logs:         tclaude-proxy logs"
}

cmd_agent_uninstall() {
    section "Uninstalling $AGENT_LABEL"

    if launchctl bootout "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null; then
        success "unloaded"
    else
        warn "was not loaded"
    fi

    if [ -f "$AGENT_PLIST" ]; then
        rm -f "$AGENT_PLIST"
        success "removed $AGENT_PLIST"
    else
        warn "$AGENT_PLIST not present"
    fi

    info "the tclaude daemon itself is untouched and still running"
    info "logs kept at $AGENT_LOG_DIR"
}

cmd_agent_status() {
    section "launchd agent"

    if [ ! -f "$AGENT_PLIST" ]; then
        warn "not installed — run: tclaude-proxy agent install"
    else
        success "plist present: $AGENT_PLIST"
    fi

    if launchctl print "gui/$(id -u)/$AGENT_LABEL" >/dev/null 2>&1; then
        success "loaded"
        launchctl print "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null |
            grep -E "state|last exit code|runs" | sed 's/^[[:space:]]*/         /' || true
    else
        warn "not loaded"
    fi

    section "local gateways"
    "$PROXY_BIN" status || true
}
