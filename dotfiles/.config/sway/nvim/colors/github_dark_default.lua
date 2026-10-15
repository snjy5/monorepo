local cmd = vim.cmd

-- Background Highlight Colors
cmd 'hi CursorLine guibg=#161b22'
cmd 'hi Search guibg=yellow'
cmd 'hi Visual guibg=#555555'
cmd 'hi VisualNOS guibg=#b3b1ad'
cmd 'hi VisualSelection guibg=#163356'
cmd 'hi Pmenu guibg=#161b22'

-- Cursor & LineNumber Colors
cmd 'hi Cursor guifg=#73b7f2 guibg=NONE'
cmd 'hi LineNr guifg=#8b949e'
cmd 'hi CursorLineNr guifg=#c9d1d9'

-- LSP & Diagnostic Colors
cmd 'hi LspDiagnosticsDefaultError guifg=#f85149'
cmd 'hi LspDiagnosticsDefaultWarning guifg=#f0883e'

-- Git & Diff Colors
cmd 'hi DiffAdd guifg=#56d364'
cmd 'hi DiffChange guifg=#ac8934'
cmd 'hi DiffDelete guifg=#f85149'
cmd 'hi DiffText guifg=#e3b341'

-- Terminal Colors
cmd 'hi Normal guifg=#c9d1d9 guibg=#0d1117'
-- cmd 'hi Normal guifg=#FFFFFF guibg=#000000'
cmd 'hi Comment guifg=#8b949e'
cmd 'hi Directory guifg=#FFFFFF'
cmd 'hi Ignore guifg=#484f58'
cmd 'hi Error guifg=red guibg=none'
cmd 'hi Warning guifg=#f0883e'
cmd 'hi Constant guifg=#79c0ff'
cmd 'hi String guifg=#a5d6ff'
cmd 'hi Identifier guifg=#79c0ff'
cmd 'hi Statement guifg=#ff7b72'
cmd 'hi Function guifg=#d2a8ff'
cmd 'hi Type guifg=#ff7b72'
cmd 'hi Special guifg=#ff7b72'
cmd 'hi Todo guifg=#8b949e'
cmd 'hi SpellBad guifg=#f85149 guisp=#f85149'
cmd 'hi SpellLocal guifg=#ffa657 guisp=#ffa657'
cmd 'hi SpellCap guifg=#ffa657 guisp=#ffa657'
cmd 'hi SpellRare guifg=#ffa657 guisp=#ffa657'
cmd 'hi PreProc guifg=#ff7b72'

-- Misc Colors
cmd 'hi Default guibg=#000000'
cmd 'hi SignColumn guifg=NONE guibg=NONE ctermbg=0 ctermfg=0'
cmd 'hi VertSplit guibg=#000000'
cmd 'hi StatusLine guibg=#090c10'
cmd 'hi StatusLineNC guibg=#090c10'
cmd 'hi Modemsg guifg=fg ctermfg=0 guibg=bg ctermbg=0'
cmd 'hi NonText guifg=bg ctermfg=0'
cmd 'hi EndOfBuffer guifg=bg ctermfg=0'
cmd 'hi MatchParen guibg=#105357'

-- Plugin Colors
cmd 'hi GitSignsAdd guifg=#196c2e'
cmd 'hi GitSignsChange guifg=#9e6a03'
cmd 'hi GitSignsDelete guifg=#b62324'

-- ALE settings
cmd 'hi ALEErrorSign guifg=red guibg=none'
cmd 'hi ALEStyleErrorSign guifg=red guibg=none'
cmd 'hi ALESignColumnWithErrors guifg=red guibg=red'
cmd 'hi ALEWarningSign guifg=red guibg=none'
cmd 'hi ALEStyleWarningSign guifg=none guibg=none'
cmd 'hi ALEInfoSign guifg=#666666 guibg=none'

