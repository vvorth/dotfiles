-- ~/.config/nvim/lua/config/keymaps.lua

local wk = require("which-key")

wk.add({
  -- register the groups first (this is what gives you the labeled headers)
  { "<leader>f", group = "File",                 icon = { icon = "󰈞 " } },
  { "<leader>b", group = "Buffer",               icon = { icon = "󰓩 " } },
  { "<leader>c", group = "Code" },
  { "<leader>w", group = "Window",               icon = { icon = "󰉐 " } },
  { "<leader>q", group = "Quit/Session",         icon = { icon = "󰗼 " } },
  { "<leader>e", desc = "Toggle File Explorer",  icon = { icon = "󰙅 " } },
  { "<leader>l", "<cmd>Lazy<cr>", desc = "Lazy", icon = { icon = "󰒲 " } },

  -- { "<leader>?", "<cmd><cr>", desc = "Which-Key all", icon = { icon = "? " } },

  -- Code
  { "<leader>cr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Render", icon = { icon = " " } },

  -- File
  { "<leader>fs", "<cmd>write<cr>",  desc = "Save File",           icon = { icon = "󰆓 " } },
  { "<leader>fe", "<cmd>edit .<cr>", desc = "Explore Current Dir", icon = { icon = "󰉋 " } },

  -- Buffer
  { "<leader>bd", "<cmd>bdelete<cr>",   desc = "Delete Buffer",    icon = { icon = "󰆴 " } },
  { "<leader>bn", "<cmd>bnext<cr>",     desc = "Next Buffer",      icon = { icon = "󰒭 " } },
  { "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous Buffer",  icon = { icon = "󰒮 " } },
  { "<leader>bl", "<cmd>ls<cr>",        desc = "List Buffers",     icon = { icon = "󰓩 " } },
  { "<leader>bb", "<cmd>b#<cr>",        desc = "To Recent Buffer", icon = { icon = "󰦨 " } },

  -- Window
  { "<leader>wv", "<cmd>vsplit<cr>",  desc = "Split Vertical",   icon = { icon = "󰤼 " } },
  { "<leader>wh", "<cmd>split<cr>",   desc = "Split Horizontal", icon = { icon = "󰤻 " } },
  { "<leader>wd", "<cmd>close<cr>",   desc = "Close Window",     icon = { icon = "󰖭 " } },

  -- Quit
  { "<leader>qq", "<cmd>quitall<cr>", desc = "Quit All", icon = { icon = "󰗼 " } },
})

