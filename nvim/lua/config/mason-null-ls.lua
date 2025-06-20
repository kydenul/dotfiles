-- null_ls Format

local util = require("util")
local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
	util.log_warn("mason load failed.")
	return
end

local null_ls_ok, null_ls = pcall(require, "null-ls")
if not null_ls_ok then
	util.log_warn("null-ls load failed.")
	return
end

local mason_null_ls_ok, mason_null_ls = pcall(require, "mason-null-ls")
if not mason_null_ls_ok then
	util.log_warn("mason-null-ls load failed.")
	return
end

mason.setup()

mason_null_ls.setup({
	-- A list of sources to install if they're not already installed.
	-- This setting has no relation with the `automatic_installation` setting.
	ensure_installed = {
		-- golang
		"gofumpt",
		"goimports_reviser",

		-- Python
		"black",

		-- lua
		"stylua",

		-- json
		"jq",

		-- markdown
		"markdownlint",
	},

	-- Run `require("null-ls").setup`.
	-- Will automatically install masons tools based on selected sources in `null-ls`.
	-- Can also be an exclusion list.
	-- Example: `automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }`
	automatic_installation = false,

	-- Sources found installed in mason will automatically be set up for null-ls.
	automatic_setup = true,

	handlers = {
		-- Hint: see https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
		--       to see what sources are available
		-- Hint: see https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
		--       to check what we can configure for each source
		-- function() end, -- disables automatic setup of all null-ls sources
		black = function(_, _)
			null_ls.register(null_ls.builtins.formatting.black)
		end,
		stylua = function(_, _)
			null_ls.register(null_ls.builtins.formatting.stylua)
		end,
		rubyformat = function(_, _)
			null_ls.register(null_ls.builtins.formatting.rubyfmt)
		end,
		clangformat = function(_, _)
			null_ls.register(null_ls.builtins.formatting.clang_format)
		end,
		ocamlformat = function(_, _)
			null_ls.register(null_ls.builtins.formatting.ocamlformat.with({
				-- Add more arguments to a source's defaults
				-- Default: { "--enable-outside-detected-project", "--name", "$FILENAME", "-" }
				-- Type `ocamlformat --help` in your terminal to check more args
				extra_args = {
					"--if-then-else",
					"vertical",
					"--break-cases",
					"fit-or-vertical",
					"--type-decl",
					"sparse",
				},
			}))
		end,
	},
})

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
	debug = false,
	log_level = "warn",
	update_in_insert = false,
	sources = {
		-- Python
		null_ls.builtins.formatting.black.with({
			extra_args = {
				"--target-version",
				"py313",
			},
		}),

		-- Lua
		null_ls.builtins.formatting.stylua,

		-- Go
		null_ls.builtins.formatting.gofumpt,
		null_ls.builtins.formatting.goimports_reviser,
		null_ls.builtins.diagnostics.golangci_lint,
	},

	-- auto format when write file
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({
				group = augroup,
				buffer = bufnr,
			})
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})
