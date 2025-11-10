-- ============================================================================
-- Space Mining - A dark, space-themed Neovim colorscheme
-- ============================================================================
-- Maintainer: [Your Name]
-- License: MIT
-- Repository: https://github.com/[username]/space-mining.nvim
-- ============================================================================

local M = {}

-- ============================================================================
-- Color Palette
-- ============================================================================
-- Base colors for the theme, organized by purpose
-- Note: Some colors may seem misnamed (e.g., green used for comments) but
-- these are intentional design choices for the theme's aesthetic
-- ============================================================================

local colors = {
	-- Background shades (darkest to lightest)
	bg = "#2F333C",
	bg_light = "#313645",
	bg_highlight = "#3A4356",
	bg_highlight2 = "#445069",
	bg_highlight3 = "#5E6A83",
	-- Foreground/text colors
	fg = "#E7F2FC",
	fg_dim = "#CDD4E8",
	fg_light = "#97A7D2",

	-- UI element colors
	ui_blue = "#7A8BB8",
	ui_blue_light = "#8EA3D9",
	ui_purple = "#6F7D9A",
	ui_grey = "#8897B6",
	ui_grey_light = "#8899BE",

	-- Syntax colors
	orange = "#FF9A5C",
	yellow = "#FCBF55",
	green = "#589A8F",
	green_dark = "#5C898B",
	cyan = "#5ABCAC",
	blue = "#567CC6",
	blue_light = "#9CD1FF",
	blue_bright = "#7EA8FF",
	blue_strong = "#78B7D7",
	blue_struct = "#A7B3EC",
	blue_param = "#5E80B7",
	pink = "#E0B4BB",
	red = "#e35c5c",
	red_error = "#D14A65",

	-- Line number colors
	line_nr = "#3A4356",
	line_nr_current = "#FCBF55",

	-- Comment/inactive colors (uses bg_highlight3 color)
	comment = "#5E6A83",
	inactive = "#617B85",

	-- Special highlight colors
	search_bg = "#5E8A83",
	visual_bg = "#3A4356",

	-- Diagnostic/status colors
	error = "#B9545E",
	warning = "#ff9900",
	info = "#5270B5",
	hint = "#567CC6",

	-- Todo/Note colors
	todo_fg = "#5270B5",
	todo_bg = "#0b1e33",
	note_fg = "#ff57fF",
	note_bg = "#7A644D",
	danger_fg = "#ff8b64",
}

-- ============================================================================
-- Highlight Groups
-- ============================================================================
-- Organized by category for easier maintenance
-- ============================================================================

local highlight_groups = {

	-- ========================================================================
	-- Editor UI
	-- ========================================================================

	Normal = { fg = colors.fg, bg = colors.bg },
	NormalNC = { link = "Normal" },
	NormalFloat = { bg = colors.bg_light, fg = "NONE" },
	FloatBorder = { fg = colors.comment, bg = "NONE" },

	-- Cursor
	Cursor = { bg = colors.fg_dim },
	CursorLine = { fg = "NONE", bg = colors.bg_highlight },
	CursorLineNr = { fg = colors.line_nr_current, bg = "NONE" },

	-- Line numbers
	LineNr = { bg = colors.bg, fg = colors.line_nr },
	LineNrAbove = { link = "LineNr" },
	LineNrBelow = { link = "LineNr" },
	SignColumn = { bg = colors.bg },

	-- Visual selection
	Visual = { bg = colors.visual_bg, fg = "NONE" },
	VisualNOS = { link = "Visual" },

	-- Search
	Search = { fg = "NONE", bg = colors.comment },
	IncSearch = { link = "Search" },
	Substitute = { link = "Search" },

	-- Messages and prompts
	MsgArea = { fg = colors.yellow, bg = colors.bg_light },
	ModeMsg = { link = "Normal" },
	MoreMsg = { link = "Normal" },
	WarningMsg = { fg = colors.yellow },
	ErrorMsg = { fg = colors.pink },
	Question = { link = "Normal" },

	-- Windows and separators
	WinSeparator = { fg = colors.bg_highlight, bg = "NONE" },
	VertSplit = { link = "WinSeparator" },

	-- Popup menu (completion)
	Pmenu = { fg = colors.ui_blue, bg = colors.bg_light },
	PmenuSel = { bg = colors.bg_light, fg = colors.fg },
	PmenuThumb = { bg = colors.inactive },
	PmenuSbar = { bg = colors.bg_highlight2 },

	-- Tabs
	TabLine = { bg = colors.bg_highlight },
	TabLineFill = { bg = colors.bg_highlight },
	TabLineSel = { fg = "NONE", bg = colors.bg_highlight },

	-- Status line
	StatusLine = { fg = colors.yellow, bg = colors.bg_light },
	StatusLineNC = { fg = colors.ui_purple, bg = colors.bg_light },
	StatusLineAccent = { bg = colors.bg_light },

	-- Folding
	Folded = { fg = colors.inactive },
	FoldColumn = { link = "Folded" },

	-- Other UI elements
	Directory = { fg = colors.blue_bright, bold = true },
	Title = { link = "Normal" },
	MatchParen = { fg = "NONE", bg = colors.bg_highlight },
	EndOfBuffer = { fg = colors.bg_highlight, bg = colors.bg },
	Colorcolumn = { link = "StatusLine" },
	Whitespace = { bg = "NONE", fg = colors.ui_blue },
	NonText = { link = "Normal" },
	SpecialKey = { fg = colors.comment },
	Conceal = { link = "Operator" },
	WildMenu = { link = "Pmenu" },

	-- Formatting
	Bold = { bold = true },
	Italic = { italic = true },
	Underlined = { undercurl = false },

	-- Spelling
	SpellBad = { undercurl = true },
	SpellLocal = { undercurl = true },
	SpellCap = { undercurl = true },
	SpellRare = { undercurl = true },

	-- ========================================================================
	-- Syntax Highlighting (Standard)
	-- ========================================================================

	Comment = { fg = colors.comment },

	Constant = { fg = colors.green_dark },
	String = { fg = colors.green },
	Character = { link = "String" },
	Number = { fg = colors.pink },
	Float = { link = "Number" },
	Boolean = { fg = colors.pink },

	Identifier = { fg = colors.ui_blue },
	Function = { fg = colors.blue_light },

	Statement = { link = "Type" },
	Conditional = { fg = colors.pink },
	Repeat = { link = "Conditional" },
	Label = { link = "String" },
	Operator = { fg = colors.ui_grey },
	Keyword = { fg = colors.ui_blue_light },
	Exception = { link = "Keyword" },

	PreProc = { fg = colors.blue },
	Include = { link = "PreProc" },
	Define = { bg = colors.comment },
	Macro = { link = "PreProc" },
	PreCondit = { link = "PreProc" },

	Type = { fg = colors.yellow },
	StorageClass = { fg = colors.fg_light },
	Structure = { fg = colors.blue_light },
	Typedef = { fg = colors.yellow },

	Special = { fg = colors.yellow },
	SpecialChar = { link = "String" },
	SpecialComment = { link = "SpecialChar" },
	Tag = { link = "SpecialChar" },
	Delimiter = { fg = colors.inactive },
	Debug = { link = "Special" },

	Error = { fg = colors.pink },
	Todo = { fg = colors.todo_fg, bg = colors.todo_bg },

	-- ========================================================================
	-- Treesitter Highlights
	-- ========================================================================

	-- Text
	["@text.todo"] = { fg = colors.todo_fg, bg = colors.todo_bg },
	["@text.note"] = { fg = colors.note_fg, bg = colors.note_bg },
	["@text.danger"] = { fg = colors.danger_fg },
	["@text.uri"] = { fg = colors.blue, underline = true },

	-- Markup (Markdown, etc.)
	["@markup.strong"] = { fg = colors.ui_blue, bg = "NONE", bold = true },
	["@markup.italic"] = { italic = true },
	["@markup.heading.1"] = { fg = colors.yellow, bg = "NONE" },
	["@markup.heading.2"] = { fg = colors.blue, bg = "NONE" },
	["@markup.heading.2.markdown"] = { fg = colors.blue, bg = "NONE" },
	["@markup.list.markdown"] = { fg = colors.ui_blue, bg = "NONE" },
	["@markup.raw.block.markdown"] = { bg = "NONE", fg = colors.fg_dim },

	-- Checklist items
	["@unchecked_list_item"] = { link = "Normal" },
	["@checked_list_item"] = { fg = colors.inactive, strikethrough = true },
	["@text.todo.unchecked"] = { link = "@unchecked_list_item" },
	["@text.todo.checked"] = { link = "@checked_list_item" },

	-- Code elements
	["@keyword"] = { link = "Keyword" },
	["@keyword.import.cpp"] = { fg = colors.blue },
	["@keyword.modifier.cpp"] = { fg = colors.ui_blue_light },
	["@function"] = { link = "Function" },
	["@method"] = { fg = colors.blue_param },
	["@field"] = { link = "Identifier" },
	["@constructor"] = { link = "Function" },
	["@label"] = { link = "String" },
	["@variable"] = { fg = colors.fg_dim },
	["@variable.builtin"] = { link = "Type" },
	["@variable.parameter.python"] = { fg = colors.pink },
	["@type"] = { link = "Type" },
	["@type.builtin"] = { fg = colors.yellow },
	["@constant"] = { link = "Constant" },
	["@operator"] = { link = "Operator" },
	["@punctuation.special"] = { link = "SpecialChar" },
	["@punctuation.bracket"] = { fg = colors.fg_light },
	["@conditional"] = { link = "Conditional" },
	["@exception"] = { link = "Exception" },

	-- ========================================================================
	-- LSP Semantic Tokens
	-- ========================================================================

	["@lsp.type.namespace"] = { fg = colors.yellow },
	["@lsp.type.interface"] = { fg = colors.yellow },
	["@lsp.type.enumMember"] = { fg = colors.green },
	["@lsp.type.macro"] = { fg = colors.cyan },
	["@lsp.type.method.cpp"] = { fg = colors.blue_light },

	-- C++ specific
	["@lsp.type.parameter.cpp"] = { fg = "#74a1fc" },
	["@lsp.typemod.parameter.declaration.cpp"] = { fg = "#82b0ff" },
	["@lsp.typemod.property.declaration.cpp"] = { fg = colors.fg_dim },
	["@lsp.typemod.variable.globalScope.cpp"] = { fg = colors.blue },

	-- Java specific
	["javaStatement"] = { link = "Keyword" },
	["javaOperator"] = { link = "Keyword" },
	["@lsp.type.property.java"] = { fg = colors.ui_blue },

	-- JavaScript specific
	["javaScriptIdentifier"] = { link = "Keyword" },
	["javaScriptFunction"] = { link = "Keyword" },
	["javaScriptEmbed"] = { fg = colors.yellow },
	["javaScriptBraces"] = { link = "Normal" },
	["@lsp.mod.defaultLibrary.javascript"] = { link = "Keyword" },
	["@lsp.type.function.javascript"] = { link = "Function" },

	-- Lua specific
	["luaTable"] = { link = "Normal" },

	-- ========================================================================
	-- Git Signs
	-- ========================================================================

	GitSignsAdd = { fg = colors.green_dark, bg = "NONE" },
	GitSignsChange = { fg = colors.yellow, bg = "NONE" },
	GitSignsDelete = { fg = colors.red, bg = "NONE" },

	-- ========================================================================
	-- Diff
	-- ========================================================================

	DiffAdd = { fg = "NONE", bg = "#1a2b1a" },
	DiffAdded = { fg = colors.green, bg = "NONE" },
	DiffChange = { fg = "NONE", bg = "#2b2b1a" },
	DiffChanged = { fg = colors.yellow, bg = "NONE" },
	DiffDelete = { fg = "NONE", bg = "#2b1a1a" },
	DiffRemoved = { fg = colors.red, bg = "NONE" },
	DiffText = { fg = colors.green, bg = "NONE", bold = true },

	-- ========================================================================
	-- Diagnostics
	-- ========================================================================

	DiagnosticError = { fg = colors.red_error },
	DiagnosticWarn = { fg = colors.yellow },
	DiagnosticInfo = { fg = colors.info },
	DiagnosticHint = { fg = colors.hint },

	DiagnosticSignError = { fg = colors.red_error, bg = "NONE" },
	DiagnosticSignWarn = { fg = colors.yellow, bg = "NONE" },
	DiagnosticSignHint = { fg = colors.hint, bg = colors.bg_light },
	DiagnosticSignInfo = { fg = colors.info, bg = colors.bg_light },

	DiagnosticVirtualTextError = { bg = "none", fg = colors.error },
	DiagnosticVirtualTextHint = { bg = "none", fg = colors.blue },
	DiagnosticVirtualTextInfo = { bg = "none", fg = colors.blue },
	DiagnosticVirtualTextWarn = { bg = "none", fg = colors.blue },

	DiagnosticUnderlineError = { undercurl = true, sp = colors.red_error },
	DiagnosticUnderlineWarn = { undercurl = true, sp = colors.warning },

	-- ========================================================================
	-- Quickfix/Location List
	-- ========================================================================

	qfLineNr = { fg = colors.comment },
	qfFileName = { fg = colors.ui_blue_light, bold = true },
	qfSeparator = { fg = colors.ui_purple },
	qfText = { fg = colors.ui_blue },
	QuickFixLine = { bg = colors.bg_highlight },

	-- ========================================================================
	-- Telescope
	-- ========================================================================

	TelescopeSelection = { bg = colors.bg_highlight },
	TelescopeSelectionCaret = { link = "TelescopeSelection" },
	TelescopeMatching = { fg = colors.fg, bold = true },

	TelescopeResultsTitle = { fg = colors.ui_blue, bold = true },
	TelescopeResultsNormal = { fg = colors.ui_blue },
	TelescopeResultsBorder = { fg = colors.ui_blue },

	TelescopePreviewTitle = { fg = colors.ui_blue },
	TelescopePreviewNormal = { bg = "NONE" },
	TelescopePreviewBorder = { fg = colors.ui_blue, bg = "NONE" },

	TelescopePromptTitle = { fg = colors.ui_blue },
	TelescopePromptPrefix = { fg = colors.ui_blue },
	TelescopePromptCounter = { fg = colors.ui_blue },
	TelescopePromptNormal = { fg = colors.ui_blue },
	TelescopePromptBorder = { fg = colors.ui_blue },

	-- ========================================================================
	-- Render-markdown.nvim
	-- ========================================================================

	RenderMarkdownCodeInline = { bg = "NONE", fg = "NONE" },
	RenderMarkdownCode = { bg = "#333946", fg = "NONE" },
	RenderMarkdownH1Bg = { fg = colors.yellow, bg = "NONE" },
	RenderMarkdownH2Bg = { fg = colors.blue, bg = "NONE" },
	RenderMarkdownBullet = { fg = colors.ui_blue, bg = "NONE" },
	RenderMarkdownQuote1 = { bg = "NONE", fg = colors.comment },
	RenderMarkdownQuote2 = { bg = "NONE", fg = colors.ui_purple },
	RenderMarkdownQuote3 = { bg = "NONE", fg = colors.ui_grey_light },

	-- ========================================================================
	-- Oil.nvim
	-- ========================================================================

	OilDir = { link = "Directory" },

	-- ========================================================================
	-- Mason.nvim
	-- ========================================================================

	MasonHeader = { link = "StatusLine" },

	-- ========================================================================
	-- Illuminate
	-- ========================================================================

	IlluminatedWordText = { bg = colors.yellow, underline = false },
	IlluminatedWordRead = { bg = colors.yellow, underline = false },
	IlluminatedWordWrite = { bg = colors.yellow, underline = false },

	-- ========================================================================
	-- DevIcons
	-- ========================================================================

	DevIconScheme = { fg = colors.red, bg = colors.bg },
	DevIconJava = { fg = colors.red },
	DevIconJavaScript = { fg = colors.yellow },

	-- ========================================================================
	-- Miscellaneous
	-- ========================================================================

	ExtraWhiteSpace = { bg = "NONE" },
	MiniExtra = { bg = "NONE" },
	LogPath = { fg = colors.ui_blue },
	Variable = { fg = colors.fg_dim },

	-- Spell checking in specific filetypes
	["@spell.gitcommit"] = { bg = "NONE", fg = colors.ui_grey },
	["@spell.markdown"] = { bg = "NONE", fg = colors.fg_dim },
	["@nospell.markdown_inline"] = { bg = "NONE", fg = colors.ui_blue },
	["@punctuation.special.markdown"] = { bg = "NONE", fg = colors.ui_purple },
	["@label.markdown"] = { bg = "NONE", fg = colors.ui_purple },
}

-- ============================================================================
-- Lualine Theme
-- ============================================================================

M.lualine_theme = {
	normal = {
		a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_highlight, fg = colors.fg },
		c = { bg = colors.bg_light, fg = colors.fg },
	},
	insert = {
		a = { bg = colors.green, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_highlight, fg = colors.fg },
	},
	visual = {
		a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_highlight, fg = colors.fg },
	},
	replace = {
		a = { bg = colors.orange, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_highlight, fg = colors.fg },
	},
	command = {
		a = { bg = colors.cyan, fg = colors.bg, gui = "bold" },
		b = { bg = colors.bg_highlight, fg = colors.fg },
	},
	inactive = {
		a = { bg = colors.bg_light, fg = colors.comment },
		b = { bg = colors.bg_light, fg = colors.comment },
		c = { bg = colors.bg_light, fg = colors.ui_grey_light },
	},
}

-- ============================================================================
-- Setup Function
-- ============================================================================

function M.setup()
	-- Clear existing highlights
	vim.cmd("hi clear")

	-- Set background and syntax
	vim.o.background = "dark"
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end

	-- Enable true color support
	vim.o.termguicolors = true

	-- Set colorscheme name
	vim.g.colors_name = "space-mining"

	-- Apply highlight groups
	for name, style in pairs(highlight_groups) do
		vim.api.nvim_set_hl(0, name, style)
	end
end

-- ============================================================================
-- Module Return
-- ============================================================================

return M
