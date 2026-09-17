# Transient prompt: once a command is submitted, its full two-line starship bar
# is redrawn as just "❯ <command>", so scrollback shows commands rather than a
# wall of repeated bars. The live prompt is always the full one.
#
# starship only has this built in for fish/PowerShell/cmd; for zsh it is done
# here by wrapping the line editor. zle-line-init runs the whole edit inside
# .recursive-edit, so when it returns (Enter, Ctrl-C, Ctrl-D) the prompt can be
# swapped for the short one, redrawn, and put back before the command runs.
# The short one is `starship prompt --profile transient` ([profiles] in
# starship.toml).
#
# zsh only: bash has no equivalent hook for redrawing a submitted prompt.

(( $+functions[prompt_starship_precmd] )) || return 0
(( $+functions[_starship_transient_line_init] )) && return 0

# Keep any zle-line-init that is already set (Debian's /etc/zsh/zshrc uses it
# for terminal keypad mode) by moving it aside and calling it first.
(( $+widgets[zle-line-init] )) && zle -A zle-line-init _starship_transient_prev_line_init

_starship_transient_prompt='$(starship prompt --profile transient --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}")'

_starship_transient_line_init() {
  emulate -L zsh
  (( $+widgets[_starship_transient_prev_line_init] )) && zle _starship_transient_prev_line_init -- "$@"
  [[ $CONTEXT == start ]] || return 0

  local -i ret
  while true; do
    zle .recursive-edit
    ret=$?
    # Ctrl-D on an empty line: exit as usual unless ignore_eof is set.
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT saved_rprompt=$RPROMPT
  PROMPT=$_starship_transient_prompt
  RPROMPT=
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}
zle -N zle-line-init _starship_transient_line_init
