local M = {}

local p = {
	background_color = "#2F333C",

	const_orange = "#FF9A5C",
	variable_purple_blue = "#7A8BB8",
	lighter_variable_whiteish = "#97A7D2",
	class_struct_blue = "#8EA3D9",
	normal_text_gray = "#E7F2FC",
	soft_grey_highlight = "#3A4356",
	softer_grey_highlight = "#445069",
	even_softer_grey_highlight = "#5E6A83",
	even_even_softer_grey_highlight = "#6F7D9A",
	even_even_even_softer_grey_highlight = "#8899BE",
	most_soft_grey_highlight = "#8897B6",
	variable_scope_color = "#CDD4E8",
	almost_background_color = "#313645",

	global_blue = "#567CC6",
	global_red = "#e35c5c",

	gold_yellow = "#FCBF55",
	dark_green = "#5C898B",
	string_green = "#589A8F",
	struct_strong_blue = "#A7B3EC",
	directory_color = "#7EA8FF",
	parameter_orangeish = "#5E80B7",
	stronger_directory_color = "#78B7D7",

	function_name_blue = "#9CD1FF",
	macro_green = "#5ABCAC",
	greyish_green_riogu = "#617B85",
	red_fixme = "#D14A65",
	soft_pinkish = "#E0B4BB",
	todo_fg = "#5270B5",
	todo_bg = "#0b1e33",
	note_fg = "#ff57fF",
	note_bg = "#7A644D",
	warning_fg = "#ff9900",
	danger_fg = "#ff8b64",
}

local highlight_groups = {
	--Main
	Conditional = { fg = p.soft_pinkish },
	Normal = { fg = p.normal_text_gray, bg = p.background_color },
	NormalNC = { link = "Normal" },
	MsgArea = { fg = p.gold_yellow, bg = p.almost_background_color },
	NormalFloat = { bg = p.almost_background_color, fg = "NONE" },
	Bold = { bold = true },
	Italic = { italic = true },
	Underlined = { undercurl = false },
	Visual = { bg = p.soft_grey_highlight, fg = "NONE" },
	Directory = { fg = p.directory_color, bold = true },
	IncSearch = { fg = "NONE", bg = p.even_softer_grey_highlight }, -- yanking color
	Search = { link = "IncSearch" },
	Substitute = { link = "IncSearch" },
	MatchParen = { fg = "NONE", bg = p.soft_grey_highlight },
	ModeMsg = { link = "Normal" },
	MoreMsg = { link = "Normal" },
	WarningMsg = { fg = p.gold_yellow },
	FloatBorder = { fg = p.even_softer_grey_highlight, bg = "NONE" },
	NonText = { link = "Normal" },
	LineNr = { bg = p.background_color, fg = p.soft_grey_highlight },
	LineNrAbove = { link = "LineNr" },
	LineNrBelow = { link = "LineNr" },
	-- Quickfix/Location list
	qfLineNr = { fg = p.even_softer_grey_highlight }, -- Softer line numbers
	qfFileName = { fg = p.class_struct_blue, bold = true },
	qfSeparator = { fg = p.even_even_softer_grey_highlight },
	qfText = { fg = p.variable_purple_blue },
	-- Selected line in quickfix
	QuickFixLine = { bg = p.soft_grey_highlight },

	DiagnosticVirtualTextError = { bg = "none", fg = "#B9545E" },
	DiagnosticVirtualTextHint = { bg = "none", fg = p.global_blue },
	DiagnosticVirtualTextInfo = { bg = "none", fg = p.global_blue },
	DiagnosticVirtualTextWarn = { bg = "none", fg = p.global_blue },

	CursorLine = { fg = "NONE", bg = p.soft_grey_highlight },
	CursorLineNr = { fg = p.gold_yellow, bg = "NONE" },
	Cursor = { bg = p.variable_scope_color },
	-- Status line ------------------------------------------
	StatusLine = { fg = p.gold_yellow, bg = p.almost_background_color },
	StatusLineNC = { fg = p.even_even_softer_grey_highlight, bg = p.almost_background_color },
	WinSeparator = { fg = p.soft_grey_highlight, bg = "NONE" },
	StatusLineAccent = { bg = p.almost_background_color },
	-- Mode = { bg =p.almost_background_color },
	-----------------------------------------------------------
	EndOfBuffer = { fg = p.soft_grey_highlight, bg = p.background_color },
	SignColumn = { bg = p.background_color },
	Colorcolumn = { link = "StatusLine" },
	TabLineFill = { bg = p.soft_grey_highlight },
	TabLine = { bg = p.soft_grey_highlight },
	TabLineSel = { fg = "NONE", bg = p.soft_grey_highlight },
	Whitespace = { bg = "NONE", fg = p.variable_purple_blue },
	Pmenu = { fg = p.variable_purple_blue, bg = p.almost_background_color },
	PmenuSel = { bg = p.almost_background_color, fg = p.normal_text_gray },
	PmenuThumb = { bg = p.greyish_green_riogu },
	PmenuSbar = { bg = p.softer_grey_highlight },

	-- YankHighlight = { bg = p.gold_yellow },

	-- telescope stuff-----------
	["@variable.parameter.python"] = { fg = p.soft_pinkish },
	-- ['@variable.python'] = { fg = p.soft_pinkish },
	-- TelescopeMatching = { fg = p.variable_whiteish },
	-- TelescopeSelection = { fg = p.variable_whiteish },
	TelescopeResultsTitle = { fg = p.variable_purple_blue, bold = true },
	TelescopeResultsNormal = { fg = p.variable_purple_blue },
	TelescopeResultsBorder = { fg = p.variable_purple_blue },
	TelescopePreviewTitle = { fg = p.variable_purple_blue },
	TelescopePreviewNormal = { bg = "NONE" },
	TelescopePreviewBorder = { fg = p.variable_purple_blue, bg = "NONE" },
	TelescopePromptTitle = { fg = p.variable_purple_blue },
	TelescopePromptPrefix = { fg = p.variable_purple_blue },
	TelescopePromptCounter = { fg = p.variable_purple_blue },
	TelescopePromptNormal = { fg = p.variable_purple_blue },
	TelescopePromptBorder = { fg = p.variable_purple_blue },
	-----------------------------
	Conceal = { link = "Operator" },
	Title = { link = "Normal" },
	Question = { link = "Normal" },
	WildMenu = { link = "Pmenu" },
	Folded = { fg = p.greyish_green_riogu },
	FoldColumn = { link = "Folded" },
	Error = { fg = p.soft_pinkish },
	ErrorMsg = { link = "Error" },
	-- Spelling
	SpellBad = { undercurl = true },
	SpellLocal = { undercurl = true },
	SpellCap = { undercurl = true },
	SpellRare = { undercurl = true },
	-- Syntax
	Boolean = { fg = p.soft_pinkish },
	Character = { link = "String" },
	Comment = { fg = p.even_softer_grey_highlight },
	Constant = { fg = p.dark_green },
	Define = { bg = p.even_softer_grey_highlight },
	Delimiter = { fg = p.greyish_green_riogu }, --colons and double dots
	Function = { fg = p.function_name_blue },
	Identifier = { fg = p.variable_purple_blue },
	Include = { link = "PreProc" },
	Keyword = { fg = p.class_struct_blue }, -- for loops and if statements (lmao)
	Label = { link = "String" },
	Number = { fg = "#E0B4BB" },
	Float = { link = "Number" },
	Operator = { fg = p.most_soft_grey_highlight },
	PreProc = { fg = p.global_blue },

	-- Repeat = { fg = p.parameter_white, bg = p.normal_text_gray },
	Special = { fg = p.gold_yellow },
	SpecialChar = { link = "String" },
	SpecialComment = { link = "SpecialChar" },
	SpecialKey = { fg = p.even_softer_grey_highlight }, -- Change here
	Statement = { link = "Type" },
	StorageClass = { fg = p.lighter_variable_whiteish },
	String = { fg = p.string_green },
	Structure = { fg = p.function_name_blue },
	LogPath = { fg = p.variable_purple_blue },
	Variable = { fg = p.variable_scope_color },
	Tag = { link = "SpecialChar" },
	Todo = { fg = p.todo_fg, bg = p.todo_bg },
	Type = { fg = p.gold_yellow },
	Typedef = { fg = p.gold_yellow },
	["luaTable"] = { link = "Normal" },
	["@text.todo"] = { fg = p.todo_fg, bg = p.todo_bg },
	["@text.note"] = { fg = p.note_fg, bg = p.note_bg },
	["@text.danger"] = { fg = p.danger_fg, bg = p.gruber_darker_red_custom_m1 },
	["@text.uri"] = { fg = p.gruber_darker_niagara, underline = true },
	["@unchecked_list_item"] = { link = "normal" },
	["@checked_list_item"] = { fg = p.greyish_green_riogu, strikethrough = true },
	["@text.todo.unchecked"] = { link = "@unchecked_list_item" },
	["@text.todo.checked"] = { link = "@checked_list_item" },
	["@keyword"] = { link = "Keyword" },
	["@function"] = { link = "Function" },
	["@method"] = { fg = p.parameter_orangeish },
	["@field"] = { link = "Identifier" },
	["@constructor"] = { link = "Function" },
	-- ['@repeat'] = { fg = p.gold },
	["@label"] = { link = "String" },
	["@variable"] = { link = "Variable" },
	["@type"] = { link = "Type" },
	["@type.builtin"] = { fg = p.gold_yellow },
	["@constant"] = { link = "Constant" },
	["@variable.builtin"] = { link = "Type" },
	["@operator"] = { link = "Operator" },
	["@punctuation.special"] = { link = "Specialchar" },
	["@punctuation.bracket"] = { fg = p.lighter_variable_whiteish },
	["@conditional"] = { link = "Conditional" },
	["@exception"] = { link = "Exception" },
	["@lsp.type.namespace"] = { fg = p.gold_yellow },
	["@lsp.type.parameter.cpp"] = { fg = "#74a1fc" },
	["@lsp.typemod.parameter.declaration.cpp"] = { fg = "#82b0ff" },
	-- LSP
	-- ['@lsp.type.class.cpp'] = { fg = p.function_name_blue },
	["@lsp.type.enumMember"] = { fg = p.string_green },
	["@lsp.type.interface"] = { fg = p.gold_yellow },
	["@lsp.typemod.variable.globalScope.cpp"] = { fg = p.global_blue },
	-- ['@lsp.mod.classScope.cpp'] = { fg = p.variable_whiteish },

	["@lsp.type.method.cpp"] = { fg = p.function_name_blue },
	-- ['@lsp.type.property.cpp'] = {fg = }

	["@lsp.typemod.property.declaration.cpp"] = { fg = p.variable_scope_color },
	["@lsp.type.macro"] = { fg = p.macro_green },
	["@keyword.modifier.cpp"] = { fg = p.class_struct_blue },
	-- ['@punctuation.bracket.cpp'] = { fg = p.variable_whiteish },
	["@keyword.import.cpp"] = { fg = p.global_blue },
	ExtraWhiteSpace = { bg = "NONE" },
	MiniExtra = { bg = "NONE" },
	-- ['@lsp.mod.readonly.cpp'] = { fg = '#44588B' },,
	-- ['@lsp.mod.functionScope.cpp'] = { fg = p.even_softer_grey_highlight },
	-- Java
	["javaStatement"] = { link = "Keyword" },
	["javaOperator"] = { link = "Keyword" },
	["@lsp.type.property.java"] = { fg = p.gruber_darker_quartz },
	-- ["@lsp.mod.typeArgument.java"]                      = { fg = p.gruber_darker_quartz },
	-- ["@lsp.typemod.class.readonly.java"]                = { fg = p.gruber_darker_quartz },
	-- JavaScript
	["javaScriptIdentifier"] = { link = "Keyword" },
	["javaScriptFunction"] = { link = "Keyword" },
	["javaScriptEmbed"] = { fg = p.gold_yellow },
	["javaScriptBraces"] = { link = "Normal" },
	["@lsp.mod.defaultLibrary.javascript"] = { link = "Keyword" },
	["@lsp.type.funciton.javascript"] = { link = "Function" },
	["@lsp.typemod.property.defaultLibrary.javascript"] = { fg = p.gruber_darker_quartz },
	["@lsp.typemod.member.defaultLibrary.javascript"] = { fg = p.gruber_darker_niagara },
	-- Markdown
	["@markup.strong"] = { fg = p.variable_purple_blue, bg = "NONE" },
	["@markup.heading.2.markdown"] = { fg = p.global_blue, bg = "NONE" },
	["markdownCodeBlock"] = { link = "String" },
	["@markup.raw.block.markdown"] = { bg = "NONE", fg = p.variable_scope_color },
	["@spell.gitcommit"] = { bg = "NONE", fg = p.most_soft_grey_highlight },

	["@spell.markdown"] = { bg = "NONE", fg = p.variable_scope_color },
	["@nospell.markdown_inline"] = { bg = "NONE", fg = p.variable_purple_blue },
	["@punctuation.special.markdown"] = { bg = "NONE", fg = p.even_even_softer_grey_highlight },
	["@label.markdown"] = { bg = "NONE", fg = p.even_even_softer_grey_highlight },
	["RenderMarkdownCodeInline"] = { bg = "NONE", fg = "NONE" },
	["RenderMarkdownCode"] = { bg = "#333946", fg = "NONE" },
	["RenderMarkdownH1Bg"] = { fg = p.gold_yellow, bg = "NONE" },
	["RenderMarkdownH2Bg"] = { fg = p.global_blue, bg = "NONE" },
	["RenderMarkdownBullet"] = { fg = p.variable_purple_blue, bg = "NONE" },
	["RenderMarkdownQuote1"] = { bg = "NONE", fg = p.even_softer_grey_highlight },
	["RenderMarkdownQuote2"] = { bg = "NONE", fg = p.even_even_softer_grey_highlight },
	["RenderMarkdownQuote3"] = { bg = "NONE", fg = p.even_even_even_softer_grey_highlight },
	-- ['@markup.quote.markdown'] = { fg = p.even_softer_grey_highlight, bg = 'NONE' },

	["@markup.list.markdown"] = { fg = p.variable_purple_blue, bg = "NONE" },
	-- ['@markup.heading.2.markdown'] = { fg = p.gold_yellow, bg = 'NONE' },
	-- Diff
	DiffAdd = { fg = "NONE", bg = p.gruber_darker_green_custom_m1 },
	DiffAdded = { fg = p.gruber_darker_green_custom, bg = "NONE" },
	DiffChange = { fg = "NONE", bg = p.gruber_darker_yellow_custom_m1 },
	DiffChanged = { fg = p.gruber_darker_yellow_custom, bg = "NONE" },
	DiffDelete = { fg = "NONE", bg = p.gruber_darker_red_custom_m1 },
	DiffRemoved = { fg = p.gruber_darker_red_custom, bg = "NONE" },
	DiffText = { fg = p.gruber_darker_green_custom, bg = "NONE", bold = true },
	-- Telescope
	TelescopeSelection = { bg = p.gruber_darker_bg_p1 },
	TelescopeSelectionCaret = { link = "TelescopeSelection" },
	TelescopeMatching = { fg = p.gruber_darker_white, bold = true },
	--Git
	GitSignsAdd = { fg = p.dark_green, bg = "NONE" },
	GitSignsChange = { fg = p.gold_yellow, bg = "NONE" },
	GitSignsDelete = { fg = p.gruber_darker_red, bg = "NONE" },
	--Diagnostic
	DiagnosticSignError = { fg = p.gruber_darker_red_custom, bg = "NONE" },
	DiagnosticSignWarn = { fg = p.gold_yellow, bg = "NONE" },
	DiagnosticSignHint = { fg = p.gruber_darker_bg_p3, bg = p.almost_background_color },
	DiagnosticSignInfo = { fg = p.todo_fg, bg = p.almost_background_color },
	DiagnosticError = { link = "DiagnosticSignError" },
	DiagnosticUnderlineError = { undercurl = true, sp = p.red_fixme }, -- NOTE: important
	DiagnosticWarn = { link = "DiagnosticSignWarn" },
	DiagnosticHint = { link = "DiagnosticSignHint" },
	DiagnosticInfo = { link = "DiagnosticSignInfo" },
	--Scheme icon
	DevIconScheme = { fg = p.gruber_darker_red, bg = p.background_color },
	DevIconJava = { fg = p.gruber_darker_red },
	DevIconJavaScript = { fg = p.gold_yellow },
	--Oil
	OilDir = { link = "Directory" },
	--Mason
	MasonHeader = { link = "StatusLine" },
	--Illuminate
	IlluminatedWordText = { bg = p.gold_yellow, underline = false },
	IlluminatedWordRead = { bg = p.gold_yellow, underline = false },
	IlluminatedWordWrite = { bg = p.gold_yellow, underline = false },
}
M.lualine_theme = {
	normal = {
		a = { bg = p.global_blue, fg = p.background_color, gui = "bold" },
		b = { bg = p.soft_grey_highlight, fg = p.normal_text_gray },
		c = { bg = p.almost_background_color, fg = p.normal_text_gray },
	},
	insert = {
		a = { bg = p.string_green, fg = p.background_color, gui = "bold" },
		b = { bg = p.soft_grey_highlight, fg = p.normal_text_gray },
	},
	visual = {
		a = { bg = p.gold_yellow, fg = p.background_color, gui = "bold" },
		b = { bg = p.soft_grey_highlight, fg = p.normal_text_gray },
	},
	replace = {
		a = { bg = p.const_orange, fg = p.background_color, gui = "bold" },
		b = { bg = p.soft_grey_highlight, fg = p.normal_text_gray },
	},
	command = {
		a = { bg = p.macro_green, fg = p.background_color, gui = "bold" },
		b = { bg = p.soft_grey_highlight, fg = p.normal_text_gray },
	},
	inactive = {
		a = { bg = p.almost_background_color, fg = p.even_softer_grey_highlight },
		b = { bg = p.almost_background_color, fg = p.even_softer_grey_highlight },
		c = { bg = p.almost_background_color, fg = p.even_even_even_softer_grey_highlight },
	},
}

function M.setup()
	vim.cmd("hi clear")
	vim.o.background = "dark"
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end
	vim.o.termguicolors = true
	vim.g.colors_name = "space-mining"
	vim.g.winblend = true

	local hi = vim.api.nvim_set_hl
	for name, style in pairs(highlight_groups) do
		hi(0, name, style)
	end
end

return M
