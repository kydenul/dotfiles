return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = { enabled = true },
    input = { enabled = false },
    picker = {
      matcher = { frecency = true, cwd_bonus = true, history_bonus = true },
      win = {
        input = {
          keys = {
            ["<CR>"] = { "confirm", mode = { "n", "i" } },
            ["q"] = { "close", mode = { "n" } },

            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
          },
        },
        list = {
          keys = {
            ["<Tab>"] = { "list_down", mode = { "n" } },
            ["<S-Tab>"] = { "list_up", mode = { "n" } },
          },
        },
      },
    },
    bigfile = { enabled = true, size = 10 * 1024 * 1024 },
    notifier = { enabled = true, timeout = 2400, style = "compact", top_down = false },
    scroll = { enabled = true, animate = { duration = { step = 10, total = 200 }, easing = "linear" } },
    bufdelete = { enabled = true },
    indent = { enabled = true },
  },

  keys = {
    --stylua: ignore start

    -- Top Pickers
    { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },

    -- Buffer
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete current buffer" },
    { "<leader>bo", function() Snacks.bufdelete({ filter = function(buf) return buf ~= vim.api.nvim_get_current_buf() end, }) end, desc = "Close Other Buffers" },
    { "<leader>q", function() Snacks.bufdelete() end, desc = "Delete current buffer" },

    -- Find
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Fuzzy find in buffer" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live grep" },
    { "<leader>fs", function() Snacks.picker.grep_word() end, desc = "Find string under cursor" },

    { "<leader>fb", function() Snacks.picker.buffers({ sort_lastused = true }) end, desc = "Find buffers" },
    { "<leader>fo", function() Snacks.picker.recent() end, desc = "Oldfiles" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc = "Resume last picker" },

    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Find diagnostics" },
    { "<leader>fm", function() Snacks.picker.marks() end, desc = "Find marks" },
    { "<leader>fj", function() Snacks.picker.jumps() end, desc = "Find jumplist" },

    { "<leader>fc", function() Snacks.picker.commands() end, desc = "Find commands" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Find keymaps" },
    { "<leader>fh", function() Snacks.picker.command_history() end, desc = "Find command history" },

    { "<leader>fn", function() Snacks.picker.notifications() end, desc = "[Snacks] Pick notification history" },

    -- Git
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
    { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
    { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git log File (buffer)" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git status" },

    -- Todo-Comment
    { "<leader>ftd", function() Snacks.picker.todo_comments() end, desc = "Todo comments" },
    --stylua: ignore end
  },
}
