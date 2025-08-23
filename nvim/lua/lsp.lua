-- NOTE: The order matters: require("mason") -> require("mason-lspconfig") -> require("lspconfig")

local util = require("util")

local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  util.log_warn("mason load failed")
  return
end

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
    border = "rounded",
  },
  max_concurrent_installers = 4,

  automatic_installation = true,
  -- Use mason-lspconfig for better integration
  ensure_installed = {
    "pylsp", -- Python
    "gopls", -- Go
    "clangd", -- C/C++
    "marksman", -- Markdown
    "lua_ls", -- lua_ls
    "cmake", -- CMake
    "bashls", -- Bash
  },
})

-- Set different settings for different languages' LSP.
-- LSP list: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- How to use setup({}): https://github.com/neovim/nvim-lspconfig/wiki/Understanding-setup-%7B%7D
--     - the settings table is sent to the LSP.
--     - on_attach: a lua callback function to run after LSP attaches to a given buffer.
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
  util.log_warn("lspconfig load failed")
  return
end

-- Remove Global Default Key mapping
vim.keymap.del("n", "grn")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grt")

-- Highlight symbol under cursor
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#504945", bold = true })
vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "LspReferenceText" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "LspReferenceText" })

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer.
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = function(desc)
    return { noremap = true, silent = true, buffer = bufnr, desc = desc }
  end

  vim.keymap.set("n", "<leader>ih", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, bufopts("[LSP] Toggle Inlay Hints"))

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts("[LSP] Go to Declaration"))
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts("[LSP] Go to Definition"))
  vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", bufopts("[LSP] Go to References"))
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts("[LSP] Go to Implementation"))
  vim.keymap.set("n", "gK", vim.lsp.buf.hover, bufopts("[LSP] Hover"))

  -- K: show diagnostics if available, otherwise show hover information
  vim.keymap.set("n", "K", function()
    local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    if next(line_diagnostics) then
      vim.diagnostic.open_float()
    else
      vim.lsp.buf.hover()
    end
  end, bufopts("[LSP] Diagnostic or Hover"))
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts("[LSP] Signature Help"))

  -- Highlighting when the cursor is on a symbol
  vim.api.nvim_create_autocmd(
    { "CursorHold", "CursorHoldI" },
    { callback = vim.lsp.buf.document_highlight, buffer = bufnr, desc = "[LSP] Document Highlight" }
  )
  vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI" },
    { callback = vim.lsp.buf.clear_references, buffer = bufnr, desc = "[LSP] Clear References" }
  )

  -- vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  -- vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts("[LSP] Code Action"))

  -- Format
  vim.api.nvim_buf_create_user_command(bufnr, "Fmt", function(opts)
    local range
    if opts.range == 2 then
      -- The range is inclusive, so we need to go to the end of the line.
      -- -1 means the end of the line.
      range = { ["start"] = { opts.line1, 0 }, ["end"] = { opts.line2, -1 } }
    end

    vim.lsp.buf.format({ async = true, range = range })
  end, { range = true })

  -- The keymap remains the same
  vim.keymap.set(
    "n",
    "<space>=",
    ":Fmt<CR>",
    { noremap = true, silent = true, buffer = bufnr, desc = "[LSP] Format code" }
  )
end

-- How to add an LSP for a specific programming language?
-- 1. Use `:Mason` to install the corresponding LSP.
-- 2. Add the configuration below. The syntax is `lspconfig.<name>.setup(...)`
-- Hint (find <name> here) : https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
lspconfig.bashls.setup({ on_attach = on_attach })

lspconfig.pylsp.setup({
  on_attach = on_attach,
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          maxLineLength = 120,
        },
      },
    },
  },
})

lspconfig.gopls.setup({
  on_attach = on_attach,
  cmd = { "gopls" },
  filetypes = {
    "go",
    "gomod",
    "gowork",
    "gotmpl",
  },
  root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
})

lspconfig.lua_ls.setup({
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      telemetry = { enable = false },
    },
  },
})

-- Case 1. For CMake Users
--     $ cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
-- Case 2. For Bazel Users, use https://github.com/hedronvision/bazel-compile-commands-extractor
-- Case 3. If you don't use any build tool and all files in a project use the same build flags
--     Place your compiler flags in the compile_flags.txt file, located in the root directory
--     of your project. Each line in the file should contain a single compiler flag.
-- src: https://clangd.llvm.org/installation#compile_commandsjson
lspconfig.clangd.setup({ on_attach = on_attach })

-- Customized on_attach function.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions.
local opts = { noremap = true, silent = true }
-- Updated to use the non-deprecated diagnostic functions
vim.keymap.set("n", "[d", function()
  vim.diagnostic.goto_prev()
end, opts)
vim.keymap.set("n", "]d", function()
  vim.diagnostic.goto_next()
end, opts)

local signs_handler = {
  text = {
    [vim.diagnostic.severity.ERROR] = "",
    [vim.diagnostic.severity.WARN] = "",
    [vim.diagnostic.severity.INFO] = "",
    [vim.diagnostic.severity.HINT] = "󰌶",
  },
  severity = {
    vim.diagnostic.severity.ERROR,
    vim.diagnostic.severity.WARN,
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.HINT,
  },
}

local virtual_text_handler = {
  spacing = 4,
  prefix = function(diagnostic)
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      return ""
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      return ""
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      return ""
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      return "󰌶"
    end
    return diagnostic.message
  end,
}

-- Disable virtual text for diagnostics, as gitsigns will handle it.
vim.diagnostic.config({
  underline = true,
  signs = signs_handler,
  update_in_insert = false,
  virtual_text = virtual_text_handler,
  virtual_lines = false,
  severity_sort = true,
  float = {
    border = "single",
    source = "always",
    focusable = true,
  },
})
