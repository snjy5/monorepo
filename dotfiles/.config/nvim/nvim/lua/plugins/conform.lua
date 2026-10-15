return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cF",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      desc = "Format buffer now",
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" }, -- prepend "ruff_organize_imports" if you want import sorting
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      sh = { "shfmt" },
      go = { "goimports", "gofmt" },
      rust = { "rustfmt" },
      ["*"] = { "trim_whitespace" },
    },
  },
}
