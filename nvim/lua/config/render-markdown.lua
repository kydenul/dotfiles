-- Aerial: code outline and symbol navigation plugin

local util = require("util")

local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
	vim.notify("nvim-cmp or its dependencies failed to load", vim.log.levels.ERROR)
	return
end

local is_ok, aerial = pcall(require, "render-markdown")
if not is_ok then
	util.log_warn("aerial load failed, please check your config")
	return
end

aerial.setup({
	sign = {
		-- Turn on / off sign rendering.
		enabled = false,
		-- Applies to background of sign text.
		highlight = "RenderMarkdownSign",
	},

	-- completions = {
	-- 	lsp = { enabled = true },
	-- 	blink = { enabled = true },
	-- },

	-- sources = cmp.config.sources({
	-- 	{ name = "render-markdown" },
	-- }),
})
