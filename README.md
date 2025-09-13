# dotfiles

**dotfiles are how you personalize system including VSCode and Neovim.**

---

## VSCode

### Create Soft Link

```bash
# Input method auto switch
$ brew tap daipeihust/tap # yay install im-select
$ brew install im-select, pngpaste
$ brew install latex2html

# MacOS
$ brew install fd
# Linux - Ubuntu
sudo apt install fd-find

# Verify
$ im-select
com.apple.keylayout.ABC

# Install
$ git clone https://github.com/kydenul/dotfiles.git ~/.dotfiles

# Mac
$ ln -s ~/.dotfiles/vscode/keybindings.json /Users/<YourUserName>/Library/Application\ Support/Code/User/keybindings.json
$ ln -s ~/.dotfiles/vscode/settings.json /Users/<YourUserName>/Library/Application\ Support/Code/User/settings.json

$ ln -s ~/.dotfiles/windsurf/keybindings.json /Users/<YourUserName>/Library/Application\ Support/Windsurf/User/keybindings.json
$ ln -s ~/.dotfiles/windsurf/settings.json /Users/<YourUserName>/Library/Application\ Support/Windsurf/User/settings.json

$ ln -s ~/.dotfiles/.zshrc ~/.zshrc
$ ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
$ ln -s ~/.dotfiles/.markdownlint.json ~/.markdownlint.json
```

---

## Neovim (Nvim)

### Requirements

- [Neovim 0.9+](https://github.com/neovim/neovim/releases)
- [Nerd Font](https://www.nerdfonts.com/)

### Install and Verify

```bash
# render-markdown.nvim
brew install latexdiff
brew install mercurial

# Linux
sudo pacman -S neovim

# Mac
brew install neovim

# Verify
$ nvim --version
NVIM v0.10.1
Build type: Release
LuaJIT 2.1.1725453128
Run "nvim -V1 -v" for more info

# Install the config on your computer
$ git clone https://github.com/kydenul/dotfiles.git ~/.dotfiles
$ ln -s ~/.dotfiles/nvim/ ~/.config/nvim

# Verify installation
$ ls -l ~/.config | grep 'nvim'
lrwxr-xr-x@ 1 kyden  staff    27B 23 Sep 22:55 nvim -> /Users/kyden/.dotfiles/nvim
```

### Getting Started

1. **First Launch**: When you first open Neovim, lazy.nvim will automatically bootstrap itself and install all plugins. This may take a few minutes.

2. **Plugin Management**: Use these commands to manage plugins:
   - `:Lazy` - Open plugin manager interface
   - `:Lazy sync` - Install/update/remove plugins
   - `:Lazy clean` - Remove unused plugins
   - `:Lazy health` - Check plugin health

3. **LSP Setup**: Language servers are managed by Mason:
   - `:Mason` - Open Mason interface to install/manage LSP servers
   - `:LspInfo` - Show LSP status for current buffer
   - `:checkhealth` - Check Neovim health (including LSP)

4. **Initial Configuration**:
   - The configuration will automatically install language servers for common languages
   - Copilot requires authentication: `:Copilot auth` (if you have access)
   - Check `:checkhealth lazy` to ensure everything is working correctly

### OSC 52 Clipboard Integration

**What is OSC 52?**
Operating System Controls (OSC) are escape sequences used in terminal programs. OSC 52 specifically defines "how to copy content from terminal to system clipboard".

**Technical Details:**

- Maximum length: 100,000 bytes per operation
- Format: `\033]52;c;[base64-encoded-text]\a`
- Practical limit: ~74,994 bytes (after base64 encoding)
- Sufficient for most daily copy-paste operations

#### Neovim setting

```lua
vim.g.clipboard = {
    name = "OSC 52",
    copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
        ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
        ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
}
vim.opt.clipboard = "unnamedplus" -- use system clipboard
```

### Plugin Manager - Lazy.nvim

This configuration uses [lazy.nvim](https://github.com/folke/lazy.nvim), a modern plugin manager that offers:

**Key Features:**

- **Fast startup**: Plugins are lazy-loaded by default
- **Automatic bootstrapping**: Installs itself on first run
- **Lockfile support**: `lazy-lock.json` ensures reproducible plugin versions
- **Rich UI**: Beautiful interface for plugin management
- **Health checks**: Built-in diagnostics for plugin issues
- **Profiling**: Startup time analysis

**Commands:**

- `:Lazy` - Open the plugin manager interface
- `:Lazy sync` - Install missing plugins and update existing ones
- `:Lazy clean` - Remove plugins that are no longer needed  
- `:Lazy update` - Update plugins to latest versions
- `:Lazy profile` - Show startup time breakdown

### Plugins

#### Colorscheme

- **gruvbox-material**: Modern gruvbox theme with better contrast and colors

`:colorscheme gruvbox-material` to switch theme

#### Which Key

Displays a popup with available keybindings when you start typing a key sequence, helping you remember and discover shortcuts

#### Buffer Line

Provides a beautiful buffer tab line that allows easy switching between multiple buffers with:

- Visual buffer indicators
- Close buttons for each buffer
- Buffer reordering support

Keymaps:

- `gt`: Next buffer
- `gT`: Previous buffer  
- `ZZ`: Close current saved buffer

#### Yank (Yanky)

Enhances copy/paste functionality with:

- Yank history management
- Smart paste operations
- Integration with system clipboard

#### Status Line (Lualine)

Powerful and customizable statusline showing:

- Current mode
- Git branch and changes
- File information and encoding
- LSP status and diagnostics
- Current location in file

#### Session Management

**auto-session**: Automatic session management that:

- Saves and restores your workspace automatically
- Remembers open files, window layouts, and more
- Works across Neovim restarts

#### File Explorer

侧边栏文件浏览器，使用户可以浏览和管理文件

- `a`: Create file
- ...

#### Outline 大纲视图

显示代码的大纲视图，方便快速导航

#### Flash (Smart Jump)

Intelligent jumping to move quickly to specific positions in files

- `,`: Flash jump to any position (replaces traditional f/t motions)

#### Surround

**nvim-surround**: Quick add, delete, or change text surroundings (brackets, quotes, etc.)

Keymaps:

- `gz<motion><replacement>`: Add surroundings
- `gzd<char>`: Delete surrounding <char>
- `gzc<old><new>`: Change surrounding from <old> to <new>

#### Code Enhancement

**indent-blankline.nvim**: Shows indentation guides and scope highlighting

**nvim-ufo**: Advanced folding with:

- LSP-based folding
- Treesitter integration
- Preview folded content

**flash.nvim**: Enhanced navigation and text objects

#### Enhanced UI

**noice.nvim**: Completely replaces the default Neovim UI for:

- Command line interface
- Messages and notifications  
- Search interface
- LSP progress indicators

**trouble.nvim**: Better diagnostics and quickfix list with:

- Pretty diagnostic display
- Workspace-wide error navigation
- Integration with LSP and Telescope

#### Git Integration

**gitsigns.nvim**: Shows Git changes in the sign column and provides Git operations

**neogit**: Full-featured Git client interface for Neovim

**vim-fugitive**: Comprehensive Git wrapper

Keymaps:

- `<leader>g`: Open Neogit interface
- Git signs appear in the sign column showing additions, deletions, and changes

#### Comments and TODO

**vim-commentary**: Easy code commenting
**todo-comments.nvim**: Highlight and search for TODO, FIXME, NOTE, etc.

Keymaps:

- `gc`: Toggle line comment (normal/visual mode)
- `gcc`: Toggle current line comment
- `gcu`: Uncomment current and adjacent commented lines

#### Terminal Integration

**toggleterm.nvim**: Integrated terminal management within Neovim

Keymaps:

- `<C-t>`: Toggle terminal window

#### Telescope

强大的模糊查找插件，可以快速查找文件、文本等

- `<leader>ff`: 查找文件
- `<leader>fb`: find buffer
- `<leader>fg`: find grep
- `<leader>ft`: find tag
- `<leader>/`: 当前文件内容模糊搜索

#### hls

为搜索结果提供高亮显示，帮助用户快速定位搜索词

#### Markdown

- **render-markdown.nvim**: Live markdown rendering in Neovim buffer
- **vim-markdown**: Enhanced markdown syntax and folding
- **PlantUML**: Syntax highlighting and preview for PlantUML diagrams

#### Autopairs

自动配对括号、引号等

#### Treesitter

提供更强大的语法高亮和代码解析，支持多种语言

#### LSP

#### Auto Complete Engine

**nvim-cmp**: Powerful autocompletion framework with multiple sources:

- LSP completions
- Buffer completions  
- Path completions
- Command line completions
- **GitHub Copilot**: AI-powered code suggestions

**LuaSnip**: Advanced snippet engine with:

- VSCode-style snippets support
- Custom snippet definitions
- Dynamic snippet expansion

#### LSP Manager

**mason**: Package manager for LSP servers, formatters, linters, and debug adapters

**nvim-lspconfig**: Language Server Protocol configurations with:

- Go-to definition, references, implementation
- Hover documentation
- Code actions and refactoring
- Diagnostic information

**inc-rename.nvim**: LSP-powered incremental rename with live preview

#### Formatter & Debugging

**conform.nvim**: Modern async formatter with support for multiple formatters per filetype

**nvim-dap**: Full debugging support with:

- Debug Adapter Protocol integration
- Visual debugging UI with variables, stack traces, and breakpoints
- Support for Python, Go, C/C++, and more
- Auto-installed debug adapters via Mason

---

## Key Mappings

### Leader Key

Leader key is set to `<Space>`

### Custom Keymaps

#### Window Management

- `<leader>sv`: Split window vertically
- `<leader>sh`: Split window horizontally  
- `<leader>h/j/k/l`: Navigate between windows
- `<C-h/j/k/l>`: Resize windows

#### File Operations

- `<leader>w`: Save file
- `<leader>q`: Quit current window
- `<leader>Q`: Quit all windows
- `<leader>e`: Toggle file explorer

#### Navigation & Editing

- `jk`: Exit insert mode (alternative to ESC)
- `H`: Move to start of line (replaces ^)
- `L`: Move to end of line (replaces $)
- `<leader>nh`: Clear search highlights

#### Visual Mode

- `J/K`: Move selected lines up/down
- `</>`; Indent/dedent while keeping selection
- `p`: Paste without copying the replaced text

#### Plugin-Specific

- `<leader>rn`: LSP rename (inc-rename)
- `<leader>g`: Open Git interface (Neogit)
- `,`: Flash jump to position
- `<C-t>`: Toggle terminal

---

## VIM Operations

### Paragraph Movement

In development, related code is usually written together without empty lines. Use paragraph movement commands to quickly move the cursor.

> `{` - Move to beginning of previous paragraph
>
> `}` - Move to beginning of next paragraph

### Bracket Matching

> `%`: Match and jump between brackets

### Word Matching

> `#`: Search for word under cursor backward
> `*`: Search for word under cursor forward

### File Operations

> `:e` - Edit, opens built-in file browser for current directory
>
> `:n filename` - New, create new file
>
> `:w filename` - Write, save file to specified name

### Window Splitting

> `:sp[filename]` - Horizontal split
>
> `:vsp[filename]` - Vertical split

---

## Problem and Solution

1. Cannot preview Markdown files, use `:messages` to check errors such as: `Error: Cannot find module 'tslib'`.

    Simply execute `:call mkdp#util#install()` manually to download the precompiled bundle

2. Linux system clipboard sharing issue

    ```bash
    # For Arch Linux
    sudo pacman -S xsel
    # For Ubuntu/Debian
    sudo apt install xsel
    ```

TODO

- [x] [nvim-spectre](https://github.com/nvim-pack/nvim-spectre) A search panel for neovim.
