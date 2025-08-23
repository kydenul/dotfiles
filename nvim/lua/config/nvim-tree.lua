local util = require("util")

-- Disable netrw at the very start
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local tree_ok, tree = pcall(require, "nvim-tree")
if not tree_ok then
  util.log_warn("nvim-tree init failed.")
  return
end

local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Use the default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- Custom mappings
  vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Up"))
  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
  vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
end

tree.setup({
  -- File/directory rendering
  renderer = {
    indent_markers = { enable = true },
    group_empty = true, -- Compact folders that only contain a single folder
    highlight_git = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },

  -- Behavior
  hijack_cursor = true,
  sync_root_with_cwd = true,
  respect_buf_cwd = false, -- Change cwd when opening a file
  on_attach = on_attach,

  -- UI
  update_focused_file = {
    enable = true,
    update_root = false, -- Update the root directory if file is not under current root
  },
  view = {
    preserve_window_proportions = true,
    adaptive_size = false, -- Don't resize on each file open
    width = 30,
  },

  -- Sorting and filtering
  sort = {
    sorter = "case_sensitive",
  },
  filters = {
    dotfiles = false,
    git_clean = false,
    no_buffer = false,
    custom = {}, -- Custom list of ignored files/directories
  },

  -- Git integration
  git = {
    enable = true,
    ignore = false, -- 设置为 false 以显示被 .gitignore 忽略的文件
    timeout = 500, -- Timeout for git status check
  },

  -- LSP diagnostics
  diagnostics = {
    enable = true,
    show_on_dirs = true, -- Show diagnostics for directories
  },

  -- Actions
  actions = {
    open_file = {
      quit_on_open = false, -- Don't close the tree when opening a file
      resize_window = true, -- Resize the window when opening a file
    },
  },

  -- System
  system_open = {
    cmd = nil, -- Use system default program to open files
  },
})
