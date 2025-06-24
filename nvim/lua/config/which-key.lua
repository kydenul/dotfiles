-- Which key

local util = require("util")
local ok, which_key = pcall(require, "which-key")
if not ok then
  util.log_warn("which-key init failed!")
  return
end

which_key.setup({
  -- Use classic preset (other options: "modern", "helix")
  preset = "modern",

  -- Delay before showing the popup (in ms)
  delay = function(ctx)
    return ctx.plugin and 0 or 200
  end,

  -- Plugins configuration
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      -- 是否接管默认 z= 的行为
      enabled = true,
      suggestions = 20, -- how many suggestions should be shown in the list
    },
    -- Add help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = true, -- adds help for operators like d, y, ...
      motions = true, -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  -- Window appearance configuration
  win = {
    -- Don't allow the popup to overlap with the cursor
    no_overlap = true,
    padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
    title = true,
    title_pos = "center",
    zindex = 1000,
  },
  -- Layout configuration
  layout = {
    width = { min = 20 }, -- min width of the columns
    spacing = 3, -- spacing between columns
  },
  -- Key bindings for navigating the popup
  keys = {
    scroll_down = "<c-d>", -- binding to scroll down inside the popup
    scroll_up = "<c-u>", -- binding to scroll up inside the popup
  },
  -- Icons configuration
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  -- Show help message in the command line
  show_help = true,
  -- Show the currently pressed key and its label as a message in the command line
  show_keys = true,
  -- Disable WhichKey for certain buffer types and file types
  disable = {
    ft = {}, -- List of filetypes to disable which-key
    bt = {}, -- List of buffer types to disable which-key
  },
})
