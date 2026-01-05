-- render-markdown.nvim: Beautiful markdown rendering

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "Avante" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",

    {
      "AndrewRadev/switch.vim",
      config = function()
        --stylua: ignore
        vim.keymap.set("n", "`", function() vim.cmd([[Switch]]) end, { desc = "Switch strings" })
        vim.g.switch_custom_definitions =
          { { "> [!TODO]", "> [!WIP]", "> [!DONE]", "> [!FAIL]" }, { "height", "width" } }
      end,
    },

    -- Image Clip For Markdown
    {
      "HakonHarnes/img-clip.nvim",
      ft = { "tex", "markdown" },
      opts = {
        default = {
          dir_path = "./images",
          use_absolute_path = false,
          copy_images = true,
          prompt_for_file_name = false,
          file_name = "img-%y%m%d-%H%M%S",
        },

        filetypes = {
          markdown = { template = "![image$CURSOR]($FILE_PATH)" },
          tex = {
            dir_path = "./figs",
            extension = "png",
            process_cmd = "",
            template = [[
              \begin{figure}[h]
              \centering
              \includegraphics[width=0.8\textwidth]{$FILE_PATH}
              \end{figure}
            ]], ---@type string | fun(context: table): string
          },
        },
      },
      keys = { { "<leader>P", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" } },
    },

    {
      "3rd/diagram.nvim",
      dependencies = {
        -- ==============================================================
        -- Image Preview
        -- ==============================================================
        {
          "3rd/image.nvim",
          build = false,
          opts = {
            backend = "kitty", -- XXX
            processor = "magick_cli", -- XXX
            integrations = {
              markdown = {
                only_render_image_at_cursor = true,
                only_render_image_at_cursor_mode = "inline", -- "popup" or "inline"
              },
            },
          },
        },
      },

      opts = {
        -- Disable automatic rendering for manual-only workflow
        events = {
          render_buffer = { "InsertLeave", "BufWinEnter", "TextChanged" }, -- Empty = no automatic rendering
          clear_buffer = { "BufLeave" },
        },
        renderer_options = {
          mermaid = {
            background = "transparent", -- nil | "transparent" | "white" | "#hex"
            theme = "dark", -- "dark",
            scale = 2,
            cli_args = { "--no-sandbox" }, -- nil | { "--no-sandbox" } | { "-p", "/path/to/puppeteer" } | ...
          },

          plantuml = {
            charset = "utf-8",
            cli_args = nil, -- nil | { "-Djava.awt.headless=true" } | ...
          },
        },
      },
      keys = {
        {
          "<leader>m",
          function()
            require("diagram").show_diagram_hover()
          end,
          mode = "n",
          ft = { "markdown", "norg" },
          desc = "Show diagram in new tab",
        },
      },
    },
  },

  opts = {
    callout = {
      abstract = {
        raw = "[!ABSTRACT]",
        rendered = "󰯂 Abstract",
        highlight = "RenderMarkdownInfo",
        category = "obsidian",
      },

      summary = {
        raw = "[!SUMMARY]",
        rendered = "󰯂 Summary",
        highlight = "RenderMarkdownInfo",
        category = "obsidian",
      },

      tldr = { raw = "[!TLDR]", rendered = "󰦩 Tldr", highlight = "RenderMarkdownInfo", category = "obsidian" },
      failure = {
        raw = "[!FAILURE]",
        rendered = " Failure",
        highlight = "RenderMarkdownError",
        category = "obsidian",
      },

      fail = { raw = "[!FAIL]", rendered = " Fail", highlight = "RenderMarkdownError", category = "obsidian" },
      missing = {
        raw = "[!MISSING]",
        rendered = " Missing",
        highlight = "RenderMarkdownError",
        category = "obsidian",
      },
      attention = {
        raw = "[!ATTENTION]",
        rendered = " Attention",
        highlight = "RenderMarkdownWarn",
        category = "obsidian",
      },
      warning = { raw = "[!WARNING]", rendered = " Warning", highlight = "RenderMarkdownWarn", category = "github" },
      danger = { raw = "[!DANGER]", rendered = " Danger", highlight = "RenderMarkdownError", category = "obsidian" },
      error = { raw = "[!ERROR]", rendered = " Error", highlight = "RenderMarkdownError", category = "obsidian" },
      bug = { raw = "[!BUG]", rendered = " Bug", highlight = "RenderMarkdownError", category = "obsidian" },
      quote = { raw = "[!QUOTE]", rendered = " Quote", highlight = "RenderMarkdownQuote", category = "obsidian" },
      cite = { raw = "[!CITE]", rendered = " Cite", highlight = "RenderMarkdownQuote", category = "obsidian" },
      todo = { raw = "[!TODO]", rendered = " Todo", highlight = "RenderMarkdownInfo", category = "obsidian" },
      wip = { raw = "[!WIP]", rendered = "󰦖 WIP", highlight = "RenderMarkdownHint", category = "obsidian" },
      done = { raw = "[!DONE]", rendered = " Done", highlight = "RenderMarkdownSuccess", category = "obsidian" },
    },

    code = {
      -- general
      width = "block",
      min_width = 120,

      -- borders
      -- border = "thin",
      left_pad = 1,
      right_pad = 1,

      -- language info
      position = "left",
      language_icon = true,
      language_name = true,

      -- avoid making headings ugly
      highlight_inline = "RenderMarkdownCodeInfo",
    },

    heading = {
      icons = { " 󰼏 ", " 󰎨 ", " 󰼑 ", " 󰎲 ", " 󰼓 ", " 󰎴 " },
      border = true,
      render_modes = true, -- keep rendering while inserting
    },

    checkbox = {
      unchecked = {
        icon = "󰄱",
        highlight = "RenderMarkdownCodeFallback",
        scope_highlight = "RenderMarkdownCodeFallback",
      },
      checked = {
        icon = "󰄵",
        highlight = "RenderMarkdownUnchecked",
        scope_highlight = "RenderMarkdownUnchecked",
      },
      custom = {
        question = {
          raw = "[?]",
          rendered = "",
          highlight = "RenderMarkdownError",
          scope_highlight = "RenderMarkdownError",
        },
        todo = {
          raw = "[>]",
          rendered = "󰦖",
          highlight = "RenderMarkdownInfo",
          scope_highlight = "RenderMarkdownInfo",
        },
        canceled = {
          raw = "[-]",
          rendered = "",
          highlight = "RenderMarkdownCodeFallback",
          scope_highlight = "@text.strike",
        },
        important = {
          raw = "[!]",
          rendered = "",
          highlight = "RenderMarkdownWarn",
          scope_highlight = "RenderMarkdownWarn",
        },
        favorite = {
          raw = "[~]",
          rendered = "",
          highlight = "RenderMarkdownMath",
          scope_highlight = "RenderMarkdownMath",
        },
      },
    },

    pipe_table = {
      alignment_indicator = "─",
      border = { "╭", "┬", "╮", "├", "┼", "┤", "╰", "┴", "╯", "│", "─" },
    },

    link = {
      wiki = { icon = " ", highlight = "RenderMarkdownWikiLink", scope_highlight = "RenderMarkdownWikiLink" },
      image = " ",
      custom = {
        github = { pattern = "github", icon = " " },
        gitlab = { pattern = "gitlab", icon = "󰮠 " },
        youtube = { pattern = "youtube", icon = " " },
        cern = { pattern = "cern.ch", icon = " " },
      },
      hyperlink = " ",
    },

    anti_conceal = {
      disabled_modes = { "n" },
      ignore = {
        bullet = true, -- render bullet in insert mode
        head_border = true,
        head_background = true,
      },
    },

    -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/509
    win_options = { concealcursor = { rendered = "nvc" } },

    completions = {
      blink = { enabled = true },
      lsp = { enabled = true },
    },

    sign = {
      -- Turn on / off sign rendering.
      enabled = true,
      -- Applies to background of sign text.
      highlight = "RenderMarkdownSign",
    },
  },
}
