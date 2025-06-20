-- Aerial: code outline and symbol navigation plugin

local util = require("util")

local is_ok, rmd = pcall(require, "render-markdown")
if not is_ok then
	util.log_warn("aerial load failed, please check your config")
	return
end

rmd.setup({
	sign = {
		-- Turn on / off sign rendering.
		enabled = false,
		-- Applies to background of sign text.
		highlight = "RenderMarkdownSign",
	},
})
