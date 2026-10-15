local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false          -- lualine shows the mode
opt.signcolumn = "yes"        -- prevent layout shift when diagnostics appear
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.fillchars = { eob = " " }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Editing behavior
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4               -- formatters enforce per-language style anyway
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- 0.10+ auto-enables OSC52 for SSH sessions
opt.undofile = true           -- persistent undo across restarts
opt.confirm = true            -- ask instead of failing on unsaved quit
opt.virtualedit = "block"

-- Windows/splits
opt.splitright = true
opt.splitbelow = true

-- Timing
opt.updatetime = 250
opt.timeoutlen = 400          -- which-key popup delay

-- 0.11+: rounded borders on all floating windows (hover, signature help, etc.)
if vim.fn.has("nvim-0.11") == 1 then
  vim.o.winborder = "rounded"
end
