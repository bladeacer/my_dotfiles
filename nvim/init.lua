vim.g.loaded_netrw = 1

vim.g.loaded_netrwPlugin = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.o.rtp = lazypath .. "," .. vim.o.rtp

vim.o.number = true
vim.o.relativenumber = true

vim.g.mapleader = ";"

-- ==========================================================================
-- 1. LOAD PLUGINS FIRST
-- ==========================================================================
require("lazy").setup({
  { import = "plugins" },
}, {
  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = true,
  },
})

require("lsp")

require("keymaps")
require("highlights")
require("startpage")
require("dict")

local autocmd_files = {
  "autocmds.color-scheme",
  "autocmds.md-headings",
  "autocmds.number",
  "autocmds.document-color",
  "autocmds.conceallevel"
}

for _, file in ipairs(autocmd_files) do
  require(file)
end

require("options")
