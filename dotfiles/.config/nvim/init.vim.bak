"" Neovim rc config starts here
set packpath+=~/.local/share/nvim

" Enable ALE
let g:ale_completion_enabled = 1

" Configure ALE
set omnifunc=ale#completion#OmniFunc
let g:ale_completion_autoimport = 0
let g:ale_use_neovim_diagnostics_api = 1

" Define a fixed path variable for config directory
"let $VIMCONFIG = expand('~/.config/nvim')

" Don't source /usr/share/vim*
"set runtimepath=$VIMCONFIG

" Basic indent and tab settings
set nocompatible
set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
" Let the cursor go anywhere, even into empty space.        
set virtualedit=all  

" UI and visual settings
set termguicolors
set hlsearch
set incsearch
set background=dark
set wrap
"set number
"set relativenumber
"set cursorline
set showmatch
set matchtime=3
set showmode
set laststatus=0
set ruler
set showcmd
set history=10000
set mouse=
set textwidth=0
set backspace=indent,eol,start
set linespace=1
set signcolumn=no
set nolist
set linebreak
set textwidth=0
set wrapmargin=0
set formatoptions-=t
set expandtab

" Clipboard
set clipboard+=unnamed,unnamedplus

" Shell configuration
set shell=/bin/bash

" Enable swapfile
set swapfile

" File type support
filetype on
filetype plugin on
filetype indent on

" Syntax highlighting
syntax on
colorscheme github_dark_default
"hi Normal guibg='#000000' guifg='#CCCCCC'
hi Normal ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
hi NormalNC ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
hi SignColumn ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE 
hi EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE 
hi LineNr ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE 

" remove ~
set fillchars=eob:\ 

" Mappings
" inoremap jk <Esc>
" inoremap kj <Esc>

" Persistent undo
set undofile
set undodir=~/.cache/nvim-undo

" Return to last edit position when opening files
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Pressing Esc in normal mode clears search highlight
nnoremap <silent> <Esc> :nohl<CR>

" Basic settings
"set autoread
"
"" Autosave (basic implementation)
"autocmd InsertLeave,TextChanged * silent! wall
"
"" Autoread with Timer
"set autoread
"set updatetime=100
"
"" Update interval in milliseconds
"let s:autoread_interval = 100
"
"" Function to check for file changes
"function! s:CheckForChanges(timer_id)
"checktime
"endfunction
"
""" Timer ID (initially empty)
"let s:autoread_timer = 0
"
""" Function to start the timer
"function! s:StartAutoreadTimer()
"if s:autoread_timer == 0
"let s:autoread_timer = timer_start(s:autoread_interval, 's:CheckForChanges', {'repeat': -1})
"endif
"endfunction
"
""" Function to stop the timer
"function! s:StopAutoreadTimer()
"if s:autoread_timer != 0
"call timer_stop(s:autoread_timer)
"let s:autoread_timer = 0
"endif
"endfunction
"
""" Stop timer on VimLeave to avoid it running after exit
"augroup autoread_timer
"autocmd!
"autocmd VimLeavePre * call s:StopAutoreadTimer()
"augroup END
"
""" Start the timer automatically when Vim starts
"augroup start_autoread
"autocmd!
"autocmd VimEnter * call s:StartAutoreadTimer()
"augroup END
"autocmd FileChangedShell * silent! edit!

" Disable autocommenting
autocmd FileType * setlocal formatoptions-=croql

