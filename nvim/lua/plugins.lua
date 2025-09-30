-- Install Lazy.nvim automatically if it's not installed(Bootstraping)
-- Hint: string concatenation is done by `..`
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- After installation, run `checkhealth lazy` to see if everything goes right
-- Hints:
--     build: It will be executed when a plugin is installed or updated
--     config: It will be executed when the plugin loads
--     event: Lazy-load on event
--     dependencies: table
--                   A list of plugin names or plugin specs that should be loaded when the plugin loads.
--                   Dependencies are always lazy-loaded unless specified otherwise.
--     ft: Lazy-load on filetype
--     cmd: Lazy-load on command
--     init: Functions are always executed during startup
--     branch: string?
--             Branch of the repository
--     main: string?
--           Specify the main module to use for config() or opts()
--           , in case it can not be determined automatically.
--     keys: string? | string[] | LazyKeysSpec table
--           Lazy-load on key mapping
--     opts: The table will be passed to the require(...).setup(opts)
require("lazy").setup({
  { "echasnovski/mini.icons", version = "*" },

  -- ==============================================================
  -- ==============================================================
  -- UI Config
  -- ==============================================================
  -- ==============================================================
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    priority = 1000,
  },

  {
    "catppuccin/nvim",
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme("catppuccin-mocha")
      vim.cmd.hi("Comment gui=none")
    end,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        term_colors = true,
        integrations = {
          aerial = true,
          diffview = true,
          mini = {
            enabled = true,
            indentscope_color = "sky",
          },
          noice = true,
          -- overseer = true,
          telescope = {
            enabled = true,
            -- style = "nvchad",
          },
          nvimtree = true,
          neotree = true,
          which_key = true,
          treesitter = true,
          notify = true,
          gitsigns = true,
          flash = true,
          blink_cmp = true,
          mason = true,
          snacks = false,
        },
        highlight_overrides = {
          mocha = function(mocha)
            return {
              CursorLineNr = { fg = mocha.yellow },
              TelescopeSelection = { bg = mocha.surface0 },
              TelescopeSelectionCaret = { fg = mocha.yellow, bg = mocha.surface0 },
              TelescopePromptPrefix = { fg = mocha.yellow },
              FlashCurrent = { bg = mocha.peach, fg = mocha.base },
              FlashMatch = { bg = mocha.red, fg = mocha.base },
              FlashLabel = { bg = mocha.teal, fg = mocha.base },
              NormalFloat = { bg = mocha.base },
              FloatBorder = { bg = mocha.base },
              FloatTitle = { bg = mocha.base },
            }
          end,
        },
      })
    end,
  },

  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = { copilot = { icon = "", color = "#cba6f7", name = "Copilot" } },
    },
  },

  -- Smooth Scrolling
  {
    "karb94/neoscroll.nvim",
    opts = {},
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",

      --     -- OPTIONAL:
      --     --   `nvim-notify` is only needed, if you want to use the notification view.
      --     --   If not available, we use `mini` as the fallback
      --     {
      --       "rcarriga/nvim-notify",
      --       opts = {
      --         stages = "static",
      --         background_colour = "Normal",
      --         timeout = 3200,
      --         render = "compact",
      --       },
      --     },
    },

    config = function()
      require("config.noice")
    end,
  },

  -- ==============================================================
  -- ==============================================================
  -- Commentary
  -- gcc / gc / gcu
  -- ==============================================================
  -- ==============================================================
  { "tpope/vim-commentary" },

  -- ==============================================================
  -- ==============================================================
  -- Todo comments
  -- ==============================================================
  -- ==============================================================
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- yanky
  {
    "gbprod/yanky.nvim",
    config = function()
      require("yanky").setup({})
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional, for file icons
    config = function()
      require("config.nvim-tree")
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("config.lualine")
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    config = function()
      require("config.which-key")
    end,
  },

  -- indentation and blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("config.indent-blankline")
    end,
  },

  -- Search & Replace
  { "nvim-pack/nvim-spectre" },

  -- Session management
  {
    "rmagatti/auto-session",
    config = function()
      require("config.auto-session")
    end,
  },

  -- Code Folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("config.nvim-ufo")
    end,
  },

  -- Smart motion
  {
    "folke/flash.nvim",
    event = "BufReadPost",
    opts = {
      label = {
        rainbow = {
          enabled = true,
          shade = 1,
        },
      },
      modes = {
        char = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        ",",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "[Flash] Jump",
      },
    },
  },

  -- Outline
  {
    "stevearc/aerial.nvim",
    config = function()
      require("config/aerial")
    end,
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    submodules = false,
    config = true,
    main = "rainbow-delimiters.setup",
  },

  -- Show colors in the text: e.g. "#b3e2a7"
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufRead",
    opts = {},
    config = function(_)
      require("colorizer").setup()
    end,
  },

  -- Git integration
  "tpope/vim-fugitive",

  -- Git decorations
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    config = function()
      require("config.gitsigns")
    end,
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional

      "nvim-telescope/telescope.nvim", -- optional
      -- "ibhagwan/fzf-lua", -- optional
    },
    config = function()
      require("config.neogit")
    end,
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    event = "BufReadPost",
    dependencies = { "famiu/bufdelete.nvim" },
    config = function()
      require("config.bufferline")
    end,
  },

  {
    -- Conflicted with vscode_nvim, don't know why
    "kevinhwang91/nvim-hlslens",
    -- stylua: ignore
    keys = {
      { "n",  "nzz<Cmd>lua require('hlslens').start()<CR>", mode = "n", desc = "Next match",      noremap = true, silent = true },
      { "N",  "Nzz<Cmd>lua require('hlslens').start()<CR>", mode = "n", desc = "Previous match",  noremap = true, silent = true },
      { "*",  "*<Cmd>lua require('hlslens').start()<CR>",   mode = "n", desc = "Next match",      noremap = true, silent = true },
      { "#",  "#<Cmd>lua require('hlslens').start()<CR>",   mode = "n", desc = "Previous match",  noremap = true, silent = true },

      { "/" },
      { "?" },
    },
    opts = {
      nearest_only = true,
    },
  },

  -- Make surrounding easier
  -- ------------------------------------------------------------------
  -- Old text                    Command         New text
  -- ------------------------------------------------------------------
  -- surr*ound_words             gziw)           (surround_words)
  -- *make strings               gz$"            "make strings"
  -- [delete ar*ound me!]        gzd]            delete around me!
  -- remove <b>HTML t*ags</b>    gzdt            remove HTML tags
  -- 'change quot*es'            gzc'"           "change quotes"
  -- delete(functi*on calls)     gzcf            function calls
  -- ------------------------------------------------------------------
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    -- You can use the VeryLazy event for things that can
    -- load later and are not important for the initial UI
    event = "VeryLazy",
    config = function()
      require("config.surround")
    end,
  },

  -- Better terminal integration
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("config.toggleterm")
    end,
  },

  -- Autopairs: [], (), "", '', etc
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("config.nvim-autopairs")
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    event = "BufReadPost",
    cmd = { "Glg", "Gst", "Diag", "Tags" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- ripgrep is a system-level dependency and needs to be installed separately.
      -- It's listed here for documentation purposes as Telescope can utilize it.
      "BurntSushi/ripgrep",
    },
    config = function()
      require("config.telescope")
    end,
  },

  -- Treesitter-integration
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",

      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "andymass/vim-matchup",
      "mfussenegger/nvim-treehopper",
    },
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    config = function()
      require("config.nvim-treesitter")
    end,
  },

  -- IDE-like breadcrumbs, out of the box
  {
    "Bekaboo/dropbar.nvim",
    -- optional, but required for fuzzy finder support
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    config = function()
      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
    end,
  },

  -- Vscode-like pictograms
  {
    "onsails/lspkind.nvim",
    event = { "VimEnter" },
  },

  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",

  -- Code formatter
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("config.nvim-conform")
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      -- Mason: Neovim 的包管理器，用来安装 LSP, DAP, Linters 等
      "williamboman/mason.nvim",
    },
  },

  -- Auto-completion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-nvim-lsp", -- lsp auto-completion
      "hrsh7th/cmp-buffer", -- buffer auto-completion
      "hrsh7th/cmp-path", -- path auto-completion
      "hrsh7th/cmp-cmdline", -- cmdline auto-completion
      "xzbdmw/colorful-menu.nvim",

      -- Code snippet engine
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          -- Load friendly snippets
          require("luasnip.loaders.from_vscode").lazy_load({
            include = { "c", "cpp", "go", "python", "sh", "json", "lua", "gitcommit", "sql", "markdown" },
          })

          -- Load custom snippets
          require("config.snippets")

          -- Configure LuaSnip
          local luasnip = require("luasnip")
          luasnip.config.setup({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = true,
            ext_opts = {
              [require("luasnip.util.types").choiceNode] = {
                active = {
                  virt_text = { { "●", "Orange" } },
                },
              },
            },
          })
        end,
      },

      -- -- Copilot
      -- "zbirenbaum/copilot-cmp", -- copilot 与 nvim-cmp 之间的桥梁
      -- {
      --   "zbirenbaum/copilot.lua",
      --   cmd = "Copilot",
      --   event = "InsertEnter",
      --   config = function()
      --     require("copilot").setup({
      --       -- 禁用 Copilot 的默认面板和建议 => 因为我们将使用 nvim-cmp 来展示建议
      --       panel = {
      --         enabled = false,
      --       },
      --       suggestion = {
      --         enabled = false,
      --       },
      --     })
      --   end,
      -- },

      -- Codeium
      {
        "Exafunction/windsurf.vim",
        config = function()
          vim.g.codeium_no_map_tab = 1
          vim.keymap.set("i", "<C-Enter>", function()
            return vim.fn["codeium#Accept"]()
          end, { expr = true, silent = true })
          vim.keymap.set("i", "<C-;>", function()
            return vim.fn["codeium#CycleCompletions"](1)
          end, { expr = true, silent = true })
          vim.keymap.set("i", "<C-,>", function()
            return vim.fn["codeium#CycleCompletions"](-1)
          end, { expr = true, silent = true })
          vim.keymap.set("i", "<C-x>", function()
            return vim.fn["codeium#Clear"]()
          end, { expr = true, silent = true })
        end,
      },
    },
    config = function()
      require("config.nvim-cmp")
    end,
  },

  --{
  --  "saghen/blink.cmp",
  --  -- optional: provides snippets for the snippet source
  --  dependencies = {
  --    "onsails/lspkind.nvim",
  --    -- Spell source based on Neovim's `spellsuggest`.
  --    "ribru17/blink-cmp-spell",
  --    ---Use treesitter to highlight the label text for the given list of sources.
  --    "xzbdmw/colorful-menu.nvim",

  --    -- Code snippet engine
  --    {
  --      "L3MON4D3/LuaSnip",
  --      event = "InsertEnter",
  --      dependencies = { "rafamadriz/friendly-snippets" },
  --      config = function()
  --        -- Load friendly snippets
  --        require("luasnip.loaders.from_vscode").lazy_load({
  --          include = { "c", "cpp", "go", "python", "sh", "json", "lua", "gitcommit", "sql", "markdown" },
  --        })

  --        -- Load custom snippets
  --        require("config.snippets")

  --        -- Configure LuaSnip
  --        local luasnip = require("luasnip")
  --        luasnip.config.setup({
  --          history = true,
  --          updateevents = "TextChanged,TextChangedI",
  --          enable_autosnippets = true,
  --          ext_opts = {
  --            [require("luasnip.util.types").choiceNode] = {
  --              active = {
  --                virt_text = { { "●", "Orange" } },
  --              },
  --            },
  --          },
  --        })
  --      end,
  --    },

  --    -- Copilot
  --    "fang2hou/blink-copilot", -- copilot 与 blink-cmp 之间的桥梁
  --    {
  --      "zbirenbaum/copilot.lua",
  --      cmd = "Copilot",
  --      event = "InsertEnter",
  --      config = function()
  --        require("copilot").setup({
  --          -- 禁用 Copilot 的默认面板和建议 => 因为我们将使用 nvim-cmp 来展示建议
  --          panel = {
  --            enabled = false,
  --          },
  --          suggestion = {
  --            enabled = false,
  --          },
  --        })
  --      end,
  --    },
  --  },

  --  event = { "InsertEnter", "CmdlineEnter" },

  --  -- use a release tag to download pre-built binaries
  --  version = "*",
  --  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  --  -- build = 'cargo build --release',
  --  -- If you use nix, you can build from source using latest nightly rust with:
  --  -- build = 'nix run .#build-plugin',

  --  config = function()
  --    require("config.blink-cmp")
  --  end,
  --},

  -- LSP Rename
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup({})
    end,
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      require("config.trouble")
    end,
  },

  -- Markdown preview
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
      "3rd/image.nvim",

      {
        "AndrewRadev/switch.vim",
        config = function()
          vim.keymap.set("n", "`", function()
            vim.cmd([[Switch]])
          end, { desc = "Switch strings" })

          vim.g.switch_custom_definitions = {
            { "> [!TODO]", "> [!WIP]", "> [!DONE]", "> [!FAIL]" },
            { "height", "width" },
          }
        end,
      },

      -- Image Clip For Markdown
      {
        "HakonHarnes/img-clip.nvim",
        ft = { "tex", "markdown" },
        opts = {
          default = {
            dir_path = "./docs/images",
            use_absolute_path = false,
            copy_images = true,
            prompt_for_file_name = false,
            file_name = "img-%y%m%d-%H%M%S",
          },

          filetypes = {
            markdown = { template = "![image$CURSOR]($FILE_PATH)" },

            tex = {
              dir_path = "./figs",
              extension = "png",
              process_cmd = "",
              template = [[
      \begin{figure}[h]
      \centering
      \includegraphics[width=0.8\textwidth]{$FILE_PATH}
      \end{figure}
        ]], ---@type string | fun(context: table): string
            },
          },
        },
        keys = {
          { "<leader>P", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
        },
      },
    },

    config = function()
      require("config.render-markdown")
    end,
  },

  -- {
  --   "3rd/image.nvim",
  --   build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
  --   opts = {
  --     processor = "magick_cli",
  --   },
  -- },

  -- PlantUML syntax
  {
    "aklt/plantuml-syntax",
    ft = "plantuml",
  },

  -- DAP
  {
    -- =============================================================================
    -- 此插件将 mason 和 nvim-dap 连接起来，实现调试器自动配置
    -- 必须在 nvim-dap 之前加载
    -- =============================================================================
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    -- handler 会自动为 mason 中安装的调试器设置好 adapter
    opts = {
      -- 在启动时确保这些调试器已安装
      ensure_installed = { "python", "go", "codelldb" },

      -- handler 为空即可，它会自动处理
      handlers = {},
    },
  },
  {
    "mfussenegger/nvim-dap", -- 核心调试器插件
    dependencies = {
      { "theHamsta/nvim-dap-virtual-text" }, -- 在代码旁显示调试信息
      {
        -- DAP UI，提供变量、堆栈、断点等窗口
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },

        keys = {
          {
            "<leader>Du",
            function()
              require("dapui").toggle({ reset = true })
            end,
            desc = "[DAP ui] Toggle dapui",
          },
        },

        config = function()
          -- 在调试会话开始和结束时自动打开/关闭 DAP UI
          local dap, dapui = require("dap"), require("dapui")
          dapui.setup()

          -- 自动开关 DAP UI
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
    },
    config = function()
      require("config.nvim-dap")
    end,
  },
})
