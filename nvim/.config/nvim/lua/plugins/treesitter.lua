-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- The main branch "does not support lazy-loading" (its README). An `event =`
  -- here was a no-op anyway: requiring nvim-treesitter.config from `init`
  -- force-loaded the plugin at startup regardless.
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- install() skips parsers that are already there, so this is cheap on a
    -- normal start. markdown_inline is required by render-markdown; toml,
    -- json and javascript match the filetypes conform formats.
    require("nvim-treesitter").install({
      "python", "lua", "bash", "vim", "vimdoc", "regex", "latex", "html", "yaml",
      "markdown", "markdown_inline", "toml", "json", "javascript",
    })

    -- Enable highlighting + treesitter-based indent per-buffer.
    -- This replaces the old `highlight = {enable=true}` / `indent = {enable=true}` opts.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      callback = function(args)
        -- attaches treesitter, disables old regex syntax highlighting; only
        -- swap in treesitter indent where a parser actually attached
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
