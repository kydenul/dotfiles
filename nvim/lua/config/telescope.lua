-- Telescope

local util = require("util")
local telescope = require("telescope")
local sorters = require("telescope.sorters")
local builtin = require("telescope.builtin")
local make_entry = require("telescope.make_entry")
local finders = require("telescope.finders")
local Path = require("plenary.path")
local actions = require("telescope.actions")
local _ = require("telescope.actions.state")

local line_no
local function post()
  if line_no then
    vim.cmd.normal(line_no .. "G")
    line_no = nil
  end
end

local function sorter(opts)
  opts = opts or {}
  local fzy = opts.fzy_mod or require("telescope.algos.fzy")
  local OFFSET = -fzy.get_score_floor()
  return sorters.Sorter:new({
    discard = true,
    scoring_function = function(_, prompt, line)
      local i = prompt:find(":", 1, true)
      if i then
        line_no = tonumber(prompt:sub(i + 1))
        prompt = prompt:sub(1, i - 1)
      else
        line_no = nil
      end
      if not fzy.has_match(prompt, line) then
        return -1
      end
      local fzy_score = fzy.score(prompt, line)
      if fzy_score == fzy.get_score_min() then
        return 1
      end
      return 1 / (fzy_score + OFFSET)
    end,
    highlighter = function(_, prompt, display)
      local i = prompt:find(":", 1, true)
      if i then
        prompt = prompt:sub(1, i - 1)
      end
      return fzy.positions(prompt, display)
    end,
  })
end

-- Apply post function to actions
actions.select_default._static_post.select_default = post
actions.select_horizontal._static_post.select_horizontal = post
actions.select_vertical._static_post.select_vertical = post
actions.select_tab._static_post.select_tab = post

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-v>"] = false,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<C-h>"] = "which_key",
      },
      n = {
        ["q"] = actions.close,
      },
    },
    file_sorter = sorter,

    -- Layout
    layout_strategy = "horizontal",
    -- layout_strategy = "vertical",
    layout_config = {
      vertical = {
        preview_cutoff = 10,
        width = 0.96,
        height = 0.96,
        prompt_position = "top", -- "bottom"
      },

      horizontal = {
        preview_cutoff = 10,
        width = 0.96,
        height = 0.96,
        prompt_position = "top", -- "bottom"
      },
    },
    preview = {
      filesize_limit = 1,
      treesitter = true,
    },

    path_display = { "truncate" },
    winblend = 0,
    set_env = { ["COLORTERM"] = "truecolor" },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
    },
  },

  pickers = {
    find_files = {
      hidden = true,
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
    },
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      mappings = {
        i = {
          ["<c-d>"] = actions.delete_buffer,
        },
        n = {
          ["dd"] = actions.delete_buffer,
        },
      },
    },
  },
})

-- Helper functions for setting options
local function set_opts(opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  opts.winnr = opts.winnr or vim.api.nvim_get_current_win()
  return opts
end

-- Tags functions with improved error handling
local function awk_tags(opts)
  opts = set_opts(opts)

  local tagfiles = opts.ctags_file and { opts.ctags_file } or vim.fn.tagfiles()
  for i, ctags_file in ipairs(tagfiles) do
    tagfiles[i] = vim.fn.expand(ctags_file, true)
  end

  if vim.tbl_isempty(tagfiles) then
    util.log_err("No tags file found.")
    return
  end

  opts.entry_maker = opts.entry_maker or make_entry.gen_from_ctags(opts)

  -- Use pcall to handle potential errors with awk command
  local status, result = pcall(function()
    return finders.new_oneshot_job(vim.iter({ "awk", opts.awk, tagfiles }):flatten():totable(), opts)
  end)

  if not status then
    util.log_err("Error creating tags finder: " .. tostring(result))
    return
  end

  opts.finder = result
  return builtin.tags(opts)
end

local function current_buffer_tags(opts)
  opts = set_opts(opts)
  opts.prompt_title = "Current Buffer Tags"
  opts.only_current_file = true
  opts.only_sort_tags = true
  opts.path_display = "hidden"

  local cwd = vim.fn.expand(opts.cwd or vim.loop.cwd())
  local current_file = Path:new(vim.api.nvim_buf_get_name(opts.bufnr)):normalize(cwd)
  opts.awk = string.format("$2 == %q{print $0}", current_file)

  return awk_tags(opts)
end

-- Enhanced keymaps with descriptions
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[Telescope] Find files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[Telescope] Find buffers" })
vim.keymap.set("n", "<leader>fg", function()
  builtin.live_grep(util.live_grep_opts({}))
end, { desc = "[Telescope] Live grep" })
vim.keymap.set("n", "<leader>ft", builtin.help_tags, { desc = "[Telescope] Find help tags" })
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "[Telescope] Fuzzy find in buffer" })
vim.keymap.set("n", "<leader>fo", current_buffer_tags, { desc = "[Telescope] Find buffer tags" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[Telescope] Find diagnostics" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[Telescope] Resume last picker" })

-- Additional useful telescope mappings
vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "[Telescope] Find commands" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[Telescope] Find keymaps" })
vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "[Telescope] Find string under cursor" })
vim.keymap.set("n", "<leader>fh", builtin.command_history, { desc = "[Telescope] Find command history" })
vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "[Telescope] Find marks" })
vim.keymap.set("n", "<leader>fj", builtin.jumplist, { desc = "[Telescope] Find jumplist" })

-- Todo-Comment
vim.keymap.set("n", "<leader>td", ":TodoTelescope<CR>", { desc = "[Todo-Comment] Telescope" })

-- Git commands with improved error handling
local git_log = { "git", "log", "--pretty=format:%h %s (%ci) <%an>\n" }

vim.api.nvim_create_user_command("Glg", function(opts)
  local commit = opts.args ~= "" and opts.args or nil
  local command = vim.iter({ git_log, commit }):flatten():totable()

  -- Check if git is available
  local git_available = vim.fn.executable("git") == 1
  if not git_available then
    util.log_err("Git command not found")
    return
  end

  builtin.git_commits({
    initial_mode = "normal",
    git_command = command,
    previewer = false,
  })
end, { nargs = "?" })

vim.api.nvim_create_user_command("Glgb", function(opts)
  local commit = opts.args ~= "" and opts.args or nil
  local command = vim.iter({ git_log, commit }):flatten():totable()

  -- Check if in a git repository
  local in_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree"):match("true")
  if not in_git_repo then
    util.log_err("Not in a git repository")
    return
  end

  builtin.git_bcommits({
    initial_mode = "normal",
    git_command = command,
    previewer = false,
  })
end, { nargs = "?" })

vim.api.nvim_create_user_command("Gst", function()
  builtin.git_status({
    initial_mode = "normal",
    git_icons = {
      added = "+",
      changed = "~",
      copied = ">",
      deleted = "-",
      renamed = "»",
      unmerged = "=",
      untracked = "?",
    },
  })
end, {})

-- Diagnostics command with improved options
vim.api.nvim_create_user_command("Diag", function()
  builtin.diagnostics({
    initial_mode = "normal",
    bufnr = 0, -- Current buffer only
    severity_limit = "WARNING",
  })
end, {})

-- Tags command with improved error handling
vim.api.nvim_create_user_command("Tags", function(opts)
  if opts.args and opts.args ~= "" then
    awk_tags({
      fname_width = 0.4,
      prompt_title = string.format("Tags ~ %q", opts.args),
      awk = string.format("$1 ~ %q{print $0}", opts.args),
    })
  else
    builtin.tags({
      fname_width = 0.4,
      show_line = true,
    })
  end
end, { nargs = "?" })

-- Additional useful commands
vim.api.nvim_create_user_command("Oldfiles", function()
  builtin.oldfiles({ initial_mode = "normal" })
end, {})

vim.api.nvim_create_user_command("Marks", function()
  builtin.marks({ initial_mode = "normal" })
end, {})

-- S 代表 Spectre 或者 Search & Replace
vim.keymap.set("n", "<leader>S", "<cmd>Spectre search_word_under_cursor<CR>", {
  desc = "[S]earch word under cursor with Spectre",
})
