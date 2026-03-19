return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = { enabled = false },
    bigfile = { enabled = true, size = 10 * 1024 * 1024 },
    notifier = { enabled = true, timeout = 2000, style = "compact", top_down = false },
    scroll = { enabled = true, animate = { duration = { step = 10, total = 200 }, easing = "linear" } },
    bufdelete = { enabled = true },
    indent = { enabled = true },
  },

  keys = {
    --stylua: ignore start
    { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete current buffer" },
    { "<leader>bo", function() Snacks.bufdelete({ filter = function(buf) return buf ~= vim.api.nvim_get_current_buf() end, }) end, desc = "Close Other Buffers" },
    { "<leader>q", function() Snacks.bufdelete() end, desc = "Delete current buffer" },
    --stylua: ignore end
  },
}
