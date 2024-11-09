set expandtab
set autoindent
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

inoremap 2{ {}<Esc>i
inoremap 2( ()<Esc>i
inoremap 2[ []<Esc>i
inoremap 2< \< \><Esc>i
inoremap 2$ $$<Esc>i
inoremap 4$ $$$$<Esc>hi
inoremap 2" ""<Esc>i
inoremap 2' ''<Esc>i
inoremap 2` ``<Esc>i
inoremap 2* **<Esc>i
inoremap 4* ****<Esc>hi
inoremap 3` ```<CR>```<Esc>kA
inoremap 3~ ~~~<CR>~~~<Esc>kA
inoremap 2# ##<Space>
inoremap 3# ###<Space>
inoremap 4# ####<Space>
inoremap 5# #####<Space>
inoremap 6# ######<Space>

inoremap `mas >[!question]- My Answer<CR>
inoremap `sas >[!question]- Suggested Answer<CR>
inoremap `nwp - [ ] UXDMT Lecture slides<CR><Backspace><Backspace> - [ ] UXDMT Lecture video<CR><Backspace><Backspace> - [ ] OSA Lecture slides<CR><Backspace><Backspace> - [ ] OSA Lecture video<CR><Backspace><Backspace> - [ ] OSA Tutorial<CR><Backspace><Backspace> - [ ] AS Lecture slides<CR><Backspace><Backspace> - [ ] AS Lecture video<CR><Backspace><Backspace> - [ ] AS Tutorial<CR><Backspace><Backspace> - [ ] EDP Lecture<CR><Backspace> [ ] EDP Practical<CR><Backspace> [ ] MAD Lecture<CR><Backspace> [ ] MAD Practical<CR><Backspace> [ ] MRTT Lecture<CR><Backspace> [ ] MRTT Lecture video<Esc>V12k4<

inoremap `chbx - [ ]

inoremap :skl 💀
inoremap :nerd 🤓

map gn :bnext<cr>
map gp :bprevious<cr>
map gd :bdelete<cr>
map gd :bdelete<cr>

nnoremap f> <Esc>I><Space><Esc>
nnoremap t> <Esc>I><Space>

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
    \       'transparent_background': 1
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

let g:airline#extensions#ale#enabled = 1
let g:ale_completion_enabled = 1

inoremap <F10> <C-X><C-K>
inoremap <F9> <C-X><C-S>
nnoremap <F10> a<C-X><C-K>
nnoremap <F9> a<C-X><C-S>
inoremap <silent><F12> <Esc>:call ToggleTransparency()<CR>a
nnoremap <silent><F12> :call ToggleTransparency()<CR>
let g:apc_trigger = "\<c-x>\<c-o>"
let g:apc_enable_ft = {'*':1, 'text':0, 'markdown':0, 'php':0 }
set cpt=.,k,w,b

set noshowmode
set background=dark
let g:airline_theme='papercolor'
colorscheme PaperColor
hi SignColumn guibg=NONE ctermbg=NONE

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}

let g:ale_fix_on_save = 1
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_sign_column_always = 1
let g:ale_filetype_opt = {
\ 'markdown': { 'enable': 0 },
\ 'php': {'enable': 0},
\ 'text': {'enable': 0}
\}

set completeopt=menu,menuone,noselect
set shortmess+=c

filetype on
filetype plugin on
aut FileType * set omnifunc=ale#completion#OmniFunc
au FileType text set omnifunc=syntaxcomplete#Complete
au FileType md set omnifunc=syntaxcomplete#Complete
au FileType php set omnifunc=syntaxcomplete#Complete

set shell=/bin/bash
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
