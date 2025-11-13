-- Neogit

return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",

    -- Git integration
    "tpope/vim-fugitive",
  },
  cmd = "Neogit",
  keys = {
    { "<leader>g", "<cmd>Neogit<cr>", desc = "Open Neogit" },
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
