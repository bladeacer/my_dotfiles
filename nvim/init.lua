-- 1. FIX: Disable netrw globally using native booleans to prevent type-errors
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 2. Bootstrap lazy.nvim
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

-- 3. Load Plugins
require("lazy").setup({
  -- FIX: Force Iceberg to load instantly on startup
  { 
    'cocopon/iceberg.vim', 
    lazy = false, 
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme iceberg]])
    end
  },
  { 'gkeep/iceberg-dark' },

  -- UI & Color Themes
  { 'ap/vim-css-color' },
  { 'junegunn/goyo.vim' },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Define a quick helper to pull the CoC status string into Lua
      local function coc_status()
        return vim.fn['coc#status']()
      end

      require('lualine').setup({
        options = {
          theme = 'iceberg_dark', -- Matches your iceberg-dark flavor perfectly
          component_separators = { left = '┃', right = '┃' },
          section_separators = { left = '', right = '' }, -- Sleek modern angles
          globalstatus = false,
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function(str)
                -- Replicates your exact 3-letter mode mappings
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
          lualine_c = { 
            { coc_status }, -- Seamlessly pulls your CoC status directly into the bar
            { 'readonly' }, 
            { 'filename', file_status = true, path = 0 } 
          },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        inactive_sections = {
          lualine_a = {}, lualine_b = {}, lualine_c = {'filename'},
          lualine_x = {'location'}, lualine_y = {}, lualine_z = {}
        },
      })
    end
  },

  -- Quality of Life Editor Improvements
  { 'tpope/vim-commentary' },
  { 'tpope/vim-sensible' },
  { 'raimondi/delimitmate' },
  { 'mbbill/undotree' },
  { 'rlue/vim-barbaric' },
  { 'matze/vim-move' },

  -- NEW: Performant, native FZF replacement plugin
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup({'fzf-native'})
    end
  },

  -- CoC Engine
  { 'neoclide/coc.nvim', branch = 'master', build = 'pnpm i' },
  { 'bladeacer/coc-quarkdown', build = 'pnpm install && pnpm run build' },

  -- FIX: Use direct shell string command execution for markdown setup script
  { 
    'iamcco/markdown-preview.nvim', 
    build = "cd app && pnpm install",
    ft = { 'markdown' } 
  },
})

-- 4. Load your clean Vimscript options
require("vimscript-config")
