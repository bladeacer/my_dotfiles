vim.cmd([[
" --- Neovide Graphic Specifics ---
if exists("g:neovide")
      " Arch usually expects the full upstream 'CaskaydiaCove Nerd Font Mono'
      set guifont=CaskaydiaCove\ Nerd\ Font\ Mono:h11
      
      let g:neovide_cursor_animation_length = 0.05
      let g:neovide_cursor_trail_size = 0.4
endif

colorscheme iceberg

" --- Core Vim Options ---
set termguicolors
set background=dark
set expandtab
set shiftwidth=2
set tabstop=2
set spell spelllang=en_gb
set smartcase
set foldcolumn=2
set mouse=a

" --- Core Keyboard Remaps ---
nnoremap <silent> <tab> >>
nnoremap <silent> <s-tab> <<
vnoremap <silent> <tab> >
vnoremap <silent> <s-tab> <

set autoindent
set smartindent
set pumheight=10
set showmatch
set laststatus=2
set omnifunc=syntaxcomplete#Complete

set noshowmode
set ignorecase
set wildmenu
set number relativenumber
set noerrorbells
set belloff=all
set re=0
set redrawtime=10000
set clipboard+=unnamedplus

" Delete character without register yank
nnoremap x "_x

highlight SpellBad ctermfg=lightred ctermbg=none
highlight SpellCap ctermfg=lightcyan ctermbg=none
highlight SpellLocal ctermfg=lightyellow ctermbg=none
highlight SpellRare ctermfg=lightgrey ctermbg=none

iabbrev 1i <Esc>cc-<Space>
iabbrev 2i <Esc>cc<Tab>-<Space>
iabbrev 3i <Esc>cc<Tab><Tab>-<Space>

" --- Markdown Navigation Remaps ---
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

" --- Buffer Control Remaps ---
nnoremap <silent> <leader>n :bnext<CR>
nnoremap <silent> <leader>p :bprevious<CR>
nnoremap <silent> <leader>d :bdelete<CR>

nnoremap } }zz
nnoremap { {zz
nnoremap % %zz
nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> <leader>= gg=G2<C-O>zz
nnoremap <silent> <leader>l <Esc>:set number! relativenumber!<CR>

set cpt=.,k,w,b
set shortmess+=c

nnoremap <silent> <leader>f <cmd>lua require('fzf-lua').files()<CR>
nnoremap <silent> <leader>r <cmd>lua require('fzf-lua').oldfiles()<CR>
let g:fzf_preview_window = ['right:60%', 'ctrl-/']

" --- lazy.nvim Global Shortcuts ---
nnoremap <silent> <leader>i :Lazy install<CR>
nnoremap <silent> <leader>c :Lazy clean<CR>

" --- DrChip's Man Page Improvements ---
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

" --- Goyo + Tmux Status Line Interactions ---
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

" Modern config reload target
nnoremap <silent> <Leader>v :so ~/.config/nvim/init.lua<CR>

set completeopt=menu,menuone,noselect,preview
set updatetime=300

imap <script><silent> <Plug>SuperTabForward <c-r>=SuperTab('n')<cr>
imap <script><silent> <Plug>SuperTabBackward <c-r>=SuperTab('p')<cr>
let g:SuperTabMappingForward = '<s-tab>'
let g:SuperTabMappingBackward = '<tab>'

" --- CoC Completion Mechanics ---
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()

let g:coc_node_path = "/usr/bin/node"
let g:coc_global_extensions = ['coc-json', 'coc-rust-analyzer', 'coc-markdownlint', 'coc-css', 'coc-yaml', 'coc-go', 'coc-tsserver', 'coc-stylelint', 'coc-prettier', '@yaegassy/coc-pylsp', '@yaegassy/coc-astro', 'coc-clangd']

nmap <silent><nowait> [g <Plug>(coc-diagnostic-prev)
nmap <silent><nowait> ]g <Plug>(coc-diagnostic-next)
nmap <leader>as  <Plug>(coc-codeaction-source)
nmap <leader>a   <Plug>(coc-codeaction-selected)

let g:move_normal_option = 1
vmap aj <Plug>MoveBlockCountLinesDown
vmap ak <Plug>MoveBlockCountLinesUp

autocmd FileType ada setlocal shiftwidth=3 ts=3 softtabstop=3 expandtab
]])
