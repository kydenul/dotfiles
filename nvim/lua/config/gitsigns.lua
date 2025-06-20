-- Gitsigns: Git integration and status display plugin

local util = require("util")

local ok, gs = pcall(require, "gitsigns")
if not ok then
	util.log_warn("gitsigns load failed, please check your config")
	return
end

-- Set highlight groups
vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#4CAF50" })
vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#2196F3" })
vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#F44336" })
vim.api.nvim_set_hl(0, "GitSignsTopdelete", { link = "GitSignsDelete" })
vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "GitSignsChange" })
vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = "#9C27B0" })

gs.setup({
	signs = {
		add = { text = "┃" }, -- 添加行
		change = { text = "┃" }, -- 修改行
		delete = { text = "_" }, -- 删除行
		topdelete = { text = "‾" }, -- 删除行（顶部）
		changedelete = { text = "~" }, -- 修改并删除
		untracked = { text = "┆" }, -- 未跟踪文件
	},

	-- Current line blame
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol",
		delay = 300,
		ignore_whitespace = true,
	},
	current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",

	watch_gitdir = {
		interval = 600, -- 检查 Git 目录变化的间隔（毫秒）
		follow_files = true, -- 跟踪文件重命名
	},
	attach_to_untracked = true, -- 附加到未跟踪文件
	update_debounce = 100, -- 更新防抖时间（毫秒）

	-- 状态栏集成
	status_formatter = nil, -- 使用默认格式化器

	-- 当插件附加到缓冲区时设置快捷键
	on_attach = function(bufnr)
		local function map(mode, lhs, rhs, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- Navigation between hunks
		map("n", "]c", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "Next git hunk" })

		map("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "Previous git hunk" })

		map("n", "ghp", gs.preview_hunk, { desc = "Preview hunk" })
		map("n", "ghi", gs.preview_hunk_inline, { desc = "Preview hunk inline" })
		map("n", "ghb", function()
			gs.blame_line({ full = true })
		end, { desc = "Blame line" })
		map("n", "ghd", gs.diffthis, { desc = "Diff this" })
		map("n", "ghD", function()
			gs.diffthis("~")
		end, { desc = "Diff this ~" })
		map("n", "ghr", gs.reset_hunk, { desc = "Reset hunk" })
	end,
})
