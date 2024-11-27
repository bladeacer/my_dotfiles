set expandtab
set shiftwidth=4
set tabstop=4
set spell spelllang=en_gb
set nocompatible
set smartcase
set foldcolumn=3

let loaded_netrwPlugin = 1

set autoindent
set smartindent
set smartcase
set pumheight=10
set showmatch
set laststatus=2
set cmdheight=1
set cursorline
filetype plugin indent on

set clipboard=unnamedplus "Linux

" delete single character without copying into register
nnoremap x "_x

highlight SpellBad ctermfg=lightgrey ctermbg=lightred
highlight SpellCap ctermfg=lightgrey ctermbg=lightcyan
highlight SpellLocal ctermfg=lightgrey ctermbg=lightyellow
highlight SpellRare ctermfg=lightgrey ctermbg=none

syntax on
set encoding=UTF-8
set re=0
set redrawtime=100000

syntax match MarkdownBold /\*\*\(.*\)\*\*/
highlight MarkdownBold ctermfg=white ctermbg=none

syntax match MarkdownBold /\*\*\(.*\)\*\*/
syntax match MarkdownUnderline /_\(.*\)_/

syntax match MarkdownBold /\*\*\(.*\)\*\*/
highlight MarkdownUnderline ctermfg=white ctermbg=none
syntax match MarkdownItalic /\*\(.*\)\*/
highlight MarkdownItalic ctermfg=white ctermbg=none

autocmd bufenter *.md inoremap 2{ {}<Esc>i
autocmd bufenter *.md inoremap 2e{ {<CR><CR>}<Esc>ki

autocmd bufenter *.md inoremap 2( ()<Esc>i
autocmd bufenter *.md inoremap 2e( (<CR><Tab><CR>)<Esc>ki

autocmd bufenter *.md inoremap  2[ []<Esc>i
autocmd bufenter *.md inoremap  2e[ [<CR><CR>]<Esc>ki
autocmd bufenter *.md inoremap  2$ $$<Esc>i
autocmd bufenter *.md inoremap  4$ $$$$<Esc>hi
autocmd bufenter *.md inoremap  4e$ $$<CR>$$<Esc>kA
autocmd bufenter *.md inoremap  2" ""<Esc>i
autocmd bufenter *.md inoremap  2' ''<Esc>i
autocmd bufenter *.md inoremap  2` ``<Esc>i
autocmd bufenter *.md inoremap  2* **<Esc>i
autocmd bufenter *.md inoremap  4* ****<Esc>hi
autocmd bufenter *.md inoremap  3` ```<CR><CR>```<Esc>kcc
autocmd bufenter *.md inoremap  js` ```js<CR><CR>```<Esc>kcc
autocmd bufenter *.md inoremap  cs` ```cs<CR><CR>```<Esc>kcc
autocmd bufenter *.md inoremap  3~ ~~~<CR>~~~<Esc>

autocmd bufenter *.md inoremap 3_ ___<Esc><<1O<Esc>2j
autocmd bufenter *.md inoremap 3- ---<Esc><<1O<Esc>2j

iabbrev i- <Esc>cc-<Space>
iabbrev 1i- <Esc>cc<Tab>-<Space>
iabbrev 2i- <Esc>cc<Tab><Tab>-<Space>

autocmd bufenter *.md iabbrev 22# <Esc>cc##
autocmd bufenter *.md iabbrev 33# <Esc>cc###
autocmd bufenter *.md iabbrev 44# <Esc>cc####
autocmd bufenter *.md iabbrev 55# <Esc>cc#####
autocmd bufenter *.md iabbrev 66# <Esc>cc######

autocmd bufenter *.md iabbrev 2# ##
autocmd bufenter *.md iabbrev 3# ###
autocmd bufenter *.md iabbrev 4# ####
autocmd bufenter *.md iabbrev 5# #####
autocmd bufenter *.md iabbrev 6# ######

autocmd bufenter *.md iabbrev iih Insert image here
autocmd bufenter *.md iabbrev OSA Operating systems and administration
autocmd bufenter *.md iabbrev AS Applications Security

autocmd bufenter *.md inoremap mans >[!question]- My Answer<CR>
autocmd bufenter *.md inoremap nans >[!question]- My Answer<CR>
autocmd bufenter *.md inoremap sans >[!question]- Suggested Answer<CR>
autocmd bufenter *.md inoremap `nwp - [ ] UXDMT Lecture slides<CR>[ ] UXDMT Lecture video<CR>[ ] OSA Lecture slides<CR>[ ] OSA Lecture video<CR>[ ] OSA Tutorial<CR>[ ] AS Lecture slides<CR>[ ] AS Lecture video<CR>[ ] AS Tutorial<CR>[ ] EDP Lecture<CR>[ ] EDP Practical<CR>[ ] MAD Lecture<CR>[ ] MAD Practical<CR>[ ] MRTT Lecture<CR>[ ] MRTT Lecture video

autocmd bufenter *.md iabbrev prop ---<CR>alias:<CR>Week:<CR>Course:<CR>Semester:<CR>Year:<CR>Topic:<CR>---<ESC>6kA
autocmd bufenter *.md abbrev nend ___<CR>## Summary<CR><CR>### Questions<CR><CR>### Tutorial
autocmd bufenter *.md abbrev chbx - [ ]
autocmd bufenter *.md abbrev skl 💀
autocmd bufenter *.md abbrev nerd 🤓

autocmd bufenter *.html iabbrev html <html></html><Esc>2ba
autocmd bufenter *.html iabbrev body <body></body><Esc>2ba
autocmd bufenter *.html iabbrev scriptsrc <script src=""></script><Esc>2bla
autocmd bufenter *.html iabbrev script <script></script><Esc>2ba

map gn :bnext<CR>
map gp :bprevious<CR>
map gd :bdelete<CR>
map gd :bdelete<CR>

nnoremap ft <Esc>{jzt<C-O>
nnoremap fm <Esc>{jzz<C-O>
nnoremap fb <Esc>{jzb<C-O>
nnoremap { {ft
nnoremap } }ft
nnoremap % %zz

set noshowmode
set ignorecase
set wildmenu
set number
set relativenumber
set noerrorbells

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

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

let g:PaperColor_Theme_Options = {
      \   'theme': {
        \     'default': {
          \       'transparent_background': 0
          \     }
          \   }
          \ }

function! SetBgOpaque()
  hi Normal guibg=#1c1c1c ctermbg=black
  hi LineNr guibg=#1c1c1c ctermbg=black
  hi SignColumn guibg=#1c1c1c ctermbg=black
endfunction

function! SetBgTransparent()
  hi Normal guibg=NONE ctermbg=NONE
  hi LineNr guibg=NONE ctermbg=NONE
  hi SignColumn guibg=NONE ctermbg=NONE
endfunction

let t:is_transparent = g:PaperColor_Theme_Options.theme.default.transparent_background
function! ToggleTransparency()
  if t:is_transparent == 0
    call SetBgTransparent()
    let t:is_transparent = 1
  else
    call SetBgOpaque()
    let t:is_transparent = 0
  endif
endfunction

inoremap <silent><F12> <Esc>:call ToggleTransparency()<CR>a
nnoremap <silent><F12> :call ToggleTransparency()<CR>

inoremap <F10> <Esc><Esc>]szza<C-X><C-S>
nnoremap <F10> <Esc>]szza<C-X><C-S>

inoremap <F9> <C-X><C-K>
nnoremap <F9> a<C-X><C-K>

inoremap <F8> <C-X><C-S>
nnoremap <F8> a<C-X><C-S>

inoremap <silent><F7> <Esc>:set number! relativenumber!<CR>a
nnoremap <silent><F7> <Esc>:set number! relativenumber!<CR>

nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> gg=G gg=G2<C-O>

let g:apc_enable_ft = {'*':1}
let g:apc_trigger = "\<c-x>\<c-o>"

set cpt=.,k,w,b

set noshowmode
set background=dark
let g:airline_theme='papercolor'
colorscheme PaperColor
hi SignColumn guibg=NONE ctermbg=NONE

set completeopt=menu,menuone,noselect
set shortmess+=c

filetype on
filetype plugin on
set omnifunc=syntaxcomplete#Complete

set rtp+=~/.fzf
let g:fzf_colors =
      \ { 'fg':      ['fg', 'Normal'],
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
