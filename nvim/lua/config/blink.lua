-- blink.cmp

local util = require("util")

local is_ok, blink = pcall(require, "blink.cmp")
if not is_ok then
	util.log_warn("blink.cmp load failed")
	return
end

blink.setup({
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
		preset = "none",

		-- Accept completion
		["<CR>"] = { "accept", "fallback" },

		-- Select completions
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
		nerd_font_variant = "Nerd Font Mono",
	},

	sources = {
		-- `lsp`, `buffer`, `snippets`, `path` and `omni` are built-in
		-- so you don't need to define them in `sources.providers`
		default = { "buffer", "lsp", "path", "snippets" },

		-- Sources are configured via the sources.providers table
		providers = {},
	},

	-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
	-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
	-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
	--
	-- See the fuzzy documentation for more information
	fuzzy = { implementation = "prefer_rust_with_warning" },
	completion = {
		-- The keyword should only match against the text before
		keyword = { range = "prefix" },

		-- 不使用预先选择第一个补全选项
		list = { selection = { preselect = false, auto_insert = true } },

		menu = {
			draw = {
				-- Use treesitter to highlight the label text for the given list of sources
				treesitter = { "lsp" },

				-- nvim-web-devicons + lspkind
				components = {
					kind_icon = {
						text = function(ctx)
							local icon = ctx.kind_icon
							if vim.tbl_contains({ "Path" }, ctx.source_name) then
								local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
								if dev_icon then
									icon = dev_icon
								end
							else
								icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
							end

							return icon .. ctx.icon_gap
						end,
					},
				},
			},
		},

		-- Show completions after tying a trigger character, defined by the source
		trigger = { show_on_trigger_character = true },

		-- Show documentation automatically
		documentation = { auto_show = true, auto_show_delay_ms = 240 },
	},

	-- Signature help when tying
	signature = { enabled = true },
})
