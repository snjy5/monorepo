return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = false,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      map("n", "]h", gs.next_hunk, "Next hunk")
      map("n", "[h", gs.prev_hunk, "Prev hunk")
      map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
      -- Visual mode MUST use the :Gitsigns command form so it computes the
      -- selection range — passing gs.stage_hunk directly would ignore it.
      map("v", "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
      map("v", "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
      map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>ghd", gs.diffthis, "Diff this")
      map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
    end,
  },
}
