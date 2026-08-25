return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-mini/mini.icons" }, -- Establish the dependency
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
      },
      sections = {
        lualine_c = {
          -- The 'filetype' and 'filename' components will now use mini.icons automatically
          { "filetype", icon_only = false },
          { "filename", path = 1 },
        },
      },
    },
  },
}
