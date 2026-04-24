-- ==============================================================
-- IDE-like Breadcrumbs
-- ==============================================================
--
return {
  "Bekaboo/dropbar.nvim",

  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },

  config = function()
    require("dropbar").setup({
      bar = {
        enable = function(buf, win, _)
          local ft = vim.bo[buf].filetype
          -- Disable winbar for NvimTree and other non-code windows
          local excluded = { NvimTree = true, alpha = true }
          if excluded[ft] then
            return false
          end
          return vim.fn.win_gettype(win) == ""
            and vim.wo[win].winbar == ""
            and vim.bo[buf].buftype == ""
        end,
      },
    })

    local dropbar_api = require("dropbar.api")
    vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
    vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
    vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
  end,
}
