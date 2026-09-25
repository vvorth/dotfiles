source $VIMRUNTIME/defaults.vim

runtime! archlinux.vim

set background=dark

" Selenized Dark to match Ghostty: ~/.vim/colors/selenized.vim, vendored as-is
" from jan-warchol/selenized (editors/vim, Vim license). Exact in truecolor;
" otherwise it uses the terminal's 16 ANSI colours, which is close under a
" Selenized terminal theme but not identical.
if has('termguicolors') && ($COLORTERM =~# '^\%(truecolor\|24bit\)$' || !empty($TMUX))
  " vim only knows the 24-bit escapes for xterm-like TERMs; spell them out so
  " tmux-256color and friends get them too.
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
try
  colorscheme selenized
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme slate
endtry

set number " show line number
set relativenumber

set expandtab " use spaces instead of tabs
set tabstop=4 " number of spaces that a tab counts for in a file
set shiftwidth=4 " number of spaces to use for each autoindent level
set softtabstop=4 " number of spaces that a tab counts for while editing

set mouse= " modes: n: normal, v: visual, i: insert, c: command-line, a: all, empty: disable
