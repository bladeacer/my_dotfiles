vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "iceberg",
  callback = function()
    local highlights = {
      -- 1. Main Editor & General Floating Windows
      Normal       = { bg = "#161821", fg = "#c6c8d1" },
      NormalFloat  = { bg = "#161821", fg = "#c6c8d1" },
      FloatBorder  = { bg = "#161821", fg = "#444b71" },
      FloatTitle   = { bg = "#2e3244", fg = "#84a0c6", bold = true },

      -- 2. Blink.cmp Completion Menu & Doc Backgrounds
      BlinkCmpMenu                 = { bg = "#1e2132", fg = "#c6c8d1" },
      BlinkCmpMenuBorder           = { bg = "#1e2132", fg = "#444b71" },
      BlinkCmpDoc                  = { bg = "#161821", fg = "#c6c8d1" },
      BlinkCmpDocBorder            = { bg = "#1e2132", fg = "#444b71" },
      BlinkCmpDocCursorLine        = { bg = "#2e3244" },
      BlinkCmpMenuSelection        = { bg = "#454b68", fg = "#ffffff", bold = true },

      -- 3. Standard Popup Menus (Lazy UI, Omnicomplete, etc.)
      Pmenu                        = { bg = "#1e2132", fg = "#c6c8d1" },
      PmenuSel                     = { bg = "#454b68", fg = "#ffffff", bold = true },
      PmenuSbar                    = { bg = "#2e3244" },
      PmenuThumb                   = { bg = "#84a0c6" },

      -- 4. Diagnostics
      DiagnosticError              = { fg = "#e27878" },
      DiagnosticWarn               = { fg = "#e2a478" },
      DiagnosticInfo               = { fg = "#84a0c6" },
      DiagnosticHint               = { fg = "#b4be82" },
      DiagnosticUnderlineError     = { sp = "#e27878", underline = true },
      DiagnosticUnderlineWarn      = { sp = "#e2a478", underline = true },

      -- 5. Flutter Specifics
      FlutterWidgetGuide           = { fg = "#3d425b" },
      FlutterClosetag              = { fg = "#6b7089", italic = true },
    }

    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end,
})
