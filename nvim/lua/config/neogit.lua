-- Neogit

local util = require("util")
local ok, cfg = pcall(require, "neogit")
if not ok then
	util.log_warn("neogit init failed.")
	return
end

cfg.setup({
	vim.keymap.set("n", "<leader>g", function()
		require("neogit").open()
	end, { noremap = true, silent = true, desc = "Neogit" }),
})
