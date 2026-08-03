#!/bin/bash

alias vi=nvim
alias vim=nvim

NVIM_LESS=/usr/share/nvim/runtime/scripts/less.sh
[[ -f $NVIM_LESS ]] && alias less=$NVIM_LESS || true
[[ -f $NVIM_LESS ]] && PAGER=$NVIM_LESS || true

export EDITOR=nvim
export MANPAGER='nvim +Man!'


