vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" and vim.bo.filetype ~= "NvimTree" then
      vim.wo.number = true
      vim.wo.relativenumber = true
    end
  end,
})
