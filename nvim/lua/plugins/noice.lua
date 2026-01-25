-- Noice: Better UI for messages, cmdline and popupmenu

return {
  "folke/noice.nvim",
  enabled = true,
  event = "VeryLazy",

  -- lazy load cmp on more keys along with insert mode
  keys = {
    ":",
    "/",
    "?",
    { "<leader>fn", "<CMD>Noice pick<CR>", desc = "[Noice] Pick history messages" },
    { "<leader>N", "<CMD>Noice<CR>", desc = "[Noice] Show messages" },
  },

  opts = {
    presets = {
      -- inc_rename = true, -- enables an input dialog for inc-rename.nvim
      long_message_to_split = true, -- long messages will be sent to a split
      lsp_doc_border = { views = { hover = { border = { style = "single" } } } },
    },

    cmdline = { enabled = true },
    popupmenu = { enabled = true },
    messages = { enabled = true },

    lsp = {
      signature = { enabled = false },
      hover = { enabled = true },
      progress = { enabled = true },

      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = false, -- requires hrsh7th/nvim-cmp
      },
    },
  },
}
