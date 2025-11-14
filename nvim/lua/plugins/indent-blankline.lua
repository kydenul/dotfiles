-- indent-blankline configuration

return {
  "lukas-reineke/indent-blankline.nvim",
  event = "BufReadPost",
  main = "ibl",

  -- Define rainbow colors for indent guides
  opts = {
    -- Indent guide configuration
    indent = {
      char = "│",
      -- Alternative characters: "▏", "┊", "┆", "¦", "│"
      tab_char = "│",
      smart_indent_cap = true,
      priority = 1,
    },

    -- Scope configuration (current code block highlighting)
    scope = {
      enabled = true,
      char = "│,",
      highlight = {
        "RainbowBlue",
        "RainbowRed",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
        "RainbowYellow",
      },
      show_start = true,
      show_end = true,
      show_exact_scope = true,
      injected_languages = true,
      priority = 1024,
    },

    -- Whitespace configuration
    whitespace = { remove_blankline_trail = true },

    -- Exclude certain file types and buffer types
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
        "NvimTree",
        "packer",
        "lspinfo",
        "TelescopePrompt",
        "TelescopeResults",
        "checkhealth",
        "",
      },
      buftypes = { "terminal", "nofile", "quickfix", "prompt" },
    },
  },

  -- Handle hooks and global settings separately
  config = function(_, opts)
    local ibl = require("ibl")
    local hooks = require("ibl.hooks")

    -- Create the highlight groups in the highlight setup hook, so they are reset
    -- every time the colorscheme changes
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    end)

    -- Register the scope highlight hook before setup
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

    -- Set global rainbow delimiters configuration
    vim.g.rainbow_delimiters = { highlight = opts.scope.highlight }

    -- Configure and initialize indent-blankline with opts
    ibl.setup(opts)
  end,
}
