return {
  "nvim-pack/nvim-spectre",
  cmd = { "Spectre" },
  keys = {
    { "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', desc = "[Spectre] Toggle search panel" },
    { "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc = "[Spectre] Search current word" },
    { "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', mode = "v", desc = "[Spectre] Search selection" },
    { "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', desc = "[Spectre] Search in file" },
  },
  opts = {
    open_cmd = "noswapfile vnew",
  },
}
