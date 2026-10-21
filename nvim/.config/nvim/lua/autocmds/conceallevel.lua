vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "json", "jsonc" },
  callback = function()
    vim.wo.conceallevel = 0
  end,
})
