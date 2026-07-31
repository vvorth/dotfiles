-- ~/.config/nvim/lua/config/autocmds.lua

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "yaml", "json", "html", "css" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})

