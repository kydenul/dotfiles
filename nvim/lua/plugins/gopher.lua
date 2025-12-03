-- NOTE: this plugin is already lazy-loaded and adds only about 1ms
-- of load time to your config

return {
  "olexsmir/gopher.nvim",
  ft = "go",
  -- branch = "develop"
  -- (optional) updates the plugin's dependencies on each update
  build = function()
    vim.cmd.GoInstallDeps()
  end,
  ---@module "gopher"
  ---@type gopher.Config
  opts = {},
}
