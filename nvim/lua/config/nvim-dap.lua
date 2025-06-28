local dap = require("dap")

-- === 启动配置 (Launch Configurations) ===
-- mason-nvim-dap 已经处理了 adapters，我们只需要定义如何启动程序

-- Python
dap.configurations.python = {
  {
    type = "python", -- mason-nvim-dap 会自动映射到 debugpy
    request = "launch",
    name = "Launch file",
    program = "${file}", -- 调试当前文件
    pythonPath = function()
      return vim.fn.input("Path to python executable: ", "python", "file")
    end,
  },
}

-- Go
dap.configurations.go = {
  {
    type = "delve", -- mason-nvim-dap 会自动映射到 delve
    request = "launch",
    name = "Launch file",
    program = "${fileDirname}", -- 调试当前文件所在的目录
  },
}

-- C, C++, Rust
dap.configurations.cpp = {
  {
    type = "codelldb", -- mason-nvim-dap 会自动映射到 codelldb
    request = "launch",
    name = "Launch file",
    program = function()
      -- 编译后，手动输入可执行文件路径
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}
-- C++ 和 Rust 可以共用一套配置
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- ===================================================================
-- ‼️ NEW: Keymappings ‼️
-- ===================================================================
vim.keymap.set({ "n", "v" }, "<leader>dc", dap.continue, { desc = "DAP: Continue" })
vim.keymap.set({ "n", "v" }, "<F5>", dap.continue, { desc = "DAP: Continue" })

vim.keymap.set({ "n", "v" }, "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set({ "n", "v" }, "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })

vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "DAP: Step Over" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })

vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step Into" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })

vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "DAP: Step Out" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP: Step Out" })

vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run Last" })
vim.keymap.set("n", "<Leader>dp", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "DAP: Set Log Point" })

-- ===================================================================
-- ‼️ NEW: 定义自定义的 DAP 图标 ‼️
-- ===================================================================
local sign = vim.fn.sign_define
sign("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
sign("DapBreakpointCondition", { text = "󰃤", texthl = "DapBreakpoint", linehl = "", numhl = "" })
sign("DapLogPoint", { text = "󰌑", texthl = "DapLogPoint", linehl = "", numhl = "" })
sign("DapRejectedBreakpoint", { text = "󰚦", texthl = "DapRejectedBreakpoint", linehl = "", numhl = "" })
sign("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
