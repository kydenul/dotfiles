local util = require("custom.util")

-- Clipboard
vim.opt.clipboard = "unnamedplus"
-- Rex 的远端 shell 由 systemd 拉起，不经 sshd，没有 $SSH_*；其 TERM 为 xterm-rex。
-- tmux 内 TERM/TERM_PROGRAM 会被改写，故再问 tmux 外层 client 的 termname。
local function in_rex()
  if vim.env.TERM_PROGRAM == "rex" or vim.env.TERM == "xterm-rex" then
    return true
  end
  if vim.env.TMUX then
    local r = vim.system({ "tmux", "display-message", "-p", "#{client_termname}" }, { text = true }):wait(500)
    return r.code == 0 and vim.trim(r.stdout) == "xterm-rex"
  end
  return false
end

local rex = in_rex()
if vim.fn.exists("$SSH_TTY") == 1 or vim.fn.exists("$SSH_CONNECTION") == 1 or rex then
  util.log_info("SSH/Rex detected, enabling OSC 52 clipboard")

  local in_tmux = vim.env.TMUX ~= nil

  -- 分块写入 stderr，避免大文本超出 TTY 缓冲区（macOS ~64KB）导致静默失败
  local function write_chunked(str)
    local chunk_size = 4096
    for i = 1, #str, chunk_size do
      local ok, err = pcall(io.stderr.write, io.stderr, str:sub(i, i + chunk_size - 1))
      if not ok then
        util.log_info("OSC52 write failed at byte " .. i .. ": " .. tostring(err))
        return false
      end
    end
    return true
  end

  local function osc52_copy(reg)
    return function(lines)
      local text = table.concat(lines, "\n")
      local base64 = vim.base64.encode(text)
      if in_tmux then
        -- 异步写入 tmux buffer，使跨 window/pane 粘贴可用（无大小限制）
        vim.system({ "tmux", "load-buffer", "-" }, { stdin = text })
        -- DCS passthrough: 绕过 tmux 直接发送到外层终端（同步到本地剪贴板）
        local seq = string.format("\x1bPtmux;\x1b\x1b]52;%s;%s\x07\x1b\\", reg, base64)
        write_chunked(seq)
      else
        local seq = string.format("\x1b]52;%s;%s\x1b\\", reg, base64)
        write_chunked(seq)
      end
    end
  end

  -- Rex 不回应 OSC 52 读取请求（只转发写入），查询会一直等到超时；
  -- 此时 paste 直接返回 nvim 自身寄存器，本地内容用 Cmd+V 终端粘贴进来。
  local function register_paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end

  local function paste_provider(reg)
    if in_tmux then
      return { "tmux", "save-buffer", "-" }
    end
    return rex and register_paste or require("vim.ui.clipboard.osc52").paste(reg)
  end

  vim.g.clipboard = {
    name = "OSC52",
    copy = {
      ["+"] = osc52_copy("c"),
      ["*"] = osc52_copy("p"),
    },
    paste = {
      -- Tmux 内 OSC 52 paste 响应无法透传，改用 tmux buffer 粘贴更可靠
      ["+"] = paste_provider("+"),
      ["*"] = paste_provider("*"),
    },
  }
end

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.o.wildmenu = true
vim.opt.mouse = "a" -- allow the mouse to be used in Nvim
vim.opt.scrolloff = 5

-- Tab
vim.opt.tabstop = 4 -- number of visual spaces per TAB
vim.opt.softtabstop = 4 -- number of spacesin tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of python

-- Comment
-- 默认 fo=tcqj 不含 r/o，各语言 ftplugin 又各自加减（python/go/markdown 就被减掉），
-- 导致注释里换行是否自动补注释符因语言而异。r: insert 模式 <CR>；o: 普通模式 o/O
vim.opt.formatoptions:append("ro")

-- UI config
vim.opt.number = true -- add numbers to each line on the left side
vim.opt.relativenumber = true -- show absolute number
vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.wo.colorcolumn = "120" -- 垂直的高亮列的，通常用于提示代码的行宽限制

vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
vim.opt.termguicolors = true -- enabl 24-bit RGB color in the TUI
vim.opt.signcolumn = "yes:1"
vim.opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint
vim.opt.conceallevel = 2

-- Searching
vim.opt.incsearch = true -- search as characters are entered
vim.opt.hlsearch = true -- do not highlight matches
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered

-- word wrap
vim.opt.wrap = true

-- Auto reload file
vim.o.autoread = true

-- 从 Tmux pane/window 切回 Neovim 时自动检测文件变化
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
  desc = "Auto reload files changed outside of Neovim",
})

-- Not swapfile
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- Smaller updatetime for better responsiveness
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Better performance
vim.o.lazyredraw = false
vim.o.regexpengine = 0 -- Use automatic regexp engine selection

-- Highlight yanked text briefly for visual feedback
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = vim.api.nvim_create_augroup("kyden-yank-highlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "CurSearch", timeout = 360 })
  end,
})

-- Override mapping in quickfix window
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    -- Unmap <CR> in quickfix window (if needed)
    vim.keymap.set("n", "<CR>", "<CR>", { buffer = true, desc = "Default Enter in quickfix" })
    -- Enable cursorline only in quickfix window
    vim.opt_local.cursorline = true
  end,
})

vim.cmd.colorscheme("aura")
