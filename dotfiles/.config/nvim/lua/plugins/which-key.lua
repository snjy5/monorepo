return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- which-key v3 API: groups live in opts.spec
    spec = {
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>q", group = "quit" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer-local keymaps",
    },
  },
}
