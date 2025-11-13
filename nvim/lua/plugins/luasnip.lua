return {
  "L3MON4D3/LuaSnip",

  version = "v2.*",
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },

  config = function()
    -- Load friendly snippets
    require("luasnip.loaders.from_vscode").lazy_load({
      include = { "c", "cpp", "go", "python", "sh", "json", "lua", "gitcommit", "sql", "markdown" },
    })

    -- Load custom snippets
    require("snippets")

    -- Configure LuaSnip
    local luasnip = require("luasnip")
    luasnip.config.setup({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
      ext_opts = {
        [require("luasnip.util.types").choiceNode] = {
          active = {
            virt_text = { { "●", "Orange" } },
          },
        },
      },
    })
  end,
}
