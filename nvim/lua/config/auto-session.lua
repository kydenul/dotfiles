-- Auto Session Configuration

local util = require("util")

local ok, auto_session = pcall(require, "auto-session")
if not ok then
  util.log_warn("auto-session load failed")
  return
end

-- Setup auto-session with sensible defaults
auto_session.setup({
  -- Enable automatic session management
  auto_save_enabled = true,
  auto_restore_enabled = true,

  -- Session directory
  auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",

  -- Session options
  auto_session_enable_last_session = false,
  auto_session_create_enabled = true,
  auto_session_use_git_branch = false,

  -- Suppress session create/restore messages
  auto_session_suppress_dirs = {
    "~/",
    "~/Downloads",
    "~/Documents",
    "~/Desktop",
    "/tmp",
  },

  -- Session lens (telescope integration)
  session_lens = {
    -- If load_on_setup is set to false, one needs to eventually call `require("auto-session").setup_session_lens()`
    -- if they want to use session-lens.
    load_on_setup = true,
    theme_conf = { border = true },
    previewer = false,
  },

  -- Auto save session on exit
  auto_save = {
    enabled = true,
  },

  -- Auto restore session on startup
  auto_restore = {
    enabled = true,
  },

  -- Pre and post hooks for session save/restore
  pre_save_cmds = {
    -- "NvimTreeClose", -- Close nvim-tree before saving session
  },

  post_restore_cmds = {
    -- You can add commands to run after session restore
  },

  -- Bypass auto save and restore for certain arguments
  bypass_auto_save_args = {
    "nvim .",
    "nvim -c",
  },

  -- Log level
  log_level = "error",
})

-- Add telescope extension for session lens
local telescope_ok, telescope = pcall(require, "telescope")
if telescope_ok then
  telescope.load_extension("session-lens")
end

-- Session management
vim.keymap.set("n", "<leader>ss", "<Cmd>AutoSession save<CR>", { noremap = true, silent = true, desc = "Save session" })
vim.keymap.set(
  "n",
  "<leader>sr",
  "<Cmd>AutoSession restore<CR>",
  { noremap = true, silent = true, desc = "Restore session" }
)
vim.keymap.set(
  "n",
  "<leader>sd",
  "<Cmd>AutoSession delete<CR>",
  { noremap = true, silent = true, desc = "Delete session" }
)
vim.keymap.set(
  "n",
  "<leader>sf",
  "<Cmd>Telescope session-lens search_session<CR>",
  { noremap = true, silent = true, desc = "Find sessions" }
)
