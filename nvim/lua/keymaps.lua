local opts = {
  noremap = true, -- non-recursive
  silent = true, -- do not show message
}

vim.g.mapleader = " " -- Map leader key

----------------------------------
-- Insert mode --
----------------------------------
vim.keymap.set("i", "jk", "<ESC>")

----------------------------------
-- Normal mode --
----------------------------------
-- New windows
vim.keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
vim.keymap.set("n", "<leader>sh", "<C-w>s") -- 垂直新增窗口

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set("n", "<C-j>", ":resize -3<CR>", opts)
vim.keymap.set("n", "<C-k>", ":resize +3<CR>", opts)
vim.keymap.set("n", "<C-h>", ":vertical resize -3<CR>", opts)
vim.keymap.set("n", "<C-l>", ":vertical resize +3<CR>", opts)

-- leader + hjkl 在窗口之间跳转
vim.keymap.set("n", "<leader>h", "<C-w>h", opts) -- 向左跳转
vim.keymap.set("n", "<leader>j", "<C-w>j", opts) -- 向下跳转
vim.keymap.set("n", "<leader>k", "<C-w>k", opts) -- 向上跳转
vim.keymap.set("n", "<leader>l", "<C-w>l", opts) -- 向右跳转

-- 文件
vim.keymap.set("n", "<leader>w", ":w!<CR>", { desc = "Save" }) -- Save file

-- 取消高亮
vim.keymap.set("n", "<leader>nh", ":nohl<CR>")

-- 光标快速移动
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Move to start of line" }) -- 移动光标至行首
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "Move to end of line" }) -- 移动光标至行尾

----------------------------------
-- Visual mode --
----------------------------------
-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- 单行或多行移动
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Visual mode, 粘贴不要复制
vim.keymap.set("v", "p", '"_dP', opts)

-- IncRename
vim.keymap.set("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

-- Toggle nvim-tree
vim.keymap.set(
  { "n", "t" },
  "<leader>e",
  "<Cmd>NvimTreeFindFileToggle<CR>",
  { noremap = true, silent = true, nowait = true }
)

-- Neogit
vim.keymap.set("n", "<leader>g", "<Cmd>Neogit<CR>", { noremap = true, silent = true, desc = "Neogit" })
