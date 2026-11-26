#!/usr/bin/env bash
# Compatibility entry point; prefer tclaude-proxy agent <command>.
set -euo pipefail

PROXY_AGENT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$#" -eq 0 ]; then
    set -- status
fi
exec /bin/bash "$PROXY_AGENT_SCRIPT_DIR/tclaude-proxy" agent "$@"
