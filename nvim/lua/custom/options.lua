local util = require("custom.util")

-- Clipboard
vim.opt.clipboard = "unnamedplus"
if vim.fn.exists("$SSH_TTY") == 1 then
  util.log_info("SSH_TTY detected")
  vim.g.clipboard = {
    name = "OSC52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end
vim.opt.completeopt = { "menu", "menuone", "noselect" }
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
vim.bo.autoread = true

-- Not swapfile
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- Smaller updatetime for better responsiveness
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Better performance
vim.o.lazyredraw = false -- Don't redraw during macros (can cause issues with some plugins)
vim.o.ttyfast = true -- Faster terminal connection
vim.o.regexpengine = 0 -- Use automatic regexp engine selection

-- 补全增强
vim.o.wildmenu = true

-- vim.g.gruvbox_material_transparent_background = 0 -- 0, 1, 2
-- vim.g.gruvbox_material_foreground = "material" -- "original" "mix" "material"
-- vim.g.gruvbox_material_background = "hard" -- 'hard'`, `'medium'`, `'soft'
-- vim.g.gruvbox_material_float_style = "dim" -- 'bright', "dim"
-- vim.g.gruvbox_material_enable_italic = true
-- vim.cmd([[ silent! colorscheme gruvbox-material ]])
-- vim.cmd([[ silent! colorscheme gruvbox-material ]])

-- setup must be called before loading
vim.cmd.colorscheme("catppuccin")
