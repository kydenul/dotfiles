return {
  "folke/sidekick.nvim",
  init = function()
    -- An unfocused terminal window only follows output while its cursor is on the
    -- last line, but leaving it parks the cursor at the TUI's input box. So on
    -- leave, snap to the last line if the view was at the bottom; a view scrolled
    -- up to read history keeps its position.
    vim.api.nvim_create_autocmd("WinLeave", {
      group = vim.api.nvim_create_augroup("sidekick_follow_output", { clear = true }),
      callback = function()
        if vim.bo.filetype ~= "sidekick_terminal" or vim.fn.line("w$") < vim.fn.line("$") then
          return
        end
        local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
        -- after the switch, otherwise the terminal-cursor sync may overwrite it
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) and win ~= vim.api.nvim_get_current_win() then
            vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
          end
        end)
      end,
    })
  end,
  opts = {
    nes = { enabled = false },

    -- add any options here
    cli = {
      win = { layout = "right", split = { width = 124 } },
      -- mux = { enabled = true, backend = "tmux", create = "terminal" }, -- "terminal"|"window"|"split"
      mux = { enabled = false },
      tools = { ["TClaude"] = { cmd = { "tclaude" } } },
      prompts = {
        -- refactor = "Please refactor {this} to be more maintainable",
        -- security = "Review {file} for security vulnerabilities",
        -- custom = function(ctx)
        --   return "Current file: " .. ctx.buf .. " at line " .. ctx.row
        -- end,
      },
    },
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

    -- open CLI directly
    -- stylua: ignore
    { "<leader>cc", function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end, desc = "Sidekick: Toggle Claude" },
    -- stylua: ignore
    { "<leader>ci", function() require("sidekick.cli").toggle({ name = "pi", focus = true }) end, desc = "Sidekick: Toggle Pi" },
  },
}
