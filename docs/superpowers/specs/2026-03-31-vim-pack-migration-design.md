# Neovim vim.pack Migration Design

Migrate from lazy.nvim to Neovim 0.12's native `vim.pack` for plugin management.

## Context

- Current setup: lazy.nvim with 31 plugin config files, 74+ plugins
- Target: Neovim 0.12 `vim.pack.add()` with zero external plugin manager dependency
- Reference: [patricorgi/dotfiles](https://github.com/patricorgi/dotfiles)

## Scope

### Changed

| File | Change |
|------|--------|
| `init.lua` | Rewrite: explicit `require` for every plugin file |
| `lua/plugins/*.lua` (31 files) | Rewrite: lazy.nvim spec → `vim.pack.add()` + `setup()` |
| `lua/custom/util.lua` | Add `util.pack_add()` safe wrapper |

### Deleted

| File | Reason |
|------|--------|
| `lua/klazy.lua` | lazy.nvim bootstrap no longer needed |
| `lazy-lock.json` | No version pinning with vim.pack |

### Unchanged

| Path | Reason |
|------|--------|
| `lua/custom/options.lua` | No plugin manager dependency |
| `lua/custom/keymaps.lua` | No plugin manager dependency |
| `lua/custom/floding.lua` | No plugin manager dependency |
| `lsp/*.lua` | LSP configs are already vim.pack-compatible |
| `lua/snippets/*` | No plugin manager dependency |

## Architecture

### Directory Structure (post-migration)

```
nvim/
├── init.lua                   # Explicit require for all modules
├── lua/
│   ├── custom/               # Unchanged
│   │   ├── options.lua
│   │   ├── keymaps.lua
│   │   ├── floding.lua
│   │   └── util.lua          # + pack_add() helper
│   ├── plugins/              # All files rewritten
│   │   ├── catppuccin.lua
│   │   ├── lsp.lua
│   │   ├── nvim-cmp.lua
│   │   └── ...
│   └── snippets/             # Unchanged
├── lsp/                      # Unchanged
```

### init.lua Loading Order

```lua
-- Phase 1: Core
require("custom.util")
require("custom.keymaps")
require("custom.floding")

-- Phase 2: Plugins (priority order)
require("plugins.catppuccin")       -- Theme first
require("plugins.lsp")              -- LSP core (mason + lspconfig)
require("plugins.nvim-cmp")         -- Completion
require("plugins.nvim-treesitter")  -- Syntax
-- ... remaining plugins
require("plugins.telescope")
require("plugins.gitsigns")
require("plugins.neogit")
-- ...

-- Phase 3: Options last (ensures overrides)
require("custom.options")
```

## Plugin Migration Patterns

### Pattern 1: Immediate Load

For startup-essential plugins (theme, statusline, bufferline, file explorer).

```lua
vim.pack.add({
  { src = "https://github.com/catppuccin/nvim" },
})
require("catppuccin").setup({ flavour = "mocha" })
vim.cmd("colorscheme catppuccin")
```

**Plugins:** catppuccin, lualine, bufferline, nvim-tree, noice, dashboard, indent-blankline, nvim-web-devicons, auto-session

### Pattern 2: Deferred Load (autocmd + once)

For plugins needed after a buffer opens. Uses `BufReadPre`/`BufNewFile` with `once = true`.

```lua
vim.pack.add({
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("SetupGitsigns", { clear = true }),
  once = true,
  callback = function()
    require("gitsigns").setup({ ... })
    vim.keymap.set("n", "]c", function() require("gitsigns").next_hunk() end)
  end,
})
```

**Plugins:** treesitter, gitsigns, telescope, nvim-cmp, conform, trouble, aerial, flash, nvim-surround, autopairs, yanky, todo-comments, render-markdown, vim-markdown

### Pattern 3: On-Demand Load (command/keymap trigger)

For heavy, infrequently used plugins. Loaded via user command or keymap.

```lua
vim.pack.add({
  { src = "https://github.com/NeogitOrg/neogit" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
})

vim.api.nvim_create_user_command("Neogit", function()
  require("neogit").setup({ ... })
  require("neogit").open()
end, {})
```

**Plugins:** neogit, fugitive, nvim-dap, spectre, toggleterm, which-key

## Dependency Handling

lazy.nvim `dependencies` field becomes multiple entries in the same `vim.pack.add()`:

```lua
vim.pack.add({
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
})
```

## LSP Migration

Mason, mason-lspconfig, and nvim-lspconfig load immediately (no lazy loading). The `lsp/` directory configs remain unchanged.

```lua
vim.pack.add({
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  { src = "https://github.com/onsails/lspkind.nvim" },
})

require("mason").setup({ ui = { border = "rounded" } })
require("mason-lspconfig").setup({ ensure_installed = { ... } })
vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
-- ...

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    -- Keymaps and highlighting (migrated as-is)
  end,
})
```

**todo-comments** is extracted from LSP dependencies into its own plugin file.

## Completion Engine

nvim-cmp and all sources registered in one `vim.pack.add()`, deferred to `BufReadPre`:

```lua
vim.pack.add({
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/hrsh7th/cmp-cmdline" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
})
```

Copilot loads separately on `InsertEnter` with `once = true`.

## Error Handling

New `util.pack_add()` wraps `vim.pack.add()` with `pcall`:

```lua
function util.pack_add(specs)
  local ok, err = pcall(vim.pack.add, specs)
  if not ok then
    util.log_warn("Failed to add packages: %s", err)
  end
  return ok
end
```

Plugin files can optionally use this for graceful degradation on missing plugins.

## Trade-offs Accepted

| Lost from lazy.nvim | Mitigation |
|---------------------|------------|
| Version pinning (lazy-lock.json) | Pin via git tag in `src` URL if needed |
| Plugin manager UI (:Lazy) | Use `:help vim.pack` commands |
| Automatic dependency resolution | Manual ordering in `vim.pack.add()` and init.lua |
| Progress UI on first install | Accept bare git clone output |

## Branch

Work on a new branch `refactor/vim-pack` from current HEAD.
