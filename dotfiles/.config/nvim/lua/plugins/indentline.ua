return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl", -- v3 renamed the module
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    indent = { char = "│" },
    scope = { enabled = false },
    exclude = { filetypes = { "help", "lazy", "mason", "oil", "checkhealth" } },
  },
}
