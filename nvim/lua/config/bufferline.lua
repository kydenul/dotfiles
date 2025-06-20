-- Bufferline: Tagbar-style buffer management plugin

local util = require("util")

local is_ok, bufferline = pcall(require, "bufferline")
if not is_ok then
	util.log_warn("Bufferline load failed")
	return
end

local hide = {
	qf = true,
	help = false,
	terminal = false,
}

bufferline.setup({
	options = {
		-- Basic settings
		mode = "buffers", -- 显示模式：缓冲区
		numbers = "ordinal",
		close_command = "bdelete! %d", -- 关闭命令
		right_mouse_command = "bdelete! %d", -- 右键关闭
		left_mouse_command = "buffer %d", -- 左键切换
		middle_mouse_command = nil, -- 中键命令

		-- Appearance settings
		color_icons = true, -- 彩色图标
		show_buffer_icons = true, -- 显示缓冲区图标
		show_buffer_close_icons = true, -- 显示关闭图标
		show_close_icon = true, -- 显示关闭图标
		show_tab_indicators = true, -- 显示标签指示器
		separator_style = "thin", -- 分隔符样式：thin/slant/thick/padded_slant
		always_show_bufferline = true, -- 总是显示 bufferline

		-- 偏移设置（为侧边栏留出空间）
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				highlight = "Directory",
				text_align = "left",
				padding = 1,
			},
			{
				filetype = "aerial",
				text = "Outline",
				highlight = "Directory",
				text_align = "left",
				padding = 0,
			},
		},

		-- 自定义过滤器（隐藏特定类型的缓冲区）
		custom_filter = function(bufnr)
			return not hide[vim.bo[bufnr].filetype]
		end,

		-- 排序规则
		sort_by = "last", -- insert it to the end of the list
	},

	-- 高亮组设置
	highlights = {
		buffer_selected = {
			bold = true,
			italic = false,
		},
		tab_selected = {
			bold = true,
			italic = false,
		},
	},
})

-- 添加自动命令组
local augroup = vim.api.nvim_create_augroup("BufferlineConfig", { clear = true })

-- 在特定文件类型中隐藏 bufferline
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "alpha", "dashboard" },
	callback = function()
		vim.opt.showtabline = 0
	end,
	desc = "在启动页面隐藏 bufferline",
})

-- 离开启动页面时显示 bufferline
vim.api.nvim_create_autocmd("BufWinLeave", {
	group = augroup,
	pattern = { "*alpha*", "*dashboard*" },
	callback = function()
		vim.opt.showtabline = 2
	end,
	desc = "离开启动页面时显示 bufferline",
})
