#!/bin/bash

# Nothing here makes sense without nvim -- and EDITOR=nvim on a host that
# lacks it breaks `git commit`, crontab -e, etc. -- so bail out early.
command -v nvim >/dev/null 2>&1 || return 0

alias v=nvim
alias vi=nvim
alias vim=nvim

# VISUAL is what most tools (git, less v, fc) check first; EDITOR is the
# fallback for the ones that only know the older variable.
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'
