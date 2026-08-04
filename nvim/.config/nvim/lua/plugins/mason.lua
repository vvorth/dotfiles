-- ~/.config/nvim/lua/plugins/mason.lua


return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- formatters
        "stylua",     -- Lua — for the config files you've been writing all guide
        "shfmt",      -- bash/shell — relevant given your sysadmin workflow
        "prettier",   -- JS/TS/JSON/YAML/HTML/CSS/Markdown, the broad web-stack catch-all
        "ruff",       -- Python — includes ruff's formatter; swap for "black" if you
                      -- need to match an existing project's convention instead
        -- feel free to also list LSP servers / linters here later — this plugin
        -- installs anything Mason knows about, not just formatters
      },
      auto_update = false,   -- set true if you want it to also keep tools up to date on startup
      run_on_start = true,
    },
  },
}
