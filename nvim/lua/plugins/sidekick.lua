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
        release_tag = "Update the changelog following the project's conventions, then create a release tag. Use the changelog-conventions skill for the changelog and the git-workflow-and-versioning skill for the version bump and tagging. Do not push the tag until I confirm.",
        commit = "Commit the current changes. Use the git-commit skill for the message format (gitmoji + conventional commits) and the git-workflow-and-versioning skill to keep commits atomic.",
        review = "Review the current uncommitted code changes (git diff, including staged). Use the code-review-and-quality skill and report findings by severity.",
        docs = "Check whether the current changes require documentation updates, and update the existing docs accordingly. Use the agents-md skill for AGENTS.md / CLAUDE.md and the changelog-conventions skill for the changelog. Do not create new Markdown files.",
        push_check = "Prepare to push the current branch. Review everything to be pushed (git log @{u}.. and git diff @{u}..) for unrelated changes, debug code and secrets, then give the deployment checklist (processes, database, Redis/cache, config, other dependencies, compatibility and rollback). Use the git-workflow-and-versioning and shipping-and-launch skills. Do not push until I confirm.",
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
