return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = { enabled = true },
    bigfile = { enabled = true, size = 10 * 1024 * 1024 },
    notifier = { enabled = true, timeout = 2000, style = "compact", top_down = false },
    scroll = { enabled = true, animate = { duration = { step = 10, total = 200 }, easing = "linear" } },
    bufdelete = { enabled = true },
    indent = { enabled = true },
  },

  keys = {
    --stylua: ignore
    vim.keymap.set("n", "<leader>z", function() Snacks.zen() end, { desc = "Toggle Zen Mode" }),
    --stylua: ignore
    vim.keymap.set("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete current buffer" }),
    --stylua: ignore
    vim.keymap.set("n", "<leader>q", function() Snacks.bufdelete() end, { desc = "Delete current buffer" }),
  },
}
