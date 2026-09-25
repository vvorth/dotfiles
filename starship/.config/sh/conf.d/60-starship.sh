# starship prompt, in this machine's host palette.
#
# starship cannot expand env vars inside style strings and has no config
# includes (both checked against 1.26), so "one config, a different colour per
# machine" is done by keeping a single ~/.config/starship.toml that says
# `palette = "host"` but defines no palettes, and generating a copy of it with
# a [palettes.host] block appended -- this machine's row from
# ~/.config/host-palette/palettes. $STARSHIP_CONFIG then points at that copy,
# under ~/.cache/starship/.
#
# Which palette, and the `host-palette` command to switch it, come from the
# host-palette package (sh/conf.d/30-host-palette.sh, sourced before this).
# Without that package the prompt still works, in plain ANSI colours.

command -v starship >/dev/null 2>&1 || return 0

_starship_base="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
[ -r "$_starship_base" ] || return 0

# (Re)generate the copy for $HOST_PALETTE and point starship at it. The copy
# is only rebuilt when starship.toml or the palettes file is newer, so a
# normal shell start costs a couple of stat()s and no subprocesses.
_starship_render() {
  _starship_gen="${XDG_CACHE_HOME:-$HOME/.cache}/starship/prompt-${HOST_PALETTE:-ansi}.toml"
  if [ ! -f "$_starship_gen" ] || [ "$_starship_base" -nt "$_starship_gen" ] ||
    [ "${HOST_PALETTE_FILE:-}" -nt "$_starship_gen" ]; then
    if [ -n "${HOST_PALETTE:-}" ] && command -v _hp_load >/dev/null 2>&1 &&
      _hp_load "$HOST_PALETTE"; then
      set -- "$HP_C1" "$HP_C2" "$HP_C3" "$HP_C4" "$HP_C5" "$HP_T1" "$HP_T2" "$HP_T5"
    else
      set -- white blue bright-black black black black bright-white white
    fi
    mkdir -p "${_starship_gen%/*}" || return 1
    {
      cat "$_starship_base"
      printf '\n# ---- appended by sh/conf.d/60-starship.sh from host-palette ----\n'
      printf '[palettes.host]\n'
      printf 'c1 = "%s"\nc2 = "%s"\nc3 = "%s"\nc4 = "%s"\nc5 = "%s"\nt1 = "%s"\nt2 = "%s"\nt5 = "%s"\n' "$@"
    } > "$_starship_gen.$$" && mv -f "$_starship_gen.$$" "$_starship_gen" || return 1
  fi
  STARSHIP_CONFIG="$_starship_gen"
  export STARSHIP_CONFIG
}

_starship_render

if [ -n "${ZSH_VERSION:-}" ]; then
  eval "$(starship init zsh)"
elif [ -n "${BASH_VERSION:-}" ]; then
  eval "$(starship init bash)"
fi
