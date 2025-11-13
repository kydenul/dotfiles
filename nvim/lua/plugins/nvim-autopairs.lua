-- nvim-autopairs: Automatic bracket pairing plugin

return {
  "windwp/nvim-autopairs",

  event = "InsertEnter",

  opts = {
    check_ts = true, -- check if treesitter is installed
    map_bs = true, -- map the <BS> key
    map_c_h = false, -- Map the <C-h> key to delete a pair
    map_c_w = false, -- Map <C-w> to delete a pair if possible
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    disable_in_macro = false, -- disable when recording or executing a macro
    disable_in_visualblock = false, -- disable when insert after visual block mode
    ignore_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
    enable_moveright = true,
    enable_afterquote = true, -- add bracket pairs after quote
    enable_check_bracket_line = true, -- check bracket in same line

    ts_config = {
      lua = { "string", "source" }, -- it will not add a pair on that treesitter node
      javascript = { "template_string" },
      java = false, -- don't check treesitter on java
    },

    -- Before        Input                    After         Note
    -- -----------------------------------------------------------------
    -- (|foobar      <M-e> then press $       (|foobar)
    -- (|)(foobar)   <M-e> then press q       (|(foobar))
    -- (|foo bar     <M-e> then press qh      (|foo) bar
    -- (|foo bar     <M-e> then press qH      (foo|) bar
    -- (|foo bar     <M-e> then press qH      (foo)| bar    if cursor_pos_before = false
    fast_wrap = {
      map = "<C-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = [=[[%'%"%>%]%)%}%,]]=],
      end_key = "$",
      before_key = "h",
      after_key = "l",
      cursor_pos_before = true,
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      manual_position = true,
      highlight = "Search",
      highlight_grey = "Comment",
    },
  },
}
