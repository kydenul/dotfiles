return {
  "folke/sidekick.nvim",
  opts = {
    -- add any options here
    cli = {
      mux = { enabled = true, backend = "tmux" },

      tools = {
        ["CodeBuddy-Code"] = {
          -- cmd = { "codebuddy-code", "--flag" },
          cmd = { "codebuddy-code" },
        },
      },
    },

    nes = { enabled = false },
  },

  keys = {
    -- {
    --   "<tab>",
    --   function()
    --     -- if there is a next edit, jump to it, otherwise apply it if any
    --     if not require("sidekick").nes_jump_or_apply() then
    --       return "<Tab>" -- fallback to normal tab
    --     end
    --   end,
    --   expr = true,
    --   desc = "Goto/Apply Next Edit Suggestion",
    -- },
    -- stylua: ignore
    { "<leader>kk", function() require("sidekick.cli").toggle() end, mode = { "n", "t", "x" }, desc = "[Sidekick] Toggle CLI" },
    -- stylua: ignore
    { "<leader>ks", function() require("sidekick.cli").select({ filter = { installed = true } }) end, desc = "[Sidekick] Select CLI" },
    -- stylua: ignore
    { "<leader>kd", function() require("sidekick.cli").close() end, desc = "[Sidekick] Detach a CLI Session" },
    -- stylua: ignore
    { "<leader>kt", function() require("sidekick.cli").send({ msg = "{this}" }) end, desc = "[Sidekick] Send This" },
    -- stylua: ignore
    { "<leader>kf", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "[Sidekick] Send File" },
    -- stylua: ignore
    { "<leader>kv", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = { "x" }, desc = "[Sidekick] Send Visual Selection" },
    -- stylua: ignore
    { "<leader>kp", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "[Sidekick] Sidekick Select Prompt" },
    -- open Gemini CLI directly
    -- stylua: ignore
    { "<leader>kg", function() require("sidekick.cli").toggle({ name = "gemini", focus = true }) end, desc = "[Sidekick] Toggle Gemini" },
    -- stylua: ignore
    { "<leader>kc", function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end, desc = "[Sidekick] Toggle Claude" },

    -- stylua: ignore
    { "<leader>kn", function() require("sidekick.cli").toggle({ name = "CodeBuddy-Code", focus = true }) end, desc = "[Sidekick] Toggle CodeBuddy-Code" },
  },
}
