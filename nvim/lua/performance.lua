-- Performance monitoring and optimization utilities

local M = {}

-- Startup time measurement
function M.measure_startup_time()
  local start_time = vim.fn.reltime()

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local end_time = vim.fn.reltime(start_time)
      local startup_time = vim.fn.reltimestr(end_time)
      vim.notify(string.format("Neovim started in %s seconds", startup_time), vim.log.levels.INFO)
    end,
  })
end

-- Plugin loading time profiler
function M.profile_plugins()
  vim.cmd("Lazy profile")
end

-- Memory usage checker
function M.check_memory()
  local memory_kb = vim.fn.system("ps -o rss= -p " .. vim.fn.getpid()):gsub("%s+", "")
  local memory_mb = math.floor(tonumber(memory_kb) / 1024)
  vim.notify(string.format("Neovim memory usage: %d MB", memory_mb), vim.log.levels.INFO)
end

-- LSP performance checker
function M.check_lsp_performance()
  local clients = vim.lsp.get_active_clients()
  if #clients == 0 then
    vim.notify("No active LSP clients", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    vim.notify(string.format("LSP: %s (ID: %d)", client.name, client.id), vim.log.levels.INFO)
  end
end

-- Create user commands for performance monitoring
vim.api.nvim_create_user_command("StartupTime", M.measure_startup_time, { desc = "Measure startup time" })
vim.api.nvim_create_user_command("ProfilePlugins", M.profile_plugins, { desc = "Profile plugin loading" })
vim.api.nvim_create_user_command("CheckMemory", M.check_memory, { desc = "Check memory usage" })
vim.api.nvim_create_user_command("CheckLSP", M.check_lsp_performance, { desc = "Check LSP performance" })

-- Auto-measure startup time
M.measure_startup_time()

return M

