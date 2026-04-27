return {
  -- ==============================================================
  -- Colorschemes
  -- ==============================================================

  {
    "miikanissi/modus-themes.nvim",
    opts = {
      transparent = true,
      italic_comments = true,
      line_nr_column_background = false,
      sign_column_background = false,

      on_highlights = function(hl, c)
        hl.NeoTreeNormal = { bg = "NONE" }
        hl.NeoTreeNormalNC = { bg = "NONE" }
        hl.NeoTreeEndOfBuffer = { bg = "NONE" }
        hl.NeoTreeWinSeparator = { bg = "NONE" }
        hl.NvimTreeNormal = { bg = "NONE" }
        hl.NvimTreeNormalNC = { bg = "NONE" }
        hl.NormalFloat = { bg = "NONE" }
        hl.FloatBorder = { bg = "NONE" }

        -- bg_blue_nuanced
        hl.Pmenu = { bg = "NONE" }
        hl.PmenuSel = { fg = "NONE", bg = "#647295", bold = true }

        hl.LineNr = { bg = "NONE", fg = c.fg_dim }
        hl.LineNrAbove = { bg = "NONE", fg = c.fg_dim }
        hl.LineNrBelow = { bg = "NONE", fg = c.fg_dim }
        hl.CursorLineNr = { bg = "NONE", fg = c.fg_active, bold = true }
        hl.SignColumn = { bg = "NONE", fg = c.fg_dim }
        hl.FoldColumn = { bg = "NONE", fg = c.fg_inactive }
        hl.CursorLine = { bg = c.bg_hl_line }
      end,
    },
  },

  {
    "catppuccin/nvim",

    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        term_colors = false,
        integrations = {
          aerial = true,
          diffview = true,
          noice = true,
          treesitter = true,
          notify = true,
          gitsigns = true,
          flash = true,
          blink_cmp = true,
          mason = true,
          snacks = true,
        },

        highlight_overrides = {
          mocha = function(mocha)
            return {
              CursorLineNr = { fg = mocha.yellow },
              FlashCurrent = { bg = mocha.peach, fg = mocha.base },
              FlashMatch = { bg = mocha.red, fg = mocha.base },
              FlashLabel = { bg = mocha.teal, fg = mocha.base },
              NormalFloat = { bg = mocha.base },
              FloatBorder = { bg = mocha.base },
              FloatTitle = { bg = mocha.base },
              RenderMarkdownCode = { bg = mocha.crust },
              Pmenu = { bg = mocha.surface0 },
              Comment = { bg = nil },
              statusline = { bg = nil },
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
    "brenoprata10/nvim-highlight-colors",
    event = "BufRead",
    opts = {
      render = "virtual",
      virtual_symbol = "■",
      virtual_symbol_position = "eow",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_var_usage = true,
      enable_named_colors = true,
      enable_tailwind = false,
      exclude_filetypes = { "lazy", "mason" },
      exclude_buftypes = { "nofile", "prompt", "terminal" },
    },
  },

  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
}
