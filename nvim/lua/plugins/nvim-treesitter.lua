-- Treesitter

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },

  cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },

  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/nvim-treesitter-context",
    "windwp/nvim-ts-autotag",
    "JoosepAlviste/nvim-ts-context-commentstring",
    "andymass/vim-matchup",
    "mfussenegger/nvim-treehopper",

    -- ==============================================================
    -- Rainbow Delimiters
    -- ==============================================================
    {
      "HiPhish/rainbow-delimiters.nvim",
      event = "BufReadPost",
      submodules = false,
      config = true,
      main = "rainbow-delimiters.setup",
    },
  },

  config = function()
    -- ts_context_commentstring setup (must be called before treesitter)
    require("ts_context_commentstring").setup({
      enable_autocmd = false, -- disable deprecated autocmd, use manual or integration instead
    })

    -- Treesitter context setup
    local context = require("treesitter-context")
    -- 0 表示不限制上下文窗口的高度
    context.setup({ enable = true, max_lines = 8 })

    -- Treesitter main setup (new main branch API)
    require("nvim-treesitter").setup({
      ensure_installed = {
        "c",
        "cmake",
        "comment", -- for tags like TODO:, FIXME(user)
        "cpp",
        "css",
        "bash",
        "diff", -- git diff
        "dockerfile",
        "git_rebase",
        "gitcommit",
        "gitattributes",
        "gitignore",
        "go",
        "gomod",
        "html",
        "ini",
        "javascript",
        "json",
        "latex",
        "lua",
        "luadoc", -- Added for better Lua documentation support
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "query", -- Added for treesitter query language
        "regex", -- Added for regex highlighting
        "rust",
        "sql",
        "php",
        "toml",
        "tsx", -- Added for TypeScript JSX
        "typescript",
        "vim",
        "vimdoc", -- Added for Vim help documentation
        "yaml",
        "xml",
      },
      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,
      -- Automatically install missing parsers when entering the buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,
      -- List of parsers to ignore installing (for "all")
      ignore_install = {},
    })

    -- Highlight is now built into Neovim (vim.treesitter), enabled by default.
    -- Disable treesitter highlight for large files.
    vim.api.nvim_create_autocmd("BufReadPost", {
      callback = function(args)
        local max_filesize = 20000 * 1024 -- 20000 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
        if ok and stats and stats.size > max_filesize then
          vim.treesitter.stop(args.buf)
        end
      end,
    })

    -- Textobjects configuration (new main branch API: setup + manual keymaps)
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    -- Move textobject keymaps
    local move = require("nvim-treesitter-textobjects.move")
    local function opts(desc)
      return { desc = "[Textobjects] " .. desc, noremap = true, silent = true, nowait = true }
    end
    --stylua: ignore start
    vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, opts("Next Function Start"))
    vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end, opts("Next Function End"))
    vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, opts("Previous Function Start"))
    vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end, opts("Previous Function End"))
    --stylua: ignore end
  end,
}
