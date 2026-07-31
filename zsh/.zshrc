[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.aliases_nvim ]] && source ~/.aliases_nvim

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/vvorth/.lmstudio/bin"
# End of LM Studio CLI section
export PATH="$PATH:/Users/vvorth/.local/bin"

# Initialize the advanced completion system
autoload -U compinit && compinit

# Enable arrow-key menu selection for completions
zstyle ':completion:*' menu select

# Group completions by type (e.g., commands, files)
zstyle ':completion:*' group-name ''

# Case-insensitive matching (type 'git' and autocomplete matches 'GIT')
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Load the Zsh color module
autoload -U colors && colors

