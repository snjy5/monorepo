return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",           -- NOTE: Mason moved to the mason-org GitHub org
    "mason-org/mason-lspconfig.nvim", -- v2: auto-installs AND auto-enables servers [[1]][[4]]
    "hrsh7th/cmp-nvim-lsp",
  },
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "Mason", "LspInfo" },
  config = function()
    -- 1. Advertise nvim-cmp capabilities to ALL servers (0.11 wildcard config)
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    -- 2. Per-server settings, merged into lspconfig's defaults
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.config("pyright", {
      settings = {
        python = { analysis = { typeCheckingMode = "basic", autoImportCompletions = true } },
      },
    })
    vim.lsp.config("gopls", {
      settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
    })

    -- 3. Diagnostics UI
    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded", source = true },
      sign = {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
    })

    -- 4. Mason: install + enable servers automatically
    require("mason").setup({ ui = { border = "rounded" } })
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls", "pyright", "ts_ls", "jsonls", "yamlls",
        "bashls", "clangd", "gopls", "rust_analyzer",
      },
      automatic_enable = true, -- default in v2; explicit for readability [[4]]
    })

    -- 5. Only what core does NOT already give us.
    --    Native since 0.11: grn/gra/grr/gri/grt/gO [[24]][[26]], K hover [[28]]
    --    Native since 0.10: [d ]d, <C-w>d
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
        if client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end

        local function map(keys, fn, desc, mode)
          vim.keymap.set(mode or "n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
        end

        map("gd", vim.lsp.buf.definition, "Goto definition")
        map("gD", vim.lsp.buf.declaration, "Goto declaration")
        map("<leader>cr", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
        map("<leader>cs", vim.lsp.buf.signature_help, "Signature help")
        map("<leader>ct", vim.lsp.buf.type_definition, "Type definition")
        map("<leader>ci", function()
          vim.lsp.inlay_hint.enable(
            not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
            { bufnr = ev.buf }
          )
        end, "Toggle inlay hints")
      end,
    })
  end,
}
