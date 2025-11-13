-- Gitsigns: Git integration and status display plugin
--
-- Optimization: Keymaps extracted to keys field for lazy-loading
--
-- Patterns applied:
-- - keys: Lazy-loaded keymaps extracted from on_attach
-- - opts: Setup configuration moved to opts table
-- - config: Only handles highlight groups setup

return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPost",

  -- Keymaps (lazy-loaded on key press)
  keys = {
    -- Navigation between hunks
    {
      "]c",
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end,
      expr = true,
      desc = "[Git] Next git hunk",
    },

    {
      "[c",
      function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsigns").prev_hunk()
        end)
        return "<Ignore>"
      end,
      expr = true,
      desc = "[Git] Previous git hunk",
    },

    -- stylua: ignore
    { "ghp", function() require("gitsigns").preview_hunk() end, desc = "[Git] Preview hunk" },
    -- stylua: ignore
    { "ghi", function() require("gitsigns").preview_hunk_inline() end, desc = "[Git] Preview hunk inline" },
    -- stylua: ignore
    { "ghr", function() require("gitsigns").reset_hunk() end, desc = "[Git] Reset hunk" },
    -- stylua: ignore
    { "ghb", function() require("gitsigns").blame_line({ full = true }) end, desc = "[Git] Blame line" },
    -- stylua: ignore
    { "ghd", function() require("gitsigns").diffthis() end, desc = "[Git] Diff this" },
    -- stylua: ignore
    { "ghD", function() require("gitsigns").diffthis("~") end, desc = "[Git] Diff this ~" },
  },

  -- Plugin configuration using opts instead of setup()
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },

    -- Current line blame
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", --'eol' | 'overlay' | 'right_align'
      delay = 240,
      ignore_whitespace = true,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",

    -- Watch Git directory
    watch_gitdir = {
      interval = 1000, -- Update interval
      follow_files = true, -- Follow file renames
    },
    attach_to_untracked = true,
    update_debounce = 100,

    status_formatter = nil,
    max_file_length = 80000, -- Disable if the file is longer than this (in lines)
    preview_config = {
      -- Options passed to nvim_open_win
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
  },

  -- Config function only handles highlight groups
  config = function(_, opts)
    -- Setup plugin with opts
    require("gitsigns").setup(opts)

    -- Set highlight groups
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#4CAF50" })
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#2196F3" })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#F44336" })
    vim.api.nvim_set_hl(0, "GitSignsTopdelete", { link = "GitSignsDelete" })
    vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "GitSignsChange" })
    vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = "#9C27B0" })
  end,
}
