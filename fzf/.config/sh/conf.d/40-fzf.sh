command -v fzf >/dev/null 2>&1 || return 0

# Use fd instead of find: respects .gitignore, skips .git, much faster
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}'"
export FZF_ALT_C_OPTS="--preview 'ls -la {}'"

if [ -n "${ZSH_VERSION:-}" ]; then
  source <(fzf --zsh)
elif [ -n "${BASH_VERSION:-}" ]; then
  eval "$(fzf --bash)"
fi

# The four things it gives you
#
# Ctrl-R — history search. Press it, type fragments in any order. git rb main finds git rebase --onto origin/main. This is the big one; it replaces bash/zsh's exact-substring Ctrl-R entirely. Enter runs it, Ctrl-/ toggles a preview of the full command when it's too long for one line.
#
# Ctrl-T — insert file paths at the cursor. You're mid-command:
#
# nvim <Ctrl-T>
#
# fzf opens, you fuzzy-find, hit Enter, and the path is pasted onto the command line — you're still editing. Tab multi-selects, so you can pick five files and paste them all
# Alt-C — cd into a subdirectory. Fuzzy-find a directory below $PWD and jump straight into it. On macOS this needs one setting: iTerm2 → Settings → Profiles → Keys → Left Option key → Esc+. Otherwise Option-C types ç.
#
# **<Tab> — fuzzy completion trigger. This is the one people miss. Anywhere you'd normally hit Tab, type ** first:
# Inside the fzf window
#
# Ctrl-J/Ctrl-K or arrows to move, Tab to multi-select, Ctrl-C/Esc to bail. Typing 'foo anchors an exact match, ^foo a prefix, foo$ a suffix, !foo excludes — useful when fuzzy matching returns too much.
#
# One caveat for your setup
#
# FZF_DEFAULT_COMMAND with fd respects .gitignore, so Ctrl-T won't show ignored files. That's usually what you want, but in a dotfiles repo where you're editing gitignored things it'll look broken. Add --no-ignore-vcs to that command if it bites you.
