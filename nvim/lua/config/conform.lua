-- Formatter & Linter
-- Mason + Conform

local util = require("util")

-- Mason-tool-installer (推荐用来替代 mason-null-ls)
local mason_tool_installer_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
if not mason_tool_installer_ok then
  util.log_warn("mason-tool-installer load failed.")
  return
end
mason_tool_installer.setup({
  ensure_installed = {
    -- Golang
    "gofumpt",
    "goimports-reviser",
    "golangci-lint",

    -- Python
    "isort",
    "black",

    -- Lua
    "stylua",

    -- JSON
    "jq",

    -- Markdown
    "markdownlint",

    -- 其他常用工具
    "prettier",
    "eslint_d",
    "shfmt",
  },
  auto_update = true,
  run_on_start = true,
})

-- Conform
local conform_ok, conform = pcall(require, "conform")
if not conform_ok then
  util.log_warn("conform load failed.")
  return
end

conform.setup({
  formatters_by_ft = {
    -- Python
    python = { "isort", "black" },

    -- Lua
    lua = { "stylua" },

    -- Go
    go = { "goimports-reviser", "gofumpt" },

    -- JSON
    json = { "jq" },

    -- Markdown
    markdown = { "markdownlint" },

    -- JavaScript/TypeScript
    javascript = { "prettier" },
    typescript = { "prettier" },

    -- Shell
    sh = { "shfmt" },
    bash = { "shfmt" },
  },

  -- 自定义格式化器配置
  formatters = {
    black = {
      prepend_args = {
        "--target-version",
        "py313",
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
    timeout_ms = 500,
    lsp_fallback = true,
  },

  -- 格式化后的回调
  format_after_save = {
    lsp_fallback = true,
  },
})

-- 手动格式化快捷键
vim.keymap.set({ "n", "v" }, "<leader>=", function()
  conform.format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  })
end, { desc = "Format file or range (in visual mode)" })
