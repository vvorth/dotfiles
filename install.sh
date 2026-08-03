#!/usr/bin/env bash
# Symlink package directories in this repo into $HOME using GNU Stow.
# Each top-level directory (bash/, zsh/, nvim/, ...) is a stow "package"
# whose contents mirror the layout under $HOME.
#
# Usage:
#   ./install.sh                 # stow every package
#   ./install.sh bash zsh nvim   # stow only the named packages
#   ./install.sh -R nvim         # restow (useful after adding files to a package)
#   ./install.sh -D vifm         # unstow (remove the symlinks again)
#
# If a target file already exists and isn't a symlink into this repo,
# stow will refuse and list the conflict instead of overwriting it.
#
# .stowrc (repo root) sets default flags for every `stow` call made here:
#   --verbose=1    print what's being (un)linked instead of running silently
#   --no-folding   symlink at the file level, not the whole-directory level,
#                  so a directory like ~/.config/nvim stays real and keeps
#                  working if it ever holds non-repo files (caches, state)
#                  alongside the repo-managed ones.
# NOTE: GNU Stow's .stowrc has no comment syntax - every line is parsed the
# same as a CLI argument (confirmed by reading stow's own source). Don't add
# "# ..." lines to .stowrc itself, it will misparse them as package names or
# error out on anything starting with "--"; keep notes about it here instead.
#
# --target/-t is intentionally never set in .stowrc: it would otherwise
# default to the stow dir's parent, which is wrong for this layout. Below,
# -t "$HOME" is always passed explicitly so it works the same regardless of
# username or OS.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_dir"

command -v stow >/dev/null 2>&1 || {
  echo "GNU Stow is required: brew install stow  /  pacman -S stow  /  apt install stow" >&2
  exit 1
}

mode="-S"
if [[ "${1:-}" == "-D" || "${1:-}" == "-R" ]]; then
  mode="$1"
  shift
fi

packages=("$@")
if [[ ${#packages[@]} -eq 0 ]]; then
  for d in */; do
    d="${d%/}"
    [[ "$d" == ".git" ]] && continue
    packages+=("$d")
  done
fi

stow "$mode" -t "$HOME" -v "${packages[@]}"
