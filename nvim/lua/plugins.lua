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

	-- Colorscheme
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({})
		end,
	},

	-- Commentary
	-- gcc / gc / gcu
	{ "tpope/vim-commentary" },

	-- Todo comments
	{
		"folke/todo-comments.nvim",
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

	-- Smart motion
	{
		"smoka7/hop.nvim",
		config = function()
			require("config.hop")
		end,
	},

	-- Outline
	{
		"stevearc/aerial.nvim",
		config = function()
			require("config/aerial")
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

	-- Scrollbar
	{
		"petertriho/nvim-scrollbar",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		config = function()
			require("scrollbar").setup({
				handlers = {
					cursor = true,
					diagnostic = true,
					gitsigns = true, -- Requires gitsigns
					handle = true,
					search = false, -- Requires hlslens
					ale = false, -- Requires ALE
				},
				set_highlights = true,
			})
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
			require("config.nvim-surround")
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
			"p00f/nvim-ts-rainbow",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-context",

			"windwp/nvim-ts-autotag",
			"JoosepAlviste/nvim-ts-context-commentstring",
			"andymass/vim-matchup",
			"mfussenegger/nvim-treehopper",
		},
		event = "BufReadPost",
		build = ":TSUpdate",
		config = function()
			require("config.nvim-treesitter")
		end,
	},

	-- Vscode-like pictograms
	{
		"onsails/lspkind.nvim",
		event = { "VimEnter" },
	},

	-- LSP manager
	{
		-- Mason: Neovim 的包管理器，用来安装 LSP, DAP, Linters 等
		"williamboman/mason.nvim",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",

	-- Add hooks to LSP to support Linter && Formatter
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			-- Note:
			--     the default search path for `require` is ~/.config/nvim/lua
			--     use a `.` as a path separator
			--     the suffix `.lua` is not needed
			require("config.mason-null-ls")
		end,
	},

	-- -- Auto-completion engine
	-- {
	-- 	"hrsh7th/nvim-cmp",
	-- 	dependencies = {
	-- 		"lspkind.nvim",
	-- 		"hrsh7th/cmp-nvim-lsp", -- lsp auto-completion
	-- 		"hrsh7th/cmp-buffer", -- buffer auto-completion
	-- 		"hrsh7th/cmp-path", -- path auto-completion
	-- 		"hrsh7th/cmp-cmdline", -- cmdline auto-completion
	-- 	},
	-- 	config = function()
	-- 		require("config.nvim-cmp")
	-- 	end,
	-- },
	--

	-- blink.cmp
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = { "rafamadriz/friendly-snippets" },

		-- use a release tag to download pre-built binaries
		version = "*",

		-- opts_extend = { "sources.default" },

		config = function()
			require("config.blink")
		end,
	},

	-- Code snippet engine
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_vscode").load({
				include = { "c", "cpp", "go", "python", "sh", "json", "lua", "gitcommit", "sql", "markdown" },
			})
		end,
	},

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

	-- Markdown support
	{
		"preservim/vim-markdown",
		require = { "godlygeek/tabular" },
		ft = { "markdown" },
	},

	-- Markdown preview
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},

		config = function()
			require("config.render-markdown")
		end,
	},

	-- PlantUML syntax
	{
		"aklt/plantuml-syntax",
		ft = "plantuml",
	},
	-- PlantUML preview
	{
		"weirongxu/plantuml-previewer.vim",
		ft = "plantuml",
		dependencies = {
			"tyru/open-browser.vim",
		},
	},

	-- Codeium
	{
		"Exafunction/windsurf.vim",
		config = function()
			vim.g.codeium_no_map_tab = 1
			vim.keymap.set("i", "<C-g>", function()
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
		-- 核心调试器插件
		"mfussenegger/nvim-dap",
		dependencies = {
			-- DAP UI，提供变量、堆栈、断点等窗口
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },

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
			-- 在代码旁显示调试信息
			{ "theHamsta/nvim-dap-virtual-text" },
		},
		config = function()
			local dap = require("dap")

			-- === 启动配置 (Launch Configurations) ===
			-- mason-nvim-dap 已经处理了 adapters，我们只需要定义如何启动程序

			-- Python
			dap.configurations.python = {
				{
					type = "python", -- mason-nvim-dap 会自动映射到 debugpy
					request = "launch",
					name = "Launch file",
					program = "${file}", -- 调试当前文件
					pythonPath = function()
						return vim.fn.input("Path to python executable: ", "python", "file")
					end,
				},
			}

			-- Go
			dap.configurations.go = {
				{
					type = "delve", -- mason-nvim-dap 会自动映射到 delve
					request = "launch",
					name = "Launch file",
					program = "${fileDirname}", -- 调试当前文件所在的目录
				},
			}

			-- C, C++, Rust
			dap.configurations.cpp = {
				{
					type = "codelldb", -- mason-nvim-dap 会自动映射到 codelldb
					request = "launch",
					name = "Launch file",
					program = function()
						-- 编译后，手动输入可执行文件路径
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}
			-- C++ 和 Rust 可以共用一套配置
			dap.configurations.c = dap.configurations.cpp
			dap.configurations.rust = dap.configurations.cpp

			-- ===================================================================
			-- ‼️ NEW: 定义自定义的 DAP 图标 ‼️
			-- ===================================================================
			local sign = vim.fn.sign_define
			sign("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
			sign("DapBreakpointCondition", { text = "󰃤", texthl = "DapBreakpoint", linehl = "", numhl = "" })
			sign("DapLogPoint", { text = "󰌑", texthl = "DapLogPoint", linehl = "", numhl = "" })
			sign("DapRejectedBreakpoint", { text = "󰚦", texthl = "DapRejectedBreakpoint", linehl = "", numhl = "" })
			sign("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })

			-- ===================================================================
			-- ‼️ NEW: Keymappings ‼️
			-- ===================================================================
			vim.keymap.set({ "n", "v" }, "<F5>", dap.continue, { desc = "DAP: Continue" })
			vim.keymap.set({ "n", "v" }, "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })

			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP: Step Out" })

			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run Last" })
			vim.keymap.set("n", "<Leader>dp", function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end)
		end,
	},
})
