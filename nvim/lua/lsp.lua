-- Note: The order matters: require("mason") -> require("mason-lspconfig") -> require("lspconfig")

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
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
local lspconfig = require("lspconfig")
local lsputil = require("lspconfig.util")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer.
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  if client.name == "rust_analyzer" then
    -- WARNING: This feature requires Neovim 0.10 or later.
    vim.lsp.inlay_hint.enable()
  end

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  -- K: show diagnostics if available, otherwise show hover information
  vim.keymap.set("n", "K", function()
    local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    if next(line_diagnostics) then
      vim.diagnostic.open_float()
    else
      vim.lsp.buf.hover()
    end
  end, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)

  -- Highlighting when the cursor is on a symbol
  vim.api.nvim_create_autocmd(
    { "CursorHold", "CursorHoldI" },
    { callback = vim.lsp.buf.document_highlight, buffer = bufnr }
  )
  vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI" },
    { callback = vim.lsp.buf.clear_references, buffer = bufnr }
  )
  -- Configure signature help to show without focusing
  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
    callback = function()
      -- Show signature help without focusing the floating window
      local params = vim.lsp.util.make_position_params(0, "utf-8")
      vim.lsp.buf_request(bufnr, "textDocument/signatureHelp", params, function(err, result, ctx, config)
        if result and result.signatures and #result.signatures > 0 then
          -- Use vim.lsp.handlers directly instead of deprecated vim.lsp.with
          local old_handler = vim.lsp.handlers["textDocument/signatureHelp"]
          vim.lsp.handlers["textDocument/signatureHelp"] = function(_, result, ctx, config)
            config = config or {}
            config.focus = false -- This prevents focus from moving to the signature window
            config.border = "rounded"
            return old_handler(_, result, ctx, config)
          end
          -- Call the handler directly with the results
          vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, {})
        end
      end)
    end,
    buffer = bufnr,
  })

  -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  -- vim.keymap.set("n", "<space>wl", function()
  -- 	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, bufopts)
  vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  -- vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)

  -- Format
  vim.api.nvim_buf_create_user_command(bufnr, "Fmt", function(opts)
    local range
    if opts.range == 2 then
      range = { ["start"] = { opts.line1, 0 }, ["end"] = { opts.line2, 0 } }
    end
    vim.lsp.buf.format({
      async = true,
      range = range,
      -- Predicate used to filter clients. Receives a client as
      -- argument and must return a boolean. Clients matching the
      -- predicate are included.
      filter = function(_client)
        -- NOTE: If an LSP contains a formatter, we don't need to use null-ls at all.
        return _client.name == "null-ls" or _client.name == "hls"
      end,
    })
  end, { range = true })
  vim.keymap.set("n", "<space>=", ":Fmt<CR>", bufopts)
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
  root_dir = lsputil.root_pattern("go.work", "go.mod", ".git"),
})
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim).
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global.
        globals = { "vim" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files.
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier.
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
vim.keymap.set("n", "<leader>k", function()
  vim.diagnostic.open_float()
end, opts)
vim.keymap.set("n", "[d", function()
  vim.diagnostic.goto_prev()
end, opts)
vim.keymap.set("n", "]d", function()
  vim.diagnostic.goto_next()
end, opts)
vim.keymap.set("n", "<space>q", function()
  vim.diagnostic.setloclist()
end, opts)
