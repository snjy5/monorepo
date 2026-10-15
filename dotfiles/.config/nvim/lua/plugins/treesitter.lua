return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- CRITICAL: 'main' is the new default branch and drops
                     -- ensure_installed; master is frozen but stable. [[8]][[10]][[13]]
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash", "c", "css", "go", "html", "javascript", "json", "lua",
        "luadoc", "markdown", "markdown_inline", "python", "regex", "rust",
        "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })

    -- Treesitter-powered folding (native API since 0.10)
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
  end,
}
