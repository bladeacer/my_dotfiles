vim.keymap.set("n", "<tab>", ">>", { silent = true })
vim.keymap.set("n", "<s-tab>", "<<", { silent = true })
vim.keymap.set("v", "<tab>", ">", { silent = true })
vim.keymap.set("v", "<s-tab>", "<", { silent = true })
vim.keymap.set("n", "x", '"_x')

vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "%", "%zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

vim.keymap.set("n", "<leader>n", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<leader>p", ":bprevious<CR>", { silent = true })
vim.keymap.set("n", "<leader>d", ":bdelete<CR>", { silent = true })
vim.keymap.set("n", "<leader>=", "gg=G2<C-O>zz", { silent = true })
vim.keymap.set("n", "<leader>l", "<Esc>:set number! relativenumber!<CR>", { silent = true })

vim.keymap.set("n", "<leader>f", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
vim.keymap.set("n", "<leader>r", "<cmd>lua require('fzf-lua').oldfiles()<CR>", { silent = true })

vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>", { silent = true })

vim.keymap.set("n", "<leader>i", ":Lazy install<CR>", { silent = true })
vim.keymap.set("n", "<leader>c", ":Lazy clean<CR>", { silent = true })

vim.keymap.set("n", "<Leader>v", ":so ~/.config/nvim/init.lua<CR>", { silent = true })

vim.keymap.set("n", "[g", "<cmd>lua vim.diagnostic.jump({ count = -1 })<CR>", { silent = true })
vim.keymap.set("n", "]g", "<cmd>lua vim.diagnostic.jump({ count = 1 })<CR>", { silent = true })
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { silent = true })
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { silent = true })
vim.keymap.set("n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", { silent = true })

vim.keymap.set("v", "aj", "<Plug>MoveBlockCountLinesDown")
vim.keymap.set("v", "ak", "<Plug>MoveBlockCountLinesUp")

vim.cmd("iabbrev 1i <Esc>cc-<Space>")
vim.cmd("iabbrev 2i <Esc>cc<Tab>-<Space>")
vim.cmd("iabbrev 3i <Esc>cc<Tab><Tab>-<Space>")

vim.cmd("imap <script><silent> <Plug>SuperTabForward <c-r>=SuperTab('n')<cr>")
vim.cmd("imap <script><silent> <Plug>SuperTabBackward <c-r>=SuperTab('p')<cr>")
