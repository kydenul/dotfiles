-- Mason and LSP Configuration

return {
  -- NOTE: mason
  "williamboman/mason.nvim",
  lazy = false,
  priority = 100,
  dependencies = {
    "neovim/nvim-lspconfig",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    -- ==============================================================
    -- LSP Kind Icons
    -- ==============================================================
    {
      "onsails/lspkind.nvim",
      event = { "VimEnter" },
    },

    -- ==============================================================
    -- ==============================================================
    -- Commentary
    -- gcc / gc / gcu
    -- ==============================================================
    -- ==============================================================
    "tpope/vim-commentary",

    -- ==============================================================
    -- ==============================================================
    -- Todo comments
    -- ==============================================================
    -- ==============================================================
    {
      "folke/todo-comments.nvim",
      event = { "BufReadPost", "BufNewFile" },
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
    },

    -- LSP Rename
    { "smjonas/inc-rename.nvim", opts = {} },

    -- Mason-LSPConfig
    "williamboman/mason-lspconfig.nvim",
  },

  opts = {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
      border = "rounded",
    },
    max_concurrent_installers = 4,
  },

  config = function(_, opts)
    require("mason").setup(opts)
    require("mason-lspconfig").setup({
      automatic_installation = true,
      ensure_installed = {
        "bashls", -- Bash
        "clangd", -- C/C++
        "gopls", -- Go
        "lua_ls", -- lua_ls
        "pylsp", -- Python
        "ts_ls", -- Typescript
        "intelephense", -- PHP
        "marksman", -- Markdown
        "cmake", -- CMake
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
    vim.lsp.enable("marksman")
    vim.lsp.enable("cmake")

    -- 禁用不需要的 providers
    vim.g.loaded_node_provider = 0
    vim.g.loaded_perl_provider = 0
    vim.g.loaded_python3_provider = 0
    vim.g.loaded_ruby_provider = 0

    -- NOTE: Remove Global Default Key mapping
    vim.keymap.del("n", "grn")
    vim.keymap.del("n", "gra")
    vim.keymap.del("n", "grr")
    vim.keymap.del("n", "gri")
    vim.keymap.del("n", "grt")

    -- NOTE: Highlight symbol under cursor
    -- stylua: ignore
    vim.api.nvim_set_hl(0, "LspReferenceText", { fg = "#E0E0FF", bg = "#A04945" })
    vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "LspReferenceText" })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "LspReferenceText" })
    vim.api.nvim_set_hl(0, "LspDocumentHighlight", { link = "LspReferenceText" })

    -- ============================================================================
    -- LSP Attach Autocmd
    -- ============================================================================
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),

      callback = function(event)
        local scopebi = require("telescope.builtin")
        local bufopts = function(desc)
          return { noremap = true, silent = true, buffer = event.buf, desc = desc }
        end

        -- notification wrapper of original gd
        vim.keymap.set("n", "gd", function()
          local clients = vim.lsp.get_clients({ bufnr = event.buf })
          local offset_encoding = clients[1] and clients[1].offset_encoding or "utf-16"
          local params = vim.lsp.util.make_position_params(0, offset_encoding)
          vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
            if not result or vim.tbl_isempty(result) then
              vim.notify("No definition found", vim.log.levels.INFO)
            else
              require("telescope.builtin").lsp_definitions()
            end
          end)
        end, bufopts("LSP: Goto Definition"))

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
        end, bufopts("LSP: Goto Definition (split)"))

        -- 添加更多telescope LSP相关的keymap
        -- stylua: ignore
        vim.keymap.set("n", "gr", scopebi.lsp_references, bufopts("LSP: Goto References"))
        -- stylua: ignore
        vim.keymap.set("n", "gi", scopebi.lsp_implementations, bufopts("LSP: Goto Implementation"))

        -- ------------------------------------------------------------------------
        -- Documentation and Diagnostics
        -- ------------------------------------------------------------------------
        vim.keymap.set("n", "gK", vim.lsp.buf.hover, bufopts("LSP: Hover"))

        -- Smart K: show diagnostics if available, otherwise hover
        vim.keymap.set("n", "K", function()
          local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
          if next(line_diagnostics) then
            vim.diagnostic.open_float()
          else
            vim.lsp.buf.hover()
          end
        end, bufopts("LSP: Diagnostic or Hover"))

        -- ------------------------------------------------------------------------
        -- Code Actions and Formatting
        -- ------------------------------------------------------------------------
        vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, bufopts("LSP: Code Action"))

        -- ------------------------------------------------------------------------
        -- Toggle Features
        -- ------------------------------------------------------------------------

        -- toggle diagnostics
        vim.keymap.set(
          "n",
          "<leader>td",
          (function()
            local diag_status = 1 -- 1 is show; 0 is hide
            return function()
              if diag_status == 1 then
                diag_status = 0
                vim.diagnostic.config({
                  underline = false,
                  virtual_text = false,
                  signs = false,
                  update_in_insert = false,
                })
              else
                diag_status = 1
                vim.diagnostic.config({
                  underline = true,
                  virtual_text = true,
                  signs = true,
                  update_in_insert = true,
                })
              end
            end
          end)(),
          bufopts("LSP: Toggle diagnostics display")
        )

        -- folding
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method("textDocument/foldingRange") then
          local win = vim.api.nvim_get_current_win()
          vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        end

        -- Inlay hint
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          vim.keymap.set("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, { buffer = event.buf, desc = "LSP: Toggle Inlay Hints" })
        end

        -- Highlight words under cursor
        if
          client
          and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
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
            end,
          })
        end
      end,
    })

    -- NOTE: LspInfo, LspLog, LspRestart
    vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to `:checkhealth vim.lsp`" })
    vim.api.nvim_create_user_command("LspLog", function()
      vim.cmd(string.format("tabnew %s", vim.lsp.get_log_path()))
    end, { desc = "Opens the Nvim LSP client log" })

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

    vim.api.nvim_create_user_command("LspRestart", function(info)
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
    -- stylua: ignore
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, { noremap = true, silent = true })
    -- stylua: ignore
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, { noremap = true, silent = true })

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
  end,
}
