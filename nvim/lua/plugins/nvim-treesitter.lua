-- Treesitter

return {
  "nvim-treesitter/nvim-treesitter",
  main = "nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },

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

  init = function()
    local has_cli --- @type boolean|nil cached result

    local highlight = function(bufnr, lang)
      -------------------[ treesitter highlights ]-------------------------------
      if not vim.treesitter.language.add(lang) then
        return vim.notify(
          string.format("Treesitter cannot load parser for language: %s", lang),
          vim.log.levels.INFO,
          { title = "Treesitter" }
        )
      end
      vim.treesitter.start(bufnr)
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ft = vim.bo.filetype
        local buf = args.buf

        if vim.bo.buftype ~= "" then
          return
        end -- don't run further.

        local ok, treesitter = pcall(require, "nvim-treesitter")
        if not ok then
          return
        end

        --------------------[ treesitter parsers ]-------------------------------
        if has_cli == nil then
          has_cli = vim.fn.executable("tree-sitter") == 1
        end
        if not has_cli then
          vim.api.nvim_echo({
            {
              "tree-sitter CLI not found. Parsers cannot be installed.",
              "ErrorMsg",
            },
          }, true, {})
          return
        end

        if not vim.treesitter.language.get_lang(ft) then
          return
        end

        if vim.list_contains(treesitter.get_installed(), ft) then
          highlight(buf, ft)
        elseif vim.list_contains(treesitter.get_available(), ft) then
          treesitter.install(ft):await(function()
            highlight(buf, ft)
          end)
        end
      end,
    })
  end,
  opts = {
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
  },
  config = function(_, opts)
    -- ts_context_commentstring setup (must be called before treesitter)
    require("ts_context_commentstring").setup({
      enable_autocmd = false, -- disable deprecated autocmd, use manual or integration instead
    })

    -- Treesitter context setup
    -- 0 表示不限制上下文窗口的高度
    require("treesitter-context").setup({ enable = true, max_lines = 8 })

    -- Textobjects configuration (new main branch API: setup + manual keymaps)
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    -- Move textobject keymaps
    local move = require("nvim-treesitter-textobjects.move")
    local function opt(desc)
      return { desc = "[Textobjects] " .. desc, noremap = true, silent = true, nowait = true }
    end
    --stylua: ignore start
    vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, opt("Next Function Start"))
    vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end, opt("Next Function End"))
    vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, opt("Previous Function Start"))
    vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end, opt("Previous Function End"))
    --stylua: ignore end

    local treesitter = require("nvim-treesitter")
    treesitter.setup(opts)
    if vim.fn.executable("tree-sitter") == 1 then
      treesitter.install(opts.ensure_installed)
    end
  end,
}
