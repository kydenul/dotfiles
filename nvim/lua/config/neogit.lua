-- Neogit

local util = require("util")
local ok, neogit = pcall(require, "neogit")
if not ok then
  util.log_warn("neogit init failed.")
  return
end

neogit.setup({})
