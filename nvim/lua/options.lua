local util = require("util")

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
vim.opt.scrolloff = 8

-- Tab
vim.opt.tabstop = 4 -- number of visual spaces per TAB
vim.opt.softtabstop = 4 -- number of spacesin tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of python

-- UI config
vim.opt.number = true -- show absolute number
vim.opt.relativenumber = true -- add numbers to each line on the left side
vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
-- vim.opt.guicursor = ""
vim.wo.colorcolumn = "100"

vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
vim.opt.termguicolors = true -- enabl 24-bit RGB color in the TUI
vim.opt.signcolumn = "yes"
vim.opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint

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

-- Smaller updatetime
vim.o.updatetime = 240
vim.o.timeoutlen = 500

-- 补全增强
vim.o.wildmenu = true

-- -------------------------------------
-- -------------------------------------
-- -- NOTE ColorScheme -> trigger
-- TODO
-- FIXME
-- -- silent! colorscheme gruvbox gruvbox-material
-- -------------------------------------
-- -------------------------------------
-- vim.cmd([[
--     augroup colorscheme_mock
--     autocmd!
--     autocmd ColorScheme * hi Normal guibg=none | hi def link LspInlayHint Comment
--     augroup END
-- ]])

vim.g.gruvbox_material_foreground = "material" -- "original" "mix" "material"
vim.g.gruvbox_material_background = "hard" -- 'hard'`, `'medium'`, `'soft'
vim.g.gruvbox_material_float_style = "dim"
vim.g.gruvbox_material_cursor = "auto"
vim.g.gruvbox_material_enable_italic = true

vim.cmd([[ silent! colorscheme gruvbox-material ]])
