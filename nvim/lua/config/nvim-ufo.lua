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

vim.o.statuscolumn =
  '%=%l%s%#FoldColumn#%{foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? "v" : ">") : " " }%*'
-- '%=%l%s%#FoldColumn#%{foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? "v" : ">") : "│" }%*'
-- '%=%l%s%#FoldColumn#%{foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? "▾" : "▸") : " " }%*'
-- '%=%l%s%#FoldColumn#%{foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? "" : "") : " " }%*'
-- %= → 右对齐。
-- %l → 显示当前行号。
-- %s → sign column（诊断标记、git signs 等）。
-- %#FoldColumn# ... %* → 在 fold column 区域显示内容，并应用 FoldColumn 高亮组

vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = "0" -- Show fold column
vim.o.foldlevel = 99 -- Start with all folds open, Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99 -- Start with all folds open
vim.o.foldenable = true -- Enable folding

local handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local totalLines = vim.api.nvim_buf_line_count(0)
  local foldedLines = endLnum - lnum
  local suffix = (" 󰁂 %d %d%%"):format(foldedLines, foldedLines / totalLines * 100)
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

vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    vim.b.ufo_foldlevel = 0
  end,
})

ufo.setup({
  open_fold_hl_timeout = 0,
  fold_virt_text_handler = handler,

  provider_selector = function(bufnr, filetype, buftype)
    if buftype == "quickfix" or buftype == "nofile" then
      return { "indent" } -- Use indent folding for non-file buffers
    end

    return { "treesitter", "indent" } -- Use treesitter for file buffers, fallback to indent
  end,
})

vim.keymap.set("n", "K", function()
  local winid = require("ufo").peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end)
