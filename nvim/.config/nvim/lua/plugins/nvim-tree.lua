-- ~/.config/nvim/lua/plugins/nvim-tree.lua

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- file icons, needs your Nerd Font
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer", icon = { icon = "󰙅 " } },
  },
  opts = {
    view = {
      width = 32,
      side = "left",
    },
    renderer = {
      group_empty = true,       -- collapse nested empty dirs into one line
      highlight_git = true,
      icons = {
        show = { git = true, folder = true, file = true, folder_arrow = true },
      },
    },
    filters = {
      dotfiles = false,          -- set true if you want to hide dotfiles by default
    },
    git = { enable = true, ignore = false },
    actions = {
      open_file = {
        quit_on_open = false,    -- keep nvim-tree shown after opening a file
      },
    },
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")

      -- load nvim-tree's full default keymap set first, so everything else
      -- (v, s, a, d, r, c, x, p, etc.) still works exactly as documented in Part 2
      api.config.mappings.default_on_attach(bufnr)

      local opts = function(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- override: Enter / o / double-click now open in a new tab instead of the last window
      vim.keymap.set("n", "<CR>",          api.node.open.tab, opts("Open in New Tab"))
      vim.keymap.set("n", "o",             api.node.open.tab, opts("Open in New Tab"))
      vim.keymap.set("n", "<2-LeftMouse>", api.node.open.tab, opts("Open in New Tab"))
    end,
  },
}

