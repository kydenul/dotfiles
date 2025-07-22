-- Snippet management utilities

local M = {}
local ls = require("luasnip")

-- Get all available snippets for current filetype
function M.list_snippets()
  local ft = vim.bo.filetype
  local snippets = ls.get_snippets(ft)

  if not snippets or #snippets == 0 then
    vim.notify("No snippets available for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local snippet_list = {}
  for _, snippet in ipairs(snippets) do
    table.insert(snippet_list, {
      trigger = snippet.trigger,
      description = snippet.dscr or "No description",
      name = snippet.name or snippet.trigger,
    })
  end

  -- Sort by trigger
  table.sort(snippet_list, function(a, b)
    return a.trigger < b.trigger
  end)

  -- Display in a floating window
  M.show_snippet_list(snippet_list, ft)
end

-- Show snippet list in a floating window
function M.show_snippet_list(snippets, filetype)
  local lines = { "Available snippets for " .. filetype .. ":", "" }

  for _, snippet in ipairs(snippets) do
    table.insert(lines, string.format("  %-15s - %s", snippet.trigger, snippet.description))
  end

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "help")

  -- Calculate window size
  local width = math.max(60, math.min(120, vim.o.columns - 20))
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Snippets ",
    title_pos = "center",
  })

  -- Set window options
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- Key mappings for the window
  local opts = { buffer = buf, silent = true }
  vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
end

-- Expand snippet by name
function M.expand_snippet(name)
  local ft = vim.bo.filetype
  local snippets = ls.get_snippets(ft)

  for _, snippet in ipairs(snippets) do
    if snippet.trigger == name or snippet.name == name then
      ls.snip_expand(snippet)
      return
    end
  end

  vim.notify("Snippet not found: " .. name, vim.log.levels.WARN)
end

-- Jump to next snippet node
function M.jump_next()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end

-- Jump to previous snippet node
function M.jump_prev()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end

-- Get snippet info
function M.snippet_info()
  local current = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
  if current then
    local snippet = current.parent.snippet
    vim.notify(string.format("Current snippet: %s", snippet.trigger), vim.log.levels.INFO)
  else
    vim.notify("No active snippet", vim.log.levels.WARN)
  end
end

-- Reload snippets
function M.reload_snippets()
  -- Clear existing snippets
  ls.cleanup()

  -- Reload snippet configuration
  package.loaded["config.snippets"] = nil
  require("config.snippets")

  vim.notify("Snippets reloaded!", vim.log.levels.INFO)
end

-- Create user commands
vim.api.nvim_create_user_command("SnippetList", M.list_snippets, { desc = "List available snippets" })
vim.api.nvim_create_user_command("SnippetReload", M.reload_snippets, { desc = "Reload snippets" })
vim.api.nvim_create_user_command("SnippetInfo", M.snippet_info, { desc = "Show current snippet info" })
vim.api.nvim_create_user_command("SnippetExpand", function(opts)
  M.expand_snippet(opts.args)
end, { nargs = 1, desc = "Expand snippet by name" })

-- Key mappings
vim.keymap.set("n", "<leader>sl", M.list_snippets, { desc = "List snippets" })
vim.keymap.set("n", "<leader>sr", M.reload_snippets, { desc = "Reload snippets" })
vim.keymap.set("i", "<C-n>", M.jump_next, { desc = "Jump to next snippet node" })
vim.keymap.set("i", "<C-p>", M.jump_prev, { desc = "Jump to previous snippet node" })
vim.keymap.set("s", "<C-n>", M.jump_next, { desc = "Jump to next snippet node" })
vim.keymap.set("s", "<C-p>", M.jump_prev, { desc = "Jump to previous snippet node" })

return M

