-- ~/.config/nvim/lua/plugins/render-markdown.lua
--
-- Two plugins for markdown, both "look at it" aids that must never get in the
-- way of plain editing:
--
--   render-markdown  renders headings/lists/code/tables in place, in Normal
--                    mode only. Insert mode shows the raw source, and the
--                    cursor line is always raw. <leader>mr turns it off.
--   markdown-table-wrap  pipe-table tooling: a wrapped read-only "Reader" view
--                    of the whole document, a per-table float, and Source
--                    editing commands (format/align, add/delete rows and
--                    columns, cell editor). ON DEMAND ONLY here - see below.

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      pipe_table = {
        enabled = true,
        style = "full", -- pad cells with virtual text so columns line up
      },
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Toggle rendering" },
    },
  },

  {
    "ice345/markdown-table-wrap.nvim",
    version = "^1", -- the plugin's own compatibility promise: no breaking changes within 1.x
    ft = { "markdown" },
    opts = {
      -- The stock default (auto_preview = true) swaps *any* markdown buffer
      -- that contains a table for a protected, unlisted "Reader" buffer the
      -- moment it is opened. In there `dd`, `x`, `p` etc. are refused (`y`/`d`
      -- are reserved for the `yic`/`dic` cell operators) and you have to
      -- press `q`/`e`/`i` first to get at the real file. That is why editing
      -- markdown felt broken. With this off nothing happens on its own; the
      -- views and table commands are reached through <leader>m… below.
      auto_preview = false,
    },
    keys = {
      -- stylua: ignore start
      { "<leader>mt", "<cmd>MarkdownTableToggleReader<cr>", ft = "markdown", desc = "Table: rendered view (q/e back)" },
      { "<leader>mp", "<cmd>MarkdownTableFloatPreview<cr>", ft = "markdown", desc = "Table: float preview" },
      { "<leader>mf", "<cmd>MarkdownTableFormat<cr>",       ft = "markdown", desc = "Table: format/align source" },
      { "<leader>me", "<cmd>MarkdownTableEditCell<cr>",     ft = "markdown", desc = "Table: edit cell (C-s save)" },
      { "<leader>ma", "<cmd>MarkdownTableAddRow<cr>",       ft = "markdown", desc = "Table: add row" },
      { "<leader>mA", "<cmd>MarkdownTableAddColumn<cr>",    ft = "markdown", desc = "Table: add column" },
      { "<leader>md", "<cmd>MarkdownTableDeleteRow<cr>",    ft = "markdown", desc = "Table: delete row" },
      { "<leader>mD", "<cmd>MarkdownTableDeleteColumn<cr>", ft = "markdown", desc = "Table: delete column" },
      { "<leader>mh", "<cmd>MarkdownTableHelp<cr>",         ft = "markdown", desc = "Table: help" },
      { "]c", "<cmd>MarkdownTableNextCell<cr>", ft = "markdown", desc = "Table: next cell" },
      { "[c", "<cmd>MarkdownTablePrevCell<cr>", ft = "markdown", desc = "Table: previous cell" },
      -- stylua: ignore end
    },
  },
}
