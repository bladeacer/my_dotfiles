return {
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
}
