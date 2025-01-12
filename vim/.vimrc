call plug#begin()
      Plug 'ap/vim-css-color'
      Plug 'sheerun/vim-polyglot'
      Plug 'junegunn/goyo.vim'
      Plug 'tpope/vim-commentary'
      Plug 'tpope/vim-sensible'
      Plug 'itchyny/lightline.vim'
      Plug 'gkeep/iceberg-dark'
      Plug 'junegunn/fzf', {'do': { -> fzf#install()}}
      Plug 'junegunn/fzf.vim'
      Plug 'raimondi/delimitmate'
      Plug 'ervandew/supertab'

      " Plug 'dense-analysis/ale'
      " Plug 'maximbaz/lightline-ale'
      " Plug 'lifepillar/vim-mucomplete'

call plug#end()

if has("gui_running")
      set guifont=CaskadiaCove\ NFM
      au VimEnter * colorscheme iceberg
endif

let g:lightline = {
      \ 'colorscheme': 'icebergDark',
      \ 'mode_map': {
            \ 'n' : 'NOR',
            \ 'i' : 'INS',
            \ 'R' : 'REP',
            \ 'v' : 'V',
            \ 'V' : 'VL',
            \ "\<C-v>": 'VB',
            \ 'c' : 'CMD',
            \ 's' : 'S',
            \ 'S' : 'SL',
            \ "\<C-s>": 'SB',
            \ 't': 'T',
      \ },
      \ 'tabline_separator': { 'left': '', 'right': '' },
      \ 'tabline_subseparator': { 'left': ''},
      \ 'subseparator': { 'left': '\ue0bb', 'right': '\ue0bd' }
\}
" let g:lightline.component_expand = {
"       \  'linter_checking': 'lightline#ale#checking',
"       \  'linter_infos': 'lightline#ale#infos',
"       \  'linter_warnings': 'lightline#ale#warnings',
"       \  'linter_errors': 'lightline#ale#errors',
"       \  'linter_ok': 'lightline#ale#ok',
"       \ }
" let g:lightline.component_type = {
"       \     'linter_checking': 'right',
"       \     'linter_infos': 'right',
"       \     'linter_warnings': 'warning',
"       \     'linter_errors': 'error',
"       \     'linter_ok': 'right',
"       \ }
" let g:lightline.active = {
"             \ 'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
"             \            [ 'lineinfo' ],
" 	    \            [ 'percent' ],
" 	    \            [ 'fileformat', 'fileencoding', 'filetype'] ] }

" let g:lightline#ale#indicator_checking = "\uf110"
" let g:lightline#ale#indicator_infos = "\uf129"
" let g:lightline#ale#indicator_warnings = "\uf071"
" let g:lightline#ale#indicator_errors = "\uf05e"
" let g:lightline#ale#indicator_ok = "\uf00c"

set background=dark
set expandtab
set shiftwidth=2
set tabstop=2
set spell spelllang=en_gb
set nocompatible
set smartcase
set foldcolumn=2

let loaded_netrwPlugin = 1
let mapleader=";"

nnoremap <silent> <tab> >>
nnoremap <silent> <s-tab> <<
vnoremap <silent> <tab> >
vnoremap <silent> <s-tab> <

set autoindent
set smartindent
set smartcase
set pumheight=10
set showmatch
set laststatus=2
filetype plugin on
set omnifunc=syntaxcomplete#Complete

set noshowmode
set ignorecase
set wildmenu
set number relativenumber
set noerrorbells

syntax on
set encoding=UTF-8
set re=0
set redrawtime=10000

set clipboard=unnamedplus "Linux

filetype on
filetype plugin on

" delete single character without copying into register
nnoremap x "_x

highlight SpellBad ctermfg=lightred ctermbg=none
highlight SpellCap ctermfg=lightcyan ctermbg=none
highlight SpellLocal ctermfg=lightyellow ctermbg=none
highlight SpellRare ctermfg=lightgrey ctermbg=none

iabbrev i <Esc>cc-<Space>
iabbrev 1i <Esc>cc<Tab>-<Space>
iabbrev 2i <Esc>cc<Tab><Tab>-<Space>

autocmd bufenter *.md nnoremap <leader>2# <Esc>I##<Space>
autocmd bufenter *.md nnoremap <leader>3# <Esc>I###<Space>
autocmd bufenter *.md nnoremap <leader>4# <Esc>I####<Space>
autocmd bufenter *.md nnoremap <leader>5# <Esc>I#####<Space>
autocmd bufenter *.md nnoremap <leader>6# <Esc>I######<Space>

autocmd bufenter *.md iabbrev 2# ##
autocmd bufenter *.md iabbrev 3# ###
autocmd bufenter *.md iabbrev 4# ####
autocmd bufenter *.md iabbrev 5# #####
autocmd bufenter *.md iabbrev 6# ######

nnoremap <silent> <leader>n :bnext<CR>
nnoremap <silent> <leader>p :bprevious<CR>
nnoremap <silent> <leader>d :bdelete<CR>

" nnoremap <leader>ft <Esc>{jzt<C-O>
nnoremap } }zz
nnoremap { {zz
" nnoremap <leader>fz <Esc>{jzz<C-O>
" nnoremap <leader>fb <Esc>{jzb<C-O>
nnoremap % %zz

nnoremap <silent> <leader>l <Esc>:set number! relativenumber!<CR>

nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> <leader>= gg=G2<C-O>zz

set cpt=.,k,w,b

colorscheme iceberg
set shortmess+=c

let g:fzf_colors =
      \ { 'fg':    ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'Ignore'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'] }
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>i :PlugInstall<CR>
nnoremap <silent> <leader>c :PlugClean<CR>
let g:fzf_preview_window = ['right:60%', 'ctrl-/']

" DrChip's additional man.vim stuff
syn match manSectionHeading "^\s\+[0-9]\+\.[0-9.]*\s\+[A-Z].*$" contains=manSectionNumber
syn match manSectionNumber "^\s\+[0-9]\+\.[0-9]*" contained
syn region manDQString start='[^a-zA-Z"]"[^", )]'lc=1 end='"' contains=manSQString
syn region manSQString start="[ \t]'[^', )]"lc=1 end="'"
syn region manSQString start="^'[^', )]"lc=1 end="'"
syn region manBQString start="[^a-zA-Z`]`[^`, )]"lc=1 end="[`']"
syn region manBQSQString start="``[^),']" end="''"
syn match manBulletZone transparent "^\s\+o\s" contains=manBullet
syn case match
syn keyword manBullet contained o
syn match manBullet contained "\[+*]"
syn match manSubSectionStart "^\*" skipwhite nextgroup=manSubSection
syn match manSubSection ".*$" contained

hi link manSectionNumber Number
hi link manDQString String
hi link manSQString String
hi link manBQString String
hi link manBQSQString String
hi link manBullet Special
hi manSubSectionStart term=NONE cterm=NONE gui=NONE ctermfg=black ctermbg=black guifg=navyblue guibg=navyblue
hi manSubSection term=underline cterm=underline gui=underline ctermfg=green guifg=green

set ts=8

nnoremap <silent> <leader>g :Goyo<CR>

function! s:goyo_enter()
      if executable('tmux') && strlen($TMUX)
            set nonumber
            set norelativenumber
            silent !tmux set status off
            silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
      endif
endfunction

function! s:goyo_leave()
      if executable('tmux') && strlen($TMUX)
            set number
            set relativenumber
            silent !tmux set status on
            silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
      endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

nnoremap <silent> <Leader>r :History<CR>
nnoremap <silent> <Leader>v :so ~/.vimrc<CR>


" source for dictionary, current or other loaded buffers, see ':help cpt'
set cpt=.,k,w,b

set completeopt=menu,menuone,noselect,preview

" let g:mucomplete#enable_auto_at_startup = 1
" let g:mucomplete#chains = {}
" let g:mucomplete#chains.default  = ['path', 'omni', 'keyn', 'dict', 'uspl']
" let g:mucomplete#chains.markdown = ['path', 'keyn', 'dict', 'uspl']
" imap <expr> <down> mucomplete#extend_fwd("\<down>")

set updatetime=300
imap <script><silent> <Plug>SuperTabForward <c-r>=SuperTab('n')<cr>
imap <script><silent> <Plug>SuperTabBackward <c-r>=SuperTab('p')<cr>
let g:SuperTabMappingForward = '<s-tab>'
let g:SuperTabMappingBackward = '<tab>'
