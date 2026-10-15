-- Set options using Neovim Lua API
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.wrap = true
vim.opt.secure = false
vim.opt.binary = true
vim.opt.number = false
vim.opt.cindent = false
vim.opt.hlsearch = true
vim.opt.laststatus = 0
vim.opt.showmode = true
vim.opt.matchtime = 3
vim.opt.showmatch = true
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.shortmess:append('F')
vim.opt.history = 10000
vim.opt.shell = '/bin/bash'
--vim.opt.clipboard = 'unnamed,unnamedplus'
vim.opt.backspace = 'indent,eol,start'
--vim.opt.path:append('**')
vim.opt.mouse = ''
vim.opt.guifont = 'JetBrainsMono'
vim.opt.linespace = 0
vim.opt.cursorline = false
vim.opt.textwidth = 0
vim.opt.guicursor = "n-v-c-i:ver25"

-- Misc settings
vim.cmd('set expandtab')
vim.cmd('set t_Co=256')
vim.cmd('noswapfile')
vim.cmd('syntax on')
vim.cmd('filetype on')
vim.cmd('filetype plugin on')
vim.cmd('filetype indent on')
vim.cmd('set signcolumn=yes')
--vim.cmd(':imap jk <Esc>')
--vim.cmd(':imap kj <Esc>')
vim.cmd('nnoremap Q :q<CR>')
vim.cmd('nnoremap QQ :q!<CR>')
vim.cmd('set omnifunc=ale#completion#OmniFunc')
vim.cmd('set nolist')

-- Vim plug
vim.cmd ('source ~/.config/nvim/autoload/plug.vim')
vim.cmd [[ call plug#begin()
	Plug 'nvim-treesitter/nvim-treesitter'
call plug#end()
]]

vim.cmd('colorscheme github_dark_default')
--vim.cmd('colorscheme slate')
--vim.cmd('highlight Function guifg=#C00D06')

-- Treesitter setup
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
	additional_vim_regex_highlighting = true,
  },
  ensure_installed = {
	  'lua',
	  'vim',
	  'vimdoc',
  },
  sync_install = true,
  auto_install = true,
}

-- ALE configuration
--vim.g.ale_enabled = 1
--vim.g.ale_lint_on_text_changed = 'never'
--vim.g.ale_lint_on_insert_leave = 0
--vim.g.ale_fix_on_save = 1
--vim.g.ale_completion_enabled = 1
--vim.g.ale_sign_error = '✖'
--vim.g.ale_sign_warning = '⚠'
--vim.g.ale_sign_info = 'I:'
--vim.g.ale_set_loclist = 1
--vim.g.ale_use_neovim_diagnostics_ = 1

-- Colorscheme adjustments
vim.api.nvim_exec([[
  hi Normal guibg=#000000 guifg=#AAAAAA
  hi NonText guifg=bg guibg=bg ctermfg=NONE ctermbg=NONE
  hi EndOfBuffer guibg=bg guifg=bg ctermfg=NONE ctermbg=NONE
  hi SignColumn guifg=bg guibg=bg ctermbg=NONE ctermfg=NONE
  hi ALEErrorSign guifg=red guibg=none
  hi ALEStyleErrorSign guifg=red guibg=none
  hi ALESignColumnWithErrors guifg=red guibg=red
  hi ALEWarningSign guifg=red guibg=none
  hi ALEStyleWarningSign guifg=none guibg=none
  hi ALEInfoSign guifg=#666666 guibg=none
]], false)

-- Autocommand to preserve last position
vim.api.nvim_exec([[
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]], false)

-- Autosave
local timer = vim.loop.new_timer()
vim.api.nvim_create_autocmd({"TextChangedI", "TextChanged"}, {
  pattern = "*",
  callback = function()
    timer:stop()
    timer:start(500, 0, vim.schedule_wrap(function()
      vim.cmd("silent! wall")
    end))
  end,
})

-- Function to run current file
local function RunCurrentFile()
    local out = vim.fn.system('make ' .. vim.fn.expand('%:r'))
    if vim.v.shell_error ~= 0 then
        print('Error: ' .. out)
    else
        local run_output = vim.fn.system('./' .. vim.fn.expand('%:r'))
        print('Output: ' .. run_output)
    end
end

-- Map <F5> to run code
vim.api.nvim_set_keymap('n', '<F5>', ':lua RunCurrentFile()<CR>', { noremap = true })

-- Enable persistent undo
vim.opt.undofile = true
vim.cmd('set undodir=~/.cache')
