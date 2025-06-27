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
