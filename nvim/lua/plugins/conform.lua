-- Formatter & Linter
-- Mason + Conform + nvim-lint

return {
  -- Mason tool installer
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      auto_update = true,
      run_on_start = true,
      ensure_installed = {
        -- Golang
        -- "gofumpt",
        -- "goimports-reviser",
        -- "golangci-lint",

        -- Python
        "isort",
        "black",
        "pylint",

        -- Lua
        "stylua",

        -- Web (JS/TS/JSON/HTML/CSS/YAML/Markdown)
        "prettier",
        "eslint_d",

        -- Shell
        "shfmt",
      },
    },
  },

  -- Conform formatter
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    dependencies = {
      "williamboman/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    keys = {
      {
        "<leader>=",
        function()
          require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "[Conform] Format file or range(in visual mode)",
      },
    },

    opts = {
      formatters_by_ft = {
        -- Python
        python = { "isort", "black" },

        -- Lua
        lua = { "stylua" },

        -- Go
        go = { "gofumpt", "goimports-reviser" },

        -- Web languages => Prettier
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        vue = { "prettier" },

        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },
      },

      -- 自定义格式化器配置
      formatters = {
        black = {
          prepend_args = {
            "--target-version",
            "py314",
            "--line-length",
            "88",
          },
        },

        stylua = {
          prepend_args = {
            "--indent-type",
            "Spaces",
            "--indent-width",
            "2",
          },
        },

        gofumpt = {
          prepend_args = { "-extra" },
        },
      },

      -- 保存时自动格式化
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
  },

  -- nvim-lint
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python = { "pylint" },
        go = { "golangcilint" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
