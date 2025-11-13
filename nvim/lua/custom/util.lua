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

function util.live_grep_opts(opts)
  -- count 机制
  --  执行命令前可以先按一串数字，表示这个命令重复执行多少次
  local flags = tostring(vim.v.count)
  local additional_args = {}
  local prompt_title = "Live Grep"

  -- 按过 1 -> 开启正则表达式
  if flags:find("1") then
    prompt_title = prompt_title .. " [.*]"
  else
    table.insert(additional_args, "--fixed-strings")
  end

  -- 按过 2 -> 开启全词匹配
  if flags:find("2") then
    prompt_title = prompt_title .. " [w]"
    table.insert(additional_args, "--word-regexp")
  end

  -- 按过 3 -> 区分大小写
  if flags:find("3") then
    prompt_title = prompt_title .. " [Aa]"
    table.insert(additional_args, "--case-sensitive")
  end

  opts = opts or {}
  opts.additional_args = function()
    return additional_args
  end
  opts.prompt_title = prompt_title
  return opts
end

return util
