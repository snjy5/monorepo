return {
  "stevearc/oil.nvim",
  lazy = false, -- oil's own recommendation: must be up at startup to replace netrw
  opts = {
    default_file_explorer = true,
    view_options = { show_hidden = true },
    columns = { "icon" },
    keymaps = { ["q"] = "actions.close" },
  },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer" },
  },
}
