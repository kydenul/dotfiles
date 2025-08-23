-- Treesitter

local util = require("util")

local context_ok, context = pcall(require, "treesitter-context")
if not context_ok then
  util.log_warn("nvim-treesitter-context init failed!")
  return
end

context.setup({
  enable = true,
  max_lines = 5, -- 0 表示不限制上下文窗口的高度
  separator = "─",
})

local is_ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not is_ok then
  util.log_warn("nvim-treesitter init failed!")
  return
end

treesitter.setup({
  -- A list of parser names, or "all" (these parsers should always be installed)
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
  -- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers",
  -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    -- Should we enable this module for all supported languages?
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example, if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- If you want to disable the module for some languages you can pass a list to the `disable` option.
    -- Or use a function for more flexibility, e.g. to disable slow tree-sitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 20000 * 1024 -- 20000 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
      return false
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },

  -- Indentation based on treesitter for the = operator. NOTE: This is an experimental feature.
  indent = {
    enable = true,
  },

  -- Incremental selection based on the named nodes from the grammar
  incremental_selection = {
    enable = true,
    -- init_selection: in normal mode, start incremental selection.
    -- node_incremental: in visual mode, increment to the upper named parent.
    -- scope_incremental: in visual mode, increment to the upper scope
    -- node_decremental: in visual mode, decrement to the previous named node.
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      node_decremental = "<BS>",
      scope_incremental = "<TAB>",
    },
  },

  -- Enable tree-sitter based folding
  fold = { enable = true },

  -- Enable tree-sitter based text objects
  textobjects = {
    enable = true,

    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
      },
    },

    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = { ["]f"] = "@function.outer" },
      goto_next_end = { ["]F"] = "@function.outer" },
      goto_previous_start = { ["[f"] = "@function.outer" },
      goto_previous_end = { ["[F"] = "@function.outer" },
    },
  },
})

-- Add commands to help with treesitter
vim.api.nvim_create_user_command("TSInstallInfo", function()
  vim.cmd("TSInstallInfo")
end, { desc = "Show installed treesitter parsers" })

vim.api.nvim_create_user_command("TSModuleInfo", function()
  vim.cmd("TSModuleInfo")
end, { desc = "Show treesitter module information" })
