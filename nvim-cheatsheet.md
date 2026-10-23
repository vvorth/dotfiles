# nvim — what is in here and which key does what

Leader is `Space`. Press it and wait half a second: which-key lists everything under it.
`<leader>fk` opens a searchable picker of **every** keymap (plugin ones included), `<leader>fc`
the same for commands, `<leader>fh` for help tags, `<leader>?` shows only this buffer's
mappings. Those four are the answer to "what was that key again".

Ground truth is `nvim/.config/nvim/lua/plugins/*.lua` (one file per plugin) and
`lua/config/*.lua`. This file is the human index of that.

## What each plugin is for

| plugin | file | what you notice |
|---|---|---|
| lazy.nvim | `config/lazy.lua` | plugin manager. `<leader>l` opens it; `:Lazy sync` updates |
| snacks.nvim | `plugins/snacks-scroll.lua` | file explorer, fuzzy pickers, notifications, smooth scroll, indent guides, inline images, big-file mode, `<leader>ut` terminal |
| which-key | `plugins/which-key.lua` + `config/keymaps.lua` | the leader popup. `keymaps.lua` is the list of leader mappings, not code |
| noice | `plugins/noice.lua` | the floating `:` command line and popup menu (`cmdheight=0`). `:Noice` shows message history |
| lualine | `plugins/lualine.lua` | status line |
| mini.icons | `plugins/icons.lua` | file icons for everything above |
| blink.cmp | `plugins/lsp.lua` | completion menu, **manual by default** (`<C-Space>`) |
| nvim-lspconfig + mason | `plugins/lsp.lua`, `plugins/mason.lua` | language servers: yaml, bash, python (basedpyright), lua, terraform (+tflint). `:Mason` manages the binaries |
| conform | `plugins/conform.lua` | formatting on demand (`<leader>cf`), not on save |
| treesitter | `plugins/treesitter.lua` | highlighting, indent, and folds (`za`) |
| render-markdown | `plugins/render-markdown.lua` | pretty headings/lists/tables in markdown, Normal mode only |
| markdown-table-wrap | `plugins/render-markdown.lua` | pipe-table tools, **only when asked** via `<leader>m…` |
| ultimate-autopair | `plugins/ultimate-autopair.lua` | auto-closes brackets/quotes. `<leader>cp` toggles it |
| vim-sleuth | `plugins/vim-sleuth.lua` | guesses indent width from the file; overrides the 2-space defaults in `autocmds.lua` when a file disagrees |
| vim-tmux-navigator | `plugins/tmux-navigator.lua` | `<C-h/j/k/l>` across vim splits *and* tmux panes |
| tf-docs | `plugins/tf-docs.lua` | Terraform registry docs for the block under the cursor |
| wilder, nvim-tree | `plugins/wilder.lua`, `plugins/nvim-tree.lua` | disabled / stubbed. Native `wildmenu` and snacks explorer replaced them |

## Leader map

| key | does |
|---|---|
| `<leader>e` | file explorer (toggle: press again to close it) |
| `<leader>ff` `fg` `fr` | find files, live grep, recent files |
| `<leader>fk` `fc` `fh` | find keymap, command, help tag |
| `<leader>fs` | save |
| `<leader>fe` | `:edit .` (opens the explorer on the cwd) |
| `<leader>bf` `bb` `bn` `bp` `bd` `bl` | buffers: find, last, next, prev, delete, list |
| `<leader>wv` `wh` `wd` | split vertical, split horizontal, close window |
| `<leader>cf` | format buffer or selection (conform, LSP fallback) |
| `<leader>ca` | toggle completion auto-popup (off by default) |
| `<leader>cd` | toggle diagnostics |
| `<leader>cp` | toggle autopair |
| `<leader>ct` | Terraform: pick a block and open its docs (tf/hcl only) |
| `<leader>m…` | markdown, see below (markdown buffers only) |
| `<leader>ug` | toggle indent guides |
| `<leader>ut` | toggle terminal |
| `<leader>un` / `<leader>n` | dismiss notifications / notification history |
| `<leader>l` | Lazy |
| `<leader>?` | which-key: this buffer's local keymaps |
| `<leader>qq` | quit all |

## Not under leader

| key | does |
|---|---|
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | move to the vim split, or tmux pane, in that direction. `<C-\>` previous pane |
| `za` `zc` `zo` `zR` `zM` | fold toggle / close / open / open all / close all (treesitter folds, files start fully open) |
| `K` | LSP hover |
| `grn` `gra` `grr` `gri` `grt` `gO` | LSP rename, code action, references, implementation, type definition, document symbols (nvim 0.11+ built-ins) |
| `<C-]>` | jump to definition (LSP tagfunc) |
| `[d` `]d` | previous / next diagnostic |
| `<C-s>` (insert) | signature help |
| `gx` | open URL under cursor (over SSH it only prints it) |
| `gK` `gY` | Terraform: open docs / copy docs URL (tf/hcl only) |
| `]c` `[c` | markdown: next / previous table cell |

## Completion (blink.cmp)

The menu does **not** pop up on its own. `<C-Space>` opens it (and toggles the docs panel),
`Tab`/`S-Tab` move, `Enter` accepts, `<C-e>` closes, `<C-b>`/`<C-f>` scroll docs.
`<leader>ca` switches to auto-popup for this session.

## Explorer (snacks, `<leader>e`)

You land in the file list in Normal mode. Keys there:

| key | does |
|---|---|
| `l` / `Enter` | open file, or expand/collapse folder |
| `h` | collapse folder |
| `<BS>` | go up one directory |
| `<C-t>` | file: open in new tab. closed folder: expand it. open folder: nothing |
| `<C-s>` `<C-v>` | open in split / vsplit |
| `a` `d` `r` `c` `m` | add (trailing `/` makes a dir), delete, rename, copy, move |
| `y` `p` | yank / paste files |
| `o` | open with the system app |
| `.` | make the folder under the cursor the root; `<C-c>` `:tcd` to it |
| `u` | refresh |
| `H` `I` | show hidden / show git-ignored |
| `Z` | collapse everything |
| `]g` `[g` `]d` `[d` | next/prev git-changed file, next/prev diagnostic |
| `<leader>/` | grep inside the folder under the cursor |
| `P` | toggle preview |
| `i` or `/` | jump to the filter prompt (insert mode); `Esc` or `<C-c>` there closes the explorer |
| `?` | help with all of the above |
| `q` | close |

`<C-h/j/k/l>` work from the list like anywhere else (editor to the right, tmux panes
otherwise). In the filter prompt `<C-j>`/`<C-k>` walk the list while you type.

## Pickers (find files, grep, buffers, keymaps, …)

Type to filter. `<C-j>`/`<C-k>` (or `<C-n>`/`<C-p>`) move, `Enter` opens, `<C-s>`/`<C-v>`/`<C-t>`
open in split/vsplit/tab, `<Tab>` selects several, `<C-q>` sends results to the quickfix list,
`<A-h>` toggles hidden files, `<A-i>` ignored files, `<A-p>` the preview, `<C-g>` switches grep
between live and fuzzy, `?` lists the rest. `Esc` closes.

## Markdown

render-markdown renders in **Normal mode only**: Insert mode shows the raw text, and the line
under the cursor is always raw, so editing is plain markdown editing. Tables are padded with
virtual text so columns line up. Nothing is ever rewritten by rendering.

markdown-table-wrap does nothing until asked (its default of hijacking every buffer with a
table into a read-only "Reader" is turned off). Under `<leader>m` in markdown buffers:

| key | does |
|---|---|
| `<leader>mr` | toggle render-markdown rendering |
| `<leader>mf` | format/align the table under the cursor (rewrites the source rows) |
| `<leader>mt` | whole document as a wrapped, read-only Reader. `q` or `e` returns to the file, `i`/`a`/`o` return and start insert |
| `<leader>mp` | table under the cursor in a float, `q` closes |
| `<leader>me` | edit the cell under the cursor in a small window, `<C-s>` saves |
| `<leader>ma` `mA` `md` `mD` | add row / add column / delete row / delete column |
| `<leader>mh` | the plugin's own key/command help |
| `]c` `[c` | next / previous cell |

`<leader>cf` (prettier) also reflows tables, together with the rest of the file.

## Where things are decided

- Indent: 4 spaces globally (`options.lua`), 2 for lua/js/ts/yaml/json/html/css/hcl/terraform
  (`autocmds.lua`), and vim-sleuth adapts to whatever an existing file uses.
- Adding a language: parser list in `treesitter.lua`, server in `lsp.lua`, formatter in
  `conform.lua`, mason package in `mason.lua`, 2-space list in `autocmds.lua`.
- `:checkhealth` when something is off, `:Lazy` for plugin state, `:Mason` for tool binaries,
  `:ConformInfo` for "why did format do nothing", `:Noice` for messages that flashed by.
