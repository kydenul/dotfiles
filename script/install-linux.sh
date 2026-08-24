#!/usr/bin/env bash
# ============================================================================
# Kyden's Dotfiles - Linux Install Script
# Supports Debian/Ubuntu (apt), Fedora (dnf) and Arch (pacman)
# Usage: bash ~/.dotfiles/script/install-linux.sh
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

DOTFILES="$HOME/.dotfiles"

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERR]${NC}  $*"; }

section() {
    echo ""
    echo -e "${CYAN}${BOLD}━━━ $* ━━━${NC}"
    echo ""
}

# Ask user before overwriting an existing symlink/file
safe_link() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        warn "Source not found, skipping: $src"
        return
    fi

    if [ -L "$dst" ]; then
        # Already a symlink — check if it points to the right place
        local current_target
        current_target=$(readlink "$dst")
        if [ "$current_target" = "$src" ]; then
            success "Already linked: $dst -> $src"
            return
        fi
        info "Updating symlink: $dst"
        rm "$dst"
    elif [ -e "$dst" ]; then
        local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing file: $dst -> $backup"
        mv "$dst" "$backup"
    else
        # Ensure parent directory exists
        mkdir -p "$(dirname "$dst")"
    fi

    ln -s "$src" "$dst"
    success "Linked: $dst -> $src"
}

# ── Preflight check ────────────────────────────────────────────────────────
section "Preflight Check"

if [ "$(uname)" != "Linux" ]; then
    error "This script is designed for Linux. Use install-macos.sh instead."
    exit 1
fi

if [ ! -d "$DOTFILES" ]; then
    error "Dotfiles directory not found at $DOTFILES"
    error "Please clone the repo first: git clone <repo> ~/.dotfiles"
    exit 1
fi

info "Dotfiles directory: $DOTFILES"

# Detect distro / package manager
PKG=""
if command -v apt-get &>/dev/null; then
    PKG="apt"
elif command -v dnf &>/dev/null; then
    PKG="dnf"
elif command -v pacman &>/dev/null; then
    PKG="pacman"
else
    error "No supported package manager found (apt/dnf/pacman)."
    error "Install the tools listed below manually, then re-run this script."
fi

if [ -n "$PKG" ]; then
    info "Detected package manager: $PKG"
fi

# ── 1. CLI Tools & Languages ───────────────────────────────────────────────
section "1/6  CLI Tools & Languages"

install_pkg() {
    local pkg="$1"
    case "$PKG" in
        apt)    sudo apt-get update -qq && sudo apt-get install -y "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        pacman) sudo pacman -S --needed --noconfirm "$pkg" ;;
    esac
}

pkg_installed() {
    case "$PKG" in
        apt)    dpkg -s "$pkg" &>/dev/null ;;
        dnf)    rpm -q "$pkg" &>/dev/null ;;
        pacman) pacman -Qi "$pkg" &>/dev/null ;;
    esac
}

# Package name mapping per distro: <dotfiles-name>|<apt>|<dnf>|<pacman>
PACKAGES=(
    "neovim|neovim|neovim|neovim"
    "fd|fd-find|fd-find|fd"
    "ripgrep|ripgrep|ripgrep|ripgrep"
    "git|git|git|git"
    "imagemagick|imagemagick|ImageMagick|imagemagick"
    "mercurial|mercurial|mercurial|mercurial"
    "tmux|tmux|tmux|tmux"
    "zsh|zsh|zsh|zsh"
    "node|nodejs npm|nodejs npm|nodejs npm"
    "go|golang-go|golang|go"
    "python3|python3 python3-venv python3-pip|python3 python3-pip|python python-pip"
    "curl|curl|curl|curl"
)

for entry in "${PACKAGES[@]}"; do
    IFS='|' read -r name apt_name dnf_name pacman_name <<<"$entry"
    case "$PKG" in
        apt)    pkg="$apt_name" ;;
        dnf)    pkg="$dnf_name" ;;
        pacman) pkg="$pacman_name" ;;
    esac
    if [ -n "$PKG" ] && pkg_installed; then
        success "Already installed: $name"
    else
        info "Installing $name ($pkg)..."
        [ -n "$PKG" ] && install_pkg "$pkg" || warn "Failed to install $name (non-fatal)"
    fi
done

# rustup — official installer works everywhere
if ! command -v rustup &>/dev/null && ! command -v cargo &>/dev/null; then
    info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || warn "rustup install failed (non-fatal)"
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
else
    success "Rust toolchain already present"
fi

# tree-sitter CLI — via cargo (available on all distros)
if ! command -v tree-sitter &>/dev/null; then
    info "Installing tree-sitter CLI via cargo..."
    command -v cargo &>/dev/null && cargo install tree-sitter-cli || warn "tree-sitter-cli install failed (non-fatal)"
else
    success "tree-sitter CLI already installed"
fi

# gofumpt — via go install
if ! command -v gofumpt &>/dev/null && command -v go &>/dev/null; then
    info "Installing gofumpt via go install..."
    go install mvdan.cc/gofumpt@latest || warn "gofumpt install failed (non-fatal)"
else
    success "gofumpt skipped or already installed"
fi

# Fonts — try distro packages first, otherwise manual download
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if ! fc-list 2>/dev/null | grep -qi "maple mono"; then
    info "Installing fonts (Hack Nerd Font + Maple Mono NF CN)..."
    FONT_URLS=(
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
        "https://github.com/subframe7536/maple-font/releases/latest/download/MapleMonoNormal-NF-CN-unhinted.zip"
    )
    for url in "${FONT_URLS[@]}"; do
        zip_name="$(basename "$url")"
        tmp_dir="$(mktemp -d)"
        if curl -fsSL "$url" -o "$tmp_dir/$zip_name" && unzip -qo "$tmp_dir/$zip_name" -d "$tmp_dir"; then
            find "$tmp_dir" -name "*.ttf" -exec cp {} "$FONT_DIR/" \; 2>/dev/null || true
            find "$tmp_dir" -name "*.otf" -exec cp {} "$FONT_DIR/" \; 2>/dev/null || true
        else
            warn "Font download failed: $url (non-fatal)"
        fi
        rm -rf "$tmp_dir"
    done
    fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
else
    success "Maple Mono already installed"
fi

# ── 2. Oh My Zsh + Plugins + Theme ─────────────────────────────────────────
section "2/6  Zsh (Oh My Zsh + Powerlevel10k + Plugins)"

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || warn "Oh My Zsh install failed (non-fatal)"
    success "Oh My Zsh installed"
else
    success "Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    success "Powerlevel10k installed"
else
    success "Powerlevel10k already installed"
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    success "zsh-autosuggestions installed"
else
    success "zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    success "zsh-syntax-highlighting installed"
else
    success "zsh-syntax-highlighting already installed"
fi

# ── 3. Tmux Plugin Manager ─────────────────────────────────────────────────
section "3/6  Tmux Plugin Manager (TPM)"

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    success "TPM installed"
else
    success "TPM already installed"
fi

# ── 4. Symlinks ─────────────────────────────────────────────────────────────
section "4/6  Creating Symlinks"

# --- Neovim ---
safe_link "$DOTFILES/nvim" "$HOME/.config/nvim"

# --- Shell ---
safe_link "$DOTFILES/.zshrc" "$HOME/.zshrc"
safe_link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
safe_link "$DOTFILES/.gitmessage" "$HOME/.gitmessage"

# --- Kitty (XDG config is the same on Linux) ---
safe_link "$DOTFILES/kitty" "$HOME/.config/kitty"
safe_link "$DOTFILES/images" "$HOME/.config/images"

# --- Ghostty ---
if [ -d "$DOTFILES/ghostty" ]; then
    safe_link "$DOTFILES/ghostty" "$HOME/.config/ghostty"
fi

# --- Zed ---
if [ -d "$DOTFILES/zed" ]; then
    safe_link "$DOTFILES/zed" "$HOME/.config/zed"
fi

# --- VSCode (Linux path) ---
if [ -d "$DOTFILES/vscode" ]; then
    safe_link "$DOTFILES/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
    safe_link "$DOTFILES/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
fi

# --- Markdownlint ---
safe_link "$DOTFILES/.markdownlint.json" "$HOME/.markdownlint.json"

# --- Claude Code / tclaude (skills, commands) ---
if [ -d "$DOTFILES/agents/skills" ] || [ -d "$DOTFILES/agents/commands" ]; then
    safe_link "$DOTFILES/agents/skills" "$HOME/.claude/skills"
    safe_link "$DOTFILES/agents/commands" "$HOME/.claude/commands"
    safe_link "$DOTFILES/agents/skills" "$HOME/.tclaude/skills"
    safe_link "$DOTFILES/agents/commands" "$HOME/.tclaude/commands"
fi

# ── 5. Git Config ───────────────────────────────────────────────────────────
section "5/6  Git Config"

# Set commit template if .gitmessage exists
if [ -f "$DOTFILES/.gitmessage" ]; then
    git config --global commit.template "$HOME/.gitmessage"
    success "Git commit template set"
fi

# ── 6. Neovim First-Run Setup ──────────────────────────────────────────────
section "6/6  Neovim First-Run Bootstrap"

info "Running Neovim headless to bootstrap lazy.nvim & install plugins..."
info "(This may take a minute on first run...)"
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
success "Neovim plugins synced"

info "Installing Treesitter parsers..."
nvim --headless "+TSUpdateSync" +qa 2>/dev/null || true
success "Treesitter parsers installed"

# Mason will auto-install LSP servers on first file open, but we can trigger it
info "Mason LSP servers will auto-install when you first open a relevant file."

# ── Summary ─────────────────────────────────────────────────────────────────
section "Installation Complete!"

echo -e "${GREEN}${BOLD}Everything is set up! Here's what to do next:${NC}"
echo ""
echo -e "  1. ${BOLD}Restart your terminal${NC} (or run: ${CYAN}source ~/.zshrc${NC})"
echo -e "  2. ${BOLD}Start tmux${NC} and press ${CYAN}prefix + I${NC} (Ctrl-a + I) to install tmux plugins"
echo -e "  3. ${BOLD}Open Neovim${NC} — Mason will auto-install LSP servers on first use"
echo -e "  4. Run ${CYAN}:checkhealth${NC} in Neovim to verify everything works"
echo ""
echo -e "${YELLOW}Notes for Linux:${NC}"
echo -e "  - ${YELLOW}pngpaste / im-select are macOS-only and were skipped${NC}"
echo -e "  - Check that your distro's neovim is >= 0.9 (${CYAN}nvim --version${NC});"
echo -e "    otherwise install it from https://github.com/neovim/neovim/releases"
echo -e "  - Ghostty may need a manual install depending on your distro"
echo ""
echo -e "${GREEN}${BOLD}Enjoy your dev environment! ${NC}"
