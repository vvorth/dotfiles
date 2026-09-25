-- Selenized Dark, the same palette Ghostty uses (`theme = Selenized Dark`).
-- calind/selenized.nvim is a Lua port of jan-warchol/selenized with treesitter,
-- LSP and gitsigns groups. It is only installed here; config/options.lua picks
-- it (or slate) once it knows whether termguicolors is on, since the port
-- defines gui colours only. The statusline theme is our own:
-- lua/lualine/themes/selenized_dark.lua.
return {
  {
    "calind/selenized.nvim",
    lazy = false,
    priority = 1000,
  },
}
