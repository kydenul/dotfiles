#!/usr/bin/env bash
# ============================================================================
# Kyden's Dotfiles - One-Click Install Script
# Tested on macOS (Apple Silicon & Intel)
# Usage: bash ~/.dotfiles/script/install.sh
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

if [ "$(uname)" != "Darwin" ]; then
    error "This script is designed for macOS. Exiting."
    exit 1
fi

if [ ! -d "$DOTFILES" ]; then
    error "Dotfiles directory not found at $DOTFILES"
    error "Please clone the repo first: git clone <repo> ~/.dotfiles"
    exit 1
fi

info "Dotfiles directory: $DOTFILES"
info "macOS $(sw_vers -productVersion) on $(uname -m)"

# ── 1. Homebrew ─────────────────────────────────────────────────────────────
section "1/7  Homebrew"

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for the rest of this script
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

info "Updating Homebrew..."
brew update

# ── 2. CLI Tools & Languages ───────────────────────────────────────────────
section "2/7  CLI Tools & Languages"

# Core tools
BREW_FORMULAS=(
    # Editor
    neovim

    # Neovim plugin dependencies
    fd          # telescope find_files
    ripgrep     # telescope live_grep
    git         # gitsigns, neogit, fugitive
    pngpaste    # image paste support
    imagemagick # image rendering
    latexdiff   # LaTeX diff
    mercurial   # some plugin dependency

    # Shell & Terminal
    tmux
    zsh

    # Languages & runtimes
    node     # LSP servers (ts_ls, prettier, eslint_d, etc.)
    go       # gopls, Go development
    python@3 # pylsp, debugpy, black, isort
    rustup   # Rust toolchain

    # Go formatters (used by conform.nvim)
    gofumpt

    # Other tools
    curl
    tree-sitter # treesitter CLI (auto_install parsers)
)

BREW_CASKS=(
    kitty                 # Terminal emulator
    font-hack-nerd-font   # Nerd Font for icons
    font-maple-mono-nf-cn # Maple Mono font (Kitty & Zed)
)

info "Installing formulae..."
for formula in "${BREW_FORMULAS[@]}"; do
    if brew list "$formula" &>/dev/null; then
        success "Already installed: $formula"
    else
        info "Installing $formula..."
        brew install "$formula" || warn "Failed to install $formula (non-fatal)"
    fi
done

info "Installing casks..."
for cask in "${BREW_CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        success "Already installed: $cask"
    else
        info "Installing $cask..."
        brew install --cask "$cask" || warn "Failed to install $cask (non-fatal)"
    fi
done

# ── 3. Oh My Zsh + Plugins + Theme ─────────────────────────────────────────
section "3/7  Zsh (Oh My Zsh + Powerlevel10k + Plugins)"

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

# ── 4. Tmux Plugin Manager ─────────────────────────────────────────────────
section "4/7  Tmux Plugin Manager (TPM)"

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    success "TPM installed"
else
    success "TPM already installed"
fi

# ── 5. Symlinks ─────────────────────────────────────────────────────────────
section "5/7  Creating Symlinks"

# --- Neovim ---
safe_link "$DOTFILES/nvim" "$HOME/.config/nvim"

# --- Shell ---
safe_link "$DOTFILES/.zshrc" "$HOME/.zshrc"
safe_link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
safe_link "$DOTFILES/.gitmessage" "$HOME/.gitmessage"

# --- Kitty ---
safe_link "$DOTFILES/kitty" "$HOME/.config/kitty"

# --- Background images for Kitty ---
safe_link "$DOTFILES/images" "$HOME/.config/images"

# --- Ghostty ---
if [ -d "$DOTFILES/ghostty" ]; then
    safe_link "$DOTFILES/ghostty" "$HOME/.config/ghostty"
fi

# ── 6. Git Config ───────────────────────────────────────────────────────────
section "6/7  Git Config"

# Set commit template if .gitmessage exists
if [ -f "$DOTFILES/.gitmessage" ]; then
    git config --global commit.template "$HOME/.gitmessage"
    success "Git commit template set"
fi

# ── 7. Neovim First-Run Setup ──────────────────────────────────────────────
section "7/7  Neovim First-Run Bootstrap"

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
echo -e "  2. ${BOLD}Start tmux${NC} and press ${CYAN}prefix + I${NC} (Ctrl-Space + I) to install tmux plugins"
echo -e "  3. ${BOLD}Open Neovim${NC} — Mason will auto-install LSP servers on first use"
echo -e "  4. Run ${CYAN}:checkhealth${NC} in Neovim to verify everything works"
echo ""
echo -e "${YELLOW}Optional:${NC}"
echo -e "  - Run ${CYAN}p10k configure${NC} to set up Powerlevel10k prompt"
echo -e "  - Run ${CYAN}rustup-init${NC} if you need Rust toolchain"
echo -e "  - Install ${CYAN}im-select${NC} if you need input method auto-switching"
echo ""
echo -e "${GREEN}${BOLD}Enjoy your dev environment! ${NC}"
