# vifm Image/Video Previews — Setup Notes

Real terminal-graphics previews for images and videos in vifm, via `vifm/.config/vifm/scripts/imgpreview`
and the `fileviewer` entries near the top of `vifm/.config/vifm/vifmrc`. Rendering is handled entirely by
`chafa`'s own auto-detection (kitty/iTerm2/sixel, or a colored ascii fallback); nothing here hardcodes a
terminal or protocol.

## Packages to install

| Tool | Purpose | Arch | macOS (brew) |
|---|---|---|---|
| chafa | image rendering, terminal/protocol auto-detection | `pacman -S chafa` | `brew install chafa` |
| ffmpegthumbnailer | video thumbnails | `pacman -S ffmpegthumbnailer` | `brew install ffmpegthumbnailer` |
| ascii-image-converter | plain-ascii last resort (only used if chafa is missing) | AUR: `yay -S ascii-image-converter` | `brew install ascii-image-converter` |
| jp2a | alt plain-ascii last resort | `pacman -S jp2a` (or AUR) | `brew install jp2a` |

`chafa` alone is enough for real graphics on kitty, Ghostty, WezTerm, iTerm2, and sixel-capable terminals —
it detects the protocol itself. The rest are just fallbacks.

## Local terminal, no tmux, no SSH

Nothing else needed. Verify with `chafa --dump-detect` — `CHAFA_PIXEL_MODE` should say `kitty`, `iterm`, or
`sixels`, not `symbols`.

## Over tmux

Already configured in `tmux/.tmux.conf`:

```tmux
set -g allow-passthrough on
set -ga update-environment "LC_TERMINAL LC_TERMINAL_VERSION GHOSTTY_BIN_DIR GHOSTTY_RESOURCES_DIR KITTY_PID WEZTERM_EXECUTABLE"
```

`allow-passthrough` lets graphics escape sequences reach the real terminal instead of being eaten by tmux.
`update-environment` forwards the vars chafa uses to identify the real terminal — `TERM_PROGRAM` itself is
useless for this since tmux always overwrites it to `"tmux"` for panes.

**This only takes effect in *new* panes/windows created after a fresh `tmux attach`** — it will not
retroactively fix an already-open pane. After pulling a config change here, detach, reattach, and open a
new window (or `tmux kill-server` and start over) before testing.

**Known chafa limitation:** as of chafa's current tmux support, only sixel and the kitty graphics protocol
are carried through the tmux passthrough layer — iTerm2's own inline-image protocol is not (see
`chafa/chafa-term-db.c`'s `tmux_inherit_seqs`, which omits `CHAFA_TERM_SEQ_BEGIN_ITERM2_IMAGE`). So iTerm2
inside tmux will always fall back to chafa's (still colored, still readable) ascii rendering, regardless of
any config here. Ghostty/kitty/WezTerm inside tmux do get real graphics.

## Over SSH

SSH does **not** forward these identifying env vars to the remote shell by default, so the remote-side
`chafa` has no way to know what terminal you're actually using — it'll fall back to ascii even outside
tmux. Add to your **local** `~/.ssh/config`:

```
Host *
    SendEnv LC_TERMINAL LC_TERMINAL_VERSION GHOSTTY_BIN_DIR GHOSTTY_RESOURCES_DIR
```

`LC_TERMINAL`/`LC_TERMINAL_VERSION` (set by iTerm2) usually work with zero server-side config, since most
`sshd_config`s already have `AcceptEnv LANG LC_*` by default for locale negotiation. `GHOSTTY_BIN_DIR`/
`GHOSTTY_RESOURCES_DIR` are not `LC_*` vars, so they need an explicit line on the **remote** machine's
`/etc/ssh/sshd_config`:

```
AcceptEnv LANG LC_* GHOSTTY_BIN_DIR GHOSTTY_RESOURCES_DIR
```

then `sudo systemctl restart sshd`. (Add `KITTY_PID`/`WEZTERM_EXECUTABLE` to both sides too if relevant.)

## Diagnosing a "still shows ascii" case

```
chafa --dump-detect
```

prints `CHAFA_TERM`, `CHAFA_PIXEL_MODE`, and `CHAFA_PASSTHROUGH`. If `CHAFA_TERM` doesn't include your
terminal's name (`ghostty`, `iterm`, `kitty`, ...), the identifying env var isn't reaching that shell —
check `env | grep -E 'LC_TERMINAL|GHOSTTY_|KITTY_PID|WEZTERM_'` to see what's actually present, and work
backwards through SSH forwarding, then tmux `update-environment`, in that order (each layer can only
forward what it already received from the one before it).
