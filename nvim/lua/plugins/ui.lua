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

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
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

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      -- 切换 pane 前自动保存当前 buffer（与 auto-session 互补）
      vim.g.tmux_navigator_save_on_switch = 2
      -- Tmux zoom 状态下禁用导航切换，避免意外退出 zoom
      vim.g.tmux_navigator_disable_when_zoomed = 1
    end,
  },
}
