# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for configuring development environments across macOS systems. It includes configurations for:
- Neovim (primary editor with extensive Lua-based plugin configuration)
- Zed (secondary editor with Vim mode)
- VSCode (alternative editor)
- Kitty (terminal emulator)
- Ghostty (alternative terminal emulator)
- Tmux (terminal multiplexer)
- Zsh (shell with Oh My Zsh and Powerlevel10k theme)

## Installation & Setup

### Neovim Setup
```bash
# Install Neovim (requires 0.9+)
brew install neovim

# Dependencies for plugins
brew install latexdiff mercurial fd
brew install im-select pngpaste latex2html

# Create symlink
ln -s ~/.dotfiles/nvim/ ~/.config/nvim

# Plugin management
# Plugins auto-install on first launch via lazy.nvim
# Manual commands:
# :Lazy - Open plugin manager
# :Lazy sync - Install/update plugins
# :Mason - Manage LSP servers
```

### Shell & Terminal Setup
```bash
# Symlink configurations
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/.markdownlint.json ~/.markdownlint.json

# Kitty
ln -s ~/.dotfiles/kitty ~/.config/kitty
ln -s ~/.dotfiles/images ~/.config/images

# Ghostty
ln -s ~/.dotfiles/ghostty ~/.config/ghostty

# VSCode
ln -s ~/.dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Zed
ln -s ~/.dotfiles/zed ~/.config/zed

# Claude skills/commands
ln -s ~/.dotfiles/claude/skills ~/.claude/skills
ln -s ~/.dotfiles/claude/commands ~/.claude/commands

# Reload configurations
source ~/.zshrc
tmux source-file ~/.tmux.conf
```

## Neovim Architecture

### Configuration Structure
```
nvim/
├── init.lua                   # Entry point - loads custom modules and klazy
├── lua/
│   ├── klazy.lua             # Lazy.nvim bootstrap and setup
│   ├── custom/               # Core configuration modules
│   │   ├── options.lua       # Vim options (clipboard, tabs, UI, search)
│   │   ├── keymaps.lua       # Custom key mappings
│   │   ├── folding.lua       # Code folding configuration
│   │   └── util.lua          # Utility functions
│   ├── plugins/              # Plugin configurations (25 files)
│   │   ├── lsp.lua          # LSP setup with mason and lspconfig
│   │   ├── blink-cmp.lua    # Autocompletion engine (with Codeium AI)
│   │   ├── nvim-treesitter.lua
│   │   ├── gitsigns.lua     # Git integration
│   │   ├── which-key.lua    # Key binding hints
│   │   └── ...              # Other plugin configs
│   └── snippets/             # Custom snippets (cpp, go)
└── lsp/                      # Language-specific LSP configs
    ├── gopls.lua
    ├── ts_ls.lua
    ├── clangd.lua
    ├── lua_ls.lua
    ├── pylsp.lua
    ├── bashls.lua
    ├── marksman.lua
    ├── intelephense.lua
    └── cmake.lua
```

### Configuration Loading Order
1. `init.lua` loads in this order:
   - `custom.util` - Utility functions
   - `custom.keymaps` - Key mappings
   - `custom.folding` - Folding setup
   - `klazy` - Plugin manager (bootstraps lazy.nvim and loads all plugins from `lua/plugins/`)
   - `custom.options` - Vim options (loaded last to ensure overrides work)

2. Plugins are lazy-loaded via `lazy.nvim` with automatic bootstrapping on first run
3. LSP servers are managed by Mason and configured in `lsp/` directory

### Key Plugins & Features

**Core Functionality:**
- Plugin Manager: `lazy.nvim` (auto-bootstrapping, lockfile support)
- Colorscheme: `catppuccin` (configured in options.lua)
- Session Management: `auto-session` (auto-saves workspace state)

**Code Intelligence:**
- LSP: `mason.nvim` + `nvim-lspconfig` (Go, TypeScript, C++, Python, Lua, Bash, etc.)
- Completion: `blink-cmp` with LSP, buffer, path, and Codeium AI sources
- Snippets: `LuaSnip` with custom snippets in `lua/snippets/`
- Syntax: `nvim-treesitter` for advanced parsing
- Folding: Custom implementation in `custom/folding.lua` with Treesitter and semantic tokens
- Formatting: `conform.nvim` (async, multi-formatter support)
- Debugging: `nvim-dap` with Mason-installed adapters

**Navigation & Search:**
- File Explorer: `nvim-tree` (sidebar file browser)
- Fuzzy Finder: `snacks.nvim` (picker, files, buffers, grep)
- Quick Jump: `flash.nvim` (smart motion)
- Outline: `aerial.nvim` (code structure sidebar)
- Breadcrumbs: `dropbar.nvim` (winbar breadcrumb navigation)
- Key Hints: `which-key.nvim` (displays available keybindings)

**Git:**
- `gitsigns.nvim` - Sign column indicators
- `neogit` - Full Git client interface

**UI Enhancements:**
- Statusline: `lualine`
- Notifications: `noice.nvim` (replaces default UI)
- Startup: `dashboard-nvim`

**Editing:**
- Surround: `nvim-surround` (add/delete/change surroundings)
- Autopairs: `nvim-autopairs` (auto-close brackets)
- Terminal: `toggleterm.nvim`
- AI Assistant: `sidekick.nvim`

**Markdown:**
- `render-markdown.nvim` - Live rendering in buffer

**Go Development:**
- `gopher.nvim` - Go-specific tooling (tags, tests, etc.)

### SSH/Remote Configuration
When working over SSH, the config automatically detects `$SSH_TTY` and enables OSC 52 clipboard integration for seamless copy/paste between remote and local systems. This is configured in `nvim/lua/custom/options.lua`.

## Shell Configuration (Zsh)

### Key Features
- Framework: Oh My Zsh
- Theme: Powerlevel10k
- Plugins: z, git, extract, web-search, zsh-autosuggestions, zsh-syntax-highlighting

### Custom Aliases
```bash
# Navigation & tools
la, ll, c (clear), vim -> nvim

# Translation (trans-shell)
tsbz, tsz (translate to Chinese)
tsbe, tse (translate to English)

# Kitty kittens
kicat (icat), kssh (ssh), kdiff (diff)

# SSH shortcuts
sshc (ssh DevCloud), sshk (ssh K-Claw)
```

### Environment Setup
- Go: GOPATH at `/Users/kyden/go`, bin directory in PATH
- Java: OpenJDK via Homebrew
- Rust: rustup via Homebrew
- Docker: Colima (Docker host via `~/.colima/default/docker.sock`)
- TERM set to `xterm-256color` for kitty SSH compatibility

## Tmux Configuration

### Key Bindings
- Prefix: `Ctrl-Space` (instead of default Ctrl-b to avoid Vim conflicts)
- Pane navigation: `h/j/k/l` (vim-style)
- Copy mode: `Escape` to enter, `v` to select (vi-style)
- Reload config: `r` (with prefix)

### Features
- Mouse support enabled
- Window numbering starts at 1
- Status bar at top with custom Catppuccin-style colors
- Clipboard integration with OSC 52 support
- Windows automatically renumber when closed

### Plugins (via TPM)
- `tmux-plugins/tmux-sensible` - Sensible defaults
- `christoomey/vim-tmux-navigator` - Seamless Neovim/Tmux pane navigation
- `tmux-plugins/tmux-yank` - Clipboard integration

## Kitty Configuration

### Key Settings
- Font: Maple Mono NF CN, 18pt
- Background: Custom image with blur and opacity
- Terminal: `xterm-256color` (for SSH compatibility)
- Cursor: Block shape with trail effect
- Tab bar: Top position with slant style

### Deep Tmux Integration
Kitty keybindings send Tmux prefix sequences for seamless control:
- `Cmd+1-9` - Switch Tmux windows 1-9
- `Cmd+T` - Create new Tmux window
- `Cmd+D` / `Cmd+Shift+D` - Split Tmux pane horizontally / vertically
- `Cmd+W` - Close current Tmux pane
- `Cmd+R` - Rename current Tmux window
- `Cmd+H` / `Cmd+L` - Previous / next Tmux window
- `Cmd+;` - Switch to previous Tmux pane
- `Cmd+Z` - Toggle Tmux pane zoom (fullscreen)

## Ghostty Configuration

### Key Settings
- Theme: Catppuccin Mocha
- Font: Maple Mono NF CN, 18pt
- Background: Custom image with 0.2 opacity
- Window: Hidden titlebar, saves state
- Quick Terminal: `Ctrl+`` (global hotkey, bottom position)

### Deep Tmux Integration
Same Tmux integration pattern as Kitty:
- `Cmd+1-9` - Switch Tmux windows
- `Cmd+T` - Create new Tmux window
- `Cmd+D` / `Cmd+Shift+D` - Split panes
- `Cmd+W` - Close pane
- `Cmd+R` - Rename window
- `Cmd+H` / `Cmd+L` - Previous / next window
- `Cmd+;` - Previous pane
- `Cmd+Z` - Toggle zoom

## Zed Configuration

### Key Settings
- Font: Maple Mono NF CN (primary), Hack Nerd Font Mono (fallback)
- Theme: Gruvbox (Dark Hard / Light, follows system mode)
- Vim mode enabled with system clipboard
- Base keymap: VSCode
- SSH connections: DevCloud remote development support

### Features
- Relative line numbers enabled
- Cursor: bar shape, no blink
- Soft wrap at editor width, wrap guide at 120
- Outline panel on right side
- Collaboration panel disabled
- Telemetry disabled

## Working with This Repository

### Making Configuration Changes

**Neovim Plugins:**
- New plugins go in `nvim/lua/plugins/` as individual files
- Each plugin file should return a lazy.nvim spec table
- Use `require('lazy').setup({ { import = 'plugins' } })` pattern
- LSP-specific configs go in `nvim/lsp/<server>.lua`

**Custom Options/Keymaps:**
- Edit `nvim/lua/custom/options.lua` for Vim settings
- Edit `nvim/lua/custom/keymaps.lua` for key mappings
- Changes take effect after restarting Neovim or `:source %`

**Shell Configuration:**
- Zsh: Edit `.zshrc` (sourced on new shells)
- Tmux: Edit `.tmux.conf` (reload with `prefix + r`)
- Kitty: Edit `kitty/kitty.conf` (reload with `Ctrl+Shift+F5` or restart)
- Ghostty: Edit `ghostty/config` (auto-reloads on save)
- Zed: Edit `zed/settings.json` and `zed/keymap.json` (auto-reloads on save)

### Testing Changes
```bash
# Neovim
nvim --version  # Check version (requires 0.9+)
nvim -c "checkhealth"  # Check plugin health
nvim -c "Lazy health"  # Check lazy.nvim health

# Shell
zsh -n ~/.zshrc  # Check syntax without executing

# Tmux
tmux source-file ~/.tmux.conf  # Reload config in running session
```

### Language Support

The configuration includes LSP support for:
- **Go:** gopls (with gopher.nvim for Go-specific features)
- **TypeScript/JavaScript:** ts_ls
- **C/C++:** clangd
- **Python:** pylsp
- **Lua:** lua_ls (with Neovim-specific settings)
- **Bash:** bashls
- **Markdown:** marksman
- **PHP:** intelephense
- **CMake:** cmake language server

Each language has a dedicated LSP config file in `nvim/lsp/` that can be customized independently.

## Important Notes

- **Leader key:** `<Space>` in Neovim
- **Colorscheme:** Currently using Catppuccin (see `nvim/lua/custom/options.lua`)
- **Clipboard:** Uses OSC 52 automatically over SSH, native clipboard otherwise
- **Plugin lockfile:** `nvim/lazy-lock.json` pins plugin versions for reproducibility
- **Git commit template:** `.gitmessage` provides structured commit format
- **Markdown linting:** `.markdownlint.json` defines rules for markdown files
- **Terminal fonts:** Maple Mono NF CN is the primary font across Kitty, Ghostty, and Zed
