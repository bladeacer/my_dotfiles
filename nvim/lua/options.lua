if vim.g.neovide then
  vim.opt.guifont = "CaskaydiaCove Nerd Font Mono:h11"
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_trail_size = 0.4
end

vim.cmd.colorscheme("iceberg")

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.spell = true
vim.opt.spelllang = "en_gb"
vim.opt.smartcase = true
vim.opt.foldcolumn = "2"
vim.opt.mouse = "a"
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.pumheight = 10
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.showmode = false
vim.opt.ignorecase = true
vim.opt.wildmenu = true
vim.opt.errorbells = false
vim.opt.belloff = "all"
vim.opt.redrawtime = 10000
vim.opt.complete = ".,k,w,b"
vim.opt.shortmess:append("c")
vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }
vim.opt.updatetime = 300
vim.opt.tabstop = 8

vim.g.fzf_preview_window = { 'right:60%', 'ctrl-/' }
vim.g.move_normal_option = 1
vim.g.SuperTabMappingForward = '<s-tab>'
vim.g.SuperTabMappingBackward = '<tab>'
