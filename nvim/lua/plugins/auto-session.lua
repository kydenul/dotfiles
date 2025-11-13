-- Auto Session Configuration

return {
  "rmagatti/auto-session",

  lazy = false,
  keys = {
    { "<leader>ss", "<cmd>AutoSession save<CR>", desc = "Save session" },
    { "<leader>sr", "<cmd>SessionRestore<CR>", desc = "Restore session" },
    { "<leader>sd", "<cmd>AutoSession delete<CR>", desc = "Delete session" },
    { "<leader>sf", "<cmd>AutoSession search<CR>", desc = "Session search" },
  },

  opts = {
    -- Session directory
    root_dir = vim.fn.stdpath("data") .. "/sessions/",

    -- Session management
    auto_save = true,
    auto_restore = true,
    auto_create = true,

    -- Suppress session create/restore in these directories
    suppressed_dirs = {
      "~/",
      "~/Downloads",
      "~/Documents",
      "~/Desktop",
      "/tmp",
      "/bin",
    },
  },

  config = function(_, opts)
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

    require("auto-session").setup(opts)
  end,
}
