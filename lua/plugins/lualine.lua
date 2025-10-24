-- temp-nvim-config/lua/plugins/lualine.lua

local colorscheme = require('space-mining')

require('lualine').setup({
	options = {
		icons_enabled = true,
		theme = colorscheme.lualine_theme,  -- Use theme from colorscheme
		component_separators = { left = '', right = '' },
		section_separators = { left = '', right = '' },
		globalstatus = false,
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = {
			'branch',
			{
				'diff',
				colored = true,
				diff_color = {
					added = { fg = '#589A8F' },
					modified = { fg = '#FCBF55' },
					removed = { fg = '#FF9A5C' },
				},
			},
			'diagnostics',
		},
		lualine_c = { { 'filename', path = 1 } },
		lualine_x = { 'encoding', 'fileformat', 'filetype' },
		lualine_y = { 'progress' },
		lualine_z = { 'location' },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { { 'filename', path = 1 } },
		lualine_x = { 'location' },
		lualine_y = {},
		lualine_z = {},
	},
})
