-- Aerial: code outline and symbol navigation plugin

return {
  "stevearc/aerial.nvim",

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },

  opts = {
    on_attach = function(bufnr) -- 当 aerial 附加到缓冲区时设置快捷键
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "PrevSymbol" })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "NextSymbol" })

      vim.keymap.set("n", "<F12>", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial" })
      vim.keymap.set("n", "<leader>at", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial" })

      -- Telescope 集成
      local found_telescope, telescope = pcall(require, "telescope")
      if found_telescope then
        telescope.load_extension("aerial")
        vim.keymap.set("n", "<leader>a.", "<cmd>Telescope aerial<CR>", { desc = "搜索符号" })
      end
    end,

    layout = {
      default_direction = "right",
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
