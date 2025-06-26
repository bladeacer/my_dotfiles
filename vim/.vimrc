call plug#begin()
      Plug 'ap/vim-css-color'
      Plug 'sheerun/vim-polyglot'
      Plug 'junegunn/goyo.vim'
      Plug 'tpope/vim-commentary'
      Plug 'tpope/vim-sensible'
      Plug 'itchyny/lightline.vim'
      Plug 'cocopon/iceberg.vim'
      Plug 'gkeep/iceberg-dark'
      Plug 'junegunn/fzf', {'do': { -> fzf#install()}}
      Plug 'junegunn/fzf.vim'
      Plug 'raimondi/delimitmate'
      Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
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
      \ 'subseparator': { 'left': '\ue0bb', 'right': '\ue0bd' },
	\ 'active': {
	\   'left': [ [ 'mode', 'paste' ],
	\             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
	\ },
	\ 'component_function': {
	\   'cocstatus': 'coc#status'
	\ },
\}

" Use autocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

set termguicolors
set background=dark
set expandtab
set shiftwidth=2
set tabstop=2
set spell spelllang=en_gb
set nocompatible
set smartcase
set foldcolumn=2
set mouse=a

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
set belloff=all

syntax on
set encoding=UTF-8
set re=0
set redrawtime=10000

set clipboard+=unnamed,unnamedplus

filetype on
filetype plugin on

" delete single character without copying into register
nnoremap x "_x

highlight SpellBad ctermfg=lightred ctermbg=none
highlight SpellCap ctermfg=lightcyan ctermbg=none
highlight SpellLocal ctermfg=lightyellow ctermbg=none
highlight SpellRare ctermfg=lightgrey ctermbg=none

iabbrev 1i <Esc>cc-<Space>
iabbrev 2i <Esc>cc<Tab>-<Space>
iabbrev 3i <Esc>cc<Tab><Tab>-<Space>

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

set updatetime=300
imap <script><silent> <Plug>SuperTabForward <c-r>=SuperTab('n')<cr>
imap <script><silent> <Plug>SuperTabBackward <c-r>=SuperTab('p')<cr>
let g:SuperTabMappingForward = '<s-tab>'
let g:SuperTabMappingBackward = '<tab>'

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

let g:coc_node_path = "/usr/local/bin/node"

let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-vimlsp', 'coc-rust-analyzer', 'coc-markdownlint', 'coc-prettier', 'coc-css']
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent><nowait> [g <Plug>(coc-diagnostic-prev)
nmap <silent><nowait> ]g <Plug>(coc-diagnostic-next)

" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
nmap <leader>a  <Plug>(coc-codeaction-selected)
