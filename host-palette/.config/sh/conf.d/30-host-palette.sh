# Host palette: one colour ramp per machine, shared by the starship prompt and
# the tmux status bar, so a glance at either says which host you are on.
#
# The ramps live in ~/.config/host-palette/palettes -- the only place they are
# defined. How a machine picks one is documented in lib.sh next to it. This
# file resolves the pick once per shell into $HOST_PALETTE, for 60-starship.sh
# (and anything else) to read, and defines the `host-palette` command:
#
#   host-palette             -> current palette + swatches of every palette
#   host-palette purple      -> switch this shell (and what it starts) only
#   host-palette -w purple   -> switch and remember on this machine; also
#                               repaints a running tmux server

_hp_lib="${XDG_CONFIG_HOME:-$HOME/.config}/host-palette/lib.sh"
if [ ! -r "$_hp_lib" ]; then
  unset _hp_lib
  return 0
fi
. "$_hp_lib"
unset _hp_lib

_hp_select
HOST_PALETTE="$HP_NAME"
export HOST_PALETTE

# "#a2b1d2" -> a truecolor background escape, for the swatches.
_hp_bg() {
  _hp_x="${1#\#}"
  _hp_g="${_hp_x#??}"
  printf '\033[48;2;%d;%d;%dm' "0x${_hp_x%????}" "0x${_hp_g%??}" "0x${_hp_x#????}"
  unset _hp_x _hp_g
}

_hp_list() {
  while read -r _hp_l_n _hp_l_rest; do
    case "$_hp_l_n" in '' | '#'*) continue ;; esac
    _hp_load "$_hp_l_n" || continue
    if [ "$_hp_l_n" = "$HOST_PALETTE" ]; then _hp_l_mark='*'; else _hp_l_mark=' '; fi
    printf '%s %-12s ' "$_hp_l_mark" "$_hp_l_n"
    for _hp_l_c in "$HP_C1" "$HP_C2" "$HP_C3" "$HP_C4" "$HP_C5"; do
      _hp_bg "$_hp_l_c"
      printf '    '
    done
    printf '\033[0m\n'
  done < "$HOST_PALETTE_FILE"
  unset _hp_l_n _hp_l_rest _hp_l_mark _hp_l_c
}

host-palette() {
  _hp_write=0
  case "$1" in
    -w | --write)
      _hp_write=1
      shift
      ;;
    -h | --help)
      printf 'usage: host-palette [-w] [NAME]\n'
      printf '  no NAME  list palettes, * marks the current one\n'
      printf '  NAME     use NAME in this shell and what it starts\n'
      printf '  -w NAME  use NAME and remember it on this machine\n'
      unset _hp_write
      return 0
      ;;
  esac

  if [ -z "$1" ]; then
    _hp_list
    unset _hp_write
    return 0
  fi

  if ! _hp_load "$1"; then
    printf 'host-palette: no palette "%s" in %s\n' "$1" "$HOST_PALETTE_FILE" >&2
    unset _hp_write
    return 1
  fi

  if [ "$_hp_write" -eq 1 ]; then
    printf '%s\n' "$1" > "$HOST_PALETTE_DIR/host" || { unset _hp_write; return 1; }
    # The file is now the source of truth; an override would shadow it.
    unset HOST_PALETTE_OVERRIDE
    if command -v tmux >/dev/null 2>&1; then
      tmux set-environment -gu HOST_PALETTE_OVERRIDE >/dev/null 2>&1
      "$HOST_PALETTE_DIR/tmux.sh"
    fi
  else
    HOST_PALETTE_OVERRIDE="$1"
    export HOST_PALETTE_OVERRIDE
  fi
  unset _hp_write

  HOST_PALETTE="$1"
  export HOST_PALETTE
  # Consumers that render per shell re-read $HOST_PALETTE.
  if command -v _starship_render >/dev/null 2>&1; then
    _starship_render
  fi
}
