vim.api.nvim_set_hl(0, "SpellBad", { ctermfg = "lightred", ctermbg = "none" })
vim.api.nvim_set_hl(0, "SpellCap", { ctermfg = "lightcyan", ctermbg = "none" })
vim.api.nvim_set_hl(0, "SpellLocal", { ctermfg = "lightyellow", ctermbg = "none" })
vim.api.nvim_set_hl(0, "SpellRare", { ctermfg = "lightgrey", ctermbg = "none" })

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
