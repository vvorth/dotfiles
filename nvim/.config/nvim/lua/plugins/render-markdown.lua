return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    config = function()
      require("render-markdown").setup({
        pipe_table = {
          -- Ensure render-markdown's built-in table features are enabled
          enabled = true,
          style = "full",
        },
      })
    end,
  },

  -- The dedicated table cell wrapping companion plugin
  {
    "ice345/markdown-table-wrap.nvim",
    ft = "markdown",
    dependencies = { "MeanderingProgrammer/render-markdown.nvim" },
    config = function()
      require("markdown-table-wrap").setup({
        -- Configuration options (leave empty for defaults)
      })
    end,
  },
}
