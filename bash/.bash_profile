#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -f ~/.aliases ]] && . ~/.aliases
[[ -f ~/.aliases_nvim ]] && . ~/.aliases_nvim

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true

