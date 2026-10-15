-- =============================================================================
-- NEOVIM CONFIGURATION
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. CORE & COMPATIBILITY
-- -----------------------------------------------------------------------------
vim.opt.swapfile = true
vim.opt.history = 10000
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Filetype support
vim.cmd.syntax("on")

-- -----------------------------------------------------------------------------
-- 2. INDENTATION & EDITING BEHAVIOR
-- -----------------------------------------------------------------------------
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.virtualedit = "all"
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.formatoptions:remove("t")

-- Disable autocommenting on new lines
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("DisableAutoComment", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o", "q", "l" })
  end,
})

-- -----------------------------------------------------------------------------
-- 3. SEARCH
-- -----------------------------------------------------------------------------
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.matchtime = 3

-- Clear search highlight on Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohl<CR>", { silent = true })

-- -----------------------------------------------------------------------------
-- 4. UI & DISPLAY
-- -----------------------------------------------------------------------------
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.linespace = 1
vim.opt.laststatus = 0
vim.opt.ruler = true
vim.opt.showcmd = true
vim.opt.showmode = true
vim.opt.signcolumn = "no"
vim.opt.list = false
vim.opt.fillchars = { eob = " " }

-- Line numbers (absolute for phone rendering performance)
vim.opt.number = true
vim.opt.relativenumber = false

-- Wrapping (optimized for small screens)
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.scrolloff = 3

-- Transparent backgrounds (re-applied on every colorscheme change)
local function set_transparent_background()
  local groups = {
    "Normal", "NormalNC", "NormalFloat", "FloatBorder",
    "SignColumn", "LineNr", "CursorLineNr", "FoldColumn",
    "EndOfBuffer", "StatusLine", "StatusLineNC",
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

set_transparent_background()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("TransparentBG", { clear = true }),
  pattern = "*",
  callback = set_transparent_background,
})

-- Sync both unnamed (*) and unnamedplus (+) to the system clipboard
vim.opt.clipboard = "unnamed,unnamedplus"

-- Explicitly tell Neovim to use wl-copy and wl-paste for these registers
vim.g.clipboard = {
  name = 'WlClipboard',
  copy = {
    ["+"] = 'wl-copy --foreground --type text/plain',
    ["*"] = 'wl-copy --foreground --primary --type text/plain',
  },
  paste = {
    ["+"] = 'wl-paste --no-newline',
    ["*"] = 'wl-paste --no-newline --primary',
  },
  cache_enabled = true,
}
-- -----------------------------------------------------------------------------
-- Plugins
-- -----------------------------------------------------------------------------
-- Vendored Plugins by git: im tired of package managers
vim.opt.packpath:append("~/.config/nvim/pack")

vim.cmd("packadd ale")

-- Core behavior
vim.g.ale_lint_on_enter = 1                -- Lint when opening a file
vim.g.ale_lint_on_save = 1                 -- Lint on save
vim.g.ale_lint_on_text_changed = 'normal'  -- Lint while typing (normal mode only)
vim.g.ale_lint_delay = 500                 -- Debounce linting by 500ms
vim.g.ale_echo_msg_format = '[%linter%] %s [%severity%]'

-- Completion & Diagnostics Integration
vim.g.ale_completion_enabled = 1
vim.g.ale_completion_autoimport = 0
vim.g.ale_use_neovim_diagnostics_api = 1   -- Push ALE diagnostics to native Neovim API
vim.opt.omnifunc = "ale#completion#OmniFunc"

-- Fixers (Auto-formatting on save)
vim.g.ale_fix_on_save = 1
vim.g.ale_fixers = {
  lua = { "stylua" },
  python = { "black", "isort" },
  javascript = { "prettier", "eslint" },
  typescript = { "prettier", "eslint" },
  json = { "prettier" },
  css = { "prettier" },
  html = { "prettier" },
  sh = { "shfmt" },
  vim = { "vint" },
  nix = { "nixfmt" },
  ["*"] = { "remove_trailing_lines", "trim_whitespace" },
}

-- Specific Fixer Options
vim.g.ale_nix_nixfmt_executable = "nixfmt"
vim.g.ale_nix_nixfmt_options = ""

-- Linters (Diagnostics)
vim.g.ale_linters = {
  lua = { 'luacheck', 'lua_language_server' },
  python = { 'ruff', 'mypy' },
  javascript = { 'eslint', 'tsserver' },
  typescript = { 'eslint', 'tsserver' },
  json = { 'jsonlint' },
  sh = { 'shellcheck' },
     vim = { 'vint' },
}

-- UI: Sign column, gutter, and virtual text
vim.g.ale_sign_error = '✗'
vim.g.ale_sign_warning = '⚠'
vim.g.ale_sign_info = 'ℹ'
vim.g.ale_sign_style_error = '✗'
vim.g.ale_sign_style_warning = '⚠'
vim.g.ale_set_highlights = 1               -- Highlight errors/warnings in buffer
vim.g.ale_set_balloons = 0                 -- Disable mouse balloons
vim.g.ale_virtualtext_cursor = 'disabled'  -- Use native diagnostics API instead

-- Quickfix / Location list
vim.g.ale_open_list = 0                    -- Don't auto-open loclist
vim.g.ale_keep_list_window_open = 0        -- Close loclist when empty
vim.g.ale_list_window_size = 8             -- Height of loclist when opened

-- ALE Keymaps
vim.keymap.set('n', '<leader>af', '<cmd>ALEFix<CR>', { desc = 'ALE Fix (format)' })
vim.keymap.set('n', '<leader>al', '<cmd>ALELint<CR>', { desc = 'ALE Lint now' })
vim.keymap.set('n', '<leader>ad', '<cmd>ALEDetail<CR>', { desc = 'ALE Detail (full diagnostic)' })
vim.keymap.set('n', '<leader>at', '<cmd>ALEToggle<CR>', { desc = 'ALE Toggle on/off' })
vim.keymap.set('n', '[e', '<cmd>ALEPreviousWrap<CR>', { desc = 'Previous error' })
vim.keymap.set('n', ']e', '<cmd>ALENextWrap<CR>', { desc = 'Next error' })

-- -----------------------------------------------------------------------------
--  NATIVE FORMATTING (=G)
-- -----------------------------------------------------------------------------
-- Configure formatprg so the native `=` operator works with your specific tools
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("NativeFormatting", { clear = true }),
  pattern = { 
    "lua", "python", "javascript", "typescript", 
    "json", "css", "html", "sh", "nix" 
  },
  callback = function(args)
    local ft = args.match
    
    if ft == "lua" then
      vim.bo.formatprg = "stylua -"
    elseif ft == "python" then
      vim.bo.formatprg = "black -q -"
    elseif ft == "javascript" or ft == "typescript" or ft == "json" or ft == "css" or ft == "html" then
      vim.bo.formatprg = "prettier --stdin-filepath " .. vim.fn.expand("%:p")
    elseif ft == "sh" then
      vim.bo.formatprg = "shfmt"
    elseif ft == "nix" then
      vim.bo.formatprg = "nixfmt"
    end
  end,
})


-- Plugin to remember position
vim.cmd("packadd nvim-lastplace")

vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.cache/nvim-undo")


-- Remember cursor position for single files
require'nvim-lastplace'.setup{
     lastplace_open_folds = true
}

-- Colorscheme
vim.cmd("packadd github-nvim-theme")

require'github-theme'.setup{}
vim.cmd("colorscheme github_dark")
