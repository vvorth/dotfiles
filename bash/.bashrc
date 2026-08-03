#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Append to the history file immediately, do not overwrite it
shopt -s histappend

# Add timestamps to history (YYYY-MM-DD HH:MM:SS)
export HISTTIMEFORMAT="%F %T "

# Save current command and fetch new ones from other terminals on every prompt
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"


# --- modular per-package config ---
_bash_confd="${XDG_CONFIG_HOME:-$HOME/.config}/bash/conf.d"
if [ -d "$_bash_confd" ]; then
  for f in "$_bash_confd"/*.sh; do
    [ -r "$f" ] && source "$f"
  done
fi
unset _bash_confd


# Color Reset
NC='\[\e[0m\]'             # No Color / Reset

# Regular Colors
BLACK='\[\e[0;30m\]'       # Black
RED='\[\e[0;31m\]'         # Red
GREEN='\[\e[0;32m\]'       # Green
YELLOW='\[\e[0;33m\]'      # Yellow
BLUE='\[\e[0;34m\]'        # Blue
PURPLE='\[\e[0;35m\]'      # Purple
CYAN='\[\e[0;36m\]'        # Cyan
WHITE='\[\e[0;37m\]'       # White

# Bold Colors
BLACK_BOLD='\[\e[1;30m\]'  # Black (Bold)
RED_BOLD='\[\e[1;31m\]'    # Red (Bold)
GREEN_BOLD='\[\e[1;32m\]'  # Green (Bold)
YELLOW_BOLD='\[\e[1;33m\]' # Yellow (Bold)
BLUE_BOLD='\[\e[1;34m\]'   # Blue (Bold)
PURPLE_BOLD='\[\e[1;35m\]' # Purple (Bold)
CYAN_BOLD='\[\e[1;36m\]'   # Cyan (Bold)
WHITE_BOLD='\[\e[1;37m\]'  # White (Bold)

# Background Colors
BLACK_BG='\[\e[40m\]'      # Black Background
RED_BG='\[\e[41m\]'        # Red Background
GREEN_BG='\[\e[42m\]'      # Green Background
YELLOW_BG='\[\e[43m\]'     # Yellow Background
BLUE_BG='\[\e[44m\]'       # Blue Background
PURPLE_BG='\[\e[45m\]'     # Purple Background
CYAN_BG='\[\e[46m\]'       # Cyan Background
WHITE_BG='\[\e[47m\]'      # White Background

PS1="[\u@\h \W]\$ "
#PS1="${CYAN_BOLD}[\u@\h \W]${NC}\$ "


#load local config if exist
[[ -f ~/.bashrc.local ]] && . ~/.bashrc.local
[[ -f ~/.aliases ]] && . ~/.aliases

