-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 250 })
  end,
})

-- Restore cursor position on file open
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close these filetypes with 'q'
-- NOTE: deliberately NOT including 'oil' — oil owns its buffer keymaps and
-- autocmd ordering between plugins is undefined territory.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "man", "qf", "lspinfo", "checkhealth" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf })
  end,
})
