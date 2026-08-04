# Manual Neovim Setup — LazyVim Features, Built by Hand

Goal: keep your existing `vimrc`-derived config as the base, layer in a plugin manager,
and manually wire up the specific LazyVim-like features you asked for:

1. Command-line popup with autocomplete (commands, shell, paths)
2. `which-key` menu, explained in depth
3. Indent guides (vertical bars with highlight)
4. Smooth scrolling
5. A short list of other "go-to" plugins worth knowing about

Everything below assumes **Neovim ≥ 0.9** (0.10+ preferred) and Lua config, since that's
what all modern plugins target. Your sourced `vimrc` can stay as-is — Lua and Vimscript
coexist fine in the same config.

---

## 0. Prerequisites

Check your Neovim version first:

```bash
nvim --version
```

You want 0.9 or newer (0.10+ ideally). If your distro's package is old, install via the
Neovim PPA/AppImage/release tarball instead of `apt install neovim` — Ubuntu repos lag
badly.

Install these system tools — nearly every plugin below assumes at least one of them:

```bash
sudo apt install ripgrep fd-find git curl unzip build-essential
```

- `ripgrep` (`rg`) — used by fuzzy finders for live grep
- `fd` — faster `find`, used for file search
- A **Nerd Font** — required for the icons you'll see in file explorers, statuslines,
  which-key, etc. Install one (e.g. `JetBrainsMono Nerd Font`) and set it as your
  terminal's font: https://www.nerdfonts.com/font-downloads
- `node` (optional but common) — some LSP servers (bash, json, yaml, etc.) are npm
  packages under the hood, installed via Mason (see §6).

---

## 1. Directory structure & bootstrapping `lazy.nvim`

LazyVim's "batteries included" feel comes from `lazy.nvim`, the plugin manager. We'll use
the same one, but configure it ourselves.

Your config lives at `~/.config/nvim/`. Target structure:

```
~/.config/nvim/
├── init.lua                  -- entry point, loads everything else
├── lua/
│   ├── config/
│   │   ├── lazy.lua           -- bootstraps and configures lazy.nvim
│   │   ├── options.lua        -- vim.opt settings
│   │   ├── keymaps.lua        -- your custom keymaps
│   │   └── autocmds.lua       -- autocommands
│   └── plugins/
│       ├── noice.lua          -- one file per plugin/feature
│       ├── which-key.lua
│       ├── indent.lua
│       ├── scroll.lua
│       └── ...
└── vimrc.vim (or your old .vimrc, sourced from init.lua)
```

This mirrors how LazyVim itself is organized — every file in `lua/plugins/` is
auto-loaded, so adding a plugin later is just "drop a new file in that folder."

### 1a. `init.lua`

```lua
-- ~/.config/nvim/init.lua

-- Keep your existing vim config working
vim.cmd("source ~/.vimrc")  -- adjust path if yours lives elsewhere

-- Load Lua config
require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")
```

> If your old vimrc sets things like `leader key`, make sure it's set **before**
> `lazy.lua` loads, since plugin keymaps often reference `<leader>`. Easiest fix: put
> `let mapleader = " "` (or whatever key you use) at the very top of your vimrc.

### 1b. Bootstrap `lazy.nvim`

```lua
-- ~/.config/nvim/lua/config/lazy.lua

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },  -- auto-loads every file in lua/plugins/
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true, notify = false }, -- auto-check for plugin updates
  change_detection = { notify = false },
})
```

Open `nvim` once — it'll clone `lazy.nvim` itself and show an empty plugin manager UI.
Run `:Lazy` any time to see installed plugins, updates, and load times. This single
command becomes your plugin dashboard for everything from here on.

---

## 2. Command popup with autocomplete (commands + shell/paths)

This is the "type `:` and get a floating popup with fuzzy suggestions, path completion,
command history" experience. LazyVim achieves this with two plugins working together:

- **`noice.nvim`** — replaces the command line and messages UI with floating windows
- **`nvim-cmp`** + **`cmp-cmdline`** — provides the actual *completion source* (commands,
  filesystem paths, shell history) that noice's popup displays

They're separable: noice is the *visual* layer, cmp-cmdline is the *intelligence* layer.
You need both for the full LazyVim-like feel.

### 2a. Install `noice.nvim`

```lua
-- ~/.config/nvim/lua/plugins/noice.lua

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",   -- UI primitives noice is built on
    "rcarriga/nvim-notify",   -- nicer notification popups (optional but common pairing)
  },
  opts = {
    lsp = {
      -- override markdown rendering for LSP hover/signature popups
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    presets = {
      bottom_search = true,         -- classic bottom cmdline for search (/ and ?)
      command_palette = true,       -- position cmdline + popupmenu centrally, together
      long_message_to_split = true, -- long messages go to a split, not a wall of text
      lsp_doc_border = true,        -- border around LSP hover docs
    },

    -- Message/notification routing. Both `messages` and `notify` have separate
    -- view/view_error/view_warn sub-keys — setting only `view` leaves errors and
    -- warnings on their own internal default ("notify", the bigger top-right box)
    -- regardless of what you set `view` to. Set all three explicitly so every
    -- message kind (plain, warning, error) renders identically.
    messages = {
      enabled = true,
      view = "notify",         -- was "mini" — switched to match view_error/view_warn below
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",  -- feeds :Noice / :Noice history
      view_search = "virtualtext", -- keep search match-count inline, not swept into this
    },
    notify = {
      enabled = true,
      view = "notify",         -- was "mini" — same reasoning, keeps vim.notify() calls consistent
    },

    -- Belt-and-suspenders: force every message/notification onto the same view
    -- regardless of any other internal default that might still diverge by kind.
    routes = {
      { filter = { event = "notify" },   view = "notify" },
      { filter = { event = "msg_show" }, view = "notify" },
    },

    views = {
      -- shrink the shared "notify" view's footprint (passed through to nvim-notify)
      notify = {
        timeout = 3000,
        max_width = 40,
        max_height = 6,
        render = "compact",  -- nvim-notify render styles: default | minimal | simple | compact | wrapped-compact
      },
    },
  },
}
```

**Testing this:** rerun the same five commands from before — they should now all render
identically (top-right, compact box), and all five should show up together in `:Noice`
or `:Noice history` going forward. That's the right place to check message history now;
native `:messages` isn't reliable once noice owns the pipeline (covered earlier in this
guide), so `:Noice`/`:Noice history` fully replaces it rather than supplementing it.

```
:lua vim.notify("Test info notification", vim.log.levels.INFO)
:lua vim.notify("Test warning", vim.log.levels.WARN)
:lua vim.notify("Test error notification", vim.log.levels.ERROR)
:echom "Test classic message"
:echoerr "Test echoerr"
:Noice history
```

If `render = "compact"` looks too sparse (drops the icon/title), try `"minimal"` instead
— it keeps a bit more structure while still being noticeably smaller than the default
bordered box.

`command_palette = true` is the key option — it's what gives you the centered popup
where you type `:` and see a floating box with suggestions dropping below it, closest
to the LazyVim/VS Code-command-palette feel.

### 2b. Wire up cmdline autocomplete with `nvim-cmp`

`nvim-cmp` is the general-purpose completion engine (also used for LSP/code completion,
see §6). For the *command-line* piece specifically:

```lua
-- ~/.config/nvim/lua/plugins/cmp-cmdline.lua

return {
  "hrsh7th/nvim-cmp",
  event = "VeryLazy",
  dependencies = {
    "hrsh7th/cmp-cmdline",  -- : and / completion source
    "hrsh7th/cmp-path",     -- filesystem path completion
    "hrsh7th/cmp-buffer",   -- words from open buffers
  },
  config = function()
    local cmp = require("cmp")

    -- Autocomplete for search (/ and ?) — suggests from buffer + history
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })

    -- Autocomplete for command mode (:) — commands, then paths once you're in
    -- a command that expects a file (:e, :w, :saveas, etc.)
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },      -- filesystem paths, tab-completes directories
        { name = "cmdline" },   -- ex-commands (:Telescope, :split, :LspInfo, etc.)
      }),
      matching = { disallow_symbol_nonprefix_matching = false },
    })
  end,
}
```

With this: type `:e ` and you get path/file suggestions; type `:sp` and you get matching
ex-commands. Tab/Shift-Tab cycles suggestions, Enter accepts.

**What this doesn't cover:** actual shell command completion (i.e. typing `:!ls -` and
getting bash-style flag completion) isn't something cmp-cmdline does out of the box —
that's genuinely closer to a shell's job. If you want that specifically, see the
alternative below.

### 2c. Alternative: `wilder.nvim`

If noice+cmp feels heavier than you want, **`wilder.nvim`** is a purpose-built cmdline
completion popup (inspired by fish shell) — narrower in scope than noice, but does the
"popup with fuzzy suggestions as you type `:`" job on its own, no cmp dependency needed.
Worth trying if you find noice's scope (it also touches messages/LSP UI) more than you
wanted. You'd pick **one or the other**, not both, for cmdline duty.

---

## 3. `which-key.nvim` — the leader-key cheat sheet

**What it does:** the moment you press a prefix key (like `<leader>` = spacebar in most
configs) and pause, a popup appears at the bottom of the screen listing every keymap
that starts with what you've typed so far, grouped and labeled. Press the next key from
the list, or keep typing — it's not a menu you click, it's a live-updating hint.

This is arguably the single most useful "vim is more discoverable now" plugin — before
which-key, you either memorized every mapping or grep'd your config to remember one.

### 3a. Install

```lua
-- ~/.config/nvim/lua/plugins/which-key.lua

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    win = {
      width = 40,                    -- narrow width = forces single column (not enough room for a 2nd)
      height = { min = 4, max = 30 },
      col = vim.o.columns - 42,      -- plain number: right edge minus width minus a little padding
      row = 1,                       -- near the top, running down the right side
      border = "rounded",
      title = true,
      title_pos = "center",
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
```

A couple of notes on this:

- `col` is computed **once**, as a plain Lua expression, when your config file loads at
  Neovim startup — `vim.o.columns - 42` isn't a live-updating function, it's arithmetic
  that runs immediately and produces a fixed number. `win.col`/`win.row` in which-key
  don't accept functions (unlike `desc`/`group`/`icon` elsewhere in the config, which
  do) — passing a function there is what caused the `bad argument #1 to 'abs'` error,
  since which-key's layout code calls `math.abs()` directly on whatever you give it,
  expecting a number. In practice this is fine for almost all sessions, since your
  terminal is already sized by the time Neovim starts — the only edge case is resizing
  your terminal window *during* the session, which won't retroactively move the popup.
- `no_overlap = true` (which-key's default, left untouched here) still applies, so if
  your cursor happens to be near the right edge already, which-key will nudge the popup
  to avoid covering it — that's expected, not a bug.
- Quick alternative worth trying first: just set `preset = "helix"` instead of
  `"modern"` — it already positions the popup bottom-right, mimicking the Helix
  editor's own keyhint UI, which gets you most of the way there with zero manual
  col/row math. The `win` overrides above are for when you want it pinned along the
  full right edge specifically, not just bottom-right.

**General tip for next time:** when an error flashes by too fast to read, `:messages`
inside Neovim shows the full message/error history for the session, stack trace
included — that's the fastest way to get the complete text without needing to reproduce
the error again.

## 2. Navigating it like an arrow-key menu

Worth being upfront about this one: **which-key fundamentally doesn't work that way**,
and there's no config option that makes it. Its entire interaction model — confirmed
straight from its own usage docs — is "press the actual key to open a group or run the
binding," not "highlight an item and press Enter." There's no cursor to move with
arrows/`j`/`k` inside the popup, no selectable list state at all. `<C-d>`/`<C-u>` scroll
the *view* when the list is long (which is what you fixed earlier), but that's paging
through entries you're still selecting by typing their key, not moving a highlight.

If what you actually want is a genuine arrow-navigable, Enter-to-execute picker over
your keymaps, that's a different tool doing a different job — two real options:

- **`:Telescope keymaps`** — if you already have Telescope installed (§6 of Part 1),
  this is free: it lists every keymap, fuzzy-searchable, `j`/`k`/arrows to move,
  `<CR>` to execute the highlighted one. Bind it if you want quick access:
  `vim.keymap.set("n", "<leader>?", "<cmd>Telescope keymaps<cr>", { desc = "Search Keymaps" })`
- **`mrjones2014/legendary.nvim`** — a dedicated "command palette" plugin: same
  arrow-navigate-and-confirm interaction, but purpose-built for this (also surfaces
  commands and autocmds alongside keymaps, not just keymaps).

Neither replaces which-key's actual job (contextual hints as you type a prefix) — they're
closer to a searchable index you'd reach for occasionally ("what was that keymap again?"),
while which-key stays running passively in the background for the moment-to-moment nudge.
Keeping both isn't redundant; they solve different problems.

That alone gets you a *functional* which-key: any keymap you already define (via
`vim.keymap.set`) will automatically show up grouped by its prefix. No further config
required for it to "work" — but it's much more useful once you name your groups.

### 3b. Naming groups (this is the part that makes it look like LazyVim)

Without group names, `<leader>f...` mappings just show raw descriptions in a flat list.
LazyVim's polish comes from **registering group labels**, so pressing `<leader>f` shows
a header like "Find" before listing `f`ile, `g`rep, `b`uffers, etc.

```lua
-- add to lua/config/keymaps.lua, or a dedicated lua/config/whichkey-groups.lua

local wk = require("which-key")

wk.add({
  { "<leader>f", group = "Find" },
  { "<leader>g", group = "Git" },
  { "<leader>b", group = "Buffers" },
  { "<leader>c", group = "Code" },
  { "<leader>w", group = "Window" },
  { "<leader>x", group = "Diagnostics/Quickfix" },
})
```

Then define actual keymaps normally, with a `desc` — which-key reads `desc` directly
from `vim.keymap.set`:

```lua
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",  { desc = "Live Grep" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>",              { desc = "Delete Buffer" })
```

Result: press `<space>`, pause → popup shows `f → Find`, `g → Git`, `b → Buffers`...
Press `f` → popup updates to show `f → Find Files`, `g → Live Grep`... This nested
disclosure *is* the LazyVim experience, and it's just this pattern repeated for every
mapping you own.

**Practical tip for a sysadmin workflow:** as you build out remote/tmux/terminal
keymaps, give them their own group (e.g. `<leader>t` = "Terminal") rather than bolting
them onto an existing one — which-key's value drops fast if groups get overloaded.

---

## 4. Indent guides (vertical bars with highlight)

Plugin: **`indent-blankline.nvim`** (import name `ibl`, this is v3 — the API changed
significantly from v2, so make sure any tutorial you read is v3-era).

```lua
-- ~/.config/nvim/lua/plugins/indent.lua

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    indent = {
      char = "│",              -- the vertical bar character; try "┊" or "¦" for dotted style
      highlight = { "IndentBlanklineChar" },
    },
    scope = {
      enabled = true,           -- highlight the *current* indent scope differently
      show_start = true,        -- underline the scope's starting line
      show_end = false,
      highlight = { "IndentBlanklineContextChar" },
    },
    exclude = {
      filetypes = { "help", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
    },
  },
  config = function(_, opts)
    -- Define the highlight colors (link to your colorscheme's palette, or set explicit colors)
    vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#3b4048", nocombine = true })
    vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#61afef", nocombine = true })
    require("ibl").setup(opts)
  end,
}
```

`scope.enabled = true` is what gives you the LazyVim look specifically — it highlights
the indent guide of the code block your cursor is currently inside in a distinct color
(needs Treesitter installed, see §6, since it detects "scope" via the syntax tree, not
just whitespace).

---

## 5. Smooth scrolling

**Recommended: `snacks.nvim`'s `scroll` module.** This supersedes the neoscroll config
below — same visual result, but architecturally avoids the which-key conflict entirely
rather than working around it. Worth understanding why: neoscroll (and most smooth-
scroll plugins) work by **remapping `<C-d>`/`<C-u>` etc. as actual keymaps** that run an
animated version of the scroll. That's exactly what put them in a race with which-key's
own use of those same keys for popup pagination. `snacks.nvim`'s scroll module takes a
different approach — it doesn't map any keys itself at all; it listens for scroll events
that already happened (native `<C-d>`, mouse wheel, whatever) and animates the visual
transition after the fact. Since it never claims `<C-d>`/`<C-u>` as a keymap, there's
nothing to race against — which-key's popup scrolling and this plugin simply don't
compete for the same key.

```lua
-- ~/.config/nvim/lua/plugins/snacks-scroll.lua

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    scroll = {
      animate = {
        duration = { step = 10, total = 200 },
        easing = "linear",
      },
    },
  },
}
```

`folke/snacks.nvim` is actually a bundle of small QoL modules (dashboard, picker,
notifier, indent-guides, and more) — you're only opting into `scroll` here via `opts`,
the rest stay off unless you explicitly enable them later. No need to adopt the whole
kit just for this.

**Remove/disable `neoscroll.nvim`** if you already installed it from earlier in this
guide — don't run both, they'd double-animate the same scroll:

```lua
-- lua/plugins/scroll.lua — either delete this file, or disable it explicitly:
return {
  "karb94/neoscroll.nvim",
  enabled = false,
}
```

<details>
<summary>Original neoscroll config, kept for reference / if you prefer it</summary>

Two common choices — pick one:

**`neoscroll.nvim`** — simpler, animates `<C-d>`, `<C-u>`, `<C-f>`, `<C-b>`, `zz`, `gg`,
`G`, etc. **Known issue:** its `<C-d>`/`<C-u>` mappings conflict with which-key's popup
scrolling (see the earlier fix note in this doc) — you'd need to exclude those two keys
from its `mappings` list if you use it alongside which-key.

```lua
-- ~/.config/nvim/lua/plugins/scroll.lua

return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  opts = {
    mappings = {
      -- <C-d>/<C-u> excluded — conflicts with which-key's popup scroll keys
      "<C-b>", "<C-f>",
      "<C-y>", "<C-e>", "zt", "zz", "zb",
    },
    hide_cursor = true,
    stop_eof = true,
    respect_scrolloff = false,
    cursor_scrolls_alone = true,
    easing_function = "quadratic",
  },
}
```

**`cinnamon.nvim`** — newer, wraps more motions generally (including `j`/`k` counts,
search jumps `n`/`N`), slightly more "does everything scroll-adjacent" in scope. Worth
trying if neoscroll feels like it's missing a motion you use often. Not verified against
the which-key conflict specifically — test before relying on it.

</details>

Don't install more than one smooth-scroll plugin — they fight over the same keys.

---

## 6. Core essentials (not explicitly requested, but required for the above to feel complete)

A few plugins the features above either depend on or assume exist. Brief, since you said
you want the walkthrough on the specific four — but skipping these will make Neovim feel
incomplete fast:

| Plugin | Purpose |
|---|---|
| `nvim-treesitter` | Real syntax parsing — powers indent-scope highlighting, better syntax highlighting, code folding |
| `nvim-lspconfig` + `mason.nvim` + `mason-lspconfig.nvim` | Language servers: autocomplete-from-code, go-to-definition, diagnostics, hover docs. `mason.nvim` gives you a `:Mason` UI to install LSPs/linters/formatters without touching your OS package manager |
| `nvim-cmp` (LSP source) | You already installed this for cmdline (§2b) — add `cmp-nvim-lsp` as a source and it doubles as your code-completion engine |
| `telescope.nvim` | Fuzzy finder: files, grep, buffers, LSP symbols — this is what your which-key `<leader>f` group should point to |
| `lualine.nvim` | Statusline (mode, git branch, diagnostics, filetype) |
| `gitsigns.nvim` | Git diff markers in the gutter, hunk stage/undo, blame |
| `nvim-tree.lua` or `neo-tree.nvim` | Sidebar file explorer |

If you want, I can write out full configs for these too (LSP setup in particular has a
few more moving parts than the others) — just say the word and I'll extend this doc.

### 6a. Autoformatting / pretty-printing code

The modern, actively-maintained standard for this is **`conform.nvim`** — it replaced
the older `null-ls`-based approach (that project is archived/unmaintained now, avoid
starting a new config with it). Conform runs real formatter binaries directly
(`prettier`, `stylua`, `black`, `shfmt`, etc.) — faster than routing through an LSP
server, and it falls back to LSP-based formatting for any filetype without a dedicated
formatter configured.

**Install the formatter binaries via Mason** — this is what `mason.nvim` (from the table
above) is for: a managed install location, so formatters don't come from `apt`/`pip`/`npm`
directly. Rather than clicking through the `:Mason` UI and pressing `i` on each one,
declare the list in config using **`mason-tool-installer.nvim`** — a small companion
plugin that adds an `ensure_installed` list, the same pattern `nvim-treesitter` uses for
parsers. It checks on every startup and installs anything missing automatically.

```lua
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
        "taplo",      -- TOML
        -- feel free to also list LSP servers / linters here later — this plugin
        -- installs anything Mason knows about, not just formatters
      },
      auto_update = false,   -- set true if you want it to also keep tools up to date on startup
      run_on_start = true,
    },
  },
}
```

This replaces the "open `:Mason`, search, press `i`" step entirely — restart Neovim once
after adding this and check progress with:

```
:MasonToolsInstall     " manually trigger the install list (also runs automatically on startup)
:MasonToolsUpdate      " update everything in the list to latest
:Mason                 " visual UI, still useful to spot-check what's actually installed
```

Add or remove entries from `ensure_installed` any time — next startup (or
`:MasonToolsInstall`) reconciles the difference, so version-controlling this file
effectively version-controls your whole toolchain, which is handy if you ever set this
config up on a second machine.

**Then configure `conform.nvim`** to map filetypes to the formatters you just installed:

```lua
-- ~/.config/nvim/lua/plugins/conform.lua

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },  -- loads just before you'd need it (i.e. on save)
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true, lsp_fallback = true }) end,
      mode = { "n", "v" },
      desc = "Format Buffer/Selection",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      python = { "ruff_format" },       -- or { "black" } if you installed that instead
      javascript = { "prettier" },
      typescript = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      toml = { "taplo" },
      -- fallback for any filetype not listed above: uses whatever the attached
      -- LSP server offers for formatting, if anything
      ["_"] = { "trim_whitespace" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    notify_on_error = true,       -- explicit: make actual formatter failures surface as a notification
    notify_no_formatters = true,  -- explicit: make "no formatter resolved" surface too, instead of a silent no-op
    -- log_level = vim.log.levels.DEBUG,  -- uncomment temporarily when debugging; see :ConformInfo for the log path

    -- Per-formatter option overrides. This is where you control a specific
    -- formatter's *style*, as opposed to formatters_by_ft above which only
    -- controls *which* formatter runs. Each formatter has its own flag syntax —
    -- taplo takes repeatable `--option key=value` flags, see taplo's own docs
    -- for the full list (align_comments, reorder_keys, column_width, etc.)
    formatters = {
      taplo = {
        prepend_args = { "--option", "align_entries=true" },
      },
    },
  },
}
```

**How this behaves:**

- Save any file (`:w`) → `format_on_save` runs the matching formatter automatically,
  before the write completes. If a filetype has no formatter listed, it silently does
  nothing extra beyond `trim_whitespace` (harmless catch-all) — it won't error out.
- `<leader>cf` in normal mode formats the whole buffer on demand; in visual mode, just
  the selected range — useful when you want to reformat one function without touching a
  file you don't otherwise want to diff heavily in version control.
- `lsp_fallback = true` means: if a filetype has no formatter configured at all, conform
  asks the attached LSP server to format instead (many servers support this natively —
  e.g. `gopls` for Go). If neither exists, nothing happens — with `notify_no_formatters`
  explicitly set above, that case now produces a notification instead of failing silently,
  which is worth having on since the default behavior can otherwise mask a missing
  formatter binary or a filetype-detection mismatch as "nothing happened, no explanation."

**If you don't want format-on-save** (some people prefer formatting to stay a deliberate
action, especially on shared/legacy repos with inconsistent existing style), just delete
the `format_on_save` block — `<leader>cf` still works as a manual trigger either way.

**Checking what conform will actually do for the current buffer:**

```
:ConformInfo
```

Shows which formatter(s) it resolved for the current filetype and whether they're
actually found on `PATH` — the fastest way to debug "why didn't this format" before
digging further.

---

## 7. Other "go-to" plugins worth knowing about

Beyond the LazyVim-parity list, these are commonly reached for and fit a sysadmin/CLI
workflow well:

- **`toggleterm.nvim`** — floating/split terminal you can summon with one keymap,
  multiple terminal instances, send commands to it from normal mode. Very natural fit
  for your workflow (ssh sessions, quick shell commands, without leaving nvim).
- **`trouble.nvim`** — a dedicated panel listing all LSP diagnostics/errors across the
  project, instead of hunting line by line.
- **`todo-comments.nvim`** — highlights and lists `TODO`, `FIXME`, `NOTE`, `HACK`
  comments across your codebase/configs.
- **`vim-fugitive`** — the long-standing, extremely thorough Git plugin (predates
  gitsigns; does full workflows — blame, log, diffs, merge conflict resolution — not
  just gutter markers).
- **`harpoon2`** (folke's maintained fork, or ThePrimeagen's original) — pin a handful
  of files you're actively working on and jump between them with single keystrokes;
  great for config-heavy, multi-file editing sessions.
- **`oil.nvim`** — file explorer that lets you edit the filesystem *as a text buffer*
  (rename/delete/create by editing lines and saving) — a good fit if you like doing
  everything via keyboard-driven text editing rather than tree navigation.
- **`persistence.nvim`** — auto-saves/restores session state (open buffers, layout) per
  project directory.

---

## 8. Sanity checks as you go

- `:checkhealth` — run this after any major addition; it flags missing system deps
  (ripgrep, fd, node, compilers, etc.) per-plugin.
- `:Lazy` — see load status/errors for every plugin.
- `:Lazy profile` — if startup feels slow, this shows what's taking the time.
- Add plugins **one file at a time** and restart Neovim between each — much easier to
  isolate a bad config than adding six plugins and debugging a wall of errors together.

---

Want me to write out the full LSP + `nvim-cmp` code-completion config next (§6's most
involved piece), or a ready-to-use `keymaps.lua` that ties which-key groups to
Telescope/git/terminal actions?
