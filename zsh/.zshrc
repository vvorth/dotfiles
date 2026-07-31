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

# Regular Colors
BLACK="$fg[black]"
RED="$fg[red]"
GREEN="$fg[green]"
YELLOW="$fg[yellow]"
BLUE="$fg[blue]"
PURPLE="$fg[magenta]"
CYAN="$fg[cyan]"
WHITE="$fg[white]"

# Bold Colors
BLACK_BOLD="$fg_bold[black]"
RED_BOLD="$fg_bold[red]"
GREEN_BOLD="$fg_bold[green]"
YELLOW_BOLD="$fg_bold[yellow]"
BLUE_BOLD="$fg_bold[blue]"
PURPLE_BOLD="$fg_bold[magenta]"
CYAN_BOLD="$fg_bold[cyan]"
WHITE_BOLD="$fg_bold[white]"

# Background Colors
BLACK_BG="$bg[black]"
RED_BG="$bg[red]"
GREEN_BG="$bg[green]"
YELLOW_BG="$bg[yellow]"
BLUE_BG="$bg[blue]"
PURPLE_BG="$bg[magenta]"
CYAN_BG="$bg[cyan]"
WHITE_BG="$bg[white]"

# Reset Color
NC="$reset_color"


# PS1="${RED_BOLD}[%n@%m %1~]%#${NC} "
# PS1="${RED_BG}${BLACK_BOLD}[%n@%m %1~]%#${NC} "
PS1="%F{red}[%n@%m %1~]%# %f"

