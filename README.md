# dotfiles

Personal development environment configuration for macOS, featuring Neovim, Zed, VSCode, Kitty, Ghostty, Tmux, and Zsh with Oh My Zsh.

---

## Quick Start

### One-Click Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/kydenul/dotfiles.git ~/.dotfiles

# Copy and customize Zsh configuration
cd ~/.dotfiles
cp .zshrc.example .zshrc
# Edit .zshrc to add your personal settings

# Run the install script
bash ~/.dotfiles/script/install.sh
```

The install script will automatically:

1. Install Homebrew (if not present)
2. Install CLI tools, languages, fonts, and terminal emulators via Homebrew
3. Set up Oh My Zsh with Powerlevel10k theme and plugins
4. Install Tmux Plugin Manager (TPM)
5. Create all necessary symlinks (with safe backup of existing files)
6. Configure Git commit template
7. Bootstrap Neovim plugins and Treesitter parsers

### Manual Installation

<details>
<summary>Click to expand manual setup steps</summary>

#### Prerequisites

```bash
# macOS
brew install neovim fd ripgrep tmux zsh node go python@3 rustup \
  gofumpt curl tree-sitter pngpaste imagemagick latexdiff mercurial im-select
brew install --cask kitty ghostty font-hack-nerd-font font-maple-mono-nf-cn

# Linux (Ubuntu/Debian)
sudo apt install neovim fd-find xsel zsh

# Linux (Arch)
sudo pacman -S neovim xsel zsh

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Create Symlinks

```bash
# Neovim
ln -s ~/.dotfiles/nvim ~/.config/nvim

# Shell & Terminal
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/.gitmessage ~/.gitmessage
ln -s ~/.dotfiles/.markdownlint.json ~/.markdownlint.json

# Kitty
ln -s ~/.dotfiles/kitty ~/.config/kitty
ln -s ~/.dotfiles/images ~/.config/images

# Ghostty
ln -s ~/.dotfiles/ghostty ~/.config/ghostty

# Zed
ln -s ~/.dotfiles/zed ~/.config/zed

# VSCode (macOS)
ln -s ~/.dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Claude Code (agents, skills, commands)
ln -s ~/.dotfiles/claude/agents ~/.claude/agents
ln -s ~/.dotfiles/claude/skills ~/.claude/skills
ln -s ~/.dotfiles/claude/commands ~/.claude/commands
ln -s ~/.dotfiles/claude/agents ~/.claude-internal/agents
ln -s ~/.dotfiles/claude/skills ~/.claude-internal/skills
ln -s ~/.dotfiles/claude/commands ~/.claude-internal/commands

# (Optional) Create secrets file for API keys
cat > ~/.zsh_secrets << 'EOF'
export KNotClaudeAPIToken="your-token-here"
export MOONSHOT="your-key-here"
export GLMKey="your-key-here"
EOF
chmod 600 ~/.zsh_secrets
```

#### Post-Install

```bash
source ~/.zshrc
tmux source-file ~/.tmux.conf  # in tmux session

# (Optional) Enable window drag with Ctrl+Cmd+Click
defaults write -g NSWindowShouldDragOnGesture -bool true
```

</details>

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
sshc, sshk           # SSH shortcuts (DevCloud, K-Claw)
tsbz, tsz            # Translate to Chinese
tsbe, tse            # Translate to English
```

### Tmux Configuration

- **Prefix Key**: `Ctrl-Space` (avoids conflict with Vim)
- **Plugin Manager**: [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)
- **Seamless Navigation**: Integrated with Neovim via [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- **Pane Navigation**: `Ctrl-h/j/k/l` to switch between Tmux panes and Neovim splits
- **Copy Mode**: `Escape` to enter, `v` to select, `y` to yank (Vi-style)
- **Mouse Support**: Enabled
- **Status Bar**: Top position with custom Catppuccin-style colors

### Kitty Terminal

- **Font**: Maple Mono NF CN (18pt)
- **Terminal Type**: `xterm-256color` (for SSH compatibility)
- **Deep Tmux Integration**:
  - `Cmd+1-9` to switch Tmux windows
  - `Cmd+t` to create new Tmux window
  - `Cmd+w` to close current Tmux pane
  - `Cmd+z` to toggle zoom (fullscreen) pane
  - `Cmd+d` / `Cmd+Shift+d` to split panes
  - `Cmd+h` / `Cmd+l` to switch previous/next window
  - `Cmd+;` to switch to previous pane

### Ghostty Terminal

- **Theme**: Catppuccin Mocha
- **Font**: Maple Mono NF CN (18pt)
- **Quick Terminal**: `` Ctrl+` `` (global hotkey, bottom position)
- **Deep Tmux Integration**: Same keybindings as Kitty (`Cmd+1-9`, `Cmd+t`, `Cmd+w`, etc.)

### Zed Editor

- **Font**: Maple Mono NF CN (primary), Hack Nerd Font Mono (fallback)
- **Theme**: Gruvbox (Dark Hard / Light, follows system mode)
- **Vim Mode**: Enabled with system clipboard
- **Base Keymap**: VSCode
- **Features**: Relative line numbers, bar cursor (no blink), soft wrap at editor width
- **SSH**: DevCloud remote development support

---

## Neovim

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
│   ├── plugins/         # 25 plugin configurations
│   └── snippets/        # Custom snippets (cpp, go)
└── lsp/                 # Language-specific LSP configs
    ├── gopls.lua        # Go
    ├── ts_ls.lua        # TypeScript/JavaScript
    ├── clangd.lua       # C/C++
    ├── lua_ls.lua       # Lua
    ├── pylsp.lua        # Python
    ├── bashls.lua       # Bash
    ├── marksman.lua     # Markdown
    ├── intelephense.lua # PHP
    └── cmake.lua        # CMake
```

### Key Features

**Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) - Fast startup, auto-bootstrapping, lockfile support

**LSP & Intelligence**:

- Mason-managed LSP servers (Go, TypeScript, C++, Python, Lua, Bash, Markdown, PHP, CMake)
- Auto-completion (blink-cmp) with LSP, buffer, path, and Codeium AI sources
- Advanced folding with Treesitter and semantic tokens
- Code formatting (conform.nvim) and debugging (nvim-dap)

**Navigation & Search**:

- File explorer (nvim-tree), fuzzy finder (snacks.nvim), outline (aerial)
- Smart jump (flash.nvim), breadcrumbs (dropbar.nvim)

**Git Integration**:

- Sign indicators (gitsigns), full Git client (neogit)

**UI Enhancements**:

- Colorscheme: Catppuccin
- Statusline (lualine), notifications (noice.nvim)
- Dashboard (dashboard-nvim), key hints (which-key)
- Markdown rendering (render-markdown.nvim)

**Editing**:

- Surround (nvim-surround), autopairs (nvim-autopairs)
- Terminal (toggleterm.nvim), AI assistant (sidekick.nvim)
- Custom snippets with LuaSnip (C++, Go)

**Essential Commands**:

```vim
:Lazy           " Plugin manager
:Mason          " LSP/tools manager
:checkhealth    " Health diagnostics
```

### OSC 52 Clipboard (SSH Support)

Automatically enabled when working over SSH (`$SSH_TTY` detected). Allows seamless copy/paste between remote Neovim and local system clipboard using escape sequences.

Configuration in `nvim/lua/custom/options.lua` - up to ~75KB per operation.

> [!TIP] **Commit Message Template**
>
> A structured commit message template is provided in `.gitmessage`. Set it up with:
>
> ```bash
> git config --global commit.template ~/.gitmessage
> ```

---

## Claude Code

This repository includes custom configurations for [Claude Code](https://claude.ai/code):

### Agents (11)

Specialized agents for different development tasks:

`api-designer`, `code-reviewer`, `database-optimizer`, `debugger`, `git-workflow-manager`, `golang-pro`, `microservices-architect`, `performance-engineer`, `refactoring-specialist`, `sql-pro`, `test-automator`

### Commands (2)

- `commit` - Structured git commit workflow
- `code-review` - Code review command

### Skills (2)

- `drawio` - Generate draw.io diagrams from descriptions
- `ifbook-automation` - Auto-generate test cases for ifbook API platform

### Setup

```bash
# Symlink to both .claude and .claude-internal
ln -s ~/.dotfiles/claude/agents ~/.claude/agents
ln -s ~/.dotfiles/claude/skills ~/.claude/skills
ln -s ~/.dotfiles/claude/commands ~/.claude/commands
ln -s ~/.dotfiles/claude/agents ~/.claude-internal/agents
ln -s ~/.dotfiles/claude/skills ~/.claude-internal/skills
ln -s ~/.dotfiles/claude/commands ~/.claude-internal/commands
```

---

## Key Mappings

**Leader Key**: `<Space>`

### Window & File Management

| Key                    | Action                                    |
| ---------------------- | ----------------------------------------- |
| `\` / `\|`            | Split window horizontally / vertically    |
| `<C-h/j/k/l>`         | Navigate between windows (and Tmux panes) |
| `<leader>h/j/k/l`     | Resize windows                            |
| `<leader>w`            | Save file                                 |
| `<leader>q` / `<leader>Q` | Quit window / Quit all                |
| `<leader>e`            | Toggle file explorer                      |

### Navigation & Editing

| Key          | Action                         |
| ------------ | ------------------------------ |
| `jk`         | Exit insert mode               |
| `H` / `L`   | Move to start / end of line    |
| `{` / `}`    | Move to prev / next paragraph  |
| `%`          | Jump between matching brackets |
| `*` / `#`    | Search word forward / backward |
| `<leader>nh` | Clear search highlights        |

### Visual Mode

| Key       | Action                              |
| --------- | ----------------------------------- |
| `J` / `K` | Move selected lines up / down       |
| `<` / `>` | Indent / dedent (keeps selection)   |
| `p`       | Paste without copying replaced text |

### Plugin Shortcuts

| Key                | Action                       |
| ------------------ | ---------------------------- |
| `<leader>ff`       | Find files (snacks.nvim)     |
| `<leader>fg`       | Find grep (snacks.nvim)      |
| `<leader>fb`       | Find buffers (snacks.nvim)   |
| `<leader>/`        | Search in current file       |
| `<leader>rn`       | LSP rename (IncRename)       |
| `<leader>g`        | Open Git interface (Neogit)  |
| `,`                | Flash jump to position       |
| `gc` / `gcc`       | Comment toggle               |
| `gt` / `gT`        | Next / previous buffer       |
| `gz<motion><char>` | Add surroundings             |
| `gzd<char>`        | Delete surroundings          |
| `<C-t>`            | Toggle terminal              |

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
- [Ghostty](https://ghostty.org/)
- [Zed](https://zed.dev/)
- [Claude Code](https://claude.ai/code)
