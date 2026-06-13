-- ==========================================================================
-- THE ULTIMATE ENGINE: HIGH-FIDELITY SINGLE-BUFFER 24-BIT ANSI HOMEPAGE
-- ==========================================================================
local function parse_and_highlight_ansi(buf, line_count, pad_width)
  local ns = vim.api.nvim_create_namespace("DashboardAnsiColors")
  local lines = vim.api.nvim_buf_get_lines(buf, 0, line_count, false)

  for row_idx, line in ipairs(lines) do
    local real_row = row_idx - 1
    local current_fg, current_bg, is_reversed = nil, nil, false

    local pos = 1
    while pos <= #line do
      if line:sub(pos, pos + 1) == "\27[" then
        local m_end = line:find("m", pos)
        if m_end then
          local seq = line:sub(pos, m_end)

          local args = {}
          for arg in seq:gmatch("%d+") do
            table.insert(args, tonumber(arg))
          end

          if seq:match("%[0m") then
            current_fg, current_bg, is_reversed = nil, nil, false
          elseif seq:match("%[7m") then
            is_reversed = true
          elseif seq:match("%[27m") then
            is_reversed = false
          else
            local i = 1
            while i <= #args do
              if args[i] == 38 and args[i+1] == 2 then
                current_fg = string.format("#%02x%02x%02x", args[i+2], args[i+3], args[i+4])
                i = i + 5
              elseif args[i] == 48 and args[i+1] == 2 then
                current_bg = string.format("#%02x%02x%02x", args[i+2], args[i+3], args[i+4])
                i = i + 5
              else
                i = i + 1
              end
            end
          end

          vim.api.nvim_buf_set_extmark(buf, ns, real_row, pos - 1, {
            end_col = m_end,
            conceal = "",
          })

          pos = m_end + 1
        else
          pos = pos + 1
        end
      else
        local byte = string.byte(line, pos)
        local char_bytes = 1

        if byte >= 0xc0 and byte <= 0xdf then
          char_bytes = 2
        elseif byte >= 0xe0 and byte <= 0xef then
          char_bytes = 3
        elseif byte >= 0xf0 and byte <= 0xf7 then
          char_bytes = 4
        end

        local chunk_start = pos - 1
        local chunk_end = pos - 1 + char_bytes

        if current_fg or current_bg or is_reversed then
          local fg = is_reversed and current_bg or current_fg
          local bg = is_reversed and current_fg or current_bg

          local group_hash = "ChafaRGB_" .. (fg and fg:sub(2) or "NONE") .. "_" .. (bg and bg:sub(2) or "NONE")
          vim.api.nvim_set_hl(0, group_hash, { fg = fg, bg = bg })
          vim.api.nvim_buf_add_highlight(buf, ns, group_hash, real_row, chunk_start, chunk_end)
        end

        pos = pos + char_bytes
      end
    end
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" and vim.bo.filetype == "" then

      local main_buf = vim.api.nvim_get_current_buf()
      local main_win = vim.api.nvim_get_current_win()

      vim.api.nvim_buf_set_name(main_buf, "Dashboard")

      -- Enforce static UI Presentation rules natively
      vim.bo[main_buf].buftype = "nofile"
      vim.bo[main_buf].bufhidden = "wipe"
      vim.bo[main_buf].swapfile = false

      vim.wo[main_win].wrap = false
      vim.wo[main_win].number = false
      vim.wo[main_win].relativenumber = false
      vim.wo[main_win].signcolumn = "no"
      vim.wo[main_win].foldcolumn = "0"
      vim.wo[main_win].cursorline = true
      vim.wo[main_win].conceallevel = 3
      vim.wo[main_win].concealcursor = "nvic"
      vim.wo[main_win].scrolloff = 999
      vim.wo[main_win].spell = false

      -- 1. Read your true-color file channel lines
      local art_path = vim.fn.expand("~/my_dotfiles/logo/blue_rose")
      local art_file = io.open(art_path, "r")
      local raw_art_lines = {}

      if art_file then
        for line in art_file:lines() do
          table.insert(raw_art_lines, line)
        end
        art_file:close()
      else
        raw_art_lines = { "[Art asset file not found]" }
      end

      for idx = #raw_art_lines, 1, -1 do
        if raw_art_lines[idx]:match("%?25h") or raw_art_lines[idx] == "" then
          table.remove(raw_art_lines, idx)
        end
      end
      if raw_art_lines[1] and raw_art_lines[1]:match("%?25l") then
        table.remove(raw_art_lines, 1)
      end

      -- 2. Calibrate dynamic window margins for standard text centering
      local screen_width = vim.api.nvim_win_get_width(main_win)
      local art_box_width = 46
      local pad_width = math.max(0, math.floor((screen_width - art_box_width) / 2))
      local margin = string.rep(" ", pad_width)

      -- 3. Package structural contents into a unified matrix
      local final_lines = {}
      for _, line in ipairs(raw_art_lines) do
        table.insert(final_lines, margin .. line)
      end

      table.insert(final_lines, "")
      table.insert(final_lines, margin .. "  󱎂  青いバラ")
      table.insert(final_lines, margin .. "  ────────────────────────────────────────")

      local button_start_idx = #final_lines + 1

      local menu_items = {
        { key = "f", icon = "󰈞 ", desc = "Find File",    action = function() require('fzf-lua').files() end },
        { key = "r", icon = "󰋚 ", desc = "Recent Files", action = function() require('fzf-lua').oldfiles() end },
        { key = "l", icon = "󱐥 ", desc = "Lazy Plugins", action = function() require('lazy').show() end },
        { key = "q", icon = "󰅚 ", desc = "Quit Neovim",  action = function() vim.cmd("qa") end },
      }

      for _, item in ipairs(menu_items) do
        table.insert(final_lines, string.format("%s  [%s]  %s  %s", margin, item.key, item.icon, item.desc))
      end

      vim.bo[main_buf].modifiable = true
      vim.api.nvim_buf_set_lines(main_buf, 0, -1, false, final_lines)

      parse_and_highlight_ansi(main_buf, #raw_art_lines, pad_width)
      vim.bo[main_buf].modifiable = false

      -- Move cursor cleanly straight to the first interactive menu element using pad_width alignment
      local target_col = pad_width + 2
      vim.api.nvim_win_set_cursor(main_win, { button_start_idx, target_col })

      -- ==========================================================================
      -- TOTAL LOCKDOWN BINDINGS (NO SCROLL, NO MOUSE SHIFT)
      -- ==========================================================================
      local min_row = button_start_idx
      local max_row = button_start_idx + #menu_items - 1

      -- Force j and k to move strictly between the menu item bounds, utilizing pad_width
      vim.keymap.set("n", "j", function()
        local curr = vim.api.nvim_win_get_cursor(main_win)[1]
        if curr < max_row then
          vim.api.nvim_win_set_cursor(main_win, { curr + 1, target_col })
        end
      end, { buffer = main_buf, silent = true })

      vim.keymap.set("n", "k", function()
        local curr = vim.api.nvim_win_get_cursor(main_win)[1]
        if curr > min_row then
          vim.api.nvim_win_set_cursor(main_win, { curr - 1, target_col })
        end
      end, { buffer = main_buf, silent = true })

      -- Completely block all window scrolling commands
      local block_keys = { "<Up>", "<Down>", "<Left>", "<Right>", "<PageUp>", "<PageDown>", "<C-d>", "<C-u>", "<C-f>", "<C-b>", "gg", "G" }
      for _, k in ipairs(block_keys) do
        vim.keymap.set("n", k, "<Nop>", { buffer = main_buf, silent = true })
      end

      -- Disable mouse clicks and dragging from shifting text lines around
      local mouse_keys = { "<LeftMouse>", "<LeftDrag>", "<LeftRelease>", "<2-LeftMouse>", "<MouseWheelUp>", "<MouseWheelDown>" }
      for _, m in ipairs(mouse_keys) do
        vim.keymap.set({ "n", "v", "i" }, m, "<Nop>", { buffer = main_buf, silent = true })
      end

      -- ==========================================================================
      -- INTERACTIVE INPUT RE-ROUTING
      -- ==========================================================================
      local function execute_row_action()
        local cursor_row = vim.api.nvim_win_get_cursor(main_win)[1]
        local item_idx = cursor_row - button_start_idx + 1
        local target_item = menu_items[item_idx]
        if target_item then
          target_item.action()
        end
      end

      for _, item in ipairs(menu_items) do
        vim.keymap.set("n", item.key, item.action, { buffer = main_buf, silent = true, nowait = true })
      end

      vim.keymap.set("n", "<CR>", execute_row_action, { buffer = main_buf, silent = true })

      -- Strict fallback constraint utilizing pad_width to reset any unexpected tracking shifts
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = main_buf,
        callback = function()
          if vim.api.nvim_get_current_buf() == main_buf then
            local curr_row = vim.api.nvim_win_get_cursor(main_win)[1]
            if curr_row < min_row then
              vim.api.nvim_win_set_cursor(main_win, { min_row, target_col })
            elseif curr_row > max_row then
              vim.api.nvim_win_set_cursor(main_win, { max_row, target_col })
            else
              vim.api.nvim_win_set_cursor(main_win, { curr_row, target_col })
            end
          end
        end,
      })

      -- ==========================================================================
      -- DYNAMIC MENU INTERFACE STYLING
      -- ==========================================================================
      -- Compile icon matching rule dynamically from your menu data array
      local icon_patterns = {}
      for _, item in ipairs(menu_items) do
        -- Strip trailing spacing markers from tracking definitions
        local clean_icon = vim.trim(item.icon)
        if #clean_icon > 0 then
          table.insert(icon_patterns, vim.pesc(clean_icon))
        end
      end
      local dynamic_icon_regex = table.concat(icon_patterns, "\\|")

      vim.api.nvim_buf_call(main_buf, function()
        vim.fn.matchadd("MenuHeader", "󱎂.*")
        vim.fn.matchadd("MenuKey", "\\[\\zs\\w\\ze\\]")
        vim.fn.matchadd("MenuDivider", "──*")
        if #dynamic_icon_regex > 0 then
          vim.fn.matchadd("MenuIcon", dynamic_icon_regex)
        end
      end)

      local highlights = {
        MenuHeader  = { fg = "#c6c8d1", bold = true },
        MenuKey     = { fg = "#84a0c6", bold = true },
        MenuDivider = { fg = "#444b71" },
        MenuIcon    = { fg = "#6b7089" },
      }
      for group, style in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, style)
      end

    end
  end
})
