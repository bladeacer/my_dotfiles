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
  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = true,
  },

  { import = "plugins"},

  { 'ap/vim-css-color' },
  { 'tpope/vim-commentary' },
  { 'tpope/vim-sensible' },
  { 'raimondi/delimitmate' },
  { 'rlue/vim-barbaric' },
  { 'matze/vim-move' },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "right"
        },
        renderer = { icons = { show = { file = true, folder = true } } },
      })
    end
  },

  {
    'saghen/blink.cmp',
    dependencies = {
      'neovim/nvim-lspconfig',
      'rafamadriz/friendly-snippets',
      'saghen/blink.lib'
    },
    branch = 'main',
    lazy = false,
    build = function()
      require('blink.cmp').build():pwait()
    end,

    opts = {
      keymap = { preset = 'super-tab' },
      appearance = { use_nvim_cmp_as_default = true },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lsp = {
            name = 'lsp',
            score_offset = 100, -- Forces language server completions to the absolute top
          },
        },
      },

      completion = {
        keyword = { range = 'full' },
        list = { max_items = 30 },
        menu = {
          auto_show = true,
          winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
        },
        documentation = {
          auto_show = true,
          window = {
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
          }
        },
      },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
})

-- ==========================================================================
-- 2. NOW SETUP NATIVE LSP (Neovim 0.12 Native Core Configuration)
-- ==========================================================================
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- 0.12 Server Configuration & Filetype Bindings Dictionary
local servers = {
  clangd = { filetypes = { 'c', 'cpp', 'objc', 'objcpp' } },
  rust_analyzer = { filetypes = { 'rust' } },
  gopls = { filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' } },
  ts_ls = { filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } },
  cssls = { filetypes = { 'css', 'scss', 'less' } },
  html = { filetypes = { 'html' } },
  jsonls = { filetypes = { 'json', 'jsonc' } },
  yamlls = { filetypes = { 'yaml', 'yaml.dockerfile' } },
  pylsp = { filetypes = { 'python' } },
  -- astro = { filetypes = { 'astro' } },
  stylelint_lsp = { filetypes = { 'css', 'less', 'scss', 'sugarss', 'vue', 'ngx-template' } },
  vimls = { filetypes = { 'vim' } },
  marksman = { filetypes = { 'markdown', 'md' } },
  lua_ls = {
    filetypes = { 'lua' },
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' } -- Tells the language server to safely ignore 'vim'
        }
      }
    }
  },
  ada_ls = {
    filetypes = { 'ada', 'ads', 'adb' },
    cmd = { "ada_language_server" } -- Forces your exact system binary name
  }
}

-- Initialize and auto-enable configurations immediately on startup
for lsp, config in pairs(servers) do
  config.capabilities = capabilities

  -- Core 0.12 APIs
  vim.lsp.config(lsp, config)
  vim.lsp.enable(lsp)
end

vim.diagnostic.config({
  virtual_text = {
    prefix = '■', -- Clean modern square marker
    spacing = 4,
  },
  signs = true,       -- Show icons/signs in the gutter line column
  underline = true,   -- Underline syntax errors inside the active text buffer
  update_in_insert = false, -- Don't yell at you while you are actively mid-typing
  severity_sort = true,
})

require("keymaps")
require("highlights")
require("startpage")
require("dict")

local autocmd_files = {
  "autocmds.color-scheme",
  "autocmds.md-headings"
}

for _, file in ipairs(autocmd_files) do
  require(file)
end

require("options")

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" and vim.bo.filetype ~= "NvimTree" then
      vim.wo.number = true
      vim.wo.relativenumber = true
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, { bufnr = args.buf })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "json", "jsonc" },
  callback = function()
    vim.wo.conceallevel = 0
  end,
})

vim.g.pyindent_open_paren = "shiftwidth()"
