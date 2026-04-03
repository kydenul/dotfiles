return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = { enabled = false },
    input = { enabled = false },
    picker = {
      matcher = { frecency = true, cwd_bonus = true, history_bonus = true },
      formatters = { icon_width = 3 },
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            -- ["<C-t>"] = { "edit_tab", mode = { "n", "i" } },
          },
        },
      },
    },
    bigfile = { enabled = true, size = 10 * 1024 * 1024 },
    -- notifier = { enabled = true, timeout = 2000, style = "compact", top_down = false },
    scroll = { enabled = true, animate = { duration = { step = 10, total = 200 }, easing = "linear" } },
    bufdelete = { enabled = true },
    indent = { enabled = true, scope = { enabled = true, underline = true } },
  },

  keys = {
    --stylua: ignore start
    { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete current buffer" },
    { "<leader>bo", function() Snacks.bufdelete({ filter = function(buf) return buf ~= vim.api.nvim_get_current_buf() end, }) end, desc = "Close Other Buffers" },
    { "<leader>q", function() Snacks.bufdelete() end, desc = "Delete current buffer" },

    -- Find
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find buffers" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live grep" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Fuzzy find in buffer" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Find diagnostics" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc = "Resume last picker" },
    { "<leader>fc", function() Snacks.picker.commands() end, desc = "Find commands" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Find keymaps" },
    { "<leader>fs", function() Snacks.picker.grep_word() end, desc = "Find string under cursor" },
    { "<leader>fh", function() Snacks.picker.command_history() end, desc = "Find command history" },
    { "<leader>fm", function() Snacks.picker.marks() end, desc = "Find marks" },
    { "<leader>fj", function() Snacks.picker.jumps() end, desc = "Find jumplist" },
    { "<leader>fo", function() Snacks.picker.recent() end, desc = "Oldfiles" },

    -- Git
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
    { "<leader>gL", function() Snacks.picker.git_log_file() end, desc = "Git log (buffer)" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git status" },

    -- Todo-Comment
    { "<leader>ftd", function() Snacks.picker.todo_comments() end, desc = "Todo comments" },
    --stylua: ignore end
  },
}
