-- Toggleterm: A terminal for Neovim

local util = require("util")
local ok, toggleterm = pcall(require, "toggleterm")
if not ok then
  util.log_warn("toggleterm init failed.")
  return
end

toggleterm.setup({
  open_mapping = [[<C-/>]], -- How to open a new terminal
  start_in_insert = true, -- Start terminal in insert mode
  persist_size = true, -- Remember terminal size
  close_on_exit = true, -- Close the terminal window when the process exits
  auto_scroll = true, -- Automatically scroll to bottom on terminal output
  direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
  hide_numbers = true, -- Hide the number column in toggleterm buffers
  shade_terminals = true, -- Shade the terminal window

  -- This function is used to calculate the size of non-floating terminals.
  size = function(term)
    if term.direction == "horizontal" then
      -- If horizontal, set height to 20% of the screen
      return math.floor(vim.o.lines * 0.2)
    elseif term.direction == "vertical" then
      -- If vertical, set width to 40% of the screen
      return vim.o.columns * 0.4
    end
  end,

  -- Float window options
  float_opts = {
    -- Border style
    border = "single", -- 'single', 'double', 'rounded', 'shadow', 'none'
    -- Transparency
    winblend = 0,
    -- Title position
    title_pos = "center",
    -- Dimensions and position to center the floating window
    width = function()
      return math.floor(vim.o.columns * 0.8)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.8)
    end,
    row = function()
      return math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2)
    end,
    col = function()
      return math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2)
    end,
  },

  -- Callbacks
  on_open = function(term)
    -- Disable line numbers in the terminal buffer
    vim.cmd("setlocal nonumber norelativenumber")
    -- Enter insert mode automatically
    vim.cmd("startinsert!")
  end,
})

-- Define terminal key mappings
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  -- Exit terminal mode
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  -- Navigate between windows from terminal mode
  vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
end

-- Apply terminal keymaps only when a toggleterm terminal opens
vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

-- ===================================================================
-- Custom Terminals
-- ===================================================================
local Terminal = require("toggleterm.terminal").Terminal

-- Lazygit
local lazygit = Terminal:new({
  cmd = "lazygit",
  dir = vim.fn.getcwd(),
  direction = "float",
  float_opts = { border = "double" },
  hidden = true, -- Hide from buffer list
})

function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end
vim.keymap.set(
  "n",
  "<leader>tg",
  "<cmd>lua _LAZYGIT_TOGGLE()<CR>",
  { noremap = true, silent = true, desc = "Toggle Lazygit" }
)

-- htop
local htop = Terminal:new({
  cmd = "htop",
  direction = "float",
  float_opts = { border = "single" },
  hidden = true,
})

function _HTOP_TOGGLE()
  htop:toggle()
end
vim.keymap.set(
  "n",
  "<leader>th",
  "<cmd>lua _HTOP_TOGGLE()<CR>",
  { noremap = true, silent = true, desc = "Toggle Htop" }
)

-- Python REPL
local python_repl = Terminal:new({
  cmd = "python",
  direction = "float",
  float_opts = { border = "rounded" },
  hidden = true,
})

function _PYTHON_REPL_TOGGLE()
  python_repl:toggle()
end
vim.keymap.set(
  "n",
  "<leader>tp",
  "<cmd>lua _PYTHON_REPL_TOGGLE()<CR>",
  { noremap = true, silent = true, desc = "Toggle Python REPL" }
)
