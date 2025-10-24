vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Use :lua vim.pack.update() to update plugins (with nice UI!)
-- Use :lua vim.pack.del({'plugin-name'}) to remove
require("options")
require("keymaps")

-- Load colorscheme
local colorscheme = require("space-mining")
colorscheme.setup()

-- Add plugins using vim.pack
vim.pack.add({
	-- Core LSP and completion
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/saadparwaiz1/cmp_luasnip",

	-- Treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter",

	-- Telescope
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-file-browser.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",

	-- Formatting
	"https://github.com/stevearc/conform.nvim",

	-- Git
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/kdheepak/lazygit.nvim",

	-- UI
	"https://github.com/folke/which-key.nvim",
	"https://github.com/numToStr/Comment.nvim",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",

	-- Mini
	"https://github.com/echasnovski/mini.nvim",

	-- Terminal
	"https://github.com/akinsho/toggleterm.nvim",

	-- Session
	"https://github.com/rmagatti/auto-session",

	-- Utilities
	"https://github.com/tpope/vim-sleuth",
	"https://github.com/prichrd/netrw.nvim",
	"https://github.com/wakatime/vim-wakatime",
	"https://github.com/kylelaker/riscv.vim",
	"https://github.com/declancm/cinnamon.nvim",
	"https://github.com/fei6409/log-highlight.nvim",
	"https://github.com/brenoprata10/nvim-highlight-colors",

	-- Custom
	"https://github.com/riogu/gcc1plus",
	"https://github.com/sakhnik/nvim-gdb",
}, { load = true, confirm = false })

-- Build hooks for plugins that need compilation
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind

		-- Build telescope-fzf-native after install/update
		if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
			if vim.fn.executable("make") == 1 then
				print("Building telescope-fzf-native...")
				vim.system({ "make" }, { cwd = ev.data.path })
			end
		end

		-- Build nvim-gdb after install/update
		if name == "nvim-gdb" and (kind == "install" or kind == "update") then
			local install_sh = ev.data.path .. "/install.sh"
			if vim.fn.filereadable(install_sh) == 1 then
				print("Building nvim-gdb...")
				vim.system({ "bash", "install.sh" }, { cwd = ev.data.path })
			end
		end
	end,
})

-- Load plugin configs
require("plugins.lsp")
require("plugins.cmp")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.conform")
require("plugins.gitsigns")
require("plugins.which-key")
require("plugins.comment")
require("plugins.todo-comments")
require("plugins.lualine")
require("plugins.mini")
require("plugins.toggleterm")
require("plugins.autosession")
require("plugins.cinnamon")
require("plugins.netrw")
require("plugins.lazygit")
require("plugins.log-highlight")


-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.filetype.add({
	extension = {
		hfs = "cpp",
		fm = "rs",
		fs = "forth",
	},
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "/tmp/neomutt-*",
	command = "setfiletype mail",
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
			vim.keymap.set("n", "gd", "<C-]>", { buffer = true, desc = "Go to definition (ctags)" })
			vim.keymap.set("n", "gr", ":ts <C-R><C-W><CR>", { buffer = true, desc = "Show tags" })
		end
	end,
})

vim.diagnostic.config({ virtual_text = true })
