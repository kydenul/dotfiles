-- Aerial: code outline and symbol navigation plugin

return {
  "stevearc/aerial.nvim",
  cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialNext", "AerialPrev" },
  keys = {
    { "<F12>", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial" },
    { "<leader>at", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial" },
  },

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },

  opts = {
    on_attach = function(bufnr)
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "PrevSymbol" })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "NextSymbol" })
    end,

    layout = {
      default_direction = "left",
      max_width = 128,
      min_width = 24,
      resize_to_content = true,
      preserve_equality = false,
      placement = "edge",
    },

    icons = {
      show_icons = true,
      icons = "nvim-web-devicons",
      prioritize_glyph = true,
    },

    window = {
      height = nil,
      border = "none",
      background_highlight = "Normal",
    },

    -- 快捷键设置
    keymaps = {
      --stylua: ignore
      ["o"] = { callback = function() require("aerial").select() end, desc = "选择" },
      --stylua: ignore
      ["<Esc>"] = { callback = function() vim.cmd([[ :AerialClose ]]) end, desc = "关闭大纲窗口" },
    },

    close_automatic_events = { "unfocus", "unsupported" },
  },
}
