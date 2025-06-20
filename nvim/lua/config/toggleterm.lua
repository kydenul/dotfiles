-- Toggleterm: A terminal for Neovim

local util = require("util")
local ok, toggleterm = pcall(require, "toggleterm")
if not ok then
	util.log_warn("toggleterm init failed.")
	return
end

toggleterm.setup({
	-- Terminal configuration
	shell = vim.o.shell, -- change the default shell
	open_mapping = [[<C-t>]], -- How to open a new terminal
	insert_mappings = true, -- whether the open mapping applies in insert mode
	terminal_mappings = true, -- whether the open mapping applies in terminal mode
	start_in_insert = true, -- start terminal in insert mode
	persist_size = true, -- remember terminal size
	persist_mode = true, -- remember terminal mode (normal/insert)
	auto_scroll = true, -- automatically scroll to bottom on terminal output

	-- Size and appearance
	size = function(term)
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		else
			return 20
		end
	end,
	hide_numbers = true, -- hide the number column in toggleterm buffers
	direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
	close_on_exit = true, -- close the terminal window when the process exits
	shade_filetypes = {},
	shade_terminals = true,
	autochdir = false, -- when neovim changes directory, terminal follows

	-- Float window options
	float_opts = {
		-- The border key is *almost* the same as 'nvim_open_win'
		-- see :h nvim_open_win for details on borders
		border = "single",
		width = math.floor(vim.o.columns * 0.9),
		height = math.floor(vim.o.lines * 0.8),
		winblend = 0,
		title_pos = "center",
	},

	-- Responsive layout
	responsiveness = {
		horizontal_breakpoint = 135, -- columns at which terminals stack vertically
	},

	-- Callbacks
	on_open = function()
		-- Disable line numbers in terminal
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

-- Define terminal key mappings
-- t: terminal mode
function _G.set_terminal_keymaps()
	local opts = { noremap = true, buffer = 0 }

	-- Normal mode mappings for closing the terminal
	vim.keymap.set("n", "<Esc>", [[<Cmd>quit<CR>]], opts)
	vim.keymap.set("n", "q", [[<Cmd>quit<CR>]], opts)

	-- Terminal mode mappings for exiting terminal mode
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)

	-- Terminal mode mappings for window navigation
	-- These are useful for non-float terminals (horizontal/vertical splits)
	vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
	vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
	vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
	vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
end

-- Apply terminal keymaps when terminal opens
-- If you only want these mappings for toggleterm use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- Create custom terminal instances
-- Toggleterm exposes the `Terminal` class to create custom terminals
local Terminal = require("toggleterm.terminal").Terminal

-- Create lazygit terminal
local lazygit = Terminal:new({
	cmd = "lazygit",
	hidden = true,
	direction = "float",
	float_opts = {
		border = "double",
	},
	on_open = function(term)
		vim.cmd("startinsert!")
		vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
	end,
})

function _LAZYGIT_TOGGLE()
	lazygit:toggle()
end

-- Create htop terminal
local htop = Terminal:new({
	cmd = "htop",
	hidden = true,
	direction = "float",
	float_opts = {
		border = "single",
	},
})

function _HTOP_TOGGLE()
	htop:toggle()
end

-- Create a terminal for running tests
local test_runner = Terminal:new({
	cmd = "", -- Will be set when called
	hidden = true,
	direction = "horizontal",

	size = function()
		return math.floor(vim.o.lines * 0.3)
	end,

	on_open = function(term)
		vim.cmd("startinsert!")
	end,

	on_exit = function()
		vim.cmd("echo 'Test run completed!'")
	end,
})

function _RUN_TEST(cmd)
	test_runner:set_cmd(cmd)
	test_runner:toggle()
end

-- Create keymappings for custom terminals
vim.api.nvim_set_keymap(
	"n",
	"<leader>tg",
	"<cmd>lua _LAZYGIT_TOGGLE()<CR>",
	{ noremap = true, silent = true, desc = "Toggle Lazygit" }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>th",
	"<cmd>lua _HTOP_TOGGLE()<CR>",
	{ noremap = true, silent = true, desc = "Toggle Htop" }
)
