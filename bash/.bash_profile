#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -f ~/.bashrc.local ]] && . ~/.bashrc.local
[[ -f ~/.aliases ]] && . ~/.aliases

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true

