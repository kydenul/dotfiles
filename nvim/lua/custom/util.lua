local util = {}

function util.log_info(fmt, ...)
  vim.notify(fmt:format(...), vim.log.levels.INFO)
end

function util.log_warn(fmt, ...)
  vim.notify(fmt:format(...), vim.log.levels.WARN)
end

function util.log_err(fmt, ...)
  vim.notify(fmt:format(...), vim.log.levels.ERROR)
end

-- Safe require function with error handling
function util.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    util.log_err("Failed to load module: %s", module)
    return nil
  end
  return result
end

-- Check if a command exists
function util.command_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Get project root directory
function util.get_project_root()
  local root_patterns = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" }
  local current_dir = vim.fn.expand("%:p:h")

  for _, pattern in ipairs(root_patterns) do
    local root = vim.fn.finddir(pattern, current_dir .. ";")
    if root ~= "" then
      return vim.fn.fnamemodify(root, ":h")
    end

    local file = vim.fn.findfile(pattern, current_dir .. ";")
    if file ~= "" then
      return vim.fn.fnamemodify(file, ":h")
    end
  end

  return current_dir
end

return util
