set ignorecase
set wildmenu
set number
hi LineNr ctermfg=cyan
set relativenumber
set noerrorbells

inoremap <F12> <C-X><C-K>
inoremap <F10> <C-X><C-O>

let g:airline_theme = 'violet'

setlocal omnifunc=syntaxcomplete#Complete
set completeopt=menuone,noselect
filetype on
filetype plugin on

autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteTags
autocmd FileType js set omnifunc=javascriptcomplete#CompleteTags
autocmd FileType py set omnifunc=pythoncomplete#CompleteTags

set expandtab
set shiftwidth=2
set tabstop=2
set spell spelllang=en_gb

highlight SpellBad ctermfg=white ctermbg=red
highlight SpellCap ctermfg=white ctermbg=blue
highlight SpellLocal ctermfg=white ctermbg=yellow
highlight SpellRare ctermfg=none ctermbg=none

syntax match MarkdownBold /\*\*\(.*\)\*\*/
highlight MarkdownBold ctermfg=white ctermbg=none

syntax match MarkdownUnderline /_\(.*\)_/
highlight MarkdownUnderline ctermfg=white ctermbg=none

syntax match MarkdownItalic /\*\(.*\)\*/ 
highlight MarkdownItalic ctermfg=white ctermbg=none

set ignorecase
set wildmenu
set number
hi LineNr ctermfg=cyan
set relativenumber
set noerrorbells

inoremap <F12> <C-X><C-K>
inoremap <F10> <C-X><C-O>

let g:airline_theme = 'violet'

setlocal omnifunc=syntaxcomplete#Complete
set completeopt=menuone,noselect
filetype on
filetype plugin on

autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteTags
autocmd FileType js set omnifunc=javascriptcomplete#CompleteTags
autocmd FileType py set omnifunc=pythoncomplete#CompleteTags
