-- if vim.g.neovide then
--   vim.o.guifont = "CaskaydiaCove Nerd Font Mono:h11"
--   vim.g.neovide_cursor_animation_length = 0.05
--   vim.g.neovide_cursor_trail_size = 0.4
-- end

vim.cmd.colorscheme("iceberg")

vim.o.termguicolors = true
vim.o.background = "dark"
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.spell = true
vim.o.spelllang = "en_gb"
vim.o.smartcase = true
vim.o.foldcolumn = "2"
vim.o.mouse = "a"
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.pumheight = 10
vim.o.showmatch = true
vim.o.laststatus = 2
vim.o.omnifunc = "syntaxcomplete#Complete"
vim.o.showmode = false
vim.o.ignorecase = true
vim.o.wildmenu = true
vim.o.errorbells = false
vim.o.belloff = "all"
vim.o.redrawtime = 10000
vim.o.complete = ".,k,w,b"
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.completeopt = "menu,menuone,noselect,preview"
vim.o.updatetime = 300
vim.o.tabstop = 8

vim.g.fzf_preview_window = { 'right:60%', 'ctrl-/' }
vim.g.move_normal_option = 1
vim.g.SuperTabMappingForward = '<s-tab>'
vim.g.SuperTabMappingBackward = '<tab>'
