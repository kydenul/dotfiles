-- Note: The order matters: require("mason") -> require("mason-lspconfig") -> require("lspconfig")

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
  },
})

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason")
if not mason_lspconfig_ok then
  util.log_warn("mason lspconfig load failed")
  return
end

mason_lspconfig.setup({
  -- A list of servers to automatically install if they're not already installed.
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
  end, bufopts("Toggle Inlay Hints"))

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts("Go to Declaration"))
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts("Go to Definition"))
  vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", bufopts("Go to References"))
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts("Go to Implementation"))

  -- K: show diagnostics if available, otherwise show hover information
  vim.keymap.set("n", "K", function()
    local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    if next(line_diagnostics) then
      vim.diagnostic.open_float()
    else
      vim.lsp.buf.hover()
    end
  end, bufopts("Hover"))
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts("Signature Help"))

  -- Highlighting when the cursor is on a symbol
  vim.api.nvim_create_autocmd(
    { "CursorHold", "CursorHoldI" },
    { callback = vim.lsp.buf.document_highlight, buffer = bufnr, desc = "Document Highlight" }
  )
  vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI" },
    { callback = vim.lsp.buf.clear_references, buffer = bufnr, desc = "Clear References" }
  )

  -- -- Configure signature help to show without focusing
  -- vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
  --   callback = function()
  --     -- Show signature help without focusing the floating window
  --     local params = vim.lsp.util.make_position_params(0, "utf-8")

  --     vim.lsp.buf_request(bufnr, "textDocument/signatureHelp", params, function(err, result, ctx, config)
  --       if result and result.signatures and #result.signatures > 0 then
  --         -- Use vim.lsp.handlers directly instead of deprecated vim.lsp.with
  --         local old_handler = vim.lsp.handlers["textDocument/signatureHelp"]
  --         vim.lsp.handlers["textDocument/signatureHelp"] = function(_, result, ctx, config)
  --           config = config or {}
  --           config.focus = false -- This prevents focus from moving to the signature window
  --           config.border = "rounded"
  --           return old_handler(_, result, ctx, config)
  --         end
  --         -- Call the handler directly with the results
  --         vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, {})
  --       end
  --     end)
  --   end,
  --   buffer = bufnr,
  -- })

  -- vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  -- vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts("Code Action"))

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
  vim.keymap.set("n", "<space>=", ":Fmt<CR>", { noremap = true, silent = true, buffer = bufnr, desc = "Format code" })
end

-- How to add an LSP for a specific programming language?
-- 1. Use `:Mason` to install the corresponding LSP.
-- 2. Add the configuration below. The syntax is `lspconfig.<name>.setup(...)`
-- Hint (find <name> here) : https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
lspconfig.bashls.setup({})
lspconfig.pylsp.setup({ on_attach = on_attach })
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
lspconfig.clangd.setup({
  on_attach = on_attach,
})

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
vim.keymap.set("n", "<space>q", function()
  vim.diagnostic.setloclist()
end, opts)

-- Disable virtual text for diagnostics, as gitsigns will handle it.
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
