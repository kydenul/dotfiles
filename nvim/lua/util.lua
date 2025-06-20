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

