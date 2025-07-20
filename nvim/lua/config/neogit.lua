-- Neogit

local util = require("util")
local ok, neogit = pcall(require, "neogit")
if not ok then
  util.log_warn("neogit init failed.")
  return
end

neogit.setup({
  -- Disables signs for sections/items.
  disable_signs = false,
  -- Disables synchronizing the status buffer with the file system.
  disable_fs_sync = false,
  -- Disables the hint that shows at the top of the status buffer.
  disable_hint = false,
  -- Automatically show console if there are unmerged files.
  auto_show_console = true,
  -- Neogit refreshes its internal state after specific events
  -- and after running git commands. If you find this to be slow,
  -- you can disable it and refresh manually.
  disable_context_highlighting = false,
  -- Disables changing the buffer highlights based on where the cursor is.
  disable_commit_confirmation = false,
  -- Shows a list of integrations and their status.
  integrations = {
    -- Diffview is a required integration for neogit but it can be disabled
    diffview = true,
    -- Telescope integration
    telescope = true,
  },
  -- The depth of the logs to fetch when showing the graph.
  -- `0` will fetch all logs.
  log_graph_depth = 256,
  -- The kind of graph to use for the log.
  -- `dense` is the default, `sparse` is also available.
  log_graph_kind = "dense",
  -- The icons used for the signs.
  signs = {
    -- { CLOSED, OPENED }
    section = { "", "" },
    item = { "", "" },
    hunk = { "", "" },
  },
})
