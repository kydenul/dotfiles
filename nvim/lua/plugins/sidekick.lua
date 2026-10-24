-- External tmux sessions (session name != sid of the tool's cwd) can't get a window:
-- sidekick's tmux:attach() returns nil for them. Rename the tmux session to the sid it
-- expects, then attach normally so it opens as a regular terminal window.
local function attach(state)
  if not state then
    return
  end
  local State = require("sidekick.cli.state")
  local Session = require("sidekick.cli.session")
  local s = state.session
  if s and state.external and s.backend == "tmux" then
    local new = Session.sid({ tool = s.tool.name, cwd = s.cwd })
    local out = vim.fn.system({ "tmux", "rename-session", "-t", s.mux_session, new })
    if vim.v.shell_error ~= 0 then
      return vim.notify(("tmux rename-session failed (name taken?): %s"):format(out), vim.log.levels.ERROR)
    end
    Session.detach(s) -- drop the stale external instance so attach() re-evaluates it
    state = State.get({ session = s.id })[1]
    if not state then
      return
    end
  end
  State.attach(state, { show = true, focus = true })
end

return {
  "folke/sidekick.nvim",
  opts = {
    nes = { enabled = false },

    -- add any options here
    cli = {
      win = { layout = "right", split = { width = 120 } },
      mux = { enabled = true, backend = "tmux", create = "terminal" }, -- "terminal"|"window"|"split"
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
    { "<leader>cs", function() require("sidekick.cli").select({ filter = { installed = true }, cb = attach }) end, desc = "Sidekick: Select CLI" },
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
