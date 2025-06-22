# dotfiles

**dotfiles are how you personalize system including VSCode and Neovim.**

---

## VSCode

### Create Soft Link

```bash
# Input method auto switch
$ brew tap daipeihust/tap # yay install im-select
$ brew install im-select

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

$ Verify
$ ls -l ~/.config | grep 'nvim'
lrwxr-xr-x@ 1 kyden  staff    27B 23 Sep 22:55 nvim -> /Users/kyden/.dotfiles/nvim
```

### Use OSC 52

Operating System Controls(OSC), 是一种约定俗成的用于终端程序中的逃逸序列表达，
终端会根据 OSC codes 所定义的行文处理方式处理它所包围的文本。

而正巧的是就有一种定义决定了「如何从终端中复制内容到系统剪贴板中」，那就是 OSC 52 escape sequence。

OSC 52 一次最长接受 100000 个字节，其中前 7 个字节为 `\033]52;c;`，
中间 99992 个字节为待复制文本，最后一个字节为 `\a`。

待复制文本需要编码为 base64 表达，因此实际可用的复制长度为 74994 个字节。
一般 74994 个字节可以超过普通的纯文本范围了，完全能够满足日常的复制粘贴的需求。

#### Steps

1. 创建 `yank` 文件，然后赋予执行权限并加入 PATH 中(这里可以使用软连接的方式 `ln -s ~/.dotfiles/yank /usr/local/bin/yank`)：

    ```bash
    #!/bin/sh

    # copy via OSC 52
    buf=$( cat "$@" )
    len=$( printf %s "$buf" | wc -c ) max=74994
    test $len -gt $max && echo "$0: input is $(( len - max )) bytes too long" >&2
    printf "\033]52;c;$( printf %s "$buf" | head -c $max | base64 | tr -d '\r\n' )\a"
    ```

2. Neovim setting

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

3. TMux setting

    ```conf
    set -g allow-passthrough on
    ```

### Plugins

#### Colorscheme

- zephyr: 清新的配色方案
- tokyonight: 一种受欢迎的配色方案，灵感来自 Tokyo 的夜景
- gruvbox: Gruvbox 主题，深色和浅色模式都支持

`:colorscheme <theme>` 可切换主题

#### Which key

提供一个帮助菜单，显示可用的快捷键，帮助用户记住和使用快捷键

#### Buffer Line

提供一个漂亮的缓冲区标签行，允许用户在多个缓冲区之间轻松切换。

- `gt`: 下一个 Buffer
- `gT`: 上一个 buffer
- `ZZ`: 关闭当前**已保存**的 Buffer

#### Yank

增强复制粘贴功能，支持更复杂的粘贴操作

#### Status Line

强大的状态栏，支持自定义显示信息

#### Vim Tmux Navigator

允许在 Neovim 和 Tmux 之间无缝导航，使用 Ctrl + hjkl 快捷键

#### File Explorer

侧边栏文件浏览器，使用户可以浏览和管理文件

- `a`: Create file
- ...

#### Outline 大纲视图

显示代码的大纲视图，方便快速导航

#### Hop

智能跳转，快速移动到文件中的特定位置

- `,<char>`: 跳转到 `<char>` 字母处

#### Surround

快速添加、删除或更改文本周围的括号或引号

- `cs<src><dst>`: change `<src>` to `<dst>`

#### Indent Blank Line

在代码中显示缩进的空行

#### Inc Rename

提供 LSP 支持的重命名功能

- `<leader>r`

#### Git

`gitsigns` 在文件中显示 Git 修改的签名和状态.

`neogit`, 一个 Git 客户端，可以通过 Neovim 进行更复杂的 Git 操作.

- `Neogit`: 打开 Git 客户端

#### Comments and TODO

方便的代码注释

- `gc`:

#### ToggleTerm

可以在 Neovim 中使用的终端集成

- `<C-t>`: 打开一个 toogleterm

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

- MarkdownPreview: `<leader>mdp`，实时预览功能

#### Autopairs

自动配对括号、引号等

#### Treesitter

提供更强大的语法高亮和代码解析，支持多种语言

#### LSP

#### Auto Complete Engine

`LuaSnip`，提供 Snippet 功能的插件，配合自动补全使用

`nvim-cmp`，强大的自动补全框架，支持多种来源的补全

#### LSP Manager

`mason`: 一个 Neovim 插件管理器，专注于提供一个简单、一致的接口来管理外部工具和语言服务器；

`nvim-lspconfig`: 函数跳转、定义查看等

`lsp_signature`: 提供 LSP 函数签名的提示

#### Formater

`mason-null-ls`: 处理 LSP 相关的格式化和检查；

- `<space>=`: 格式化

---

## VIM 操作

### 段落移动

在程序开发时，通常一段功能相关的代码会写在一起，即之间没有空行，这时可以用段落移动命令来快速移动光标。

> `{`   # 移动到上一段的开头
>
> `}`   # 移动到下一段的开头

### 括号切换

> `%`: 括号匹配以及切换

### 单词快速匹配

> `#`: 匹配光标所在单词，向前查找（快速查看这个单词在其他什么位置使用过）

### 文件操作

> `:e`：edit，会打开内置的文件浏览器，浏览当下目录的文件
>
> `:n filename`：new，新建文件
>
> `:w filename`：write，保存文件

### 分屏

> `:sp[filename]`：split，水平分屏
>
> `:vsp[filename]`：vertical split，垂直分屏

---

## Preblem and Solution

1. 无法预览Markdown，使用 `:message` 查看报错如下：`Error: Cannot find module 'tslib'`.

    只需手动执行 `:call mkdp#util#install()` 下载预编译 bundle 即可

2. Linux 共用系统剪切板的问题

    `sudo pacman -S xsel`
