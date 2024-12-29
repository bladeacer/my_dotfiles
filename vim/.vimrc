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
set cmdheight=1
filetype plugin indent on

set clipboard=unnamedplus "Linux

" delete single character without copying into register
nnoremap x "_x

highlight SpellBad ctermfg=lightgrey ctermbg=lightred
highlight SpellCap ctermfg=lightgrey ctermbg=lightcyan
highlight SpellLocal ctermfg=lightgrey ctermbg=lightyellow
highlight SpellRare ctermfg=lightgrey ctermbg=none

syntax on
set encoding=utf8
set re=0
set redrawtime=10000

syntax match MarkdownBold /\*\*\(.*\)\*\*/
highlight MarkdownBold ctermfg=white ctermbg=none

syntax match MarkdownBold /\*\*\(.*\)\*\*/
syntax match MarkdownUnderline /_\(.*\)_/

syntax match MarkdownBold /\*\*\(.*\)\*\*/
highlight MarkdownUnderline ctermfg=white ctermbg=none
syntax match MarkdownItalic /\*\(.*\)\*/
highlight MarkdownItalic ctermfg=white ctermbg=none

autocmd bufenter * inoremap 2{ {}<Esc>i
autocmd bufenter * inoremap 2e{ {<CR><CR>}<Esc>ki

autocmd bufenter * inoremap 2( ()<Esc>i
autocmd bufenter * inoremap 2e( (<CR><Tab><CR>)<Esc>ki

autocmd bufenter * inoremap  2[ []<Esc>i
autocmd bufenter * inoremap  4[ [[]]<Esc>hi
autocmd bufenter *.md inoremap  2e[ [<CR><CR>]<Esc>ki
autocmd bufenter *.md inoremap  2$ $$<Esc>i
autocmd bufenter *.md inoremap  4$ $$$$<Esc>hi
autocmd bufenter *.md inoremap  4e$ $$<CR>$$<Esc>kA
autocmd bufenter * inoremap  2" ""<Esc>i
autocmd bufenter * inoremap  2' ''<Esc>i
autocmd bufenter *.md inoremap  2` ``<Esc>i
autocmd bufenter *.md inoremap  2* **<Esc>i
autocmd bufenter *.md inoremap  4* ****<Esc>hi
autocmd bufenter *.md inoremap  3` ```<CR><CR>```<Esc>kcc
autocmd bufenter *.md inoremap  `js ```js<CR><CR>```<Esc>kcc
autocmd bufenter *.md inoremap  `cs ```cs<CR><CR>```<Esc>kcc
autocmd bufenter *.md inoremap  3~ ~~~<CR>~~~<Esc>

autocmd bufenter *.md inoremap 3- ---
autocmd bufenter *.md inoremap 3_ ___

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

autocmd bufenter *.md iabbrev iih Insert image here
autocmd bufenter *.md iabbrev OSA Operating systems and administration
autocmd bufenter *.md iabbrev AS Applications Security

autocmd bufenter *.md inoremap mans >[!question]- My Answer<CR>
autocmd bufenter *.md inoremap nans >[!question]- My Answer<CR>
autocmd bufenter *.md inoremap sans >[!question]- Suggested Answer<CR>
autocmd bufenter *.md inoremap `nwp - [ ] UXDMT Lecture slides<CR>[ ] UXDMT Lecture video<CR>[ ] OSA Lecture slides<CR>[ ] OSA Lecture video<CR>[ ] OSA Tutorial<CR>[ ] AS Lecture slides<CR>[ ] AS Lecture video<CR>[ ] AS Tutorial<CR>[ ] EDP Lecture<CR>[ ] EDP Practical<CR>[ ] MAD Lecture<CR>[ ] MAD Practical<CR>[ ] MRTT Lecture<CR>[ ] MRTT Lecture video

autocmd bufenter *.md iabbrev prop ---<CR>alias:<CR>Week:<CR>Course:<CR>Semester:<CR>Year:<CR>Topic:<CR>tags:<CR>---<ESC>7kA
autocmd bufenter *.md iabbrev nend ___<CR>## Summary<CR><CR>### Questions<CR><CR>### Tutorial<Esc>4kA
autocmd bufenter *.md iabbrev chbx - [ ]
autocmd bufenter *.md iabbrev skl 💀
autocmd bufenter *.md iabbrev nerd 🤓

autocmd bufenter *.html iabbrev html <html></html><Esc>2ba
autocmd bufenter *.html iabbrev body <body></body><Esc>2ba
autocmd bufenter *.html iabbrev scriptsrc <script src=""></script><Esc>2bla
autocmd bufenter *.html iabbrev script <script></script><Esc>2ba
autocmd bufenter *.html iabbrev div <div></div><Esc>2ba
autocmd bufenter *.jsx iabbrev div <div></div><Esc>2ba

nnoremap <silent> <leader>n :bnext<CR>
nnoremap <silent> <leader>p :bprevious<CR>
nnoremap <silent> <leader>d :bdelete<CR>

nnoremap <leader>ft <Esc>{jzt<C-O>
nnoremap } }zz
nnoremap { {zz
nnoremap <leader>fz <Esc>{jzz<C-O>
nnoremap <leader>fb <Esc>{jzb<C-O>
nnoremap % %zz
nnoremap <leader>fv 0ma}b:'a,.j<CR>120 ?  *<Esc>dwi<CR><Esc>

set noshowmode
set ignorecase
set wildmenu
set number
set relativenumber
set noerrorbells

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ycm#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'

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
  hi foldcolumn guibg=#1c1c1c ctermbg=black
endfunction

function! SetBgTransparent()
  hi Normal guibg=NONE ctermbg=NONE
  hi LineNr guibg=NONE ctermbg=NONE
  hi SignColumn guibg=NONE ctermbg=NONE
  hi foldcolumn guibg=NONE ctermbg=NONE
endfunction

let g:is_transparent = g:PaperColor_Theme_Options.theme.default.transparent_background
function! ToggleTransparency()
  if g:is_transparent == 0
    call SetBgTransparent()
    let g:is_transparent = 1
  else
    call SetBgOpaque()
    let g:is_transparent = 0
  endif
endfunction

nnoremap <silent><leader>t :call ToggleTransparency()<CR>
nnoremap <silent> <leader>l <Esc>:set number! relativenumber!<CR>

nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> <leader>= gg=G2<C-O>zz

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
nnoremap <silent> <leader>f :FZF!<CR>

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

command! -bang -nargs=? FZFMru call fzf_mru#actions#mru(<q-args>,
    \{
        \'window': {'width': 1, 'height': 1},
        \'options': [
            \'--preview', 'bat --style=numbers --color=always {}',
            \'--preview-window', 'right:60%',
            \'--bind', 'ctrl-_:toggle-preview'
        \]
    \}
\)
nnoremap <silent> <Leader>r :FZFMru<CR>
nnoremap <silent> <Leader>v :so ~/.vimrc<CR>
nnoremap <silent> <Leader>a :!git add -A<CR>

let g:ycm_filetype_blacklist = {'text':1, 'markdown':1, 'php':1}
let g:apc_enable_ft = {'text':1, 'markdown':1, 'php':1}

" source for dictionary, current or other loaded buffers, see ':help cpt'
set cpt=.,k,w,b

" don't select the first item.
set completeopt=menu,menuone,noselect

" suppress annoy messages.
set shortmess+=c

let g:apc_trigger="\<c-x>\<c-k>"
nnoremap <silent> <leader>gt :YcmCompleter GoTo<CR>
let g:ycm_enable_semantic_highlighting=1
let g:airline_skip_empty_sections = 1
let g:airline_section_z = airline#section#create(['windowswap', '%3p%% ', 'linenr', ':%3v'])
imap <c-b> <plug>(YCMComplete)
