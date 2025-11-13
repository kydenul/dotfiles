-- nvim-cmp: Auto-completion engine

return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },

  dependencies = {
    "onsails/lspkind.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "xzbdmw/colorful-menu.nvim",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",

    -- Github Copilot
    -- "zbirenbaum/copilot-cmp", -- copilot 与 nvim-cmp 之间的桥梁
    -- {
    --   "zbirenbaum/copilot.lua",
    --   cmd = "Copilot",
    --   event = "InsertEnter",
    --   config = function()
    --     require("copilot").setup({
    --       -- 禁用 Copilot 的默认面板和建议 => 因为我们将使用 nvim-cmp 来展示建议
    --       panel = {
    --         enabled = false,
    --       },
    --       suggestion = {
    --         enabled = false,
    --       },
    --     })
    --   end,
    -- },

    -- Codeium
    {
      "Exafunction/windsurf.vim",
      config = function()
        vim.g.codeium_no_map_tab = 1
        vim.keymap.set("i", "<C-Enter>", function()
          return vim.fn["codeium#Accept"]()
        end, { expr = true, silent = true })
        vim.keymap.set("i", "<C-;>", function()
          return vim.fn["codeium#CycleCompletions"](1)
        end, { expr = true, silent = true })
        vim.keymap.set("i", "<C-,>", function()
          return vim.fn["codeium#CycleCompletions"](-1)
        end, { expr = true, silent = true })
        vim.keymap.set("i", "<C-x>", function()
          return vim.fn["codeium#Clear"]()
        end, { expr = true, silent = true })
      end,
    },
  },

  config = function()
    local luasnip = require("luasnip")
    local cmp = require("cmp")
    local lspkind = require("lspkind")
    local cmenu = require("colorful-menu")

    -- Helper function to check if there are words before cursor position
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local kind_icons = {
      Text = "",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰇽",
      Variable = "󰂡",
      Class = "",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "",
      Event = "",
      Operator = "",
      TypeParameter = "",

      Copilot = "",
      Windsurf = "",
    }

    cmp.setup({
      preselect = cmp.PreselectMode.None,
      view = { entries = { name = "custom", selection_order = "near_cursor" } }, -- Change the default selection order
      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
      },

      -- Add window configuration for better appearance
      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        }),

        documentation = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        }),
      },

      mapping = cmp.mapping.preset.insert({
        -- Use <C-b/f> to scroll the docs
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        -- Use <C-k/j> to switch in items
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),

        -- Use <CR>(Enter) to confirm selection, Accept the currently selected item.
        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if luasnip.expandable() then
              luasnip.expand()
            else
              cmp.confirm({
                select = true,
              })
            end
          else
            fallback()
          end
        end),

        -- A super tab
        -- Source: https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
        ["<Tab>"] = cmp.mapping(function(fallback)
          -- Hint: if the completion menu is visible select the next one
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.locally_jumpable(1) then
            luasnip.jump(1)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }), -- i - insert mode; s - select mode

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      -- Let's configure the item's appearance
      -- source: https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
      formatting = {
        fields = { "kind", "abbr", "menu" },

        format = function(entry, vim_item)
          local kind = lspkind.cmp_format({
            -- Show only symbol annotations "text_symbol" "symbol_text" 'symbol'
            mode = "symbol",

            -- Prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            maxwidth = {
              menu = 36, -- leading text (labelDetails)
              abbr = 128, -- actual suggestion item
            },

            -- When the popup menu exceeds maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            ellipsis_char = "...",
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default

            symbol_map = { Copilot = kind_icons.Copilot },
          })(entry, vim.deepcopy(vim_item))

          -- highlight_info is nil means we are missing the ts parser, it's
          -- better to fallback to use default `vim_item.abbr`. What this plugin
          -- offers is two fields: `vim_item.abbr_hl_group` and `vim_item.abbr`.
          local highlights_info = cmenu.cmp_highlights(entry)
          if highlights_info ~= nil then
            vim_item.abbr_hl_group = highlights_info.highlights
            vim_item.abbr = highlights_info.text
          end

          vim_item.kind = vim.split(kind.kind, "%s", { trimempty = true })[1] or ""
          vim_item.menu = ""

          return vim_item
        end,
      },

      -- Set source precedence with proper priority
      sources = cmp.config.sources({
        -- { name = "copilot" }, -- For Github Copilot
        { name = "nvim_lsp" }, -- For nvim-lsp
        { name = "luasnip", option = { use_show_condition = false } }, -- For luasnip user
      }, {
        { name = "buffer" }, -- For buffer word completion
        { name = "path" }, -- For path completion
      }),

      -- Add performance settings
      performance = {
        debounce = 60, -- Delay before triggering completion
        throttle = 30, -- Delay between completion requests
        fetching_timeout = 500, -- Timeout for fetching completions
        confirm_resolve_timeout = 80, -- Timeout for resolving completion items
        async_budget = 1, -- Maximum time per async operation
        max_view_entries = 24, -- Maximum number of completion items
      },
    })

    -- Set configuration for specific filetype.
    cmp.setup.filetype("gitcommit", {
      sources = cmp.config.sources({
        { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
      }, { { name = "buffer" } }),
    })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      -- Allow non-prefix matching in command mode
      matching = { disallow_symbol_nonprefix_matching = false },
    })

    -- Set up LSP capabilities for nvim-cmp
    -- This ensures LSP servers use nvim-cmp for autocompletion
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if has_cmp_lsp then
      capabilities = cmp_lsp.default_capabilities(capabilities)
      -- Make this available to lspconfig
      vim.g.cmp_capabilities = capabilities
    end

    -- Set highlight groups for nvim-cmp
    -- gray
    vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", fg = "#7E8294", strikethrough = true })
    -- blue
    vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6", bold = true })
    vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })

    -- light blue
    vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#9CDCFE" })
    vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
    vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
    -- pink
    vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
    vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
    -- front
    vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
    vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
    vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })
  end,
}
