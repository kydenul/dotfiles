#!/usr/bin/env bash
# ============================================================================
# Kyden's Dotfiles - Install Entry Point (OS dispatcher)
# Detects the OS and delegates to the matching install script.
# Usage: bash ~/.dotfiles/script/install.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname)" in
    Darwin)
        echo "Detected macOS — running install-macos.sh..."
        exec bash "$SCRIPT_DIR/install-macos.sh" "$@"
        ;;
    Linux)
        echo "Detected Linux — running install-linux.sh..."
        exec bash "$SCRIPT_DIR/install-linux.sh" "$@"
        ;;
    *)
        echo "Unsupported OS: $(uname). Only macOS and Linux are supported." >&2
        exit 1
        ;;
esac
