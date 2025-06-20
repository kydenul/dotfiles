-- indent-blankline configuration

local util = require("util")
local is_ok, ibl = pcall(require, "ibl")
if not is_ok then
	util.log_warn("indent-blankline load failed.")
	return
end

-- Create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
local hooks = require("ibl.hooks")
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
	vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
	vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
	vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
	vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
	vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
	vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)
-- Register the scope highlight hook before setup
hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

-- Define rainbow colors for indent guides
local highlight = {
	"RainbowBlue",
	"RainbowRed",
	"RainbowOrange",
	"RainbowGreen",
	"RainbowViolet",
	"RainbowCyan",
	"RainbowYellow",
}

-- Set global rainbow delimiters configuration
vim.g.rainbow_delimiters = { highlight = highlight }

-- Configure and initialize indent-blankline
ibl.setup({
	indent = { char = "│" },
	scope = { highlight = highlight },
})
