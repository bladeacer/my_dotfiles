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
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ";"

-- ==========================================================================
-- COLOR PATCHES: Force menus, windows, and diagnostics to use Iceberg theme
-- ==========================================================================
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "iceberg",
  callback = function()
    local highlights = {
      -- 1. Fix Lazy.nvim and Floating Documentation UI Backgrounds
      NormalFloat  = { bg = "#161821", fg = "#c6c8d1" },
      FloatBorder  = { bg = "#161821", fg = "#444b71" },
      FloatTitle   = { bg = "#2e3244", fg = "#84a0c6", bold = true },

      -- 2. Fix blink.cmp Popups & Completion Menus
      BlinkCmpMenu            = { bg = "#1e2132", fg = "#c6c8d1" },
      BlinkCmpMenuBorder      = { bg = "#1e2132", fg = "#444b71" },
      BlinkCmpDoc             = { bg = "#161821", fg = "#c6c8d1" },
      BlinkCmpDocBorder       = { bg = "#161821", fg = "#444b71" },

      -- 3. Highlighting active selections in menus
      BlinkCmpMenuSelection   = { bg = "#454b68", fg = "#ffffff", bold = true },
      PmenuSel                = { bg = "#454b68", fg = "#ffffff", bold = true },

      -- 4. DIAGNOSTIC COLORS: Map the warnings/errors to Iceberg's palette
      DiagnosticError         = { fg = "#e27878" }, -- Iceberg Red
      DiagnosticWarn          = { fg = "#e2a478" }, -- Iceberg Orange
      DiagnosticInfo          = { fg = "#84a0c6" }, -- Iceberg Blue
      DiagnosticHint          = { fg = "#b4be82" }, -- Iceberg Green

      -- Curly underlines inside the code text
      DiagnosticUnderlineError = { sp = "#e27878", underline = true },
      DiagnosticUnderlineWarn  = { sp = "#e2a478", underline = true },
    }

    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end,
})

-- ==========================================================================
-- 1. LOAD PLUGINS FIRST
-- ==========================================================================
require("lazy").setup({
  {
    'cocopon/iceberg.vim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme iceberg]])
    end
  },

  { 'ap/vim-css-color' },
  { 'junegunn/goyo.vim' },

  {
    'sphamba/smear-cursor.nvim',
    opts = {
      smear_between_buffers = true,
      smear_between_lines = true,
      cursor_color = '#84a0c6', -- Matches Iceberg Blue perfectly
    },
  },

  -- 2. SMOOTH SCROLLING EMULATION
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup({
        mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>', 'zt', 'zz', 'zb'},
        hide_cursor = true,          -- Temporarily hides cursor during fast scrolls
        stop_eof = true,             -- Stop scroll at end of file
        easing_function = "quadratic" -- Smooth slow-down effect
      })
    end
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local function coc_status()
        return vim.fn['coc#status']()
      end

      local colors = {
        base_fg     = '#c6c8d1',
        base_bg     = '#1e2132',
        edge_bg     = '#3d435c',
        gradient_bg = '#2e3244',
        nc_bg       = '#0f1117',
        normal_bg   = '#454b68',
        error_bg    = '#e27878',
        warning_bg  = '#e2a478',
        insert_bg   = '#84a0c6',
        replace_bg  = '#e2a478',
        visual_bg   = '#b4be82',
        dark_text   = '#161821',
      }

      local iceberg_dark_palette = {
        normal = {
          a = { fg = colors.base_fg, bg = colors.normal_bg, bold = true },
          b = { fg = colors.base_fg, bg = colors.gradient_bg },
          c = { fg = colors.base_fg, bg = colors.base_bg },
        },
        insert = {
          a = { fg = colors.dark_text, bg = colors.insert_bg, bold = true },
          b = { fg = colors.base_fg, bg = colors.gradient_bg },
        },
        visual = {
          a = { fg = colors.dark_text, bg = colors.visual_bg, bold = true },
          b = { fg = colors.base_fg, bg = colors.gradient_bg },
        },
        replace = {
          a = { fg = colors.dark_text, bg = colors.replace_bg, bold = true },
          b = { fg = colors.base_fg, bg = colors.gradient_bg },
        },
        inactive = {
          a = { fg = colors.base_fg, bg = colors.nc_bg },
          b = { fg = colors.base_fg, bg = colors.nc_bg },
          c = { fg = colors.base_fg, bg = colors.nc_bg },
        },
      }

      require('lualine').setup({
        options = {
          theme = iceberg_dark_palette,
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          icons_enabled = false,
          globalstatus = false,
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function(str)
                local mode_map = {
                  NORMAL = 'NOR', INSERT = 'INS', REPLACE = 'REP',
                  ['V-LINE'] = 'VL', ['V-BLOCK'] = 'VB', VISUAL = 'V',
                  COMMAND = 'CMD', TERMINAL = 'T'
                }
                return mode_map[str] or str
              end
            }
          },
          lualine_b = { 'paste' },
          lualine_c = { { coc_status }, { 'readonly' }, { 'filename', path = 0 } },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
      })
    end
  },

  { 'tpope/vim-commentary' },
  { 'tpope/vim-sensible' },
  { 'raimondi/delimitmate' },
  { 'mbbill/undotree' },
  { 'rlue/vim-barbaric' },
  { 'matze/vim-move' },

  {
    'ibhagwan/fzf-lua',
    config = function()
      require('fzf-lua').setup({
        fzf_opts = { ['--color'] = true },
        winopts = {
          preview = {
            layout = 'horizontal',
            horizontal = 'right:60%',
          }
        }
      })
    end
  },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { icons = { show = { file = false, folder = true } } },
      })
    end
  },

  {
    'neovim/nvim-lspconfig',
    lazy = false,
    priority = 900,
  },
  { 'rafamadriz/friendly-snippets' },

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
        menu = { auto_show = true },
        documentation = { auto_show = true },
      },
    },
  },

  {
    'iamcco/markdown-preview.nvim',
    build = "cd app && pnpm install",
    ft = { 'markdown' }
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
  astro = { filetypes = { 'astro' } },
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

require("startpage")
require("vimscript-config")
