-- Auto Session Configuration

return {
  "rmagatti/auto-session",

  lazy = false,

  dependencies = { "folke/snacks.nvim" },

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
      picker = "snacks", -- "telescope"|"snacks"|"fzf"|"select"|nil
      load_on_setup = true,
      previewer = "summary", -- 'summary'|'active_buffer'|function
    },
  },

  config = function(_, opts)
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

    -- HACK: Neovim 0.12.0 diagnostic.lua bug workaround
    -- When auto-session wipes buffers during session switch, LSP detach triggers
    -- diagnostic.hide() -> cleanup_show_autocmd -> nvim_del_autocmd on an already
    -- deleted autocmd, causing an error. Wrap with pcall to degrade to a warning.
    -- Remove this once Neovim fixes the issue upstream.
    if vim.fn.has("nvim-0.12") == 1 and vim.fn.has("nvim-0.13") == 0 then
      local orig_del_autocmd = vim.api.nvim_del_autocmd
      vim.api.nvim_del_autocmd = function(id)
        local ok, err = pcall(orig_del_autocmd, id)
        if not ok then
          vim.notify("[nvim 0.12 compat] nvim_del_autocmd: " .. tostring(err), vim.log.levels.WARN)
        end
      end
    end

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
