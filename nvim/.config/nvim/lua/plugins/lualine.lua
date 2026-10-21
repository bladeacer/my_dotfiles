return {
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
}
