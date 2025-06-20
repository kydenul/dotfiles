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
	"williamboman/mason.nvim",
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
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = {
				-- Each keymap may be a list of commands and/or functions
				preset = "enter",
				-- Select completions
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				-- Scroll documentation
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				-- Show/hide signature
				["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			sources = {
				-- `lsp`, `buffer`, `snippets`, `path` and `omni` are built-in
				-- so you don't need to define them in `sources.providers`
				default = { "lsp", "path", "snippets", "buffer" },

				-- Sources are configured via the sources.providers table
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },
			completion = {
				-- The keyword should only matchh against the text before
				keyword = { range = "prefix" },
				menu = {
					-- Use treesitter to highlight the label text for the given list of sources
					draw = {
						treesitter = { "lsp" },
					},
				},
				-- Show completions after tying a trigger character, defined by the source
				trigger = { show_on_trigger_character = true },
				documentation = {
					-- Show documentation automatically
					auto_show = true,
				},
			},

			-- Signature help when tying
			signature = { enabled = true },
		},
		opts_extend = { "sources.default" },
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
})
