-- NOTE: UFO is a folding plugin.

local util = require("util")

local ufo_ok, ufo = pcall(require, "ufo")
if not ufo_ok then
  util.log_warn("ufo load failed")
  return
end

-- Folding hints:
--   A uppercase letter followed `z` means recursive
--   zo: open one fold under the cursor
--   zc: close one fold under the cursor
--   za: toggle the folding
--   zv: open just enough folds to make the line in which the cursor is located not folded
--   zM: close all foldings
--   zR: open all foldings

-- Set up folding based on treesitter
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = "1" -- Show fold column
vim.o.foldlevel = 99 -- Start with all folds open
vim.o.foldlevelstart = 99 -- Start with all folds open
vim.o.foldenable = true -- Enable folding

local handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local totalLines = vim.api.nvim_buf_line_count(0)
  local foldedLines = endLnum - lnum
  local suffix = ("  %d %d%%"):format(foldedLines, foldedLines / totalLines * 100)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  local rAlignAppndx = math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
  suffix = (" "):rep(rAlignAppndx) .. suffix
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end
ufo.setup({
  fold_virt_text_handler = handler,

  provider_selector = function(bufnr, filetype, buftype)
    if buftype == "quickfix" or buftype == "nofile" then
      return { "indent" } -- Use indent folding for non-file buffers
    end

    return { "treesitter", "indent" } -- Use treesitter for file buffers, fallback to indent
  end,
})
