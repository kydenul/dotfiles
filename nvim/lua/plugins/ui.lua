return {
  -- ==============================================================
  -- Colorschemes
  -- ==============================================================
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "hard" -- 'hard', 'medium', 'soft'
      vim.g.gruvbox_material_foreground = "material" -- 'material', 'mix', 'original'
      vim.g.gruvbox_material_float_style = "blend"
      vim.g.gruvbox_material_transparent_background = 2 -- 0, 1, 2
    end,
  },

  {
    "catppuccin/nvim",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("catppuccin-mocha")
      vim.cmd.hi("Comment gui=none")
    end,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        term_colors = true,
        integrations = {
          aerial = true,
          diffview = true,
          noice = true,
          which_key = true,
          notify = false,
          blink_cmp = true,
          mason = true,
          snacks = false,
        },

        highlight_overrides = {
          mocha = function(mocha)
            return {
              CursorLineNr = { fg = mocha.yellow },
              TelescopeSelection = { bg = mocha.surface0 },
              TelescopeSelectionCaret = { fg = mocha.yellow, bg = mocha.surface0 },
              TelescopePromptPrefix = { fg = mocha.yellow },
              FlashCurrent = { bg = mocha.peach, fg = mocha.base },
              FlashMatch = { bg = mocha.red, fg = mocha.base },
              FlashLabel = { bg = mocha.teal, fg = mocha.base },
              NormalFloat = { bg = mocha.base },
              FloatBorder = { bg = mocha.base },
              FloatTitle = { bg = mocha.base },
            }
          end,
        },
      })
    end,
  },

  -- ==============================================================
  -- Color Highlighter
  -- ==============================================================
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufRead",
    config = function(_)
      require("colorizer").setup()
    end,
  },
}
