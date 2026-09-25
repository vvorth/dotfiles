#!/bin/sh
# Push this machine's palette into tmux as the @hp_c1..@hp_t5 user options
# (plus @hp_name). tmux/.tmux.conf writes its status bar in terms of those, so
# this script only supplies colours, never layout.
#
# Run by .tmux.conf on every (re)load, and by `host-palette -w` to repaint a
# running server. Must print nothing: run-shell shows any output in a pane.

lib="${0%/*}/lib.sh"
[ -r "$lib" ] || exit 0
. "$lib"
_hp_select || exit 0

tmux set -g @hp_name "$HP_NAME" \; \
  set -g @hp_c1 "$HP_C1" \; \
  set -g @hp_c2 "$HP_C2" \; \
  set -g @hp_c3 "$HP_C3" \; \
  set -g @hp_c4 "$HP_C4" \; \
  set -g @hp_c5 "$HP_C5" \; \
  set -g @hp_t1 "$HP_T1" \; \
  set -g @hp_t2 "$HP_T2" \; \
  set -g @hp_t5 "$HP_T5" \
  >/dev/null 2>&1
exit 0
