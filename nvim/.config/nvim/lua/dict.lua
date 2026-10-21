local function define_word()
   local word = vim.fn.expand("<cword>")
   local buffer = vim.api.nvim_create_buf(false, true)
   local lines = nil

   if vim.fn.executable('dict') == 0 then
      vim.notify("dict executable not found", "ERROR")
      return
   end

   local command = vim.system({ "dict", word }, { text = true }):wait()

   if command.code ~= 0 then
      print(command.stderr)
      return
   end

   lines = vim.split(command.stdout, "\n", { plain = true })
   vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

   local window = vim.api.nvim_open_win(buffer, true, {
      relative = "cursor",
      bufpos = { 0, 0 },
      border = "single",
      width = 90,
      height = 25,
      style = "minimal",
      title = word
   })

   vim.api.nvim_create_autocmd("WinLeave", {
      buf = buffer,
      once = true,
      callback = function()
         vim.api.nvim_win_close(window, true)
         vim.bo[buffer].bufhidden = "wipe"
      end
   })

   print("Dictionary", word)
end

vim.keymap.set("n", "<leader>di", define_word, { desc = "Dictionary" })
