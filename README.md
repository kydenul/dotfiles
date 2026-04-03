# dotfiles

Personal development environment configuration for macOS, featuring Neovim, VSCode, Kitty, Ghostty, Tmux, and Zsh with Oh My Zsh.

---

## Quick Start

### Prerequisites

```bash
# macOS packages
brew install zsh neovim fd im-select pngpaste latex2html latexdiff mercurial

# mmdc
npm install -g @mermaid-js/mermaid-cli

# Linux (Ubuntu/Debian)
sudo apt install neovim fd-find xsel zsh

# Linux (Arch)
sudo pacman -S neovim xsel zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

# (Optional) Enable window with ctrl+command+click
# Set
defaults write -g NSWindowShouldDragOnGesture -bool true
# UnSet
defaults delete -g NSWindowShouldDragOnGesture

# Create symlinks
ln -s ~/.dotfiles/nvim ~/.config/
ln -s ~/.dotfiles/zed ~/.config/
ln -s ~/.dotfiles/kitty ~/.config/kitty
ln -s ~/.dotfiles/ghostty ~/.config/ghostty
ln -s ~/.dotfiles/images ~/.config/images
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/.markdownlint.json ~/.markdownlint.json

# VSCode (macOS)
ln -s ~/.dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Claude SubAgents
ln -s ~/.dotfiles/claude/agents ~/.claude/agents
ln -s ~/.dotfiles/claude/agents ~/.claude-internal/agents
ln -s ~/.dotfiles/claude/skills ~/.claude/skills
ln -s ~/.dotfiles/claude/skills ~/.claude-internal/skills

ln -s ~/.dotfiles/claude/commands ~/.claude/commands
ln -s ~/.dotfiles/claude/commands ~/.claude-internal/commands

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
- **Plugin Manager**: [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)
- **Seamless Navigation**: Integrated with Neovim via [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- **Pane Navigation**: `Ctrl-h/j/k/l` to switch between Tmux panes and Neovim splits
- **Copy Mode**: `Escape` to enter, `v` to select, `y` to yank (Vi-style)
- **Mouse Support**: Enabled
- **Status Bar**: Top position with custom colors

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

### Ghostty Terminal

- **Theme**: Catppuccin Mocha
- **Font**: Maple Mono NF CN (18pt)
- **Quick Terminal**: `Ctrl+`` (global hotkey, bottom position)
- **Deep Tmux Integration**: Same keybindings as Kitty (Cmd+1-9, Cmd+t, Cmd+w, etc.)

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
│   ├── plugins/         # 25 plugin configurations
│   └── snippets/        # Custom snippets (cpp, go)
└── lsp/                 # Language-specific LSP configs
```

### Key Features

**Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) - Fast startup, auto-bootstrapping, lockfile support

**LSP & Intelligence**:

- Mason-managed LSP servers (Go, TypeScript, C++, Python, Lua, Bash, Markdown, PHP)
- Auto-completion (blink-cmp) with LSP, buffer, path, and Codeium AI sources
- Advanced folding with Treesitter and semantic tokens
- Code formatting (conform.nvim) and debugging (nvim-dap)

**Navigation & Search**:

- File explorer (nvim-tree), fuzzy finder (snacks.nvim), outline (aerial)
- Smart jump (flash.nvim), breadcrumbs (dropbar.nvim)

**Git Integration**:

- Sign indicators (gitsigns), full Git client (neogit)

```bash
git config --global core.editor "nvim"
git config --global commit.template
nvim ~/.gitmessage
git config --global commit.template ~/.gitmessage
```

> [!TIP] **Commit Message Template**
>
> ```text
> # <type>: <subject>
> # |<----  Try to limit to 50 characters  ---->|
>
> # Explain why this change is being made (optional, wrap at 72 characters)
> # |<----   Try to limit each line to 72 characters   ---->|
>
>
> # --- COMMIT END ---
> # Type can be:
> #   feat:     A new feature
> #   fix:      A bug fix
> #   docs:     Documentation changes
> #   style:    Code style changes (formatting, missing semi colons, etc)
> #   refactor: Code refactoring
> #   perf:     Performance improvements
> #   test:     Adding or updating tests
> #   chore:    Build process or auxiliary tool changes
> #   revert:   Revert a previous commit
> #
> # Examples:
> #   feat: add user authentication
> #   fix: resolve cart calculation error
> #   docs: update installation guide in README
> #
> # Remember:
> # - Use imperative mood: "add" not "added" or "adds"
> # - Don't capitalize first letter
> # - No period at the end of subject line
> # - Separate subject from body with a blank line
> # - Body explains what and why, not how
> ```

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
```

### OSC 52 Clipboard (SSH Support)

Automatically enabled when working over SSH (`$SSH_TTY` detected). Allows seamless copy/paste between remote Neovim and local system clipboard using escape sequences.

Configuration in `nvim/lua/custom/options.lua` - up to ~75KB per operation.

---

## Key Mappings

**Leader Key**: `<Space>`

### Window & File Management

| Key                         | Action                                    |
| --------------------------- | ----------------------------------------- |
| `<leader>sv` / `<leader>sh` | Split window vertically / horizontally    |
| `<C-h/j/k/l>`               | Navigate between windows (and Tmux panes) |
| `<leader>h/j/k/l`           | Resize windows                            |
| `<leader>w`                 | Save file                                 |
| `<leader>q` / `<leader>Q`   | Quit window / Quit all                    |
| `<leader>e`                 | Toggle file explorer                      |

### Navigation & Editing

| Key          | Action                         |
| ------------ | ------------------------------ |
| `jk`         | Exit insert mode               |
| `H` / `L`    | Move to start / end of line    |
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

| Key                | Action                      |
| ------------------ | --------------------------- |
| `<leader>ff`       | Find files (Telescope)      |
| `<leader>fg`       | Find grep (Telescope)       |
| `<leader>fb`       | Find buffers (Telescope)    |
| `<leader>/`        | Search in current file      |
| `<leader>rn`       | LSP rename                  |
| `<leader>g`        | Open Git interface (Neogit) |
| `,`                | Flash jump to position      |
| `gc` / `gcc`       | Comment toggle              |
| `gt` / `gT`        | Next / previous buffer      |
| `gz<motion><char>` | Add surroundings            |
| `gzd<char>`        | Delete surroundings         |
| `<C-t>`            | Toggle terminal             |

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
