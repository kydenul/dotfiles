-- Smart motion

local util = require("util")
local ok, cfg = pcall(require, "hop")
if not ok then
	util.log_warn("nvim-hop init failed.")
	return
end

cfg.setup({
	-- vim.keymap.set({ "n", "v" }, "<leader>,", function()
	-- 	cfg.hint_char1({ current_line_only = false })
	-- end, { remap = true }),

	vim.keymap.set({ "n", "v" }, ",", function()
		cfg.hint_char1({ current_line_only = false })
	end, { remap = true }),
})
