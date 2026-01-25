return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = { enabled = true },
    bigfile = { enabled = true, size = 10 * 1024 * 1024 },

    notifier = {
      enabled = true,
      timeout = 2000,
    },

    image = {
      enabled = true,
      doc = { enabled = true, inline = false, float = true, max_width = 50, max_height = 50 },
    },
  },

  keys = {
    --stylua: ignore
    vim.keymap.set("n", "<leader>Z", function() Snacks.zen() end, { desc = "Toggle Zen Mode" }),
  },
}
