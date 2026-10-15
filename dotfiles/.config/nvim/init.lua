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

-- -----------------------------------------------------------------------------
-- 5. CLIPBOARD (environment-aware)
-- -----------------------------------------------------------------------------
-- Priority: Termux -> Wayland -> X11 -> SSH (OSC52) -> none
local function is_termux()
  return vim.env.TERMUX_VERSION ~= nil
    or (vim.env.PREFIX ~= nil and vim.env.PREFIX:find("com.termux", 1, true) ~= nil)
end

local function setup_clipboard()
  if is_termux() and vim.fn.executable("termux-clipboard-set") == 1 then
    -- Termux:API calls are slow, so keep the cache on
    vim.g.clipboard = {
      name = "termux",
      copy = {
        ["+"] = "termux-clipboard-set",
        ["*"] = "termux-clipboard-set",
      },
      paste = {
        ["+"] = "termux-clipboard-get",
        ["*"] = "termux-clipboard-get",
      },
      cache_enabled = true,
    }
    return true
  end

  if vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 then
    vim.g.clipboard = {
      name = "WlClipboard",
      copy = {
        ["+"] = "wl-copy --foreground --type text/plain",
        ["*"] = "wl-copy --foreground --primary --type text/plain",
      },
      paste = {
        ["+"] = "wl-paste --no-newline",
        ["*"] = "wl-paste --no-newline --primary",
      },
      cache_enabled = true,
    }
    return true
  end

  if vim.env.DISPLAY and (vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1) then
    -- Let Neovim auto-detect its built-in xclip/xsel provider
    return true
  end

  if (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) and vim.ui.clipboard and vim.ui.clipboard.osc52 then
    local osc52 = require("vim.ui.clipboard.osc52")
    vim.g.clipboard = {
      name = "OSC 52",
      copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
      paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
    }
    return true
  end

  return false
end

-- Only sync with the system clipboard when a provider exists,
-- otherwise every yank would throw a "no clipboard tool" warning.
if setup_clipboard() then
  vim.opt.clipboard = "unnamed,unnamedplus"
end

-- -----------------------------------------------------------------------------
-- 6. PLUGINS (vendored in ~/.config/nvim/pack/*/opt/)
-- -----------------------------------------------------------------------------
-- ALE variables MUST be set before `packadd ale`, especially
-- ale_completion_enabled, or they are ignored.

-- Core behavior
vim.g.ale_lint_on_enter = 1
vim.g.ale_lint_on_save = 1
vim.g.ale_lint_on_text_changed = "normal"
vim.g.ale_lint_delay = 500
vim.g.ale_echo_msg_format = "[%linter%] %s [%severity%]"

-- Completion & diagnostics integration
vim.g.ale_completion_enabled = 1
vim.g.ale_completion_autoimport = 0
vim.g.ale_use_neovim_diagnostics_api = 1

-- Fixers (auto-format on save)
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
vim.g.ale_nix_nixfmt_executable = "nixfmt"
vim.g.ale_nix_nixfmt_options = ""

-- Linters
vim.g.ale_linters = {
  lua = { "luacheck", "lua_language_server" },
  python = { "ruff", "mypy" },
  javascript = { "eslint", "tsserver" },
  typescript = { "eslint", "tsserver" },
  json = { "jsonlint" },
  sh = { "shellcheck" },
  vim = { "vint" },
}

-- UI
vim.g.ale_sign_error = "✗"
vim.g.ale_sign_warning = "⚠"
vim.g.ale_sign_info = "ℹ"
vim.g.ale_sign_style_error = "✗"
vim.g.ale_sign_style_warning = "⚠"
vim.g.ale_set_highlights = 1
vim.g.ale_set_balloons = 0
vim.g.ale_virtualtext_cursor = "disabled"

-- Location list
vim.g.ale_open_list = 0
vim.g.ale_keep_list_window_open = 0
vim.g.ale_list_window_size = 8

-- Load after configuring
pcall(vim.cmd, "packadd ale")

-- ALE keymaps
vim.keymap.set("n", "<leader>af", "<cmd>ALEFix<CR>", { desc = "ALE Fix (format)" })
vim.keymap.set("n", "<leader>al", "<cmd>ALELint<CR>", { desc = "ALE Lint now" })
vim.keymap.set("n", "<leader>ad", "<cmd>ALEDetail<CR>", { desc = "ALE Detail" })
vim.keymap.set("n", "<leader>at", "<cmd>ALEToggle<CR>", { desc = "ALE Toggle" })
vim.keymap.set("n", "[e", "<cmd>ALEPreviousWrap<CR>", { desc = "Previous error" })
vim.keymap.set("n", "]e", "<cmd>ALENextWrap<CR>", { desc = "Next error" })

-- -----------------------------------------------------------------------------
-- 7. NATIVE FORMATTING (= operator, gq)
-- -----------------------------------------------------------------------------
-- `=` uses 'equalprg'; `gq` uses 'formatprg'. Set both.
local formatters = {
  lua = "stylua -",
  python = "black -q -",
  sh = "shfmt",
  nix = "nixfmt",
}
for _, ft in ipairs({ "javascript", "typescript", "json", "css", "html" }) do
  formatters[ft] = "prettier --stdin-filepath " .. ft
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("NativeFormatting", { clear = true }),
  pattern = vim.tbl_keys(formatters),
  callback = function(args)
    local cmd = formatters[args.match]
    -- prettier needs a real filename to pick its parser
    if cmd:find("^prettier") then
      local name = vim.api.nvim_buf_get_name(args.buf)
      if name == "" then
        name = "stdin." .. (args.match == "javascript" and "js" or args.match == "typescript" and "ts" or args.match)
      end
      cmd = "prettier --stdin-filepath " .. vim.fn.shellescape(name)
    end
    vim.bo[args.buf].equalprg = cmd
    vim.bo[args.buf].formatprg = cmd
  end,
})

-- -----------------------------------------------------------------------------
-- 8. UNDO & CURSOR POSITION
-- -----------------------------------------------------------------------------
local undodir = vim.fn.expand("~/.cache/nvim-undo")
vim.fn.mkdir(undodir, "p")
vim.opt.undodir = undodir
vim.opt.undofile = true

if pcall(vim.cmd, "packadd nvim-lastplace") then
  require("nvim-lastplace").setup({
    lastplace_open_folds = true,
  })
end

-- -----------------------------------------------------------------------------
-- 9. COLORSCHEME
-- -----------------------------------------------------------------------------
if pcall(vim.cmd, "packadd github-nvim-theme") then
  require("github-theme").setup({})
  vim.cmd.colorscheme("github_dark")
end
