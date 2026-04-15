return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = {
      enabled = true,
      doc = {
        -- Only when I hover over them render the image inline in the buffer.
        -- If your env doesn't support unicode placeholders, this will be disabled
        inline = vim.g.neovim_mode == "skitty" and true or false,

        -- only_render_image_at_cursor = vim.g.neovim_mode == "skitty" and false or true,
        -- render the image in a floating window only used if `opts.inline` is disabled
        float = true,

        -- Sets the size of the image
        max_width = vim.g.neovim_mode == "skitty" and 5 or 60,
        max_height = vim.g.neovim_mode == "skitty" and 2.5 or 30,

        conceal = true,
      },
    },
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
    bigfile = { enabled = true, size = 10 * 1024 * 1024, line_length = math.huge },
    notifier = { enabled = true, timeout = 2400, style = "compact", top_down = false },
    scroll = { enabled = true, animate = { duration = { step = 10, total = 200 }, easing = "linear" } },
    bufdelete = { enabled = true },
    indent = { enabled = true },
    quickfile = { enabled = true },
    words = { enabled = true, debounce = 50 },
    toggle = { enabled = true },
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
    { "<leader>ff", function() Snacks.picker.files({ args = { "--no-ignore", "--hidden" } }) end, desc = "Find ALL files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live grep" },
    { "<leader>fG", function() Snacks.picker.grep({ args = { "--no-ignore", "--hidden" } }) end, desc = "Live grep (all files)" },
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

    -- Words (LSP references)
    { "]]", function() Snacks.words.jump(vim.v.count1, true) end, desc = "Next Reference", mode = { "n", "t" } },
    { "[[", function() Snacks.words.jump(-vim.v.count1, true) end, desc = "Prev Reference", mode = { "n", "t" } },
    --stylua: ignore end
  },
}
