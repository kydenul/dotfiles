-- Neogit

return {
  "NeogitOrg/neogit",

  lazy = true,

  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",

    {
      "isakbm/gitgraph.nvim",
      dependencies = { "sindrets/diffview.nvim" },
      ---@type I.GGConfig
      opts = {
        git_cmd = "git",
        symbols = {
          merge_commit = "M",
          commit = "*",
        },

        format = {
          timestamp = "%H:%M:%S %d-%m-%Y",
          fields = { "hash", "timestamp", "author", "branch_name", "tag" },
        },

        hooks = {
          -- Check diff of a commit
          on_select_commit = function(commit)
            vim.notify("DiffviewOpen " .. commit.hash .. "^!")
            vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
          end,

          -- Check diff from commit a -> commit b
          on_select_range_commit = function(from, to)
            vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
            vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
          end,
        },
      },
    },
  },

  cmd = "Neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "[Neogit] TUI Toggle" },

    { "gho", "<cmd>DiffviewOpen<cr>", desc = "[Diffview] Open" },
    { "ghc", "<cmd>DiffviewClose<cr>", desc = "[Diffview] Close" },
    -- stylua: ignore
    { "ghg", function() require("gitgraph").draw({}, { all = true, max_count = 5000 }) end, desc = "[GitGraph] Draw" },
  },

  opts = {
    -- Disables synchronizing the status buffer with the file system.
    disable_fs_sync = false,

    -- Disables changing the buffer highlights based on where the cursor is.
    disable_commit_confirmation = false,

    -- Shows a list of integrations and their status.
    integrations = {
      diffview = true, -- Diffview is a required integration for neogit but it can be disabled
      telescope = true, -- Telescope integration
    },

    -- The depth of the logs to fetch when showing the graph.
    -- `0` will fetch all logs.
    log_graph_depth = 256,

    -- The kind of graph to use for the log.
    -- `dense` is the default, `sparse` is also available.
    log_graph_kind = "dense",
  },
}
