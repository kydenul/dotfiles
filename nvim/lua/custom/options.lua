local util = require("custom.util")

-- Clipboard
vim.opt.clipboard = "unnamedplus"
if vim.fn.exists("$SSH_TTY") == 1 or vim.fn.exists("$SSH_CONNECTION") == 1 then
  util.log_info("SSH detected, enabling OSC 52 clipboard")

  local in_tmux = vim.env.TMUX ~= nil

  local function osc52_copy(reg)
    return function(lines)
      local text = table.concat(lines, "\n")
      local base64 = vim.base64.encode(text)
      local seq
      if in_tmux then
        -- DCS passthrough: 绕过 tmux 直接发送到外层终端（同步到本地剪贴板）
        seq = string.format("\x1bPtmux;\x1b\x1b]52;%s;%s\x07\x1b\\", reg, base64)
        -- 异步写入 tmux buffer，使跨 window/pane 粘贴可用
        vim.system({ "tmux", "load-buffer", "-" }, { stdin = text })
      else
        seq = string.format("\x1b]52;%s;%s\x1b\\", reg, base64)
      end
      pcall(io.stderr.write, io.stderr, seq)
    end
  end

  vim.g.clipboard = {
    name = "OSC52",
    copy = {
      ["+"] = osc52_copy("c"),
      ["*"] = osc52_copy("p"),
    },
    paste = {
      -- Tmux 内 OSC 52 paste 响应无法透传，改用 tmux buffer 粘贴更可靠
      ["+"] = in_tmux and { "tmux", "save-buffer", "-" } or require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = in_tmux and { "tmux", "save-buffer", "-" } or require("vim.ui.clipboard.osc52").paste("*"),
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
vim.o.ttyfast = true -- Faster terminal connection
vim.o.regexpengine = 0 -- Use automatic regexp engine selection

-- Highlight yanked text briefly for visual feedback
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = vim.api.nvim_create_augroup("kyden-yank-highlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "CurSearch", timeout = 360 })
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

-- setup must be called before loading
-- vim.cmd.colorscheme("gruvbox-material")
vim.cmd.colorscheme("catppuccin")
-- vim.cmd.colorscheme("tokyonight")
