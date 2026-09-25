# host-palette: which colour ramp this machine uses, and what is in it.
#
# Sourced by sh/conf.d/30-host-palette.sh (bash, zsh) and by tmux.sh (/bin/sh),
# so this is plain POSIX sh. Functions set variables instead of printing, and
# use only builtins, so a shell start costs no forks here.
#
# Which palette, highest precedence first:
#   1. $HOST_PALETTE_OVERRIDE -- set by `host-palette NAME`, for this shell
#      and whatever it starts (subshells, a tmux server started from it)
#   2. ~/.config/host-palette/host -- one word, untracked, machine-local;
#      `host-palette -w NAME` writes it
#   3. ~/.config/starship-host -- the same thing under its old name, still
#      honoured so machines set up before the rename keep their colour
#   4. the hostname table in _hp_for_host() below (tracked, so filling it in
#      once teaches every machine that syncs this repo)
#   5. slate, the neutral fallback -- also used when a name is not in the file

HOST_PALETTE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/host-palette"
HOST_PALETTE_FILE="$HOST_PALETTE_DIR/palettes"

# Sets HP_NAME from the hostname.
_hp_for_host() {
  _hp_h="${HOST:-${HOSTNAME:-}}"
  [ -n "$_hp_h" ] || _hp_h="$(uname -n 2>/dev/null)"
  case "${_hp_h%%.*}" in
    # ---- one line per machine; `host-palette` lists the choices ----------
    # mbp | mbp-*) HP_NAME=cyan   ;;
    # nas)         HP_NAME=green  ;;
    # vps)         HP_NAME=purple ;;
    *) HP_NAME=slate ;;
  esac
  unset _hp_h
}

# Sets HP_NAME to the palette this machine should use (not yet validated).
_hp_resolve() {
  HP_NAME="${HOST_PALETTE_OVERRIDE:-}"
  for _hp_f in "$HOST_PALETTE_DIR/host" "${XDG_CONFIG_HOME:-$HOME/.config}/starship-host"; do
    [ -z "$HP_NAME" ] && [ -r "$_hp_f" ] && read -r HP_NAME _hp_rest < "$_hp_f"
  done
  unset _hp_f _hp_rest
  [ -n "$HP_NAME" ] || _hp_for_host
}

# _hp_load NAME -- sets HP_C1..HP_C5, HP_T1, HP_T2, HP_T5 from the palettes
# file. Returns 1, with them unset, if there is no such (complete) row.
_hp_load() {
  if [ -n "$1" ] && [ -r "$HOST_PALETTE_FILE" ]; then
    while read -r _hp_n HP_C1 HP_C2 HP_C3 HP_C4 HP_C5 HP_T1 HP_T2 HP_T5 _hp_rest; do
      if [ "$_hp_n" = "$1" ] && [ -n "$HP_T5" ]; then
        unset _hp_n _hp_rest
        return 0
      fi
    done < "$HOST_PALETTE_FILE"
  fi
  unset _hp_n _hp_rest HP_C1 HP_C2 HP_C3 HP_C4 HP_C5 HP_T1 HP_T2 HP_T5
  return 1
}

# Resolve and load this machine's palette: HP_NAME plus the colours. A typo in
# the host file or the table lands on slate rather than on a missing palette.
_hp_select() {
  _hp_resolve
  _hp_load "$HP_NAME" && return 0
  HP_NAME=slate
  _hp_load slate
}
