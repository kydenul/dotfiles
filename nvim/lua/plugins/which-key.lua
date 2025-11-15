-- Plugin Name: which-key.nvim - Displays available keybindings in popup
-- Optimization: Converted to use opts pattern for simple setup
--
-- Patterns applied:
-- - opts: Simple setup configuration (replaces config function)

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- Use classic preset (other options: "modern", "helix")
    preset = "helix",

    -- Delay before showing the popup (in ms)
    delay = function(ctx)
      return ctx.plugin and 0 or 200
    end,

    -- Plugins configuration
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },

    -- Window appearance configuration
    win = {
      no_overlap = true,
      padding = { 1, 2 },
      title = true,
      title_pos = "center",
      zindex = 1000,
    },

    -- Layout configuration
    layout = {
      width = { min = 20 },
      spacing = 3,
    },

    -- Key bindings for navigating the popup
    keys = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },

    -- Icons configuration
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },

    -- Show help message in the command line
    show_help = true,

    -- Show the currently pressed key and its label as a message in the command line
    show_keys = true,

    -- Disable WhichKey for certain buffer types and file types
    disable = {
      ft = {},
      bt = {},
    },
  },
}
