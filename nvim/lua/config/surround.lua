-- nvim-surround

local util = require("util")
local ok, surround = pcall(require, "nvim-surround")
if not ok then
  util.log_warn("nvim-surround init failed.")
  return
end

surround.setup({
  context_offset = 100,
  load_autogroups = false,
  mappings_style = "surround",
  map_insert_mode = true,
  quotes = { "'", '"' },
  brackets = { "(", "{", "[" },
  space_on_closing_char = true,

  -- Move cursor between paired surrounds
  move_cursor = "begin",

  pairs = {
    nestable = {
      b = { "(", ")" },
      s = { "[", "]" },
      B = { "{", "}" },
      a = { "<", ">" },
    },

    -- Aliases for common surrounds
    aliases = {
      ["b"] = ")", -- brackets
      ["s"] = "]", -- square brackets
      ["B"] = "}", -- braces
      ["a"] = ">", -- angle brackets
      ["q"] = "'", -- single quotes
      ["d"] = '"', -- double quotes
      ["t"] = "`", -- backticks
    },
  },
})
