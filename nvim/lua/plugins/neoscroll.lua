return {
  'karb94/neoscroll.nvim',
  config = function()
    require('neoscroll').setup({
      mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>', 'zt', 'zz', 'zb'},
      hide_cursor = true,           -- Temporarily hides cursor during fast scrolls
      stop_eof = true,              -- Stop scroll at end of file
      easing_function = "quadratic" -- Smooth slow-down effect
    })
  end
}
