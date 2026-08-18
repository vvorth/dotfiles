-- ~/.config/nvim/lua/plugins/snacks-scroll.lua

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    scroll = {
      animate = {
        duration = { step = 10, total = 200 },
        easing = "linear",
      },
    },
    picker = { enabled = true },
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    indent = { enabled = true },
  },
  keys = {
    {
      "<leader>ug",
      function() Snacks.toggle.indent():toggle() end,
      desc = "Toggle Indent Guides",
    },
  },
}

