-- Miscellaneous plugins with simple configurations
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

	-- Mini.nvim collection
	{
		"echasnovski/mini.nvim",
		config = function()
			-- Add mini.nvim configs here if needed
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				notify_on_error = false,
				format_on_save = false,
				formatters_by_ft = {
					lua = { "stylua" },
					c = { "clang_format" },
					cpp = { "clang_format" },
					ocaml = { "ocamlformat" },
					rust = { "rustfmt" },
				},
			})
			vim.keymap.set({ "n", "v" }, "F", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { desc = "[F]ormat buffer" })
		end,
	},

	-- LazyGit integration
	{
		"kdheepak/lazygit.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
		end,
	},

	-- TODO comments highlighting
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({
				keywords = {
					FIX = {
						icon = " ",
						color = "#B9545E",
						alt = { "FIXME", "BUG", "ISSUE" },
					},
					TODO = { icon = " ", color = "#3D6F64" },
					HACK = { icon = " ", color = "warning" },
					WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
					PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
					NOTE = { icon = " ", color = "info", alt = { "INFO" } },
					TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
				},
				signs = false,
				merge_keywords = false,
			})
		end,
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup({
				open_mapping = { [[<C-S-7>]], [[<c-/>]] },
				direction = "float",
			})
		end,
	},

	-- Netrw enhancements
	{
		"prichrd/netrw.nvim",
		config = function()
			require("netrw").setup({
				icons = {
					symlink = "",
					directory = "",
					file = "",
				},
				use_devicons = true,
				mappings = {
					["p"] = function(payload)
						print(vim.inspect(payload))
					end,
				},
			})
		end,
	},

	-- Color highlighting
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({
				render = "background",
				enable_named_colors = false,
				enable_tailwind = false,
			})
		end,
	},

	-- Utilities without config
	{ "tpope/vim-sleuth" }, -- Detect tabstop and shiftwidth automatically
	{ "wakatime/vim-wakatime" }, -- Wakatime time tracking
	{ "kylelaker/riscv.vim" }, -- RISC-V syntax
	{ "riogu/gcc1plus" }, -- Custom gcc1plus

	-- nvim-gdb with build hook
	{
		"sakhnik/nvim-gdb",
		build = "bash install.sh",
	},
}
