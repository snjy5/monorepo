return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto",
      globalstatus = true, -- one statusline for the whole window grid
      component_separators = "|",
      section_separators = "",
    },
  },
}
