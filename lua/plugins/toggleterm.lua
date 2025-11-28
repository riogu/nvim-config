return {
	"akinsho/toggleterm.nvim",
	config = function()
		require("toggleterm").setup({
			open_mapping = { [[<C-S-7>]], [[<c-/>]] },
			direction = "float", -- 'horizontal' or 'float'
		})
	end,
}
