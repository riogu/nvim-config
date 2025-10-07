local M = {}

local p = {
  background_color = '#2F333C',

  const_orange = '#FF9A5C',
  variable_whiteish = '#7A8BB8',
  lighter_variable_whiteish = '#97A7D2',
  class_struct_blue = '#8EA3D9',
  normal_text_gray = '#E7F2FC',
  soft_grey_highlight = '#3A4356',
  softer_grey_highlight = '#445069',
  even_softer_grey_highlight = '#5E6A83',
  even_even_softer_grey_highlight = '#6F7D9A',
  even_even_even_softer_grey_highlight = '#8899BE',
  most_soft_grey_highlight = '#8897B6',
  variable_scope_color = '#CDD4E8',
  almost_background_color = '#313645',

  global_blue = '#567CC6',
  global_red = '#e35c5c',

  gold_yellow = '#FCBF55',
  dark_green = '#5C898B',
  string_green = '#589A8F',
  struct_strong_blue = '#A7B3EC',
  directory_color = '#7EA8FF',
  parameter_orangeish = '#5E80B7',
  stronger_directory_color = '#78B7D7',

  function_name_blue = '#9CD1FF',
  macro_green = '#5ABCAC',
  greyish_green_riogu = '#617B85',
  red_fixme = '#D14A65',
  soft_pinkish = '#E0B4BB',
  -- gruber_darker_fg_alpha = '#96A6AD@0.9',
  gruber_darker_fg_2 = '#e1e8f7',
  gruber_darker_white = '#ffffff',
  gruber_darker_black = '#000000',
  gruber_darker_bg_m1 = '#101010',
  gruber_darker_bg = '#66677D',
  -- gruber_darker_bg = '#3C3C4D',
  gruber_darker_niagara = '#96a6c8',
  gruber_darker_niagara_dark = '#384052',
  gruber_darker_wisteria = '#5C76CB',
  gruber_darker_green_custom = '#369432',
  gruber_darker_green_custom_m1 = '#e6b647',
  todo_fg = '#5270B5',
  todo_bg = '#0b1e33',
  note_fg = '#ff57fF',
  note_bg = '#7A644D',
  warning_fg = '#ff9900',
  danger_fg = '#ff8b64',

  -- Blacks. Not in base Nord.
  black0 = '#191D24',
  -- Slightly darker than bg.  Very useful for certain popups
  black2 = '#222630',

  -- Grays
  -- This color is used on their website's dark theme.
  gray0 = '#242933', --bg
  -- Polar Night.
  gray1 = '#2E3440',
  gray2 = '#3B4252',
  gray3 = '#434C5E',
  gray4 = '#4C566A',

  -- A light blue/gray.
  -- From @nightfox.nvim.
  gray5 = '#60728A',

  -- Dim white.
  -- default fg, has a blue tint.
  white0_normal = '#BBC3D4',
  -- less blue tint
  white0_reduce_blue = '#C0C8D8',

  -- Snow storm.
  white1 = '#D8DEE9',
  white2 = '#E5E9F0',
  white3 = '#ECEFF4',

  -- Frost.
  blue0 = '#5E81AC',
  blue1 = '#81A1C1',
  blue2 = '#88C0D0',

  cyan = {
    base = '#8FBCBB',
    bright = '#9FC6C5',
    dim = '#80B3B2',
  },

  -- Aurora.
  -- These colors are used a lot, so we need variations for them.
  -- Base colors are from original Nord palette.
  red = {
    base = '#BF616A',
    bright = '#C5727A',
    dim = '#B74E58',
  },
  orange = {
    base = '#D08770',
    bright = '#D79784',
    dim = '#CB775D',
  },
  yellow = {
    base = '#EBCB8B',
    bright = '#EFD49F',
    dim = '#E7C173',
  },
  green = {
    base = '#A3BE8C',
    bright = '#B1C89D',
    dim = '#97B67C',
  },
  magenta = {
    base = '#B48EAD',
    bright = '#BE9DB8',
    dim = '#A97EA1',
  },
}

local highlight_groups = {
  --Main
  Conditional = { fg = p.soft_pinkish },
  Normal = { fg = p.normal_text_gray, bg = p.background_color },
  NormalNC = { link = 'Normal' },
  MsgArea = { fg = p.gold_yellow, bg = p.almost_background_color },
  NormalFloat = { bg = p.almost_background_color, fg = 'NONE' },
  Bold = { bold = true },
  Italic = { italic = true },
  Underlined = { undercurl = true },
  Visual = { bg = p.soft_grey_highlight, fg = 'NONE' },
  Directory = { fg = p.directory_color, bold = true },
  IncSearch = { fg = 'NONE', bg = p.even_softer_grey_highlight }, -- yanking color
  Search = { link = 'IncSearch' },
  Substitute = { link = 'IncSearch' },
  MatchParen = { fg = 'NONE', bg = p.soft_grey_highlight },
  ModeMsg = { link = 'Normal' },
  MoreMsg = { link = 'Normal' },
  WarningMsg = { fg = p.gold_yellow },
  FloatBorder = { fg = p.even_softer_grey_highlight, bg = 'NONE' },
  NonText = { link = 'Normal' },
  LineNr = { bg = p.background_color, fg = p.soft_grey_highlight },
  LineNrAbove = { link = 'LineNr' },
  LineNrBelow = { link = 'LineNr' },
  qfText = { fg = '#C29C6D' },
  DiagnosticVirtualTextError = { bg = 'none', fg = '#B9545E' },
  DiagnosticVirtualTextHint = { bg = 'none', fg = p.global_blue },
  DiagnosticVirtualTextInfo = { bg = 'none', fg = p.global_blue },
  DiagnosticVirtualTextWarn = { bg = 'none', fg = p.global_blue },

  CursorLine = { fg = 'NONE', bg = p.soft_grey_highlight },
  CursorLineNr = { fg = p.gold_yellow, bg = 'NONE' },
  Cursor = { bg = p.variable_scope_color },
  -- Status line ------------------------------------------
  StatusLine = { fg = p.gold_yellow, bg = p.almost_background_color },
  StatusLineNC = { fg = p.even_even_softer_grey_highlight, bg = p.almost_background_color },
  WinSeparator = { fg = p.soft_grey_highlight, bg = 'NONE' },
  StatusLineAccent = { bg = p.almost_background_color },
  -- Mode = { bg =p.almost_background_color },
  -----------------------------------------------------------
  SignColumn = { bg = p.background_color },
  Colorcolumn = { link = 'StatusLine' },
  TabLineFill = { bg = p.soft_grey_highlight },
  TabLine = { bg = p.soft_grey_highlight },
  TabLineSel = { fg = 'NONE', bg = p.soft_grey_highlight },
  Whitespace = { bg = 'NONE', fg = p.variable_whiteish },
  Pmenu = { fg = p.variable_whiteish, bg = p.almost_background_color },
  PmenuSel = { bg = p.almost_background_color, fg = p.normal_text_gray },
  PmenuThumb = { bg = p.greyish_green_riogu },
  PmenuSbar = { bg = p.softer_grey_highlight },

  -- YankHighlight = { bg = p.gold_yellow },

  -- telescope stuff-----------
  ['@variable.parameter.python'] = { fg = p.soft_pinkish },
  -- ['@variable.python'] = { fg = p.soft_pinkish },
  -- TelescopeMatching = { fg = p.variable_whiteish },
  -- TelescopeSelection = { fg = p.variable_whiteish },
  TelescopeResultsTitle = { fg = p.variable_whiteish, bold = true },
  TelescopeResultsNormal = { fg = p.variable_whiteish },
  TelescopeResultsBorder = { fg = p.variable_whiteish },
  TelescopePreviewTitle = { fg = p.variable_whiteish },
  TelescopePreviewNormal = { bg = 'NONE' },
  TelescopePreviewBorder = { fg = p.variable_whiteish, bg = 'NONE' },
  TelescopePromptTitle = { fg = p.variable_whiteish },
  TelescopePromptPrefix = { fg = p.variable_whiteish },
  TelescopePromptCounter = { fg = p.variable_whiteish },
  TelescopePromptNormal = { fg = p.variable_whiteish },
  TelescopePromptBorder = { fg = p.variable_whiteish },
  -----------------------------
  Conceal = { link = 'Operator' },
  Title = { link = 'Normal' },
  Question = { link = 'Normal' },
  WildMenu = { link = 'Pmenu' },
  Folded = { fg = p.greyish_green_riogu },
  FoldColumn = { link = 'Folded' },
  Error = { fg = p.soft_pinkish },
  ErrorMsg = { link = 'Error' },
  -- Spelling
  SpellBad = { undercurl = true },
  SpellLocal = { undercurl = true },
  SpellCap = { undercurl = true },
  SpellRare = { undercurl = true },
  -- Syntax
  Boolean = { fg = p.soft_pinkish },
  Character = { link = 'String' },
  Comment = { fg = p.even_softer_grey_highlight },
  Constant = { fg = p.dark_green },
  Define = { bg = p.even_softer_grey_highlight },
  Delimiter = { fg = p.greyish_green_riogu }, --colons and double dots
  Function = { fg = p.function_name_blue },
  Identifier = { fg = p.variable_whiteish },
  Include = { link = 'PreProc' },
  Keyword = { fg = p.class_struct_blue }, -- for loops and if statements (lmao)
  Label = { link = 'String' },
  Number = { fg = '#E0B4BB' },
  Float = { link = 'Number' },
  Operator = { fg = p.most_soft_grey_highlight },
  PreProc = { fg = p.global_blue },

  -- Repeat = { fg = p.parameter_white, bg = p.normal_text_gray },
  Special = { fg = p.gold_yellow },
  SpecialChar = { link = 'String' },
  SpecialComment = { link = 'SpecialChar' },
  SpecialKey = { fg = p.even_softer_grey_highlight }, -- Change here
  Statement = { link = 'Type' },
  StorageClass = { fg = p.lighter_variable_whiteish },
  String = { fg = p.string_green },
  Structure = { fg = p.function_name_blue },
  LogPath = { fg = p.variable_whiteish},
  Variable = { fg = p.variable_scope_color },
  Tag = { link = 'SpecialChar' },
  Todo = { fg = p.todo_fg, bg = p.todo_bg },
  Type = { fg = p.gold_yellow },
  Typedef = { fg = p.gold_yellow },
  ['luaTable'] = { link = 'Normal' },
  ['@text.todo'] = { fg = p.todo_fg, bg = p.todo_bg },
  ['@text.note'] = { fg = p.note_fg, bg = p.note_bg },
  ['@text.danger'] = { fg = p.danger_fg, bg = p.gruber_darker_red_custom_m1 },
  ['@text.uri'] = { fg = p.gruber_darker_niagara, underline = true },
  ['@unchecked_list_item'] = { link = 'normal' },
  ['@checked_list_item'] = { fg = p.greyish_green_riogu, strikethrough = true },
  ['@text.todo.unchecked'] = { link = '@unchecked_list_item' },
  ['@text.todo.checked'] = { link = '@checked_list_item' },
  ['@keyword'] = { link = 'Keyword' },
  ['@function'] = { link = 'Function' },
  ['@method'] = { fg = p.parameter_orangeish },
  ['@field'] = { link = 'Identifier' },
  ['@constructor'] = { link = 'Function' },
  -- ['@repeat'] = { fg = p.gold },
  ['@label'] = { link = 'String' },
  ['@variable'] = { link = 'Variable' },
  ['@type'] = { link = 'Type' },
  ['@type.builtin'] = { fg = p.gold_yellow },
  ['@constant'] = { link = 'Constant' },
  ['@variable.builtin'] = { link = 'Type' },
  ['@operator'] = { link = 'Operator' },
  ['@punctuation.special'] = { link = 'Specialchar' },
  ['@punctuation.bracket'] = { fg = p.lighter_variable_whiteish },
  ['@conditional'] = { link = 'Conditional' },
  ['@exception'] = { link = 'Exception' },
  ['@lsp.type.namespace'] = { fg = p.gold_yellow },
  ['@lsp.type.parameter.cpp'] = { fg = '#41A695' },
  ['@lsp.typemod.parameter.declaration.cpp'] = { fg = p.variable_scope_color },
  -- LSP
  -- ['@lsp.type.class.cpp'] = { fg = p.function_name_blue },
  ['@lsp.type.enumMember'] = { fg = p.string_green },
  ['@lsp.type.interface'] = { fg = p.gold_yellow },
  ['@lsp.typemod.variable.globalScope.cpp'] = { fg = p.global_blue },
  -- ['@lsp.mod.classScope.cpp'] = { fg = p.variable_whiteish },

  ['@lsp.type.method.cpp'] = { fg = p.function_name_blue },
  -- ['@lsp.type.property.cpp'] = {fg = }

  ['@lsp.typemod.property.declaration.cpp'] = { fg = p.variable_scope_color },
  ['@lsp.type.macro'] = { fg = p.macro_green },
  ['@keyword.modifier.cpp'] = { fg = p.class_struct_blue },
  -- ['@punctuation.bracket.cpp'] = { fg = p.variable_whiteish },
  ['@keyword.import.cpp'] = { fg = p.global_blue },
  ExtraWhiteSpace = { bg = 'NONE' },
  MiniExtra = { bg = 'NONE' },
  -- ['@lsp.mod.readonly.cpp'] = { fg = '#44588B' },,
  -- ['@lsp.mod.functionScope.cpp'] = { fg = p.even_softer_grey_highlight },
  -- Java
  ['javaStatement'] = { link = 'Keyword' },
  ['javaOperator'] = { link = 'Keyword' },
  ['@lsp.type.property.java'] = { fg = p.gruber_darker_quartz },
  -- ["@lsp.mod.typeArgument.java"]                      = { fg = p.gruber_darker_quartz },
  -- ["@lsp.typemod.class.readonly.java"]                = { fg = p.gruber_darker_quartz },
  -- JavaScript
  ['javaScriptIdentifier'] = { link = 'Keyword' },
  ['javaScriptFunction'] = { link = 'Keyword' },
  ['javaScriptEmbed'] = { fg = p.gold_yellow },
  ['javaScriptBraces'] = { link = 'Normal' },
  ['@lsp.mod.defaultLibrary.javascript'] = { link = 'Keyword' },
  ['@lsp.type.funciton.javascript'] = { link = 'Function' },
  ['@lsp.typemod.property.defaultLibrary.javascript'] = { fg = p.gruber_darker_quartz },
  ['@lsp.typemod.member.defaultLibrary.javascript'] = { fg = p.gruber_darker_niagara },
  -- Markdown
  ['markdownCodeBlock'] = { link = 'String' },
  ['@markup.raw.block.markdown'] = { bg = 'NONE', fg = p.variable_scope_color },
  ['@spell.markdown'] = { bg = 'NONE', fg = p.variable_whiteish },
  ['RenderMarkdownCode'] = { fg = 'NONE' },
  ['RenderMarkdownH2Bg'] = { bg = 'NONE'},
  -- ['@markup.heading.2.markdown'] = { fg = p.gold_yellow, bg = 'NONE' },
  -- Diff
  DiffAdd = { fg = 'NONE', bg = p.gruber_darker_green_custom_m1 },
  DiffAdded = { fg = p.gruber_darker_green_custom, bg = 'NONE' },
  DiffChange = { fg = 'NONE', bg = p.gruber_darker_yellow_custom_m1 },
  DiffChanged = { fg = p.gruber_darker_yellow_custom, bg = 'NONE' },
  DiffDelete = { fg = 'NONE', bg = p.gruber_darker_red_custom_m1 },
  DiffRemoved = { fg = p.gruber_darker_red_custom, bg = 'NONE' },
  DiffText = { fg = p.gruber_darker_green_custom, bg = 'NONE', bold = true },
  -- Telescope
  TelescopeSelection = { bg = p.gruber_darker_bg_p1 },
  TelescopeSelectionCaret = { link = 'TelescopeSelection' },
  TelescopeMatching = { fg = p.gruber_darker_white, bold = true },
  --Git
  GitSignsAdd = { fg = p.dark_green, bg = 'NONE' },
  GitSignsChange = { fg = p.gold_yellow, bg = 'NONE' },
  GitSignsDelete = { fg = p.gruber_darker_red, bg = 'NONE' },
  --Diagnostic
  DiagnosticSignError = { fg = p.gruber_darker_red_custom, bg = 'NONE' },
  DiagnosticSignWarn = { fg = p.gold_yellow, bg = 'NONE' },
  DiagnosticSignHint = { fg = p.gruber_darker_bg_p3, bg = p.almost_background_color },
  DiagnosticSignInfo = { fg = p.todo_fg, bg = p.almost_background_color },
  DiagnosticError = { link = 'DiagnosticSignError' },
  DiagnosticUnderlineError = { undercurl = true, sp = p.red_fixme }, -- NOTE: important
  DiagnosticWarn = { link = 'DiagnosticSignWarn' },
  DiagnosticHint = { link = 'DiagnosticSignHint' },
  DiagnosticInfo = { link = 'DiagnosticSignInfo' },
  --Scheme icon
  DevIconScheme = { fg = p.gruber_darker_red, bg = p.background_color },
  DevIconJava = { fg = p.gruber_darker_red },
  DevIconJavaScript = { fg = p.gold_yellow },
  --Oil
  OilDir = { link = 'Directory' },
  --Mason
  MasonHeader = { link = 'StatusLine' },
  --Illuminate
  IlluminatedWordText = { bg = p.gold_yellow, underline = false },
  IlluminatedWordRead = { bg = p.gold_yellow, underline = false },
  IlluminatedWordWrite = { bg = p.gold_yellow, underline = false },
}

function M.setup()
  vim.cmd 'hi clear'

  vim.o.background = 'dark'
  if vim.fn.exists 'syntax_on' then
    vim.cmd 'syntax reset'
  end
  -- vim.api.nvim_set_hl(cterm=undercurl, ctermul=red)
  -- vim.api.nvim_set_hl(ns_id, name, val)

  vim.o.termguicolors = true
  vim.g.colors_name = 'riogu-minimal'
  vim.g.winblend = true

  local hi = vim.api.nvim_set_hl

  for name, style in pairs(highlight_groups) do
    hi(0, name, style)
  end
end

return M
