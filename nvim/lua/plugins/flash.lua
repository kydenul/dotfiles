-- Flash: Quickly jump to a location in the buffer

return {
  "folke/flash.nvim",
  event = "VeryLazy",

  opts = {
    label = {
      rainbow = { enabled = true, shade = 1 },
    },

    modes = { char = { enabled = false } },
  },

  keys = {
    -- stylua: ignore
    { ",", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "[Flash] Jump" },
  },
}
