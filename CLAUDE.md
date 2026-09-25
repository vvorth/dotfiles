# dotfiles — notes for picking this repo back up

Personal dotfiles for Arch Linux + macOS, managed with GNU Stow. This file is a map of the
repo and a dump of non-obvious things learned while working in it — read it before making
changes, especially to `vifm/`, `tmux/`, or the shared shell config.

## Layout: GNU Stow packages

Every top-level directory (`bash/`, `zsh/`, `fzf/`, `starship/`, `nvim/`, `vifm/`, `tmux/`,
`screen/`, `vim/`, `ghostty/`, `iterm2/`, `linearmouse/`) is a Stow "package" whose contents mirror `$HOME`
exactly (e.g. `vifm/.config/vifm/vifmrc` → `~/.config/vifm/vifmrc`). `install.sh` wraps
`stow`:

```bash
./install.sh                 # stow every package
./install.sh bash zsh nvim   # stow only the named packages
./install.sh -R nvim         # restow (after adding files to a package)
./install.sh -D vifm         # unstow
```

`.stowrc` sets `--verbose=1 --no-folding` for every call. `--no-folding` matters: it symlinks
at the *file* level instead of folding a whole directory into one symlink, so e.g.
`~/.config/nvim` stays a real directory and keeps working if it ever holds non-repo files
(caches, plugin state) alongside the repo-managed ones. **`.stowrc` has no comment syntax** —
every line is parsed as a CLI arg by GNU Stow itself, confirmed by reading stow's source; don't
add `#` lines there, put notes here instead. `-t/--target` is deliberately never set in
`.stowrc` — `install.sh` always passes `-t "$HOME"` explicitly instead, since stow's default
target (the stow-dir's parent) is wrong for this layout.

New package checklist: create `<name>/<path-mirroring-$HOME>`, then `./install.sh -R <name>`.

Moving a file between packages (as `40-fzf.sh` moved `bash/` → `fzf/`): on a machine stowed
before the move, the old symlink dangles. Just stow the new package — `./install.sh fzf` —
and stow replaces the dangling link itself, since it points into the stow dir. `-R` on the
*old* package does **not** clean it up (both verified against a throwaway `$HOME`).

## Shared shell config: `sh/conf.d`

Both `bash/.bashrc` and `zsh/.zshrc` source, in order:
1. `~/.aliases` (from `bash/.aliases`, shared by both shells)
2. every `*.sh` in `${XDG_CONFIG_HOME:-$HOME/.config}/sh/conf.d/` — a shell-agnostic drop-in
   dir. **Any package can contribute a file here**, not just `bash/`: e.g.
   `fzf/.config/sh/conf.d/40-fzf.sh` sets up fzf (its own package, so it works with either
   shell's package), `nvim/.config/sh/conf.d/50-nvim.sh` aliases `vi`/`vim` → `nvim` and sets
   `$EDITOR`/`$VISUAL`/`$MANPAGER`, `starship/.config/sh/conf.d/60-starship.sh` picks this
   machine's prompt colour and runs `starship init`. Convention: a conf.d file whose tool is
   missing bails out with `command -v <tool> >/dev/null 2>&1 || return 0` first (works in
   both shells, since the file is sourced) — `50-nvim.sh` does this so `EDITOR=nvim` never
   lands on a host without nvim and breaks `git commit`. Use this when a package's
   shell integration should apply regardless of which shell is running.
3. shell-specific conf.d (`bash/conf.d/*.sh` or `zsh/conf.d/*.zsh`) for things that must be
   bash-only or zsh-only.
4. a machine-local, untracked override file (`~/.bashrc.local` / `~/.zshrc.local` /
   `~/.aliases.local`) — these are never created by this repo, just conditionally sourced if
   present, so machine-specific secrets/tweaks don't need to touch git at all.

`.gitignore` only excludes `nvim/.config/nvim/lazy-lock.json` (plugin lockfile, regenerates
per-machine) — the `.local` files above aren't gitignored, they just never get committed
because nothing here creates them.

## starship — per-host prompt colour

`starship/.config/starship.toml` + `starship/.config/sh/conf.d/60-starship.sh`.

The layout is the stock **tokyo-night preset's powerline bar**, with its single blue ramp
replaced by **one ramp per machine**. The gradient still runs bright → dark left to right; only
its hue changes per host, which is what replaces the old "whole prompt is cyan/green/purple
depending on the host" PS1.

Every palette is generated from one HSL recipe rather than hand-picked, so all hues read as the
same design. At hue 222 that recipe reproduces tokyo-night's own stops (c4 and c5 come out
identical to the preset's hex, the rest within a couple of points) — the `blue` palette is
effectively the preset, which is why the recipe was chosen. Palettes shipped: `blue`, `cyan`,
`green`, `purple`, `amber`, `rose`, and `slate` (a desaturated fallback for a machine that has
not been assigned one).

Ramp stops, and what sits on each:

| key | role | segment |
|-----|------|---------|
| `c1` | lightest | OS icon + `[user@]host` — the brightest thing on the line, on purpose |
| `c2` | vivid | directory; also the text colour on every dark stop, and the `❯` |
| `c3` | dark | git branch + status |
| `c4` | darker | toolchain versions |
| `c5` | darkest | jobs, command duration, exit status, clock |
| `t1` / `t2` / `t5` | text | near-black on `c1`, light on `c2`, muted on `c5` |

The palette blocks are generated; regenerate rather than hand-editing them if the recipe ever
changes (the generator is a few lines of `colorsys` — see the file header for the stop values).

**Why the colour switch is indirect:** starship has no config includes and does not expand
environment variables inside style strings — both confirmed against starship 1.26 by testing
the binary rather than reading docs (`format = "[x](${VAR})"` renders unstyled; a top-level
`include = "..."` key errors with `Unknown key`). A palette is chosen by one static top-level
`palette = "..."` key. So `60-starship.sh` sed-rewrites that single line into a generated copy
at `~/.cache/starship/prompt-<palette>.toml` and exports `STARSHIP_CONFIG` pointing at it.
What follows from that:

- **`~/.config/starship.toml` is still the only file to edit.** The cache copy is regenerated
  whenever the tracked file is newer (`-nt`), so edits appear in the next new shell.
- The `palette = "..."` line in the tracked config must keep its exact shape (that literal at
  column 0) — the sed matches on it. It is set to `slate` there so the file also works
  standalone, e.g. under a bare `STARSHIP_CONFIG=... starship print-config`.
- A normal shell start costs one `stat()`; the sed and the palette-name validation only run on
  a cache miss.

Palette selection, highest precedence first: an already-exported `$STARSHIP_HOST_PALETTE` →
the untracked one-word file `~/.config/starship-host` → the hostname `case` table inside
`60-starship.sh` (tracked, so filling it in once covers every machine that syncs this repo) →
`slate`. Per host the quickest setup is `starship-palette -w green`; without `-w` it switches
only the current shell, which is how to compare ramps side by side.

Non-obvious things learned building this:

- **A palette *name* is not a colour name.** `fg:rose` does not resolve just because
  `[palettes.rose]` exists — a palette maps only its own keys (`c1`…`c5`, `t1`, `t2`, `t5`).
  An unresolvable colour makes starship silently drop the *whole* style, which here showed up
  as one segment losing its background and punching a hole in the bar. Use ramp keys or plain
  ANSI names, and re-render after touching styles.
- Conversely, palette names do **not** shadow ANSI colour names: with `palette = "cyan"`
  active, `fg:cyan` still renders ANSI cyan (verified). The git-status icons deliberately use
  ANSI names (`green`, `yellow`, `red`, `bright-blue`, …) so they follow the terminal theme
  instead of being pinned to the ramp.
- Each git-status item is its own conditional group — `([ $staged](fg:green bg:c3))` — so a
  clean repo prints nothing rather than a row of zeroes.
- **Empty segments do not disappear, they taper.** The powerline separators live in the root
  `format`, not inside the modules, so outside a git repo (or with no toolchain detected) the
  `c3`/`c4` stops collapse to bare chevrons rather than vanishing. That is inherited from the
  tokyo-night preset and reads as an intentional fade; making them truly conditional is not
  expressible, because starship's `(...)` groups have no "else" branch to supply the
  alternative `fg:c2 bg:c4` separator.
- The ramp is hex, so it needs truecolor. Inside tmux that comes from the `terminal-features
  ... :RGB` lines in `tmux/.tmux.conf` (see the tmux section). If the bar ever looks washed out
  inside tmux but fine outside it, check the outer terminal's `$TERM` is in that list.
- `starship init bash` replaces `PROMPT_COMMAND`, but stashes the previous value in
  `STARSHIP_PROMPT_COMMAND` and evals it from its own precmd — so `.bashrc`'s
  `history -a; history -c; history -r` sharing keeps working underneath it.
- **`shlvl` (shown from level 2) needs `set-environment -gu SHLVL` in `tmux/.tmux.conf`.**
  tmux panes inherit `SHLVL` from the shell that started the server and add one, so without
  it every pane reads 2 and the gate is useless (verified with tmux 3.6). Nested shells
  inside vifm's `:shell` / nvim's `:terminal` still count normally. Beware when testing with
  `zsh -c 'zsh -c ...'`: zsh decrements `SHLVL` when it execs its last command, so a
  one-command `-c` shows no nesting.
- `status` has `pipestatus = true`: a failing pipeline shows `0|1|0`, and signals show by
  name (`130 INT`). `$signal_name` has to be in *both* `format` and `pipestatus_format` —
  the plain `format` is what a single killed command uses.
- Verified in the sandbox by downloading the real starship binary and rendering
  `starship prompt` against a throwaway git repo in every state (clean, staged, modified,
  deleted, untracked, non-zero exit, background jobs, outside a repo), for every palette, plus
  sourcing `60-starship.sh` in real `bash -c` and `zsh -f -c` shells. `starship print-config`
  is the fast "does this even parse" check — it warns about unknown keys and missing palettes.

## vifm — image/video previews

`vifm/.config/vifm/scripts/imgpreview` + two `fileviewer` entries near the top of
`vifm/.config/vifm/vifmrc` (placed *before* the stock `identify`/`ffprobe` fileviewer entries
further down, intentionally — first match wins in vifm, and the stock ones stay reachable via
`a`/`A` in view mode as a manual fallback). **Full setup guide, package list, and the
tmux/SSH env-forwarding requirements are in [`vifm-image-previews.md`](vifm-image-previews.md)
— read that before touching this again.** The short version: `chafa` does all the real work via
its own auto-detection; the script's job is just cache video thumbnails and work around two
vifm quirks (below).

Non-obvious things learned by reading vifm's and chafa's actual source (their docs/wiki
undersell this):

- **`%pd` is required for any previewer that writes real terminal-graphics bytes to stdout**,
  or vifm captures/redraws the output through its own ncurses layer and corrupts it into
  literal escape-code garbage. Tools that write directly to `/dev/tty` (like `kitty icat`)
  don't need it; `chafa` writes to stdout, so it does.
- **`%pd` alone isn't enough for multi-line output.** vifm's pass-through handler
  (`src/ui/ui.c:ui_pass_through()`) positions the cursor *once*, at the pane's top-left corner,
  then blindly `puts()`s every line — correct for a single self-contained graphics blob
  (sixel/kitty/iTerm2 don't need line breaks for row placement), but wrong for chafa's
  multi-line ascii/symbol fallback: each `\n` can drift the cursor to the terminal's real
  column 0 instead of the pane's edge, corrupting neighboring panes, not just the preview.
  `imgpreview`'s `reposition()` function works around this by re-emitting every output line
  with its own absolute cursor-position escape, derived from the `%px`/`%py` macros (confirmed
  via `src/macros.c` to be 0-indexed screen coords — `getbegx`/`getbegy` — so `+1` to convert to
  ANSI CUP's 1-indexed form).
- **The clear command's stdout is silently discarded by vifm**
  (`src/ui/quickview.c:qv_cleanup_area()` reads it via a pipe and drains it with a bare
  `fgetc()` loop, never displaying it) — unlike the draw command, whose captured output vifm
  deliberately re-prints. So the clear command must write straight to `/dev/tty`, same as
  `kitty icat --clear` does.
- Inside tmux, `/dev/tty` is tmux's own pty, not the physical terminal, so raw escape bytes
  written there still need tmux's DCS passthrough envelope (`\ePtmux;<payload, ESC doubled>\e\\`)
  to reach the real terminal — `imgpreview`'s `send_passthrough()` handles this (and the
  analogous GNU screen wrapper).
- `chafa`'s own tmux support (`chafa/chafa-term-db.c`) currently only carries **sixel and the
  kitty graphics protocol** through its tmux-passthrough inheritance list
  (`tmux_inherit_seqs`) — iTerm2's protocol is not in that list. So iTerm2-in-tmux always falls
  back to chafa's (still colored, still readable) ascii rendering; this is an upstream chafa
  gap, not something fixable from this repo. Confirmed via `chafa --dump-detect` showing
  `CHAFA_TERM='tmux-*-3.4:iterm'` (both correctly identified) but `CHAFA_PIXEL_MODE='symbols'`
  anyway.
- `chafa --dump-detect` is the go-to diagnostic when a terminal shows ascii instead of real
  graphics — prints `CHAFA_TERM`/`CHAFA_PIXEL_MODE`/`CHAFA_PASSTHROUGH`, tells you immediately
  whether it's an env-var-not-reaching-the-shell problem (check with
  `env | grep -E 'LC_TERMINAL|GHOSTTY_|KITTY_PID|WEZTERM_'`) or something else.
- **General debugging approach that worked well here**: vifm's and chafa's own wikis/`--help`
  are incomplete or unreachable (both `wiki.vifm.info` and `man.archlinux.org` returned 403 to
  `WebFetch` this session); `git clone`-ing `vifm/vifm` and `hpjansson/chafa` and grepping the
  actual C source (`src/ui/quickview.c`, `src/ui/ui.c`, `src/macros.c` for vifm;
  `chafa/chafa-term-db.c`, `chafa/chafa-term-info.c` for chafa) settled every question docs
  couldn't, faster than guessing. Worth reaching for again before re-guessing at vifm/chafa
  behavior.

## tmux

`tmux/.tmux.conf`: prefix is `C-a` (not default `C-b`; `C-a C-a` is last-window, `C-a a`
sends a literal `C-a`), `base-index 1`, `escape-time 0` (avoids the classic "ESC feels laggy
in nvim" issue), `focus-events on` (for nvim), `C-h/j/k/l` pane moves shared with nvim via
vim-tmux-navigator (the `is_vim` bindings here are the tmux half of that plugin — both halves
are needed).

Terminal/colour: `default-terminal` is `tmux-256color`, falling back to `screen-256color`
when `infocmp` can't find it (older macOS system terminfo lacks it). `terminal-features` adds
`RGB:usstyle:clipboard` **per outer terminal** (`xterm-256color` — which is what iTerm2
reports — `xterm-ghostty`, `xterm-kitty`, `alacritty`, `wezterm`), deliberately not `*`, so a
bare Linux console isn't forced into truecolor. Add a line there for any new terminal.

Copy mode: `mode-keys vi` (`v` select, `C-v` block, `y` yank) plus `set-clipboard on`, so every
tmux copy, and OSC 52 from programs inside tmux (nvim over SSH), reaches the system clipboard.

Zoom banner: an `after-resize-pane` hook shows the "MAXIMIZED" border only on the zoomed
window. It must use `set -w`; the original `set -g` leaked the banner onto every other split
window (reproduced and the fix verified on tmux 3.6 with `tmux -L <socket> -f <file>`).

For image previews (yazi *and* vifm+chafa):

```tmux
set -g allow-passthrough on
set -ga update-environment "LC_TERMINAL LC_TERMINAL_VERSION GHOSTTY_BIN_DIR GHOSTTY_RESOURCES_DIR KITTY_PID WEZTERM_EXECUTABLE"
```

`TERM_PROGRAM` itself is useless for this and deliberately not in that list — tmux always
overwrites it to `"tmux"` for pane processes, so image tools have to identify the real terminal
some other way; the vars above are what they actually check per-terminal. **This only takes
effect in *new* panes/windows created after a fresh `tmux attach`** — changing this config does
not retroactively fix an already-open pane; detach/reattach and open a new window, or
`tmux kill-server`, before testing. Over SSH, these vars also need `SendEnv`/`AcceptEnv`
forwarding — see `vifm-image-previews.md`.

## nvim

Hand-built LazyVim-alike (not the LazyVim distro) on top of `lazy.nvim`. Ground truth is
`nvim/.config/nvim/lua/plugins/*.lua` (one file per plugin) and `lua/config/*.lua`
(`options.lua`, `keymaps.lua`, `autocmds.lua`, `lazy.lua` for the bootstrap). Active plugins:
noice (cmdline popup), which-key, treesitter (+ native fold via `foldexpr`), conform
(formatting), mason + mason-tool-installer, snacks (`snacks-scroll.lua` — despite the name it
configures all of snacks: scroll, picker, explorer, notifier, indent, image, terminal),
lualine, mini.icons (mocking nvim-web-devicons), render-markdown + markdown-table-wrap,
ultimate-autopair, vim-sleuth, vim-tmux-navigator.

Not active, despite files existing: `wilder.lua` is `enabled = false` (kept in favor of native
`wildmenu`/`wildoptions=pum` in `options.lua`); `nvim-tree.lua` is a `return {}` stub with the
old config commented out (snacks' explorer replaced it on `<leader>e`). **There is no LSP and
no completion plugin yet** — noice's `cmp.entry.get_documentation` override is inert.

Load-order things that are easy to break:
- **`config/keymaps.lua` is a which-key spec, not code**: it `return`s a table that
  `plugins/which-key.lua` passes as `opts.spec`, and `init.lua` does not require it. Calling
  `require("which-key")` at top level anywhere forces which-key to load during startup instead
  of on `VeryLazy` (verified via lazy's `_.loaded` reason: it was `require` from keymaps.lua).
  which-key creates the mappings a tick after it loads, so a headless check has to
  `doautocmd User VeryLazy` and then `vim.defer_fn` before probing `maparg`.
- **nvim-treesitter's `main` branch does not support lazy-loading** (its README), so it is
  `lazy = false` with everything in `config`. Its `install()` already skips installed parsers.
  `markdown_inline` is required by render-markdown; the parser list also covers what conform
  formats. The `FileType` hook only sets the treesitter `indentexpr` when
  `vim.treesitter.start` actually succeeded, so filetypes without a parser keep their normal
  indent. Installing parsers on `main` needs the `tree-sitter` CLI (mason installs it).
- **`vim.ui.open` is only overridden over SSH** (in `options.lua`): it `vim.notify`s the target
  instead of opening it. Locally `gx` uses the stock opener. An override must return `nil`,
  not `{}` — nvim's `gx` calls `:wait()` on the return value, and the old `{}` made every `gx`
  throw "attempt to call method 'wait'".

`neovim-manual-setup.md` (repo root) is the build journal for all of this — it says at the top
that it's "a point-in-time journal, not living documentation" and may drift from the actual
config (the wilder→native-wildmenu switch above is the example it names). **Treat it as
narrative/rationale, not a source of truth for current state — read the `lua/` files for that.**

`options.lua` has its own tmux/screen-aware terminal-capability detection
(`supports_truecolor()`, queries `tmux display-message` for the client terminal when inside
tmux) — a smaller-scale precedent for the same "TERM lies inside a multiplexer, ask around it"
problem solved more thoroughly for vifm/chafa above.

## ghostty

`ghostty/.config/ghostty/config`: Selenized Dark theme, `macos-titlebar-style = transparent`
(`tabs` and `hidden` are kept commented out next to it).
`shell-integration-features = ssh-env,ssh-terminfo` makes `ssh` from a Ghostty shell install
Ghostty's terminfo on the remote (or fall back to `xterm-256color`), so remote hosts don't
choke on `TERM=xterm-ghostty`; needs Ghostty ≥ 1.2, and doesn't apply inside tmux (TERM there
is already `tmux-256color`). Listing features only adds them; unlisted ones keep defaults.

**Known upstream bug with `macos-titlebar-style = tabs`** (why it's not the active value): it is squished/barely-visible on
macOS 26/27 in some Ghostty versions — fixed for the original "tiny box next to +" symptom in
Ghostty 1.2.3, but a *different* regression on macOS 26/27 was reported against a 1.3.2-main
nightly (`ghostty-org/ghostty#13066`) and fixed by PR #13069, which **had not reached a stable
release as of 2026-08-23** (latest stable was 1.3.1; 1.3.2 not yet cut, 1.4.0 ~94% done per
their milestone tracker). Check `ghostty +version` and this project's release notes before
assuming it's fixed. Workarounds if stuck on an unfixed version: toggle focus with `cmd+1`/
`cmd+2` repeatedly, or temporarily set `macos-titlebar-style = native` (loses the integrated-tab
look but sidesteps the bug entirely).

## iterm2

`iterm2/.config/iterm2/com.googlecode.iterm2.plist` is a full **exported** preferences plist
(~6000 lines of XML) — treat it as a snapshot from iTerm2's own "load preferences from a custom
folder" export, not something to hand-edit. If iTerm2 settings need to change, change them in
the app and re-export, or edit narrowly with a plist-aware tool.

## screen, vim

Both present but essentially unmodified upstream sample configs (`screen/.screenrc` is GNU
screen's own example file almost verbatim; `vim/.vimrc` is ~18 lines of basic
options/colorscheme). Not actively developed — `nvim/` is where the real editor config lives
now (`nvim/.config/sh/conf.d/50-nvim.sh`, contributed by the `nvim` package, aliases `vi`/`vim` →
`nvim` globally).

## Brewfile — known gap

`Brewfile` (repo root) is the macOS package list for `brew bundle`. **It does not currently
list the packages the vifm image-preview feature needs**: `chafa`, `ffmpegthumbnailer`, and
optionally `ascii-image-converter`/`jp2a` (see `vifm-image-previews.md` for the full table,
including Arch equivalents). It also has no `ghostty` cask, despite a tracked `ghostty/`
config package existing (only `iterm2` is listed as a cask) — may be intentional (installed
some other way) or may just be an oversight; worth confirming with the user rather than
assuming either way before editing `Brewfile`.

## Working in this sandbox / session-specific gotchas

- `git push` to `origin` (GitHub) requires a credential the sandbox doesn't have by default;
  fails with `fatal: could not read Username for 'https://github.com'`. Fix is on the user's
  host: `sbx secret set github --sandbox <sandbox-name> -t "$(gh auth token)"`
  (`<sandbox-name>` = `$SANDBOX_VM_ID`/`hostname` inside the sandbox). **`git fetch`/`pull`
  work fine without this** (read-only), so don't assume a push failed without also `fetch`ing
  to check — this session had pushes silently succeed (or get pushed from elsewhere) despite
  every local `git push` invocation reporting the auth error above.
- No live vifm/tmux/chafa terminal to test against in this sandbox — verification this session
  relied on: `bash -n` + stubbed-binary unit tests for `imgpreview`'s branching logic, and
  installing real `chafa`/`tmux` via `apt-get` just to check `--dump-detect` output / config
  parsing, then removing them again. Reasonable fallback when the user can't easily test
  something live themselves either (e.g. answering "what does vifm actually do with %pd" by
  reading vifm's C source directly, rather than speculating).
- Testing nvim/tmux/stow for real works here: `apt-get install neovim tmux zsh stow` (apt had
  nvim 0.11.6, tmux 3.6). GitHub *release downloads* 502 through the proxy but `git clone`
  from GitHub works, so lazy.nvim can install every plugin. Point `XDG_CONFIG_HOME` /
  `XDG_DATA_HOME` / `XDG_STATE_HOME` / `XDG_CACHE_HOME` at a scratch dir with
  `config/nvim` symlinked to `nvim/.config/nvim`, then `nvim --headless "+Lazy! sync" +qa`.
  Test tmux on its own socket (`tmux -L test -f tmux/.tmux.conf new -d`), and stow into a fake
  `HOME=... ./install.sh`.
- Sandbox-only nvim quirk, not a config bug: lazy.nvim's rtp reset uses `<prefix>/lib64/nvim`
  whenever `/usr/lib64` exists, and here it does but holds no `nvim/`, so nvim's bundled
  parsers (`/usr/lib/nvim/parser`) vanish and the stock `ftplugin/lua.lua` errors with
  "Parser could not be created". Add `-c 'set rtp+=/usr/lib/nvim'` for tests. On Arch
  `/usr/lib64` → `/usr/lib`, and Homebrew has no `lib64`, so the user's machines are unaffected.
