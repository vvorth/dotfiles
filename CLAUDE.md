# dotfiles — notes for picking this repo back up

Personal dotfiles for Arch Linux + macOS, managed with GNU Stow. This file is a map of the
repo and a dump of non-obvious things learned while working in it — read it before making
changes, especially to `vifm/`, `tmux/`, or the shared shell config.

## Layout: GNU Stow packages

Every top-level directory (`bash/`, `zsh/`, `nvim/`, `vifm/`, `tmux/`, `screen/`, `vim/`,
`ghostty/`, `iterm2/`, `linearmouse/`) is a Stow "package" whose contents mirror `$HOME`
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

## Shared shell config: `sh/conf.d`

Both `bash/.bashrc` and `zsh/.zshrc` source, in order:
1. `~/.aliases` (from `bash/.aliases`, shared by both shells)
2. every `*.sh` in `${XDG_CONFIG_HOME:-$HOME/.config}/sh/conf.d/` — a shell-agnostic drop-in
   dir. **Any package can contribute a file here**, not just `bash/`: e.g.
   `bash/.config/sh/conf.d/40-fzf.sh` sets up fzf, `nvim/.config/sh/conf.d/50-nvim.sh` aliases
   `vi`/`vim` → `nvim` and sets `$EDITOR`/`$MANPAGER`. Use this when a package's shell
   integration should apply regardless of which shell is running.
3. shell-specific conf.d (`bash/conf.d/*.sh` or `zsh/conf.d/*.zsh`) for things that must be
   bash-only or zsh-only.
4. a machine-local, untracked override file (`~/.bashrc.local` / `~/.zshrc.local` /
   `~/.aliases.local`) — these are never created by this repo, just conditionally sourced if
   present, so machine-specific secrets/tweaks don't need to touch git at all.

`.gitignore` only excludes `nvim/.config/nvim/lazy-lock.json` (plugin lockfile, regenerates
per-machine) — the `.local` files above aren't gitignored, they just never get committed
because nothing here creates them.

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

`tmux/.tmux.conf`: prefix is `C-a` (not default `C-b`), `base-index 1`, `escape-time 0` (avoids
the classic "ESC feels laggy in nvim" issue), `focus-events on` (for nvim). For image previews
(yazi *and* vifm+chafa):

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
noice (cmdline popup), nvim-cmp-backed cmdline completion, which-key, treesitter (+ native fold
via `foldexpr`), conform (formatting), mason, nvim-tree, ultimate-autopair,
render-markdown, snacks-scroll (smooth scrolling), vim-sleuth, icons.

`nvim/.config/nvim/lua/plugins/wilder.lua` is present but `enabled = false` — deliberately kept
around disabled rather than deleted, in favor of native `wildmenu`/`wildoptions=pum` configured
in `options.lua`.

`neovim-manual-setup.md` (repo root) is the build journal for all of this — it says at the top
that it's "a point-in-time journal, not living documentation" and may drift from the actual
config (the wilder→native-wildmenu switch above is the example it names). **Treat it as
narrative/rationale, not a source of truth for current state — read the `lua/` files for that.**

`options.lua` has its own tmux/screen-aware terminal-capability detection
(`supports_truecolor()`, queries `tmux display-message` for the client terminal when inside
tmux) — a smaller-scale precedent for the same "TERM lies inside a multiplexer, ask around it"
problem solved more thoroughly for vifm/chafa above.

## ghostty

`ghostty/.config/ghostty/config`: Selenized Dark theme, `macos-titlebar-style = tabs` (custom
tab bar in the title bar). **Known upstream bug**: this setting is squished/barely-visible on
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
now (`vim/.config/sh/conf.d/50-nvim.sh`, contributed by the `nvim` package, aliases `vi`/`vim` →
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
