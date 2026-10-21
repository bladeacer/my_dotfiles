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
