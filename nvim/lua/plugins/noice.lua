-- Noice: Better UI for messages, cmdline and popupmenu

return {
  "folke/noice.nvim",
  enabled = true,
  event = "VeryLazy",

  opts = {
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      lsp_doc_border = { views = { hover = { border = { style = "single" } } } },
      inc_rename = true, -- enables an input dialog for inc-rename.nvim
    },

    lsp = {
      signature = { enabled = false },
      hover = { enabled = true },
      progress = { enabled = true },

      -- override markdown rendering
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
  },
}
