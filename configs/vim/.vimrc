" ~/.vimrc - Portable Vim editor configuration

" Core UI settings
set number              " Show line numbers
set relativenumber      " Show relative line numbers (helpful for navigation)
set ruler               " Show cursor position info
set showcmd             " Show incomplete commands in status line
set wildmenu            " Visual autocomplete for command menu

" Search settings
set hlsearch            " Highlight search matches
set incsearch           " Show search matches as you type
set ignorecase          " Case insensitive search
set smartcase           " Case sensitive search if search term contains uppercase letters

" Code formatting / Indentation
set expandtab           " Convert tabs to spaces
set tabstop=4           " A tab is 4 spaces wide
set shiftwidth=4        " Indent is 4 spaces wide
set softtabstop=4       " Match tabstop
set autoindent          " Copy indent from current line when starting a new line
set smartindent         " Intelligent auto-indenting for C-like syntax

" Performance & UX
set backspace=indent,eol,start " Normal backspace behavior over indent, eol, and start
set hidden              " Allow switching away from unsaved buffers
set nobackup            " Don't create backup files
set noswapfile          " Don't create swap files
set history=1000        " Store 1000 lines of command history

" Syntax highlighting
syntax on               " Enable syntax highlighting
filetype plugin indent on " Enable file type detection, plugins, and custom indents

" Visual line mapping (navigates wrapped lines logically)
nnoremap j gj
nnoremap k gk
