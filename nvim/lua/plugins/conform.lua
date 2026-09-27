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
      {
        "<leader>tf",
        function()
          vim.g.format_on_save_enabled = not vim.g.format_on_save_enabled
          if vim.g.format_on_save_enabled then
            vim.notify("Format on save: ON", vim.log.levels.INFO)
          else
            vim.notify("Format on save: OFF", vim.log.levels.INFO)
          end
        end,
        desc = "[Conform] Toggle format on save",
      },
    },

    opts = {
      formatters_by_ft = {
        -- Python
        python = { "isort", "black" },

        -- Lua
        lua = { "stylua" },

        -- Go
        go = { "golangci-lint" },

        -- Web languages => Prettier
        javascript = { "eslint_d", "prettier" },
        typescript = { "eslint_d", "prettier" },
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

        -- 锚定到 buffer 所属 Go module 根，保证 golangci-lint fmt 能发现子目录里的 .golangci.yaml
        -- 注意：不能写 require("conform.util").root_file(...) —— 静态 opts 表在 conform 加载前求值，会报 module not found
        ["golangci-lint"] = {
          cwd = function(_, ctx)
            return vim.fs.root(ctx.dirname, { "go.mod" })
          end,
        },
      },

      format_on_save = function()
        if not vim.g.format_on_save_enabled then
          return
        end

        return {
          timeout_ms = 3000,
          lsp_fallback = true,
        }
      end,
    },
  },
}
