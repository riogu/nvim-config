"AUTHOR: Alessandro Yorba
"SCRIPT: https://github.com/AlessandroYorba/Sierra
"
"UPDATED: Fri Aug 12, 2022
"CHANGES: Organized colors in groups, revised terminal_ansi_colors
"
"SUPPORT:
" 256 color terminals, Gui versions of vim, and Termguicolors versions of vim
"
"INSTALL LOCATION:
"Unix users, place sierra.vim in ~/.vim/colors
"Windows users, place sierra.vim in ~\vimfiles\colors

"From your .vimrc add one of the following options
" colorscheme sierra
"
set background=dark

highlight clear
if exists("syntax_on")
	syntax reset
endif

let g:colors_name="sierra"

if !exists("g:sierra_Nevada")
	let g:sierra_Nevada = 0
endif

"TERMINAL COLORS
let g:terminal_ansi_colors = [
	\ '#262626',
	\ '#D75F5F',
	\ '#5F8787',
	\ '#DFAF5F',
	\ '#ae8687',
	\ '#5F87AF',
	\ '#AF8787',
	\ '#87AFAF',
	\ '#BFBFBF',
	\ '#3a3a3a',
	\ '#D75F5F',
	\ '#5F8787',
	\ '#DFAF5F',
	\ '#AF8787',
	\ '#87AFAF',
	\ '#E5E5E5',]


"CYAN:
highlight! Cyan guifg=#87afaf guibg=NONE gui=NONE ctermfg=109 ctermbg=NONE cterm=NONE
highlight! link FoldColumn Cyan
highlight! link cssTagName Cyan
highlight! link vimUserFunc Cyan
highlight! link Function Cyan
highlight! link vimFunction Cyan
highlight! link Identifier Cyan
highlight! link vimAutoEventList Cyan

"CYAN_REVERSE:
highlight! Cyan_Reverse guifg=#87afaf guibg=NONE gui=reverse ctermfg=109 ctermbg=NONE cterm=reverse
highlight! link DiffAdd Cyan_Reverse
highlight! link DiffText Cyan_Reverse
highlight! link diffAdded Cyan_Reverse

"CYAN_DARK:
highlight! Cyan_Dark guifg=#5f8787 guibg=NONE gui=NONE ctermfg=66 ctermbg=NONE cterm=NONE

"CYAN_DARK_REVERSE:
highlight! Cyan_Dark_Reverse guifg=#5f8787 guibg=NONE gui=reverse ctermfg=66 ctermbg=NONE cterm=reverse
highlight! link DiffChange Cyan_Dark_Reverse

"RED:
highlight! Red guifg=#d75f5f guibg=NONE gui=NONE ctermfg=167 ctermbg=NONE cterm=NONE
highlight! link htmlEndTag Red
highlight! link htmlTag Red
highlight! link htmlItalic Red
highlight! link htmlStatement Red
highlight! link vimAutoCmdSfxList Red
highlight! link PreProc Red
highlight! link cssClassName Red
highlight! link cssIdentifier Red
highlight! link Title Red
highlight! link WarningMsg Red
highlight! link diffBDiffer Red
highlight! link diffCommon Red
highlight! link diffDiffer Red
highlight! link diffIdentical Red
highlight! link diffIsA Red
highlight! link diffNoEOL Red
highlight! link diffOnly Red
highlight! link netrwExe Red

"RED_REVERSE:
highlight! Red_Reverse guifg=#d75f5f guibg=NONE gui=reverse ctermfg=167 ctermbg=NONE cterm=reverse
highlight! link Error Red_Reverse
highlight! link ErrorMsg Red_Reverse

highlight! Red_Dark guifg=#af5f5f guibg=NONE gui=NONE ctermfg=131 ctermbg=NONE cterm=NONE
highlight! link Label Red_Dark
highlight! link Constant Red_Dark

highlight! Red_Medium guifg=#d78787 guibg=NONE gui=NONE ctermfg=174 ctermbg=NONE cterm=NONE
highlight! link htmlArg Red_Medium
highlight! link Number Red_Medium
highlight! link Type Red_Medium

highlight! Red_Light guifg=#dfafaf guibg=NONE gui=NONE ctermfg=181 ctermbg=NONE cterm=NONE
highlight! link String Red_Light

highlight! Red_Dark_Reverse guifg=#af5f5f guibg=NONE gui=reverse ctermfg=131 ctermbg=NONE cterm=reverse
highlight! link DiffDelete Red_Dark_Reverse
highlight! link diffChanged Red_Dark_Reverse
highlight! link diffFile Red_Dark_Reverse
highlight! link diffIndexLine Red_Dark_Reverse
highlight! link diffRemoved Red_Dark_Reverse

"PURPLE:
highlight! Purple guifg=#af8787 guibg=NONE gui=NONE ctermfg=138 ctermbg=NONE cterm=NONE
highlight! link Special Purple
highlight! link vimCmdSep Purple
highlight! link Directory Purple

highlight! Purple_Dark guifg=#875f5f guibg=NONE gui=NONE ctermfg=95 ctermbg=NONE cterm=NONE

"GREY:
highlight! Grey guifg=#a8a8a8 guibg=NONE gui=NONE ctermfg=248 ctermbg=NONE cterm=NONE
highlight! link Operator Grey
highlight! link Statement Grey
highlight! link StorageClass Grey
highlight! link Conditional Grey

highlight! Grey_Reverse guifg=#767676 guibg=NONE gui=reverse ctermfg=243 ctermbg=NONE cterm=reverse
highlight! link SpecialComment Grey_Reverse
highlight! link VimCommentTitle Grey_Reverse
highlight! link vimCommentTitle Grey_Reverse

highlight! Grey_Light_Reverse guifg=#c6c6c6 guibg=NONE gui=reverse ctermfg=251 ctermbg=NONE cterm=reverse
highlight! link WildMenu Grey_Light_Reverse
highlight! link Visual Grey_Light_Reverse
highlight! link Search Grey_Light_Reverse


"ORANGE:
highlight! Orange guifg=#dfaf5f guibg=NONE gui=NONE ctermfg=179 ctermbg=NONE cterm=NONE
highlight! link MoreMsg Orange
highlight! link Question Orange

"TODO:
highlight Underlined guifg=#dfaf87 guibg=NONE gui=NONE ctermfg=180 ctermbg=NONE cterm=NONE
highlight MatchParen guifg=#eeeeee guibg=#875f5f gui=NONE ctermfg=255 ctermbg=95 cterm=NONE
highlight ModeMsg guifg=#dfdfdf guibg=NONE gui=NONE ctermfg=188 ctermbg=NONE cterm=NONE
highlight Todo guifg=#eeeeee guibg=#1c1c1c gui=reverse ctermfg=255 ctermbg=234 cterm=reverse
highlight SignColumn guifg=#87af87 guibg=NONE gui=NONE ctermfg=108 ctermbg=NONE cterm=NONE

"DEFAULT UI
if 1
	"COLORS
	highlight Normal guifg=#d0d0d0 guibg=#262626 gui=NONE ctermfg=252 ctermbg=236 cterm=NONE
	highlight Comment guifg=#626262 guibg=NONE gui=NONE ctermfg=241 ctermbg=NONE cterm=NONE

	"WINDOW UI
	highlight StatusLine guifg=#eeeeee guibg=#262626 gui=NONE ctermfg=255 ctermbg=235 cterm=NONE
	highlight StatusLineNC guifg=#6c6c6c guibg=#262626 gui=NONE ctermfg=242 ctermbg=235 cterm=NONE
	highlight StatusLineTerm guifg=#eeeeee guibg=#262626 gui=NONE ctermfg=255 ctermbg=235 cterm=NONE
	highlight StatusLineTermNC guifg=#6c6c6c guibg=#262626 gui=NONE ctermfg=242 ctermbg=235 cterm=NONE

	highlight Pmenu guifg=#6c6c6c guibg=#3a3a3a gui=NONE ctermfg=242 ctermbg=237 cterm=NONE
	highlight PmenuSel guifg=#eeeeee guibg=#3a3a3a gui=NONE ctermfg=255 ctermbg=237 cterm=NONE
	highlight PmenuSbar guifg=#303030 guibg=#3a3a3a gui=NONE ctermfg=236 ctermbg=237 cterm=NONE
	highlight PmenuThumb guifg=#303030 guibg=#3a3a3a gui=NONE ctermfg=236 ctermbg=237 cterm=NONE

	highlight TabLine guifg=#6c6c6c guibg=#262626 gui=NONE ctermfg=242 ctermbg=235 cterm=NONE
	highlight TabLineSel guifg=#eeeeee guibg=#262626 gui=NONE ctermfg=255 ctermbg=235 cterm=NONE
	highlight TabLineFill guifg=NONE guibg=#262626 gui=NONE ctermfg=NONE ctermbg=235 cterm=NONE

	highlight CursorLineNR guifg=#9e9e9e guibg=#262626 gui=NONE ctermfg=247 ctermbg=235 cterm=NONE
	highlight CursorLine guifg=NONE guibg=#3a3a3a gui=NONE ctermfg=NONE ctermbg=237 cterm=NONE
	highlight CursorColumn guifg=NONE guibg=#3a3a3a gui=NONE ctermfg=NONE ctermbg=237 cterm=NONE
	highlight ColorColumn guifg=NONE guibg=#3a3a3a gui=NONE ctermfg=NONE ctermbg=237 cterm=NONE
	highlight Folded guifg=#6c6c6c guibg=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE

	" highlight VertSplit guifg=#3a3a3a guibg=#303030 gui=NONE ctermfg=237 ctermbg=236 cterm=NONE
	highlight WinSeparator guifg=#3a3a3a guibg=00 gui=NONE ctermfg=237 ctermbg=236 cterm=NONE
	highlight LineNr guifg=#4e4e4e guibg=#262626 gui=NONE ctermfg=239 ctermbg=235 cterm=NONE
	highlight NonText guifg=#3a3a3a guibg=NONE gui=NONE ctermfg=237 ctermbg=NONE cterm=NONE
	highlight SpecialKey guifg=#3a3a3a guibg=NONE gui=NONE ctermfg=237 ctermbg=NONE cterm=NONE

	highlight SpellBad guifg=#ff0000 guibg=NONE gui=undercurl ctermfg=196 ctermbg=NONE cterm=undercurl
	highlight SpellLocal guifg=#5f875f guibg=NONE gui=undercurl ctermfg=65 ctermbg=NONE cterm=undercurl
	highlight SpellCap guifg=#87afff guibg=NONE gui=undercurl ctermfg=111 ctermbg=NONE cterm=undercurl
	highlight SpellRare guifg=#ff8700 guibg=NONE gui=undercurl ctermfg=208 ctermbg=NONE cterm=undercurl

	highlight VisualNOS guifg=NONE guibg=NONE gui=underline ctermfg=NONE ctermbg=NONE cterm=underline
	highlight Cursor guifg=#000000 guibg=#ffffff gui=NONE ctermfg=16 ctermbg=231 cterm=NONE
endif

"REMOVE BLOCK MATCHPARENS - ADDS UNDERLINE
if g:sierra_Nevada
	"WINDOW UI
	highlight MatchParen guifg=#ffffff guibg=#000000 gui=underline ctermfg=231 ctermbg=16 cterm=underline
endif

