local opts = {
  noremap = true, -- non-recursive
  silent = true, -- do not show message
}

-- Map leader key
vim.g.mapleader = " "

----------------------------------
-- Insert mode --
----------------------------------
vim.keymap.set("i", "jk", "<ESC>")

----------------------------------
-- Normal mode --
----------------------------------
-- New windows
vim.keymap.set("n", "\\", "<CMD>:sp<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "|", "<CMD>:vsp<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wd", "<CMD>:close<CR>", { desc = "Close window" })

-- Resize with arrows
vim.keymap.set("n", "<leader>h", ":vertical resize +3<CR>", opts)
vim.keymap.set("n", "<leader>l", ":vertical resize -3<CR>", opts)
vim.keymap.set("n", "<leader>j", ":resize +3<CR>", opts)
vim.keymap.set("n", "<leader>k", ":resize -3<CR>", opts)

-- -- leader + hjkl 在窗口之间跳转
-- vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
-- vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
-- vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
-- vim.keymap.set("n", "<C-l>", "<C-w>l", opts)
-- NOTE: Use vim-tmux-navigator instead

-- Save file
vim.keymap.set("n", "<leader>w", ":w!<CR>", { noremap = true, silent = true, desc = "[File] Save" }) -- Save file
-- Quick save and quit
vim.keymap.set("n", "<leader>q", "<Cmd>q<CR>", { noremap = true, silent = true, desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<Cmd>qa<CR>", { noremap = true, silent = true, desc = "Quit all" })

-- Close current tab
vim.keymap.set("n", "<leader>tc", "<Cmd>tabclose<CR>", { noremap = true, silent = true, desc = "[Tab] Close current" })

-- Clear highlight
vim.keymap.set("n", "<leader>nh", ":nohl<CR>")

-- Hint: use 'H L' to move to beginning or end of line
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "[Cursor] Move to start of line" })
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "[Cursor] Move to end of line" })

----------------------------------
-- Visual mode --
----------------------------------
-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Up and down by visual line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Visual mode, 粘贴不要复制
vim.keymap.set("v", "p", '"_dP', opts)

-- IncRename
vim.keymap.set("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true, desc = "[IncRename] Rename" })

-- Toggle nvim-tree
-- stylua: ignore
vim.keymap.set({ "n", "t" }, "<leader>e", "<Cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, nowait = true, desc = "[NvimTree] Toggle" })
