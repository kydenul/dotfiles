return {
  "folke/sidekick.nvim",
  opts = {
    -- add any options here
    cli = {
      mux = { enabled = true, backend = "tmux" },

      tools = {
        ["Claude-Internal"] = { cmd = { "claude-internal" } },
      },
    },

    nes = { enabled = false },
  },

  keys = {
    -- stylua: ignore
    { "<leader>ck", function() require("sidekick.cli").toggle() end, mode = { "n", "t", "x" }, desc = "Sidekick: Toggle CLI" },
    -- stylua: ignore
    { "<leader>cs", function() require("sidekick.cli").select({ filter = { installed = true } }) end, desc = "Sidekick: Select CLI" },
    -- stylua: ignore
    { "<leader>cd", function() require("sidekick.cli").close() end, desc = "Sidekick: Detach a CLI Session" },
    -- stylua: ignore
    { "<leader>ct", function() require("sidekick.cli").send({ msg = "{this}" }) end, desc = "Sidekick: Send This" },
    -- stylua: ignore
    { "<leader>cf", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Sidekick: Send File" },
    -- stylua: ignore
    { "<leader>cv", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = { "x" }, desc = "Sidekick: Send Visual Selection" },
    -- stylua: ignore
    { "<leader>cp", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "Sidekick: Sidekick Select Prompt" },
    -- open Gemini CLI directly
    -- stylua: ignore
    { "<leader>cc", function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end, desc = "Sidekick: Toggle Claude" },
    -- stylua: ignore
    { "<leader>ci", function() require("sidekick.cli").toggle({ name = "Claude-Internal", focus = true }) end, desc = "Sidekick: Toggle Claude-Internal" },
  },
}
