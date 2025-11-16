--
-- File: dashboard.lua
-- Author: kyden
-- Date: 2025-11-16
-- Description: Dashboard is a startup screen for Neovim
--

return {
  "glepnir/dashboard-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons", "rmagatti/auto-session" },

  config = function()
    require("dashboard").setup({
      theme = "hyper",
      config = {
        header = {
          " ▄▀▀▄ █  ▄▀▀▄ ▀▀▄  ▄▀▀█▄▄   ▄▀▀█▄▄▄▄  ▄▀▀▄ ▀▄  ▄▀▀▄ ▄▀▀▄  ▄▀▀▀▀▄     ",
          "█  █ ▄▀ █   ▀▄ ▄▀ █ ▄▀   █ ▐  ▄▀   ▐ █  █ █ █ █   █    █ █    █      ",
          "▐  █▀▄  ▐     █   ▐ █    █   █▄▄▄▄▄  ▐  █  ▀█ ▐  █    █  ▐    █      ",
          "  █   █       █     █    █   █    ▌    █   █    █    █       █       ",
          "▄▀   █      ▄▀     ▄▀▄▄▄▄▀  ▄▀▄▄▄▄   ▄▀   █      ▀▄▄▄▄▀    ▄▀▄▄▄▄▄▄▀ ",
          "█    ▐      █     █     ▐   █    ▐   █    ▐                █         ",
          "▐           ▐     ▐         ▐        ▐                     ▐         ",
        },

        shortcut = {
          { desc = "[  Github]", group = "DashboardShortCut" },
          { desc = "[  kydenul]", group = "DashboardShortCut" },
          { key = "u", action = "Lazy update", desc = "󰊳 Update", group = "@property" },
        },

        packages = { enable = true }, -- show how many plugins neovim loaded
        project = { enable = false },
        mru = { enable = false },
        footer = {
          "Read not to contradict and confute; nor to believe and take for granted;",
          "     nor to find talk and discourse; but to weigh and consider.",
        },
      },
    })
  end,
}
