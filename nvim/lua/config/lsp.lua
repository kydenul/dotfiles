-- LSP, qi dong!
-- vim.lsp.enable 'clangd'

local util = require("util")

local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  util.log_warn("mason load failed")
  return
end

-- NOTE: mason
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
    "typescript-language-server", -- Typescript
    "intelephense",
  },
})

-- NOTE: LSP Enable
vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
vim.lsp.enable("gopls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("pylsp")
vim.lsp.enable("ts_ls")
vim.lsp.enable("intelephense")

-- NOTE: Remove Global Default Key mapping
vim.keymap.del("n", "grn")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grt")

-- NOTE: Highlight symbol under cursor
vim.api.nvim_set_hl(
  0,
  "LspReferenceText",
  { fg = "#E0E0FF", bg = "#504945", bold = true, underline = true, italic = true }
)
vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "LspReferenceText" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "LspReferenceText" })
vim.api.nvim_set_hl(0, "LspDocumentHighlight", { link = "LspReferenceText" })

-- Define LSP-related keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),

  callback = function(event)
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = function(desc)
      return { noremap = true, silent = true, buffer = event.buf, desc = desc }
    end

    -- notification wrapper of original gd
    vim.keymap.set("n", "gd", function()
      local params = vim.lsp.util.make_position_params(0, "utf-8")
      vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
        if not result or vim.tbl_isempty(result) then
          vim.notify("No definition found", vim.log.levels.INFO)
        else
          require("telescope.builtin").lsp_definitions()
        end
      end)
    end, { buffer = event.buf, desc = "LSP: Goto Definition" })

    -- open gd in new split
    vim.keymap.set("n", "gD", function()
      local win = vim.api.nvim_get_current_win()
      local width = vim.api.nvim_win_get_width(win)
      local height = vim.api.nvim_win_get_height(win)

      -- Mimic tmux formula: 8 * width - 20 * height
      local value = 8 * width - 20 * height
      if value < 0 then
        vim.cmd("split") -- vertical space is more: horizontal split
      else
        vim.cmd("vsplit") -- horizontal space is more: vertical split
      end

      vim.lsp.buf.definition()
    end, { buffer = event.buf, desc = "LSP: Goto Definition (split)" })

    -- 添加更多telescope LSP相关的keymap
    vim.keymap.set(
      "n",
      "gr",
      require("telescope.builtin").lsp_references,
      { buffer = event.buf, desc = "LSP: Goto References" }
    )

    vim.keymap.set(
      "n",
      "gi",
      require("telescope.builtin").lsp_implementations,
      { buffer = event.buf, desc = "LSP: Goto Implementation" }
    )

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
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts("[LSP] Code Action"))

    -- Format
    vim.api.nvim_buf_create_user_command(event.buf, "Fmt", function(opts)
      local range
      if opts.range == 2 then
        -- The range is inclusive, so we need to go to the end of the line.
        -- -1 means the end of the line.
        range = { ["start"] = { opts.line1, 0 }, ["end"] = { opts.line2, -1 } }
      end

      vim.lsp.buf.format({ async = true, range = range })
    end, { range = true })

    -- The keymap remains the same
    vim.keymap.set("n", "<space>=", ":Fmt<CR>", bufopts("[LSP] Format code"))

    -- toggle diagnostics
    vim.keymap.set(
      "n",
      "<leader>td",
      (function()
        local diag_status = 1 -- 1 is show; 0 is hide
        return function()
          if diag_status == 1 then
            diag_status = 0
            vim.diagnostic.config({ underline = false, virtual_text = false, signs = false, update_in_insert = false })
          else
            diag_status = 1
            vim.diagnostic.config({ underline = true, virtual_text = true, signs = true, update_in_insert = true })
          end
        end
      end)(),
      { buffer = event.buf, desc = "LSP: Toggle diagnostics display" }
    )

    -- folding
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.supports_method("textDocument/foldingRange") then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end

    -- Inlay hint
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      -- vim.lsp.inlay_hint.enable()
      vim.keymap.set("n", "<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, { buffer = event.buf, desc = "LSP: Toggle Inlay Hints" })
    end

    -- Highlight words under cursor
    if
      client
      and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
      and vim.bo.filetype ~= "bigfile"
    then
      local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
          -- vim.cmd 'setl foldexpr <'
        end,
      })
    end

    -- require("Comment").setup()
  end,
})

-- NOTE: LspInfo, LspLog, LspRestart
local api, lsp = vim.api, vim.lsp
api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to `:checkhealth vim.lsp`" })
api.nvim_create_user_command("LspLog", function()
  vim.cmd(string.format("tabnew %s", lsp.get_log_path()))
end, {
  desc = "Opens the Nvim LSP client log.",
})

local complete_client = function(arg)
  return vim
    .iter(vim.lsp.get_clients())
    :map(function(client)
      return client.name
    end)
    :filter(function(name)
      return name:sub(1, #arg) == arg
    end)
    :totable()
end
api.nvim_create_user_command("LspRestart", function(info)
  for _, name in ipairs(info.fargs) do
    if vim.lsp.config[name] == nil then
      vim.notify(("Invalid server name '%s'"):format(info.args))
    else
      vim.lsp.enable(name, false)
    end
  end

  local timer = assert(vim.uv.new_timer())
  timer:start(500, 0, function()
    for _, name in ipairs(info.fargs) do
      vim.schedule_wrap(function(x)
        vim.lsp.enable(x)
      end)(name)
    end
  end)
end, {
  desc = "Restart the given client(s)",
  nargs = "+",
  complete = complete_client,
})

-- NOTE: Diagnostics
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
