-- nvim-tree: File explorer

return {
  "nvim-tree/nvim-tree.lua",

  dependencies = {
    {
      "nvim-tree/nvim-web-devicons",
      opts = { override = { copilot = { icon = "", color = "#cba6f7", name = "Copilot" } } },
    },
  },

  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },

  keys = {
    { "<leader>e", "<CMD>NvimTreeToggle<CR>", desc = "[Explorer] Toggle" },
    { "<leader>o", "<CMD>NvimTreeFocus<CR>", desc = "[Explorer] Focus" },
  },

  init = function()
    -- Disable netrw at the very start
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,

  config = function()
    local tree = require("nvim-tree")

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
        dotfiles = false, -- Display files starting with a dot, e.g. .gitignore
        git_clean = false, -- Display untracked files
        no_buffer = false, -- Display all files with unOpen and Open buffers

        -- Custom list of ignored files/directories
        custom = {
          -- macOS system files
          "^%.DS_Store$",
          "^%.AppleDouble$",
          "^%.LSOverride$",
          "^%._",

          -- Windows system files
          "^Thumbs%.db$",
          "^Desktop%.ini$",

          -- Editor/IDE files
          "^%.vscode$",
          "^%.idea$",
          "^%.vs$",
          "%.swp$",
          "%.swo$",
          "%.swn$",

          -- Version control
          "^%.git$",
          "^%.svn$",
          "^%.hg$",

          -- Dependencies & build artifacts
          "^node_modules$",
          "^%.next$",
          "^%.nuxt$",
          "^dist$",
          "^build$",
          "^out$",
          "^target$", -- Rust/Java
          "^vendor$", -- Go/PHP

          -- Package manager files
          "^%.pnpm%-store$",
          "^%.yarn$",
          "^%.npm$",

          -- Language-specific
          "__pycache__",
          "%.pyc$",
          "%.pyo$",
          "%.class$", -- Java
          "%.o$", -- C/C++
          "%.so$", -- Shared libraries
          "%.dylib$", -- macOS libraries
          "%.dll$", -- Windows libraries

          -- Logs and temp files
          "%.log$",
          "%.tmp$",
          "%.temp$",

          -- Coverage and test reports
          "^coverage$",
          "^%.coverage$",
          "^%.pytest_cache$",
          "^%.nyc_output$",

          -- Environment files (optional - remove if you need to see them)
          -- "^%.env$",
          -- "^%.env%.local$",
        },
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
  end,
}
