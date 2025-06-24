-- nvim-autopairs: Automatic bracket pairing plugin

local util = require("util")
local is_ok, npairs = pcall(require, "nvim-autopairs")
if not is_ok then
  util.log_warn("nvim-autopairs init failed.")
  return
end

npairs.setup({
  check_ts = true, -- check if treesitter is installed
  map_bs = true, -- map the <BS> key
  map_c_h = false, -- Map the <C-h> key to delete a pair
  map_c_w = false, -- Map <C-w> to delete a pair if possible
  disable_filetype = { "TelescopePrompt", "spectre_panel" },
  disable_in_macro = false, -- disable when recording or executing a macro
  disable_in_visualblock = false, -- disable when insert after visual block mode
  ignore_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
  enable_moveright = true,
  enable_afterquote = true, -- add bracket pairs after quote
  enable_check_bracket_line = true, -- check bracket in same line
  ts_config = {
    lua = { "string", "source" }, -- it will not add a pair on that treesitter node
    javascript = { "template_string" },
    java = false, -- don't check treesitter on java
  },
  fast_wrap = {
    map = "<M-e>", -- Alt+e to fast wrap
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    offset = 0, -- Offset from pattern match
    end_key = "$",
    keys = "qwertyuiopzxcvbnmasdfghjkl",
    check_comma = true,
    highlight = "PmenuSel",
    highlight_grey = "LineNr",
  },
})
