return {
	"brenoprata10/nvim-highlight-colors",
	config = function()
		require("nvim-highlight-colors").setup({
			render = "background", -- or 'foreground' or 'virtual'
			enable_named_colors = false,
			enable_tailwind = false,
		})
	end,
}
