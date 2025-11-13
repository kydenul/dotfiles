return {
  "akinsho/toggleterm.nvim",

  keys = {
    { [[<C-\>]], desc = "Toggle terminal" },
    { "<leader>tp", "<cmd>lua _PYTHON_REPL_TOGGLE()<CR>", desc = "[Python] Toggle REPL", mode = "n" },
  },

  opts = {
    open_mapping = [[<C-\>]],
    start_in_insert = true,
    persist_size = true,
    close_on_exit = true,
    auto_scroll = true,
    direction = "vertical",
    hide_numbers = true,
    shade_terminals = true,

    -- This function is used to calculate the size of non-floating terminals.
    size = function(term)
      if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.2)
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,

    -- Float window options
    float_opts = {
      border = "single",
      winblend = 0,
      title_pos = "center",
      width = function()
        return math.floor(vim.o.columns * 0.8)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
      row = function()
        return math.floor((vim.o.lines - (vim.o.lines * 0.8)) / 2)
      end,
      col = function()
        return math.floor((vim.o.columns - (vim.o.columns * 0.8)) / 2)
      end,
    },

    -- Callbacks
    on_open = function(term)
      vim.cmd("setlocal nonumber norelativenumber")
      vim.cmd("startinsert!")
    end,
  },

  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- Define terminal key mappings
    function _G.set_terminal_keymaps()
      local opts_local = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts_local)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts_local)
    end

    -- Apply terminal keymaps only when a toggleterm terminal opens
    vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

    -- Custom Terminals
    local Terminal = require("toggleterm.terminal").Terminal

    -- Python REPL
    local python_repl = Terminal:new({
      cmd = "python",
      direction = "float",
      float_opts = { border = "rounded" },
      hidden = true,
    })

    function _G._PYTHON_REPL_TOGGLE()
      python_repl:toggle()
    end
  end,
}
