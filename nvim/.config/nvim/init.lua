
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd("source ~/.vimrc")

-- Load Lua config
require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- 3. Install and Configure Plugins
-- require("lazy_init")
-- Override vim.ui.open on headless SSH sessions to suppress warnings
vim.ui.open = function(path)
  -- If you want it to at least try printing the URL/path to the screen:
  print("Open target: " .. path)
end


