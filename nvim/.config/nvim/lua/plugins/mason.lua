-- ~/.config/nvim/lua/plugins/mason.lua


return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- formatters
        "stylua",     -- Lua
        "shfmt",      -- bash/shell
        "prettier",   -- JS/TS/JSON/YAML/HTML/CSS/Markdown
        "ruff",       -- Python (swap for "black" to match a project's convention)
        "taplo",      -- TOML
        -- LSP servers / linters can also go in this list — this plugin
        -- installs anything Mason knows about, not just formatters
          "tree-sitter-cli",
      },
      auto_update = false,   -- set true if you want it to also keep tools up to date on startup
      run_on_start = true,
    },
  },
}
