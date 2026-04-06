-- blink-cmp: Fast auto-completion engine (alternative to nvim-cmp)
-- Docs: https://cmp.saghen.dev

return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  version = "1.*",

  dependencies = {
    "onsails/lspkind.nvim",
    "rafamadriz/friendly-snippets",
    { "L3MON4D3/LuaSnip", version = "v2.*" },

    -- Codeium
    {
      "Exafunction/windsurf.vim",
      config = function()
        vim.g.codeium_no_map_tab = 1

        --stylua: ignore start
        vim.keymap.set("i", "<C-CR>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
        vim.keymap.set("i", "<M-CR>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
        vim.keymap.set("i", "<C-;>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true, silent = true })
        vim.keymap.set("i", "<C-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true, silent = true })
        vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true, silent = true })
        -- stylua: ignore end
      end,
    },
  },

  opts = {
    -- Snippet engine configuration
    snippets = { preset = "luasnip" },

    -- Keymap configuration
    keymap = {
      preset = "none",

      -- Use <C-b/f> to scroll the docs
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },

      -- Use <C-k/j> to switch in items
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },

      -- Use <CR>(Enter) to confirm selection
      ["<CR>"] = { "accept", "fallback" },

      -- Super tab behavior
      ["<Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_next()
          elseif require("luasnip").locally_jumpable(1) then
            require("luasnip").jump(1)
            return true
          end
        end,
        "fallback",
      },

      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          elseif require("luasnip").jumpable(-1) then
            require("luasnip").jump(-1)
            return true
          end
        end,
        "fallback",
      },

      -- Cancel completion
      ["<C-e>"] = { "cancel", "fallback" },

      -- Manually trigger completion
      ["<C-Space>"] = { "show", "fallback" },
    },

    -- Appearance configuration
    appearance = { nerd_font_variant = "mono" },

    -- Completion settings
    completion = {
      -- Auto-select first item
      list = { selection = { preselect = true, auto_insert = false } },

      -- Menu configuration
      menu = {
        auto_show = true,
        border = "rounded",
        draw = {
          -- Use treesitter highlighting for LSP items
          treesitter = { "lsp" },

          -- Columns layout
          columns = {
            -- { "kind_icon", "kind", gap = 1 },
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
            -- { "source_name" },
          },
        },
      },

      -- Documentation window
      documentation = {
        auto_show = true,
        window = { border = "rounded" },
      },

      -- Ghost text preview
      ghost_text = { enabled = false },
    },

    -- Signature help
    signature = { enabled = true, window = { border = "rounded" } },

    -- Sources configuration
    sources = {
      default = { "lsp", "snippets", "path", "buffer" },

      -- Provider-specific settings
      providers = {
        lsp = { score_offset = 100 },
        snippets = { score_offset = 90 },
        path = { score_offset = 80 },
        buffer = { score_offset = 70 },
      },
    },

    -- Cmdline completion configuration
    cmdline = {
      enabled = true,
      keymap = { preset = "inherit" },
      completion = { menu = { auto_show = true } },
      sources = function()
        local type = vim.fn.getcmdtype()

        -- Search commands
        if type == "/" or type == "?" then
          return { "buffer" }
        end

        -- Commands
        if type == ":" then
          return { "cmdline", "path" }
        end

        return {}
      end,
    },

    -- Fuzzy matching configuration
    fuzzy = { implementation = "prefer_rust_with_warning", sorts = { "exact", "score", "sort_text" } },
  },

  config = function(_, opts)
    -- Set kind_icons: prefer lspkind if available, fallback to custom icons
    local has_lspkind, lspkind = pcall(require, "lspkind")
    if has_lspkind and lspkind.symbol_map then
      -- Use lspkind's preset icons
      local icons = vim.deepcopy(lspkind.symbol_map)

      -- Add custom icons for AI completions
      icons.Copilot = ""
      icons.Windsurf = ""
      icons.Codeium = ""

      opts.appearance.kind_icons = icons
    end

    require("blink.cmp").setup(opts)

    -- Set highlight groups for blink-cmp (matching nvim-cmp colors)
    vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { bg = "NONE", fg = "#7E8294", strikethrough = true })
    vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { bg = "NONE", fg = "#C586C0", bold = true })

    -- Kind-specific highlights
    -- light blue
    vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { bg = "NONE", fg = "#9CDCFE" })
    vim.api.nvim_set_hl(0, "BlinkCmpKindInterface", { link = "BlinkCmpKindVariable" })
    vim.api.nvim_set_hl(0, "BlinkCmpKindText", { link = "BlinkCmpKindVariable" })
    -- pink
    vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { bg = "NONE", fg = "#20C997" })
    vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { link = "BlinkCmpKindFunction" })
    -- front
    vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
    vim.api.nvim_set_hl(0, "BlinkCmpKindProperty", { link = "BlinkCmpKindKeyword" })
    vim.api.nvim_set_hl(0, "BlinkCmpKindUnit", { link = "BlinkCmpKindKeyword" })
  end,
}
