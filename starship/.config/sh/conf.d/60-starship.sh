# starship prompt, with a per-host colour.
#
# starship cannot expand env vars inside style strings and has no config
# includes (both checked against 1.26), so "one config, a different colour per
# machine" is done by keeping a single ~/.config/starship.toml with several
# [palettes.*] in it, and generating a copy per palette whose `palette = "..."`
# line has been rewritten. $STARSHIP_CONFIG then points at that copy, under
# ~/.cache/starship/. Nothing else in this repo has to know about it.
#
# Which palette this machine uses, highest precedence first:
#   1. $STARSHIP_HOST_PALETTE, if already exported (so subshells agree)
#   2. ~/.config/starship-host -- one word, untracked, machine-local
#   3. the hostname table in _starship_palette_for_host() below (tracked, so
#      filling it in once teaches every machine that syncs this repo)
#   4. "slate", the neutral grey fallback for machines not assigned a colour
#
# Day to day:  starship-palette            -> show current + available
#              starship-palette purple     -> switch this shell only
#              starship-palette -w purple  -> switch and remember on this host

command -v starship >/dev/null 2>&1 || return 0

_starship_base="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
[ -r "$_starship_base" ] || return 0

# Palette names, read straight out of the config, so adding a [palettes.foo]
# block there is the only step needed to make "foo" selectable here.
_starship_palettes() {
  sed -n 's/^\[palettes\.\([A-Za-z0-9_-]*\)\].*/\1/p' "$_starship_base"
}

_starship_has_palette() {
  for _starship_p in $(_starship_palettes); do
    if [ "$_starship_p" = "$1" ]; then
      unset _starship_p
      return 0
    fi
  done
  unset _starship_p
  return 1
}

_starship_palette_for_host() {
  _starship_h="${HOST:-${HOSTNAME:-}}"
  [ -n "$_starship_h" ] || _starship_h="$(uname -n 2>/dev/null)"
  case "${_starship_h%%.*}" in
    # ---- one line per machine; `starship-palette` lists the choices -------
    # mbp | mbp-*) echo cyan   ;;
    # nas)         echo green  ;;
    # vps)         echo purple ;;
    *) echo slate ;;
  esac
  unset _starship_h
}

# Rewrite the palette line into a cached copy and point starship at it. The
# copy is only rebuilt when the tracked config is newer, so a normal shell
# start costs one stat() and no subprocesses -- the validation and the sed
# only run on the rare miss.
_starship_render() {
  _starship_gen="${XDG_CACHE_HOME:-$HOME/.cache}/starship/prompt-$1.toml"
  if [ ! -f "$_starship_gen" ] || [ "$_starship_base" -nt "$_starship_gen" ]; then
    _starship_has_palette "$1" || return 1
    mkdir -p "${_starship_gen%/*}" || return 1
    sed "s/^palette = .*/palette = \"$1\"/" "$_starship_base" > "$_starship_gen" || return 1
  fi
  STARSHIP_CONFIG="$_starship_gen"
  export STARSHIP_CONFIG
}

starship-palette() {
  _starship_write=0
  case "$1" in
    -w | --write)
      _starship_write=1
      shift
      ;;
  esac

  if [ -z "$1" ]; then
    printf 'current:   %s\n' "${STARSHIP_HOST_PALETTE:-?}"
    printf 'available: %s\n' "$(_starship_palettes | tr '\n' ' ')"
    unset _starship_write
    return 0
  fi

  if ! _starship_has_palette "$1"; then
    printf 'starship-palette: no palette "%s" in %s\n' "$1" "$_starship_base" >&2
    unset _starship_write
    return 1
  fi

  _starship_render "$1" || return 1
  STARSHIP_HOST_PALETTE="$1"
  export STARSHIP_HOST_PALETTE
  if [ "$_starship_write" -eq 1 ]; then
    printf '%s\n' "$1" > "${XDG_CONFIG_HOME:-$HOME/.config}/starship-host"
  fi
  unset _starship_write
}

if [ -z "${STARSHIP_HOST_PALETTE:-}" ]; then
  _starship_host_file="${XDG_CONFIG_HOME:-$HOME/.config}/starship-host"
  if [ -r "$_starship_host_file" ]; then
    read -r STARSHIP_HOST_PALETTE < "$_starship_host_file"
  fi
  [ -n "${STARSHIP_HOST_PALETTE:-}" ] || STARSHIP_HOST_PALETTE="$(_starship_palette_for_host)"
  export STARSHIP_HOST_PALETTE
  unset _starship_host_file
fi

# A typo in starship-host or in the table above lands here: fall back rather
# than let starship warn about a missing palette on every single prompt.
_starship_render "$STARSHIP_HOST_PALETTE" || {
  STARSHIP_HOST_PALETTE=slate
  export STARSHIP_HOST_PALETTE
  _starship_render slate
}

if [ -n "${ZSH_VERSION:-}" ]; then
  eval "$(starship init zsh)"
elif [ -n "${BASH_VERSION:-}" ]; then
  eval "$(starship init bash)"
fi
