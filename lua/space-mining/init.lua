-- ============================================================================
-- Space Mining - A dark, space-themed Neovim colorscheme
-- ============================================================================
-- Maintainer: Egas Ribeiro
-- License: MIT
-- Repository: https://github.com/riogu/space-mining.nvim
-- ============================================================================

local M = {}

-- ============================================================================
-- Color Palette
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
	blue_struct = "#8CA1D7",
	blue_param = "#5E80B7",
	pink = "#E0B4BB",
	red = "#e35c5c",
	red_error = "#D14A65",

	-- Line number colors
	line_nr = "#3A4356",
	line_nr_current = "#FCBF55",

	-- Comment/inactive colors
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
	-- Syntax Highlighting (Standard Vim groups)
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
	Repeat = { fg = colors.blue_struct },
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
	Structure = { fg = colors.blue_struct },
	Typedef = { fg = colors.yellow },

	Special = { fg = colors.yellow },
	SpecialChar = { link = "String" },
	SpecialComment = { link = "SpecialChar" },
	Tag = { link = "SpecialChar" },
	Delimiter = { fg = colors.fg_light },
	Debug = { link = "Special" },

	Error = { fg = colors.pink },
	Todo = { fg = colors.todo_fg, bg = colors.todo_bg },

	-- ========================================================================
	-- C/C++ Vim Syntax Fallback Groups
	-- ========================================================================
	-- These are critical when treesitter is not active or partially active.
	-- They cover the old-style vim syntax groups for C/C++ files.

	cBlock = { fg = colors.fg_light },
	cParen = { fg = colors.fg_light },
	cBracket = { fg = colors.fg_light },
	cCppBracket = { fg = colors.fg_light },
	cCurly = { fg = colors.fg_light },
	cParenError = { fg = colors.fg_light },
	cErrInParen = { fg = colors.fg_light },
	cErrInBracket = { fg = colors.fg_light },

	cStatement = { link = "Keyword" },
	cConditional = { link = "Conditional" },
	cRepeat = { link = "Repeat" },
	cLabel = { link = "Label" },
	cOperator = { link = "Operator" },
	cStructure = { fg = colors.blue_struct },
	cStorageClass = { fg = colors.fg_light },
	cType = { fg = colors.yellow },
	cConstant = { link = "Constant" },
	cString = { link = "String" },
	cNumber = { link = "Number" },
	cFloat = { link = "Float" },
	cCharacter = { link = "Character" },
	cComment = { link = "Comment" },
	cCommentL = { link = "Comment" },
	cTodo = { link = "Todo" },
	cInclude = { fg = colors.blue },
	cIncluded = { fg = colors.green },
	cDefine = { fg = colors.blue },
	cPreProc = { fg = colors.blue },
	cPreCondit = { fg = colors.blue },
	cFormat = { link = "SpecialChar" },
	cSpecial = { link = "SpecialChar" },
	cSpecialCharacter = { link = "SpecialChar" },

	-- C++ specific vim syntax groups
	cppStatement = { link = "Keyword" },
	cppAccess = { fg = colors.ui_blue_light },
	cppType = { fg = colors.yellow },
	cppStructure = { fg = colors.blue_struct },
	cppBoolean = { fg = colors.pink },
	cppConstant = { link = "Constant" },
	cppModifier = { fg = colors.ui_blue_light },
	cppOperator = { link = "Operator" },
	cppCast = { fg = colors.ui_blue_light },
	cppExceptions = { link = "Exception" },
	cppString = { link = "String" },
	cppNumber = { link = "Number" },
	cppRawString = { link = "String" },
	cppMinMax = { fg = colors.fg_light },

	-- ========================================================================
	-- Rust Vim Syntax Fallback Groups
	-- ========================================================================

	rustFoldBraces = { fg = colors.fg_light },
	rustCommentLineDoc = { link = "Comment" },
	rustCommentBlockDoc = { link = "Comment" },
	rustComment = { link = "Comment" },
	rustStorage = { fg = colors.ui_blue_light },
	rustSigil = { fg = colors.ui_grey },
	rustOperator = { link = "Operator" },
	rustArrowCharacter = { fg = colors.ui_grey },
	rustKeyword = { fg = colors.ui_blue_light },
	rustConditional = { link = "Conditional" },
	rustRepeat = { link = "Repeat" },
	rustTypedef = { fg = colors.yellow },
	rustType = { fg = colors.yellow },
	rustStructure = { fg = colors.blue_struct },
	rustTrait = { fg = colors.yellow },
	rustEnum = { fg = colors.yellow },
	rustEnumVariant = { fg = colors.green },
	rustSelf = { fg = colors.ui_blue_light },
	rustIdentifier = { fg = colors.fg_dim },
	rustFuncName = { fg = colors.blue_light },
	rustFuncCall = { fg = colors.blue_light },
	rustModPath = { fg = colors.yellow },
	rustModPathSep = { fg = colors.fg_light },
	rustString = { link = "String" },
	rustStringDelimiter = { link = "String" },
	rustCharacter = { link = "Character" },
	rustNumber = { link = "Number" },
	rustFloat = { link = "Float" },
	rustBoolean = { fg = colors.pink },
	rustConstant = { link = "Constant" },
	rustMacro = { fg = colors.cyan },
	rustAssert = { fg = colors.cyan },
	rustPanic = { fg = colors.cyan },
	rustAttribute = { fg = colors.ui_grey },
	rustDerive = { fg = colors.ui_grey },
	rustDeriveTrait = { fg = colors.yellow },
	rustLifetime = { fg = colors.orange },
	rustLabel = { fg = colors.orange },
	rustEscape = { link = "SpecialChar" },
	rustQuestionMark = { fg = colors.ui_grey },
	rustPubScopeDelim = { fg = colors.fg_light },
	rustPubScopeCrate = { fg = colors.ui_blue_light },
	rustSuper = { fg = colors.ui_blue_light },
	rustUnsafe = { fg = colors.orange },
	rustAsync = { fg = colors.ui_blue_light },
	rustAwait = { fg = colors.ui_blue_light },
	rustExternCrate = { fg = colors.ui_blue_light },
	rustUse = { fg = colors.blue },

	-- ========================================================================
	-- Python Vim Syntax Fallback Groups
	-- ========================================================================

	pythonStatement = { link = "Keyword" },
	pythonFunction = { fg = colors.blue_light },
	pythonConditional = { link = "Conditional" },
	pythonRepeat = { link = "Repeat" },
	pythonOperator = { link = "Operator" },
	pythonException = { link = "Exception" },
	pythonInclude = { fg = colors.blue },
	pythonDecorator = { fg = colors.orange },
	pythonDecoratorName = { fg = colors.orange },
	pythonBuiltinType = { fg = colors.yellow },
	pythonBuiltinObj = { fg = colors.yellow },
	pythonBuiltinFunc = { fg = colors.blue_light },
	pythonString = { link = "String" },
	pythonRawString = { link = "String" },
	pythonNumber = { link = "Number" },
	pythonFloat = { link = "Float" },
	pythonBoolean = { fg = colors.pink },
	pythonNone = { fg = colors.pink },
	pythonComment = { link = "Comment" },
	pythonTodo = { link = "Todo" },

	-- ========================================================================
	-- Lua Vim Syntax Fallback Groups
	-- ========================================================================

	luaTable = { link = "Normal" },
	luaFunc = { fg = colors.blue_light },
	luaFunction = { fg = colors.ui_blue_light },
	luaStatement = { link = "Keyword" },
	luaOperator = { link = "Operator" },
	luaConstant = { fg = colors.pink },
	luaCond = { link = "Conditional" },
	luaRepeat = { link = "Repeat" },
	luaString = { link = "String" },
	luaNumber = { link = "Number" },
	luaComment = { link = "Comment" },
	luaParen = { fg = colors.fg_light },
	luaBraces = { fg = colors.fg_light },

	-- ========================================================================
	-- Java Vim Syntax Fallback Groups
	-- ========================================================================

	javaStatement = { link = "Keyword" },
	javaOperator = { link = "Keyword" },
	javaType = { fg = colors.yellow },
	javaTypeDef = { fg = colors.yellow },
	javaClassDecl = { fg = colors.blue_struct },
	javaScopeDecl = { fg = colors.ui_blue_light },
	javaStorageClass = { fg = colors.ui_blue_light },
	javaBoolean = { fg = colors.pink },
	javaConstant = { link = "Constant" },
	javaString = { link = "String" },
	javaNumber = { link = "Number" },
	javaComment = { link = "Comment" },
	javaParen = { fg = colors.fg_light },

	-- ========================================================================
	-- JavaScript/TypeScript Vim Syntax Fallback Groups
	-- ========================================================================

	javaScriptIdentifier = { link = "Keyword" },
	javaScriptFunction = { link = "Keyword" },
	javaScriptEmbed = { fg = colors.yellow },
	javaScriptBraces = { link = "Normal" },
	javaScriptParens = { fg = colors.fg_light },
	javaScriptNumber = { link = "Number" },
	javaScriptString = { link = "String" },
	javaScriptComment = { link = "Comment" },
	javaScriptOperator = { link = "Operator" },
	javaScriptNull = { fg = colors.pink },

	typescriptBraces = { fg = colors.fg_light },
	typescriptParens = { fg = colors.fg_light },
	typescriptEndColons = { fg = colors.fg_light },
	typescriptOperator = { link = "Operator" },
	typescriptType = { fg = colors.yellow },
	typescriptVariable = { fg = colors.ui_blue_light },
	typescriptImport = { fg = colors.blue },
	typescriptExport = { fg = colors.blue },

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

	-- Comments
	["@comment"] = { link = "Comment" },
	["@comment.todo"] = { fg = colors.todo_fg, bg = colors.todo_bg },
	["@comment.note"] = { fg = colors.note_fg, bg = colors.note_bg },
	["@comment.error"] = { fg = colors.danger_fg },
	["@comment.warning"] = { fg = colors.warning },
	["@comment.documentation"] = { link = "Comment" },

	-- Punctuation (critical for {} () [] :: ; , etc.)
	["@punctuation"] = { fg = colors.fg_light },
	["@punctuation.bracket"] = { fg = colors.fg_light },
	["@punctuation.delimiter"] = { fg = colors.fg_light },
	["@punctuation.special"] = { link = "SpecialChar" },
	["@punctuation.separator"] = { fg = colors.fg_light },

	-- Language-specific punctuation overrides
	["@punctuation.bracket.cpp"] = { fg = colors.fg_light },
	["@punctuation.delimiter.cpp"] = { fg = colors.fg_light },
	["@punctuation.bracket.rust"] = { fg = colors.fg_light },
	["@punctuation.delimiter.rust"] = { fg = colors.fg_light },
	["@punctuation.bracket.python"] = { fg = colors.fg_light },
	["@punctuation.delimiter.python"] = { fg = colors.fg_light },
	["@punctuation.bracket.lua"] = { fg = colors.fg_light },
	["@punctuation.delimiter.lua"] = { fg = colors.fg_light },
	["@punctuation.bracket.java"] = { fg = colors.fg_light },
	["@punctuation.delimiter.java"] = { fg = colors.fg_light },
	["@punctuation.bracket.javascript"] = { fg = colors.fg_light },
	["@punctuation.delimiter.javascript"] = { fg = colors.fg_light },
	["@punctuation.bracket.typescript"] = { fg = colors.fg_light },
	["@punctuation.delimiter.typescript"] = { fg = colors.fg_light },

	-- Keywords
	["@keyword"] = { link = "Keyword" },
	["@keyword.function"] = { fg = colors.ui_blue_light },
	["@keyword.operator"] = { fg = colors.ui_grey },
	["@keyword.return"] = { fg = colors.ui_blue_light },
	["@keyword.conditional"] = { link = "Conditional" },
	["@keyword.repeat"] = { link = "Repeat" },
	["@keyword.exception"] = { link = "Exception" },
	["@keyword.import"] = { fg = colors.blue },
	["@keyword.modifier"] = { fg = colors.ui_blue_light },
	["@keyword.type"] = { fg = colors.ui_blue_light },
	["@keyword.coroutine"] = { fg = colors.ui_blue_light },
	["@keyword.storage"] = { fg = colors.fg_light },

	-- Language-specific keyword overrides
	["@keyword.import.cpp"] = { fg = colors.blue },
	["@keyword.modifier.cpp"] = { fg = colors.ui_blue_light },

	-- Functions
	["@function"] = { link = "Function" },
	["@function.call"] = { fg = colors.blue_light },
	["@function.builtin"] = { fg = colors.blue_light },
	["@function.method"] = { fg = colors.blue_light },
	["@function.method.call"] = { fg = colors.blue_light },
	["@function.macro"] = { fg = colors.cyan },

	-- Methods (older treesitter capture name)
	["@method"] = { fg = colors.blue_param },
	["@method.call"] = { fg = colors.blue_light },

	-- Variables
	["@variable"] = { fg = colors.fg_dim },
	["@variable.builtin"] = { link = "Type" },
	["@variable.parameter"] = { fg = colors.fg_dim },
	["@variable.member"] = { fg = colors.ui_blue },
	["@variable.parameter.python"] = { fg = colors.pink },

	-- Fields (older treesitter capture name)
	["@field"] = { link = "Identifier" },
	["@property"] = { fg = colors.ui_blue },

	-- Types
	["@type"] = { link = "Type" },
	["@type.builtin"] = { fg = colors.yellow },
	["@type.definition"] = { fg = colors.yellow },
	["@type.qualifier"] = { fg = colors.ui_blue_light },

	-- Constructors
	["@constructor"] = { link = "Function" },

	-- Constants
	["@constant"] = { link = "Constant" },
	["@constant.builtin"] = { fg = colors.pink },
	["@constant.macro"] = { fg = colors.cyan },

	-- Strings
	["@string"] = { link = "String" },
	["@string.escape"] = { fg = colors.cyan },
	["@string.special"] = { fg = colors.cyan },
	["@string.regex"] = { fg = colors.orange },

	-- Numbers
	["@number"] = { link = "Number" },
	["@number.float"] = { link = "Float" },
	["@boolean"] = { fg = colors.pink },

	-- Operators
	["@operator"] = { link = "Operator" },

	-- Labels
	["@label"] = { link = "String" },

	-- Conditionals and loops (older capture names)
	["@conditional"] = { link = "Conditional" },
	["@exception"] = { link = "Exception" },
	["@repeat"] = { link = "Repeat" },

	-- Includes
	["@include"] = { fg = colors.blue },

	-- Namespaces / Modules
	["@namespace"] = { fg = colors.yellow },
	["@module"] = { fg = colors.yellow },

	-- Attributes
	["@attribute"] = { fg = colors.ui_grey },
	["@attribute.builtin"] = { fg = colors.ui_grey },

	-- Tags (HTML/XML)
	["@tag"] = { fg = colors.blue_struct },
	["@tag.attribute"] = { fg = colors.ui_blue },
	["@tag.delimiter"] = { fg = colors.fg_light },

	-- ========================================================================
	-- LSP Semantic Tokens
	-- ========================================================================

	-- General LSP types
	["@lsp.type.namespace"] = { fg = colors.yellow },
	["@lsp.type.interface"] = { fg = colors.yellow },
	["@lsp.type.enumMember"] = { fg = colors.green },
	["@lsp.type.macro"] = { fg = colors.cyan },
	["@lsp.type.struct"] = { fg = colors.yellow },
	["@lsp.type.enum"] = { fg = colors.yellow },
	["@lsp.type.typeParameter"] = { fg = colors.yellow },
	["@lsp.type.parameter"] = { fg = colors.fg_dim },
	["@lsp.type.variable"] = { fg = colors.fg_dim },
	["@lsp.type.property"] = { fg = colors.ui_blue },
	["@lsp.type.function"] = { fg = colors.blue_light },
	["@lsp.type.method"] = { fg = colors.blue_light },
	["@lsp.type.keyword"] = { fg = colors.ui_blue_light },
	["@lsp.type.comment"] = { link = "Comment" },
	["@lsp.type.string"] = { link = "String" },
	["@lsp.type.number"] = { link = "Number" },
	["@lsp.type.type"] = { fg = colors.yellow },
	["@lsp.type.class"] = { fg = colors.yellow },
	["@lsp.type.decorator"] = { fg = colors.orange },
	["@lsp.type.lifetime"] = { fg = colors.orange },

	-- CRITICAL: Prevent LSP semantic tokens from overriding punctuation
	-- These empty tables mean "don't apply any LSP highlight for these"
	["@lsp.type.operator"] = {},
	["@lsp.type.punctuation"] = {},
	["@lsp.type.bracket"] = {},
	["@lsp.type.delimiter"] = {},
	["@lsp.type.builtinAttribute"] = { fg = colors.ui_grey },
	["@lsp.type.selfKeyword"] = { fg = colors.ui_blue_light },
	["@lsp.type.selfTypeKeyword"] = { fg = colors.ui_blue_light },
	["@lsp.type.builtinType"] = { fg = colors.yellow },
	["@lsp.type.formatSpecifier"] = { fg = colors.cyan },
	["@lsp.type.escapeSequence"] = { fg = colors.cyan },
	["@lsp.type.generic"] = { fg = colors.fg_dim },
	["@lsp.type.unresolvedReference"] = { undercurl = true, sp = colors.red_error },

	-- LSP modifier combinations
	["@lsp.mod.declaration"] = {},
	["@lsp.mod.definition"] = {},
	["@lsp.mod.readonly"] = {},
	["@lsp.mod.defaultLibrary"] = {},
	["@lsp.mod.mutable"] = {},
	["@lsp.mod.consuming"] = {},
	["@lsp.mod.callable"] = {},
	["@lsp.mod.static"] = {},
	["@lsp.mod.async"] = {},
	["@lsp.mod.unsafe"] = {},
	["@lsp.mod.attribute"] = {},
	["@lsp.mod.controlFlow"] = {},
	["@lsp.mod.reference"] = {},

	-- C++ specific LSP
	["@lsp.type.method.cpp"] = { fg = colors.blue_light },
	["@lsp.type.parameter.cpp"] = { fg = "#74a1fc" },
	["@lsp.type.operator.cpp"] = {},
	["@lsp.typemod.parameter.declaration.cpp"] = { fg = "#82b0ff" },
	["@lsp.typemod.property.declaration.cpp"] = { fg = colors.fg_dim },
	["@lsp.typemod.variable.globalScope.cpp"] = { fg = colors.blue },
	["@lsp.typemod.operator.userDefined.cpp"] = {},

	-- Rust specific LSP (rust-analyzer)
	["@lsp.type.operator.rust"] = {},
	["@lsp.type.punctuation.rust"] = {},
	["@lsp.type.bracket.rust"] = {},
	["@lsp.type.builtinAttribute.rust"] = { fg = colors.ui_grey },
	["@lsp.type.selfKeyword.rust"] = { fg = colors.ui_blue_light },
	["@lsp.type.selfTypeKeyword.rust"] = { fg = colors.ui_blue_light },
	["@lsp.type.lifetime.rust"] = { fg = colors.orange },
	["@lsp.type.typeAlias.rust"] = { fg = colors.yellow },
	["@lsp.type.builtinType.rust"] = { fg = colors.yellow },
	["@lsp.type.formatSpecifier.rust"] = { fg = colors.cyan },
	["@lsp.type.escapeSequence.rust"] = { fg = colors.cyan },
	["@lsp.type.unresolvedReference.rust"] = { undercurl = true, sp = colors.red_error },
	["@lsp.typemod.function.declaration.rust"] = { fg = colors.blue_light },
	["@lsp.typemod.function.trait.rust"] = { fg = colors.blue_light },
	["@lsp.typemod.keyword.controlFlow.rust"] = { fg = colors.pink },
	["@lsp.typemod.keyword.unsafe.rust"] = { fg = colors.orange },
	["@lsp.typemod.variable.mutable.rust"] = {},
	["@lsp.typemod.variable.callable.rust"] = {},
	["@lsp.typemod.selfKeyword.mutable.rust"] = { fg = colors.ui_blue_light },
	["@lsp.typemod.operator.controlFlow.rust"] = {},

	-- Java specific LSP
	["@lsp.type.property.java"] = { fg = colors.ui_blue },

	-- JavaScript/TypeScript specific LSP
	["@lsp.mod.defaultLibrary.javascript"] = { link = "Keyword" },
	["@lsp.type.function.javascript"] = { link = "Function" },
	["@lsp.mod.defaultLibrary.typescript"] = { link = "Keyword" },
	["@lsp.type.function.typescript"] = { link = "Function" },

	-- Python specific LSP
	["@lsp.type.parameter.python"] = { fg = colors.pink },

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
