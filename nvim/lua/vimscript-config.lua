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

vim.keymap.set("n", "<tab>", ">>", { silent = true })
vim.keymap.set("n", "<s-tab>", "<<", { silent = true })
vim.keymap.set("v", "<tab>", ">", { silent = true })
vim.keymap.set("v", "<s-tab>", "<", { silent = true })

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

vim.keymap.set("n", "x", '"_x')

vim.api.nvim_set_hl(0, "SpellBad", { ctermfg = "lightred", ctermbg = "none" })
vim.api.nvim_set_hl(0, "SpellCap", { ctermfg = "lightcyan", ctermbg = "none" })
vim.api.nvim_set_hl(0, "SpellLocal", { ctermfg = "lightyellow", ctermbg = "none" })
vim.api.nvim_set_hl(0, "SpellRare", { ctermfg = "lightgrey", ctermbg = "none" })

vim.cmd("iabbrev 1i <Esc>cc-<Space>")
vim.cmd("iabbrev 2i <Esc>cc<Tab>-<Space>")
vim.cmd("iabbrev 3i <Esc>cc<Tab><Tab>-<Space>")

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.md",
  callback = function()
    vim.keymap.set("n", "<leader>2#", "I##<Space>", { buffer = true })
    vim.keymap.set("n", "<leader>3#", "I###<Space>", { buffer = true })
    vim.keymap.set("n", "<leader>4#", "I####<Space>", { buffer = true })
    vim.keymap.set("n", "<leader>5#", "I#####<Space>", { buffer = true })
    vim.keymap.set("n", "<leader>6#", "I######<Space>", { buffer = true })

    vim.cmd("iabbrev 2# ##")
    vim.cmd("iabbrev 3# ###")
    vim.cmd("iabbrev 4# ####")
    vim.cmd("iabbrev 5# #####")
    vim.cmd("iabbrev 6# ######")
  end,
})

vim.keymap.set("n", "<leader>n", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<leader>p", ":bprevious<CR>", { silent = true })
vim.keymap.set("n", "<leader>d", ":bdelete<CR>", { silent = true })

vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "%", "%zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "<leader>=", "gg=G2<C-O>zz", { silent = true })
vim.keymap.set("n", "<leader>l", "<Esc>:set number! relativenumber!<CR>", { silent = true })

vim.opt.complete = ".,k,w,b"
vim.opt.shortmess:append("c")

vim.keymap.set("n", "<leader>f", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
vim.keymap.set("n", "<leader>r", "<cmd>lua require('fzf-lua').oldfiles()<CR>", { silent = true })
vim.g.fzf_preview_window = { 'right:60%', 'ctrl-/' }

vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>", { silent = true })

vim.keymap.set("n", "<leader>i", ":Lazy install<CR>", { silent = true })
vim.keymap.set("n", "<leader>c", ":Lazy clean<CR>", { silent = true })

vim.cmd([[
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
]])

vim.api.nvim_set_hl(0, "manSectionNumber", { link = "Number" })
vim.api.nvim_set_hl(0, "manDQString", { link = "String" })
vim.api.nvim_set_hl(0, "manSQString", { link = "String" })
vim.api.nvim_set_hl(0, "manBQString", { link = "String" })
vim.api.nvim_set_hl(0, "manBQSQString", { link = "String" })
vim.api.nvim_set_hl(0, "manBullet", { link = "Special" })
vim.api.nvim_set_hl(0, "manSubSectionStart", { ctermfg = "black", ctermbg = "black", fg = "navyblue", bg = "navyblue" })
vim.api.nvim_set_hl(0, "manSubSection", { underline = true, ctermfg = "green", fg = "green" })

vim.opt.tabstop = 8

vim.keymap.set("n", "<Leader>v", ":so ~/.config/nvim/init.lua<CR>", { silent = true })

vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }
vim.opt.updatetime = 300

vim.cmd("imap <script><silent> <Plug>SuperTabForward <c-r>=SuperTab('n')<cr>")
vim.cmd("imap <script><silent> <Plug>SuperTabBackward <c-r>=SuperTab('p')<cr>")
vim.g.SuperTabMappingForward = '<s-tab>'
vim.g.SuperTabMappingBackward = '<tab>'

vim.keymap.set("n", "[g", "<cmd>lua vim.diagnostic.jump({ count = -1 })<CR>", { silent = true })
vim.keymap.set("n", "]g", "<cmd>lua vim.diagnostic.jump({ count = 1 })<CR>", { silent = true })

vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { silent = true })
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { silent = true })

vim.keymap.set("n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", { silent = true })

vim.g.move_normal_option = 1
vim.keymap.set("v", "aj", "<Plug>MoveBlockCountLinesDown")
vim.keymap.set("v", "ak", "<Plug>MoveBlockCountLinesUp")
