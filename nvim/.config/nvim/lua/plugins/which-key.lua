-- ~/.config/nvim/lua/plugins/which-key.lua

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern", -- "classic", "modern", or "helix" layout preset
    delay = 1000, -- ms to wait before popup shows (lower = snappier, more intrusive)
    win = {
      width = 40, -- narrow width = forces single column (not enough room for a 2nd)
      height = { min = 4, max = 30 },
      col = vim.o.columns - 42, -- right edge of the whole editor...
      row = 1, -- ...near the top, running down the right side
      border = "rounded",
      title = true,
      title_pos = "center",
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
      -- icon = "? ",
    },
  },
}
