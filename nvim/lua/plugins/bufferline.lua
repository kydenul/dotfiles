-- Bufferline: Tagbar-style buffer management plugin

return {
  "akinsho/bufferline.nvim",
  event = { "BufReadPost" },
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons", "famiu/bufdelete.nvim" },

  opts = {
    -- 高亮组设置
    highlights = {
      buffer_selected = { bold = true, italic = true },
      tab_selected = { bold = true, italic = true },
    },

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
      show_buffer_close_icons = false, -- 显示关闭图标
      show_close_icon = true, -- 显示关闭图标
      show_tab_indicators = true, -- 显示标签指示器
      separator_style = "thin", -- 分隔符样式：thin/slant/thick/padded_slant
      always_show_bufferline = true, -- 总是显示 bufferline

      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        -- local icon = level:match("error") and "" or ""
        -- return " " .. icon .. count

        local icon = level:match("error") and "" or ""
        return icon
      end,

      -- 偏移设置（为侧边栏留出空间）
      offsets = {
        { filetype = "NvimTree", text = "File Explorer", highlight = "Directory", text_align = "left", padding = 1 },
        { filetype = "aerial", text = "Outline", highlight = "Directory", text_align = "left", padding = 0 },
      },

      -- 自定义过滤器（隐藏特定类型的缓冲区）
      custom_filter = function(bufnr)
        local hide = { qf = true, help = false, terminal = false }
        return not hide[vim.bo[bufnr].filetype]
      end,

      -- 排序规则
      sort_by = "insert_at_end", -- insert it to the end of the list
    },
  },

  config = function(_, opts)
    local util = require("custom.util")
    local bufferline = require("bufferline")
    bufferline.setup(opts)

    -- Buffer line
    -- 1. 使用 <leader> + 数字 => 直接跳转到对应缓冲区
    for i = 1, 9 do
      vim.keymap.set("n", "<leader>" .. i, function()
        bufferline.go_to(i, true)
      end, { desc = "Go to buffer " .. i })
    end

    -- 2. 使用 gt/gT 在缓冲区之间切换
    vim.keymap.set({ "v", "n" }, "gt", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
    vim.keymap.set({ "v", "n" }, "gT", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

    -- 3. 关闭当前缓冲区并切换到上一个
    local buffer_close = function()
      if vim.bo.modified then
        util.log_err("No write sine last change.")
        return
      end
      local buf = vim.fn.bufnr()
      bufferline.cycle(-1)
      vim.cmd.bdelete(buf)
    end
    vim.keymap.set({ "v", "n" }, "ZZ", buffer_close, { desc = "Close current buffer" })
    vim.keymap.set({ "v", "n" }, "<leader>q", buffer_close, { desc = "Close current buffer" })

    -- 4. 添加更多实用的快捷键
    vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "选择关闭缓冲区" })
    --stylua: ignore
    vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseLeft<CR><cmd>BufferLineCloseRight<CR>", { desc = "关闭其他缓冲区" })
    vim.keymap.set("n", "<leader>br", "<cmd>BufferLineCloseRight<CR>", { desc = "关闭右侧缓冲区" })
    vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", { desc = "关闭左侧缓冲区" })

    vim.keymap.set("n", "<leader>bs", "<cmd>BufferLineSortByDirectory<CR>", { desc = "按目录排序" })
    vim.keymap.set("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "选择缓冲区" })

    vim.keymap.set("n", "<leader>bmm", "<cmd>BufferLineMovePrev<CR>", { desc = "向左移动缓冲区" })
    vim.keymap.set("n", "<leader>bmn", "<cmd>BufferLineMoveNext<CR>", { desc = "向右移动缓冲区" })

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
  end,
}
