
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd("source ~/.vimrc")

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH


-- Load Lua config
require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- 3. Install and Configure Plugins
-- require("lazy_init")
-- Override vim.ui.open on SSH sessions: opening a browser over SSH just
-- errors, so print the target instead. Local sessions keep the
-- vim.notify-based override from config.options (works well with noice).
if os.getenv("SSH_TTY") or os.getenv("SSH_CONNECTION") then
  vim.ui.open = function(path)
    print("Open target: " .. path)
    return {}, nil
  end
end


