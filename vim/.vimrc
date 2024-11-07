set expandtab
set shiftwidth=2
set tabstop=2
set spell spelllang=en_gb
set nocompatible

highlight SpellBad ctermfg=white ctermbg=red
highlight SpellCap ctermfg=white ctermbg=blue
highlight SpellLocal ctermfg=white ctermbg=yellow
highlight SpellRare ctermfg=none ctermbg=none

syntax on
set encoding=UTF-8

syntax match MarkdownBold /\*\*\(.*\)\*\*/
highlight MarkdownBold ctermfg=white ctermbg=none

syntax match MarkdownUnderline /_\(.*\)_/
highlight MarkdownUnderline ctermfg=white ctermbg=none
syntax match MarkdownItalic /\*\(.*\)\*/ 
highlight MarkdownItalic ctermfg=white ctermbg=none

inoremap 2{ {}<Esc>ha
inoremap 2( ()<Esc>ha
inoremap 2[ []<Esc>ha
inoremap 2" ""<Esc>ha
inoremap 2' ''<Esc>ha
inoremap 3` ```<Esc>o```<Esc>ka

set noshowmode
set ignorecase
set wildmenu
set number
hi LineNr ctermfg=cyan
set relativenumber
set noerrorbells

inoremap <F12> <C-X><C-K>
inoremap <F10> <C-X><C-O>

map gn :bnext<cr>
map gp :bprevious<cr>
map gd :bdelete<cr>  

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_exclude_preview = 1
"au User AirlineAfterInit let g:airline_section_z = airline#section#create(['%l:%v ', 'linenr', '%p%%'])

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
      endif

let g:airline_symbols.colnr = ':'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = ' '
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'SPELL'
let g:airline_symbols.notexists = '!EXIST'
let g:airline_symbols.whitespace = 'Errors:'

set noshowmode
set background=dark
colorscheme PaperColor

setlocal omnifunc=syntaxcomplete#Complete
set completeopt=menuone,noselect
filetype on
filetype plugin on

autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteTags
autocmd FileType js set omnifunc=javascriptcomplete#CompleteTags
autocmd FileType py set omnifunc=pythoncomplete#CompleteTags
autocmd FileType kt set omnifunc=kotlincomplete#CompleteTags
autocmd FileType java set omnifunc=javacomplete#CompleteTags
autocmd FileType json set omnifunc=jsoncomplete#CompleteTags
