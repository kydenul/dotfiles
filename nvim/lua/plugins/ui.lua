return {
  -- ==============================================================
  -- Colorschemes
  -- ==============================================================

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
      -- 'background'|'foreground'|'virtual'
      render = "background",
      ---Set virtual symbol position()
      virtual_symbol_position = "inline",
      ---Highlight hex colors, e.g. '#FFFFFF'
      enable_hex = true,
      ---Highlight short hex colors e.g. '#fff'
      enable_short_hex = true,
      ---Highlight rgb colors, e.g. 'rgb(0 0 0)'
      enable_rgb = true,
      ---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
      enable_hsl = true,
      ---Highlight ansi colors, e.g '\033[0;34m'
      enable_ansi = true,
      ---Highlight xterm 256 (8bit) colors, e.g '\033[38;5;118m'
      enable_xterm256 = true,
      ---Highlight xterm True Color (24bit) colors, e.g '\033[38;2;118;64;90m'
      enable_xtermTrueColor = true,
      -- Highlight hsl colors without function, e.g. '--foreground: 0 69% 69%;'
      enable_hsl_without_function = true,
      ---Highlight CSS variables, e.g. 'var(--testing-color)'
      enable_var_usage = true,
      ---Highlight named colors, e.g. 'green'
      enable_named_colors = true,
      ---Highlight tailwind colors, e.g. 'bg-blue-500'
      enable_tailwind = false,

      -- Exclude filetypes or buftypes from highlighting e.g. 'exclude_buftypes = {'text'}'
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
