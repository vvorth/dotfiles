-- ~/.config/nvim/lua/plugins/noice.lua

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",   -- UI primitives noice is built on
    -- "rcarriga/nvim-notify",   -- nicer notification popups (optional but common pairing)
  },
  opts = {
    lsp = {
      -- override markdown rendering for LSP hover/signature popups
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    presets = {
      -- bottom_search = true,         -- classic bottom cmdline for search (/ and ?)
      command_palette = true,       -- position cmdline + popupmenu centrally, together
      long_message_to_split = true, -- long messages go to a split, not a wall of text
      lsp_doc_border = true,        -- border around LSP hover docs
    },
    views = {
      -- shrink the shared "notify" view's footprint (passed through to nvim-notify)
      -- notify = {
      --   timeout = 3000,
      --   -- max_width = 40,
      --   -- max_height = 6,
      --   render = "compact",  -- nvim-notify render styles: default | minimal | simple | compact | wrapped-compact
      -- },
      -- test 
      -- cmdline_popup = {
      --   position = { row = "25%", col = "50%" },
      -- },
    },
    routes = {
      { filter = { cmdline = "^:!" }, view = "split" },
    },
    -- test
    notify = { enabled = false },
    messages = { enabled = false },
    popupmenu = { enabled = true, backend = "nui" }, -- completion menu
    cmdline = { enabled = true, view = "cmdline_popup" },
  },
}

