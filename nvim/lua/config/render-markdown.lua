-- render-markdown.nvim

local util = require("util")

local is_ok, rmd = pcall(require, "render-markdown")
if not is_ok then
  util.log_warn("aerial load failed, please check your config")
  return
end

rmd.setup({
  completions = { lsp = { enabled = true } },

  sign = {
    -- Turn on / off sign rendering.
    enabled = true,
    -- Applies to background of sign text.
    highlight = "RenderMarkdownSign",
  },
})
