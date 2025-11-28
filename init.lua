vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

require("options")
require("keymaps")

-- Load colorscheme
local colorscheme = require("space-mining")
colorscheme.setup()

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	-- Import all plugin specs from lua/plugins/
	{ import = "plugins" },
}, {
	checker = { enabled = false },
	change_detection = { notify = false },
})

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
