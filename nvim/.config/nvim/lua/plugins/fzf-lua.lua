return {
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
}
