return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tag, downloads the prebuilt fuzzy-matcher binary
    opts = {
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-@>"] = { "show", "show_documentation", "hide_documentation" },

        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        -- "default" preset:
        --   <C-Space> show menu / toggle docs   <C-y> accept   <C-e> close
        --   <C-n>/<C-p> or <Up>/<Down> select    <C-b>/<C-f> scroll docs
        -- preset = "default",
        -- preset = "enter",
        -- preset = "super-tab",
        -- Fallback for terminals that send Ctrl+Space as NUL
        -- ["<C-@>"] = { "show", "show_documentation", "hide_documentation" },
      },
      completion = {
        -- menu = { auto_show = false }, -- only appears on Ctrl+Space
        menu = {
          auto_show = function()
            return vim.g.blink_auto_show == true
          end,
        },
        documentation = {
          auto_show = true, -- docs panel next to the open menu
          auto_show_delay_ms = 200,
        },
        list = { selection = { preselect = true, auto_insert = false } },
        ghost_text = { enabled = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      signature = { enabled = false },
    },
    config = function(_, opts)
      require("blink.cmp").setup(opts)

      vim.g.blink_auto_show = false -- start with manual-only (Ctrl+Space)

      vim.keymap.set({ "n" }, "<leader>ca", function()
        vim.g.blink_auto_show = not vim.g.blink_auto_show
        if not vim.g.blink_auto_show then
          require("blink.cmp").hide()
        end
        vim.notify("Completion auto-popup: " .. (vim.g.blink_auto_show and "ON" or "OFF"))
      end, { desc = "Toggle completion auto-popup" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
    config = function()
      -- Tell servers blink.cmp's completion capabilities (snippets, docs, etc.)
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            validate = true,
            hover = true,
            completion = true,
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
          },
        },
      })
      vim.lsp.enable({ "yamlls", "bashls", "basedpyright", "lua_ls" })
    end,
  },
}
