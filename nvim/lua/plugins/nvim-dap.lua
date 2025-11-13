-- DAP (Debug Adapter Protocol)

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
    "leoluz/nvim-dap-go",
    "mfussenegger/nvim-dap-python",

    -- -- ==============================================================
    -- -- DAP Virtual Text
    -- -- ==============================================================
    -- {
    --   "theHamsta/nvim-dap-virtual-text",
    --   config = function()
    --     require("nvim-dap-virtual-text").setup()
    --   end,
    -- },

    -- ==============================================================
    -- DAP UI
    -- ==============================================================
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {
        "nvim-neotest/nvim-nio",
      },
      keys = {
        -- stylua: ignore
        { "<leader>du", function() require("dapui").toggle({ reset = true }) end, desc = "[DAP ui] Toggle dapui" },
      },

      config = function()
        local dap, dapui = require("dap"), require("dapui")
        dapui.setup()

        -- 自动开关 DAP UI
        local hide_info = function()
          print("hide")
          vim.diagnostic.enable(false)
          vim.api.nvim_command(":Gitsigns toggle_current_line_blame")
        end

        local show_info = function()
          vim.diagnostic.enable()
          vim.api.nvim_command(":Gitsigns toggle_current_line_blame")
        end

        dap.listeners.after.event_initialized["dapui_config"] = function()
          hide_info()
          dapui.open({})
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          show_info()
          dapui.close({})
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          show_info()
          dapui.close({})
        end
      end,
    },
  },

  keys = {
    -- stylua: ignore
    { "<leader>dc", function() require("dap").continue() end, mode = { "n", "v" }, desc = "[DAP] Continue" },
    -- stylua: ignore
    { "<F5>", function() require("dap").continue() end, mode = { "n", "v" }, desc = "[DAP] Continue" },
    -- stylua: ignore
    { "<leader>db", function() require("dap").toggle_breakpoint() end, mode = { "n", "v" }, desc = "[DAP] Toggle Breakpoint" },
    -- stylua: ignore
    { "<F9>", function() require("dap").toggle_breakpoint() end, mode = { "n", "v" }, desc = "[DAP] Toggle Breakpoint" },
    -- stylua: ignore
    { "<leader>ds", function() require("dap").step_over() end, desc = "[DAP] Step Over" },
    -- stylua: ignore
    { "<F10>", function() require("dap").step_over() end, desc = "[DAP] Step Over" },
    -- stylua: ignore
    { "<leader>di", function() require("dap").step_into() end, desc = "[DAP] Step Into" },
    -- stylua: ignore
    { "<F11>", function() require("dap").step_into() end, desc = "[DAP] Step Into" },
    -- stylua: ignore
    { "<leader>do", function() require("dap").step_out() end, desc = "[DAP] Step Out" },
    -- stylua: ignore
    { "<F12>", function() require("dap").step_out() end, desc = "[DAP] Step Out" },
    -- stylua: ignore
    { "<leader>dt", function() require("dap").terminate() end, desc = "[DAP] Terminate" },
    -- stylua: ignore
    { "<leader>dr", function() require("dap").repl.open() end, desc = "[DAP] Open REPL" },
    -- stylua: ignore
    { "<leader>dl", function() require("dap").run_last() end, desc = "[DAP] Run Last" },
    -- stylua: ignore
    {"<Leader>dp", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "[DAP] Set Log Point" },
  },

  config = function()
    -- Mason-nvim-dap setup
    require("mason-nvim-dap").setup({
      ensure_installed = { "codelldb" },
      handlers = {},
    })

    -- === 启动配置 (Launch Configurations) ===
    -- mason-nvim-dap 已经处理了 adapters，我们只需要定义如何启动程序
    local dap = require("dap")

    -- Go
    require("dap-go").setup()
    -- Python
    require("dap-python").setup("python3")
    -- If using the above, then `python3 -m debugpy --version` must work in the shell
    -- C, C++, Rust
    dap.configurations.cpp = {
      {
        name = "Launch file",
        type = "codelldb", -- mason-nvim-dap 会自动映射到 codelldb
        request = "launch",
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
    -- ‼️ NEW: 定义自定义的 DAP 图标 ‼️
    -- ===================================================================
    local sign = vim.fn.sign_define
    sign("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    sign("DapBreakpointCondition", { text = "󰃤", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    sign("DapLogPoint", { text = "󰌑", texthl = "DapLogPoint", linehl = "", numhl = "" })
    sign("DapRejectedBreakpoint", { text = "󰚦", texthl = "DapRejectedBreakpoint", linehl = "", numhl = "" })
    sign("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
  end,
}
