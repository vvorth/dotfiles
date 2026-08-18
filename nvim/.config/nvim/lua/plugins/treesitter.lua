-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    -- Enable highlighting + treesitter-based indent per-buffer.
    -- This replaces the old `highlight = {enable=true}` / `indent = {enable=true}` opts.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)  -- attaches treesitter, disables old regex syntax highlighting
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Install parsers, skipping ones already installed (so this doesn't reinstall on every start)
    local ensure_installed = { "python", "lua", "bash", "vim", "vimdoc", "markdown", "regex", "latex", "html", "yaml" }
    local already_installed = require("nvim-treesitter.config").get_installed()
    local to_install = vim.iter(ensure_installed)
      :filter(function(p) return not vim.tbl_contains(already_installed, p) end)
      :totable()
    if #to_install > 0 then
      require("nvim-treesitter").install(to_install)
    end
  end,
}

