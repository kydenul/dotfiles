-- Trouble: A better way to handle diagnostics and other lists

local util = require("util")
local is_ok, trouble = pcall(require, "trouble")
if not is_ok then
	util.log_warn("trouble init failed")
	return
end

trouble.setup({
	-- Core settings
	auto_close = true, -- auto close when there are no items
	auto_open = false, -- auto open when there are items
	auto_preview = true, -- automatically open preview when on an item
	auto_refresh = true, -- auto refresh when open
	auto_jump = false, -- auto jump to the item when there's only one
	focus = false, -- Focus the window when opened
	restore = true, -- restores the last location in the list when opening
	follow = true, -- Follow the current item
	indent_guides = true, -- show indent guides
	max_items = 200, -- limit number of items that can be displayed per section
	multiline = true, -- render multi-line messages
	pinned = false, -- When pinned, the opened trouble window will be bound to the current buffer
	warn_no_results = true, -- show a warning when there are no results
	open_no_results = false, -- open the trouble window when there are no results

	-- Window options
	win = {}, -- window options for the results window
	preview = {
		type = "main", -- show preview in main editor window
		scratch = true, -- use scratch buffer for non-loaded files
	},

	-- Throttle/Debounce settings
	throttle = {
		refresh = 20, -- fetches new data when needed
		update = 10, -- updates the window
		render = 10, -- renders the window
		follow = 100, -- follows the current item
		preview = { ms = 100, debounce = true }, -- shows the preview for the current item
	},

	-- Key mappings
	keys = {
		["?"] = "help",
		r = "refresh",
		R = "toggle_refresh",
		q = "close",
		o = "jump_close",
		["<esc>"] = "cancel",
		["<cr>"] = "jump",
		["<2-leftmouse>"] = "jump",
		["<c-s>"] = "jump_split",
		["<c-v>"] = "jump_vsplit",
		-- go down to the next item (accepts count)
		-- j = "next",
		["}"] = "next",
		["]]"] = "next",
		-- go up to the prev item (accepts count)
		-- k = "prev",
		["{"] = "prev",
		["[["] = "prev",
		dd = "delete", -- Added delete action
		d = { action = "delete", mode = "v" }, -- Visual mode delete
		i = "inspect",
		p = "preview",
		P = "toggle_preview",
		zo = "fold_open",
		zO = "fold_open_recursive",
		zc = "fold_close",
		zC = "fold_close_recursive",
		za = "fold_toggle",
		zA = "fold_toggle_recursive",
		zm = "fold_more",
		zM = "fold_close_all",
		zr = "fold_reduce",
		zR = "fold_open_all",
		zx = "fold_update",
		zX = "fold_update_all",
		zn = "fold_disable",
		zN = "fold_enable",
		zi = "fold_toggle_enable",
		-- Custom actions
		gb = {
			action = function(view)
				view:filter({ buf = 0 }, { toggle = true })
			end,
			desc = "Toggle Current Buffer Filter",
		},
		s = {
			action = function(view)
				local f = view:get_filter("severity")
				local severity = ((f and f.filter.severity or 0) + 1) % 5
				view:filter({ severity = severity }, {
					id = "severity",
					template = "{hl:Title}Filter:{hl} {severity}",
					del = severity == 0,
				})
			end,
			desc = "Toggle Severity Filter",
		},
	},

	-- Mode configurations
	modes = {
		-- LSP base mode configuration
		lsp_base = {
			params = {
				-- don't include the current location in the results
				include_current = false,
			},
		},
		-- LSP references configuration
		lsp_references = {
			params = {
				include_declaration = true,
			},
		},
		-- Symbols mode configuration
		symbols = {
			desc = "document symbols",
			mode = "lsp_document_symbols",
			focus = false,
			win = { position = "right" },
			filter = {
				-- Remove Package since luals uses it for control flow structures
				["not"] = { ft = "lua", kind = "Package" },
				any = {
					-- all symbol kinds for help / markdown files
					ft = { "help", "markdown" },
					-- default set of symbol kinds
					kind = {
						"Class",
						"Constructor",
						"Enum",
						"Field",
						"Function",
						"Interface",
						"Method",
						"Module",
						"Namespace",
						"Package",
						"Property",
						"Struct",
						"Trait",
					},
				},
			},
		},
	},

	icons = {
		indent = {
			top = "│ ",
			middle = "├╴",
			last = "└╴",
			fold_open = " ",
			fold_closed = " ",
			ws = "  ",
		},

		folder_closed = " ",
		folder_open = " ",

		kinds = {
			Array = " ",
			Boolean = "󰨙 ",
			Class = " ",
			Constant = "󰏿 ",
			Constructor = " ",
			Enum = " ",
			EnumMember = " ",
			Event = " ",
			Field = " ",
			File = " ",
			Function = "󰊕 ",
			Interface = " ",
			Key = " ",
			Method = "󰊕 ",
			Module = " ",
			Namespace = "󰦮 ",
			Null = " ",
			Number = "󰎠 ",
			Object = " ",
			Operator = " ",
			Package = " ",
			Property = " ",
			String = " ",
			Struct = "󰆼 ",
			TypeParameter = " ",
			Variable = "󰀫 ",
		},
	},
})

-- Define keymaps for opening Trouble with different modes
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Diagnostics (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>xX",
	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Toggle Buffer Diagnostics (Trouble)" }
)
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Toggle Symbols (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>cl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "Toggle LSP Definitions/References (Trouble)" }
)
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Toggle Location List (Trouble)" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Toggle Quickfix List (Trouble)" })

-- Set wrap for Trouble buffer
vim.cmd([[
augroup trouble_setlocal
	autocmd!
	autocmd FileType trouble setlocal wrap
augroup END
]])
