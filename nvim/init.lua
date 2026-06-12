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

require("lazy").setup({
  { 
    'cocopon/iceberg.vim', 
    lazy = false, 
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme iceberg]])
    end
  },
  { 'gkeep/iceberg-dark' },

  { 'ap/vim-css-color' },
  { 'junegunn/goyo.vim' },

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
          theme = iceberg_dark_palette, -- Load our exact converted theme
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
        -- Forces fzf-lua to inherit colors from your 'iceberg' colorscheme directly
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

  { 'neoclide/coc.nvim', branch = 'master', build = 'pnpm i' },
  { 'bladeacer/coc-quarkdown', build = 'pnpm install && pnpm run build' },

  { 
    'iamcco/markdown-preview.nvim', 
    build = "cd app && pnpm install",
    ft = { 'markdown' } 
  },
})

require("vimscript-config")
