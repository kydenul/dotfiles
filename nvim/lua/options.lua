local keymap = vim.keymap
local opts = {
	noremap = true, -- non-recursive
	silent = true, -- do not show message
}

vim.g.mapleader = " " -- Map leader key

vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a" -- allow the mouse to be used in Nvim

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
vim.opt.scrolloff = 8
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

-- Clipboard
vim.opt.clipboard = "unnamedplus"
if vim.fn.exists("$SSH_TTY") == 1 then
	util.log_info("SSH_TTY detected")
	vim.g.clipboard = {
		name = "osc52",
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


----------------------------------
-- Insert mode --
----------------------------------
keymap.set("i", "jk", "<ESC>")

----------------------------------
-- Normal mode --
----------------------------------
-- New windows
keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
keymap.set("n", "<leader>sh", "<C-w>s") -- 垂直新增窗口

-- Resize with arrows
-- delta: 2 lines
keymap.set("n", "<C-j>", ":resize -3<CR>", opts)
keymap.set("n", "<C-k>", ":resize +3<CR>", opts)
keymap.set("n", "<C-h>", ":vertical resize -3<CR>", opts)
keymap.set("n", "<C-l>", ":vertical resize +3<CR>", opts)

-- leader + hjkl 在窗口之间跳转
keymap.set('n', '<leader>h', '<C-w>h', opts) -- 向左跳转
keymap.set('n', '<leader>j', '<C-w>j', opts) -- 向下跳转
keymap.set('n', '<leader>k', '<C-w>k', opts) -- 向上跳转
keymap.set('n', '<leader>l', '<C-w>l', opts) -- 向右跳转

-- 文件
keymap.set("n", "<leader>w", ":w!<CR>", { desc = "Save" }) -- Save file

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- 光标快速移动
keymap.set({ "n", "v" }, "H", "^", { desc = "Move to start of line" }) -- 移动光标至行首
keymap.set({ "n", "v" }, "L", "$", { desc = "Move to end of line" }) -- 移动光标至行尾

----------------------------------
-- Visual mode --
----------------------------------
-- Hint: start visual mode with the same area as the previous area and the same mode
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- 单行或多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")
keymap.set({ "n" }, "J", "5j")

-- Visual mode, 粘贴不要复制
keymap.set("v", "p", '"_dP', opts)

-- IncRename
vim.keymap.set("n", "<leader>rn", function()
	return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

-- Toggle nvim-tree
vim.keymap.set({ "n", "t" }, "<leader>e", 
    "<Cmd>NvimTreeFindFileToggle<CR>", 
    { noremap = true, silent = true, nowait = true }
)

-- Buffer line
-- 1. 使用 <leader> + 数字 => 直接跳转到对应缓冲区
for i = 1, 9 do
	vim.keymap.set("n", "<leader>" .. i, function()
		bufferline.go_to(i, true)
	end, { desc = "Go to buffer " .. i })
end

-- 2. 使用 gt/gT 在缓冲区之间切换
vim.keymap.set({ "v", "n" }, "gt", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set({ "v", "n" }, "gT", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- 3. 关闭当前缓冲区并切换到上一个
vim.keymap.set({ "v", "n" }, "ZZ", function()
	if vim.bo.modified then
		util.log_err("No write sine last change.")
		return
	end
	local buf = vim.fn.bufnr()
	bufferline.cycle(-1)
	vim.cmd.bdelete(buf)
end, { desc = "Close current buffer" })

-- 4. 添加更多实用的快捷键
vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "选择关闭缓冲区" })
vim.keymap.set(
	"n",
	"<leader>bo",
	"<cmd>BufferLineCloseLeft<CR><cmd>BufferLineCloseRight<CR>",
	{ desc = "关闭其他缓冲区" }
)
vim.keymap.set("n", "<leader>br", "<cmd>BufferLineCloseRight<CR>", { desc = "关闭右侧缓冲区" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", { desc = "关闭左侧缓冲区" })

vim.keymap.set("n", "<leader>bs", "<cmd>BufferLineSortByDirectory<CR>", { desc = "按目录排序" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "选择缓冲区" })

vim.keymap.set("n", "<leader>bmm", "<cmd>BufferLineMovePrev<CR>", { desc = "向左移动缓冲区" })
vim.keymap.set("n", "<leader>bmn", "<cmd>BufferLineMoveNext<CR>", { desc = "向右移动缓冲区" })


-------------------------------------
-------------------------------------
-- NOTE ColorScheme -> trigger
-- silent! colorscheme gruvbox
-------------------------------------
-------------------------------------
vim.cmd([[
    augroup colorscheme_mock
    autocmd!
    autocmd ColorScheme * hi Normal guibg=none | hi def link LspInlayHint Comment
    augroup END
]])

vim.cmd([[ silent! colorscheme gruvbox ]])

