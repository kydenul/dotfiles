# dotfiles

Personal development environment configuration for macOS, featuring Neovim, VSCode, Kitty, Tmux, and Zsh with Oh My Zsh.

---

## Quick Start

### Prerequisites

```bash
# macOS packages
brew install neovim fd im-select pngpaste latex2html latexdiff mercurial

# Linux (Ubuntu/Debian)
sudo apt install neovim fd-find xsel

# Linux (Arch)
sudo pacman -S neovim xsel
```

### Installation

```bash
# Clone the repository
git clone https://github.com/kydenul/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Copy and customize Zsh configuration
cp .zshrc.example .zshrc
# Edit .zshrc to add your personal settings

# (Optional) Create secrets file for API keys
cat > ~/.zsh_secrets << 'EOF'
export KNotClaudeAPIToken="your-token-here"
export MOONSHOT="your-key-here"
export GLMKey="your-key-here"
EOF
chmod 600 ~/.zsh_secrets

# Create symlinks
ln -s ~/.dotfiles/nvim ~/.config/nvim
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/.markdownlint.json ~/.markdownlint.json

# VSCode (macOS)
ln -s ~/.dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Windsurf (macOS)
ln -s ~/.dotfiles/windsurf/keybindings.json ~/Library/Application\ Support/Windsurf/User/keybindings.json
ln -s ~/.dotfiles/windsurf/settings.json ~/Library/Application\ Support/Windsurf/User/settings.json

# Reload configurations
source ~/.zshrc
tmux source-file ~/.tmux.conf  # in tmux session
```

---

## Terminal Environment

### Zsh Configuration

- **Framework**: Oh My Zsh
- **Theme**: Powerlevel10k
- **Plugins**: z, git, extract, web-search, zsh-autosuggestions, zsh-syntax-highlighting

**Custom Aliases**:
```bash
vim -> nvim          # Use Neovim by default
la, ll, c            # Navigation shortcuts
gs, gp, gm, ga       # Git shortcuts
gor, gob             # Go shortcuts (go run, go build)
kicat, kssh, kdiff   # Kitty kittens
```

### Tmux Configuration

- **Prefix Key**: `Ctrl-Space` (avoids conflict with Vim)
- **Pane Navigation**: `h/j/k/l` (Vim-style)
- **Copy Mode**: `Escape` to enter, `v` to select (Vi-style)
- **Mouse Support**: Enabled
- **Status Bar**: Top position with custom colors

### Kitty Terminal

- **Font**: Hack Nerd Font Mono (16pt)
- **Terminal Type**: `xterm-256color` (for SSH compatibility)
- **Tab Navigation**: `Cmd+1-9` to switch tabs
- **Window Navigation**: `Cmd+[/]` for prev/next

## Neovim (Nvim)

### Overview

Modern Neovim configuration powered by **lazy.nvim** with comprehensive LSP support, AI-assisted coding, and an extensive plugin ecosystem.

**Requirements**:
- [Neovim 0.9+](https://github.com/neovim/neovim/releases)
- [Nerd Font](https://www.nerdfonts.com/) (for icons)

**Configuration Structure**:
```
nvim/
├── init.lua              # Entry point
├── lua/
│   ├── klazy.lua        # Lazy.nvim bootstrap
│   ├── custom/          # Core config (options, keymaps, folding, utils)
│   ├── plugins/         # 34 plugin configurations
│   └── snippets/        # Custom snippets (cpp, go)
└── lsp/                 # Language-specific LSP configs
```

### Key Features

**Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) - Fast startup, auto-bootstrapping, lockfile support

**LSP & Intelligence**:
- Mason-managed LSP servers (Go, TypeScript, C++, Python, Lua, Bash, Markdown, PHP)
- Auto-completion (nvim-cmp) with LSP, buffer, path sources
- GitHub Copilot integration
- Advanced folding (nvim-ufo) with LSP/Treesitter
- Code formatting (conform.nvim) and debugging (nvim-dap)

**Navigation & Search**:
- File explorer (nvim-tree), fuzzy finder (telescope), outline (aerial)
- Smart jump (flash.nvim), project-wide search (nvim-spectre)

**Git Integration**:
- Sign indicators (gitsigns), full Git client (neogit), wrapper (vim-fugitive)

**UI Enhancements**:
- Colorscheme: Catppuccin
- Statusline (lualine), buffer tabs (bufferline)
- Enhanced UI (noice.nvim), diagnostics (trouble.nvim)
- Markdown rendering (render-markdown.nvim)

**Essential Commands**:
```vim
:Lazy           " Plugin manager
:Mason          " LSP/tools manager
:checkhealth    " Health diagnostics
:Copilot auth   " GitHub Copilot setup (optional)
```

### OSC 52 Clipboard (SSH Support)

Automatically enabled when working over SSH (`$SSH_TTY` detected). Allows seamless copy/paste between remote Neovim and local system clipboard using escape sequences.

Configuration in `nvim/lua/custom/options.lua` - up to ~75KB per operation.

---

## Key Mappings

**Leader Key**: `<Space>`

### Window & File Management
| Key | Action |
|-----|--------|
| `<leader>sv` / `<leader>sh` | Split window vertically / horizontally |
| `<leader>h/j/k/l` | Navigate between windows |
| `<C-h/j/k/l>` | Resize windows |
| `<leader>w` | Save file |
| `<leader>q` / `<leader>Q` | Quit window / Quit all |
| `<leader>e` | Toggle file explorer |

### Navigation & Editing
| Key | Action |
|-----|--------|
| `jk` | Exit insert mode |
| `H` / `L` | Move to start / end of line |
| `{` / `}` | Move to prev / next paragraph |
| `%` | Jump between matching brackets |
| `*` / `#` | Search word forward / backward |
| `<leader>nh` | Clear search highlights |

### Visual Mode
| Key | Action |
|-----|--------|
| `J` / `K` | Move selected lines up / down |
| `<` / `>` | Indent / dedent (keeps selection) |
| `p` | Paste without copying replaced text |

### Plugin Shortcuts
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Find grep (Telescope) |
| `<leader>fb` | Find buffers (Telescope) |
| `<leader>/` | Search in current file |
| `<leader>rn` | LSP rename |
| `<leader>g` | Open Git interface (Neogit) |
| `,` | Flash jump to position |
| `gc` / `gcc` | Comment toggle |
| `gt` / `gT` | Next / previous buffer |
| `gz<motion><char>` | Add surroundings |
| `gzd<char>` | Delete surroundings |
| `<C-t>` | Toggle terminal |

---

## Troubleshooting

### Markdown Preview Issues
If you encounter `Error: Cannot find module 'tslib'`, manually install the preview bundle:
```vim
:call mkdp#util#install()
```

### Linux Clipboard Not Working
Install clipboard support:
```bash
# Arch Linux
sudo pacman -S xsel

# Ubuntu/Debian
sudo apt install xsel
```

### Plugin Installation Fails
```vim
:Lazy restore     " Restore from lockfile
:Lazy clear       " Clear cache
:checkhealth lazy " Check diagnostics
```

### LSP Not Working
```vim
:Mason            " Install/reinstall language servers
:LspInfo          " Check LSP status
:checkhealth lsp  " Check LSP diagnostics
```

---

## License

MIT License - Feel free to use and modify for your own setup.

---

## References

- [Neovim](https://neovim.io/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Kitty Terminal](https://sw.kovidgoyal.net/kitty/)
