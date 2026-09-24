
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH


-- Load Lua config
require("config.lazy")
require("config.options")
require("config.autocmds")
-- config.keymaps is a which-key spec, loaded from plugins/which-key.lua


