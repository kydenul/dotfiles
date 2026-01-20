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

    -- Check and clean up invalid sessions on startup
    vim.schedule(function()
      local session_dir = opts.root_dir

      -- Ensure session directory exists
      if vim.fn.isdirectory(session_dir) == 0 then
        return
      end

      -- URL decode helper function
      local function url_decode(str)
        str = str:gsub("%%(%x%x)", function(hex)
          return string.char(tonumber(hex, 16))
        end)
        return str
      end

      -- Iterate through all session files
      local sessions = vim.fn.glob(session_dir .. "*.vim", false, true)
      for _, session_file in ipairs(sessions) do
        -- Extract directory path from session filename
        -- Session files are URL-encoded like: %2FUsers%2Fkyden%2Fproject.vim
        local session_name = vim.fn.fnamemodify(session_file, ":t:r") -- Get filename without extension
        local dir_path = url_decode(session_name)

        -- Check if the directory still exists
        if vim.fn.isdirectory(dir_path) == 0 then
          vim.fn.delete(session_file)
          vim.notify("Cleaned up invalid session for non-existent directory: " .. dir_path, vim.log.levels.INFO)
        end
      end
    end)
  end,
}
