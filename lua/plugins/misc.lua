-- Miscellaneous plugins that don't need special configuration
return {
	-- Comment plugin
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Which-key
	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup()
		end,
	},

	-- Mini.nvim
	{
		"echasnovski/mini.nvim",
		config = function()
			-- Add mini.nvim configs here if needed
		end,
	},

	-- Detect tabstop and shiftwidth automatically
	{ "tpope/vim-sleuth" },

	-- Wakatime
	{ "wakatime/vim-wakatime" },

	-- RISC-V syntax
	{ "kylelaker/riscv.vim" },

	-- Custom gcc1plus
	{ "riogu/gcc1plus" },

	-- nvim-gdb
	{
		"sakhnik/nvim-gdb",
		build = "bash install.sh",
	},
}
