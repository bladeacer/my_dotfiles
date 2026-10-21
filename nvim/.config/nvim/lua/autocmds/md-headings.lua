vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.md",
  callback = function()
    vim.keymap.set("n", "<leader>2#", "I##<Space>", { buffer = true })
    vim.keymap.set("n", "<leader>3#", "I###<Space>", { buffer = true })
    vim.keymap.set("n", "<leader>4#", "I####<Space>", { buffer = true })
    vim.keymap.set("n", "<leader>5#", "I#####<Space>", { buffer = true })
    vim.keymap.set("n", "<leader>6#", "I######<Space>", { buffer = true })

    vim.cmd("iabbrev 2# ##")
    vim.cmd("iabbrev 3# ###")
    vim.cmd("iabbrev 4# ####")
    vim.cmd("iabbrev 5# #####")
    vim.cmd("iabbrev 6# ######")
  end,
})
