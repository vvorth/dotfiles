
plugins=()

bindkey -e

CNF=/usr/share/doc/pkgfile/command-not-found.zsh
[[ -f $CNF ]] && source $CNF || true

# Define where history is stored
export HISTFILE=~/.zsh_history
#
# Increase memory and file storage limits (Defaults are often too low)
export HISTSIZE=50000
export SAVEHIST=50000

# Save timestamps to the history file
setopt EXTENDED_HISTORY

# Share history across all active terminal windows immediately
setopt SHARE_HISTORY

# Skip saving duplicate consecutive commands
setopt HIST_IGNORE_DUPS

# Don't remove trailing slash from path
setopt NO_AUTO_REMOVE_SLASH

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/vvorth/.lmstudio/bin"
# End of LM Studio CLI section
export PATH="$PATH:/Users/vvorth/.local/bin"

# Initialize the advanced completion system
autoload -U compinit && compinit

# Don't strip trailing slashes
zstyle ':completion:*' squeeze-slashes false

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


# Default PS1
PS1="[%n@%m %1~]%# "

[[ -f ~/.aliases ]] && source ~/.aliases

# --- modular per-package generic config ---
_sh_confd="${XDG_CONFIG_HOME:-$HOME/.config}/sh/conf.d"
  for f in "$_sh_confd"/*.sh(N); do
    [[ -r "$f"  ]] && source "$f"
  done
unset _sh_confd

# --- modular per-package config ---
_zsh_confd="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/conf.d"
  for f in "$_zsh_confd"/*.zsh(N); do
    [[ -r "$f"  ]] && source "$f"
  done
unset _zsh_confd

# --- machine-local overrides, not tracked in git ---
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

