-- Auto Session Configuration

return {
  "rmagatti/auto-session",

  lazy = false,

  dependencies = { "nvim-telescope/telescope.nvim" },

  keys = {
    { "<leader>ss", "<cmd>AutoSession save<CR>", desc = "[Session] Save" },
    { "<leader>sr", "<cmd>AutoSession restore<CR>", desc = "[Session] Restore" },
    { "<leader>sd", "<cmd>AutoSession delete<CR>", desc = "[Session] Delete" },
    { "<leader>sf", "<cmd>AutoSession search<CR>", desc = "[Session] Search" },
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

    -- Session Lens
    session_lens = {
      picker = "telescope", -- "telescope"|"snacks"|"fzf"|"select"|nil
      load_on_setup = true,
      theme_conf = { border = true },
      previewer = "summary", -- 'summary'|'active_buffer'|function
    },
  },

  config = function(_, opts)
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

    -- Load Telescope extension
    require("telescope").load_extension("session-lens")

    require("auto-session").setup(opts)
  end,
}
