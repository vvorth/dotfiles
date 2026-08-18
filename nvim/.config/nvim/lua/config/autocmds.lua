-- ~/.config/nvim/lua/config/autocmds.lua

-- Unlike Vim, Neovim doesn't restore the cursor to its last position on
-- reopen by default (github.com/neovim/neovim/issues/16339 is still open).
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Jump to the last known cursor position when reopening a file",
  callback = function(args)
    local excluded_ft = { xxd = true, gitrebase = true, tutor = true }
    local ft = vim.bo[args.buf].filetype
    local last_pos = vim.fn.line("'\"")
    if
      last_pos >= 1
      and last_pos <= vim.fn.line("$")
      and not ft:match("commit")
      and not excluded_ft[ft]
      and not vim.wo.diff
    then
      vim.cmd('normal! g`"')
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "yaml", "json", "html", "css" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})

