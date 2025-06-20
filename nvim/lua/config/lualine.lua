-- Status Line

local util = require("util")
local ok, lualine = pcall(require, "lualine")
if not ok then
	util.log_warn("lualine load failed")
	return
end

-- Configure lualine with better defaults
lualine.setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = { "dashboard", "alpha" },
			winbar = {},
		},
		ignore_focus = { "NvimTree", "neo-tree", "Outline" },
		always_divide_middle = true,
		globalstatus = true, -- Use Neovim's global statusline
		refresh = {
			statusline = 100,
			tabline = 100,
			winbar = 100,
		},
	},

	-- +-------------------------------------------------+
	-- | A | B | C                             X | Y | Z |
	-- +-------------------------------------------------+
	sections = {
		lualine_a = { "mode" },

		lualine_b = { "branch", "diff", "diagnostics" },

		lualine_c = {
			{
				"filename",

				-- Path configurations
				-- 0: Just the filename
				-- 1: Relative path
				-- 2: Absolute path
				-- 3: Absolute path, with tilde as the home directory
				-- 4: Filename and parent dir, with tilde as the home directory
				path = 3,
				symbols = {
					modified = "●",
					readonly = "",
					unnamed = "[No Name]",
				},
			},
		},

		lualine_x = {
			"encoding",
			"fileformat",
			"filetype",
			{
				"filesize",
				cond = function()
					return vim.fn.getfsize(vim.fn.expand("%:p")) > 0
				end,
			},
			{ "datetime", style = "%H:%M:%S" },
		},

		lualine_y = { "progress" },
		lualine_z = { "location" },
	},

	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},

	tabline = {}, -- Let another plugin handle the tabline
	winbar = {},
	inactive_winbar = {},
	extensions = {
		"nvim-tree",
		"toggleterm",
		"quickfix",
		"fugitive",
	},
})
