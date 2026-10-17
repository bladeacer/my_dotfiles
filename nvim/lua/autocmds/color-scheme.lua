vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "iceberg",
  callback = function()
    local highlights = {
      -- 1. Fix Lazy.nvim and Floating Documentation UI Backgrounds
      NormalFloat  = { bg = "#161821", fg = "#c6c8d1" },
      FloatBorder  = { bg = "#161821", fg = "#444b71" },
      FloatTitle   = { bg = "#2e3244", fg = "#84a0c6", bold = true },

      -- 2. Fix blink.cmp Popups & Completion Menus
      BlinkCmpMenu               = { bg = "#1e2132", fg = "#c6c8d1" },
      BlinkCmpMenuBorder         = { bg = "#1e2132", fg = "#444b71" },
      BlinkCmpDoc                = { bg = "#161821", fg = "#c6c8d1" },
      BlinkCmpDocBorder          = { bg = "#161821", fg = "#444b71" },
      BlinkCmpDocCursorLine      = { bg = "#2e3244" }, -- Added for doc window cursor line

      -- 3. Highlighting active selections in menus
      BlinkCmpMenuSelection      = { bg = "#454b68", fg = "#ffffff", bold = true },
      PmenuSel                   = { bg = "#454b68", fg = "#ffffff", bold = true },

      -- 4. DIAGNOSTIC COLORS
      DiagnosticError            = { fg = "#e27878" },
      DiagnosticWarn             = { fg = "#e2a478" },
      DiagnosticInfo             = { fg = "#84a0c6" },
      DiagnosticHint             = { fg = "#b4be82" },

      DiagnosticUnderlineError = { sp = "#e27878", underline = true },
      DiagnosticUnderlineWarn  = { sp = "#e2a478", underline = true },
    }

    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end,
})
