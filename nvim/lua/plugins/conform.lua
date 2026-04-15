-- Formatter & Linter
-- Mason + Conform

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
        desc = "[Conform] Format file or range",
      },
    },

    opts = {
      formatters_by_ft = {
        -- Python
        python = { "isort", "black", "pylint" },

        -- Lua
        lua = { "stylua" },

        -- Go
        go = { "gofumpt", "goimports-reviser", "golangci-lint" },

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
        prettier = { prepend_args = { "--ignore-path", "/dev/null" } },
        eslint_d = { prepend_args = { "--no-ignore" } },
        stylua = {
          prepend_args = {
            "--no-ignore-vcs",
            "--indent-type",
            "Spaces",
            "--indent-width",
            "2",
          },
        },

        black = {
          prepend_args = {
            "--target-version",
            "py314",
            "--line-length",
            "120",
          },
        },

        gofumpt = { prepend_args = { "-extra" } },
      },

      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
  },
}
