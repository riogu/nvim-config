-- Keymaps
local map = vim.keymap.set
vim.keymap.set('n', '<leader>gf', ':FindTest ')

-- Clear search highlight
vim.opt.hlsearch = true
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- Quick save
map("n", "s", "<cmd>w<CR>", { desc = "Save" })

-- File exploration (using built-in netrw)
map("n", "-", "<cmd>Explore<CR>", { desc = "File explorer" })
map("n", "e", "<cmd>Explore<CR>", { desc = "File explorer" })
-- Undo/Redo (using faster core commands)
map("n", "U", "<C-r>", { desc = "Redo (mapped from U)" }) -- U now performs Redo
-- Delete word in insert mode
-- Delete word forward with Ctrl+Delete
map("i", "<C-h>", "<C-w>", { desc = "Delete word" })
map("i", "<C-BS>", "<C-w>", { desc = "Delete word" })
map("i", "<A-BS>", "<C-w>", { desc = "Delete word" })

-- Window management (w prefix)
map("n", "wv", "<C-w>v", { desc = "Split vertical" })
map("n", "ws", "<C-w>s", { desc = "Split horizontal" })
map("n", "wq", "<C-w>q", { desc = "Close window" })
map("n", "wt", "<cmd>terminal<CR>", { desc = "Terminal" })
map("n", "w<left>", "<C-w>h", { desc = "Go left" })
map("n", "w<right>", "<C-w>l", { desc = "Go right" })
map("n", "w<up>", "<C-w>k", { desc = "Go up" })
map("n", "w<down>", "<C-w>j", { desc = "Go down" })

-- Move lines up/down with Alt+arrow keys
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })

-- Indent with Alt+Left/Right
vim.keymap.set("n", "<A-Left>", "<<", { desc = "Decrease indent", silent = true })
vim.keymap.set("n", "<A-Right>", ">>", { desc = "Increase indent", silent = true })
vim.keymap.set("v", "<A-Left>", "<gv", { desc = "Decrease indent", silent = true })
vim.keymap.set("v", "<A-Right>", ">gv", { desc = "Increase indent", silent = true })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
-- Note: It's cleaner to use the built-in :LspDiag to open the quickfix list for diagnostics
vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })

-- Telescope (FIXED to use Lua function for file_browser extension)
-- Terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<leader>fb", function()
	require("telescope").extensions.file_browser.file_browser()
end, { desc = "File browser" })
map("n", "<leader>fc", "<cmd>Telescope find_files cwd=~/.config/nvim<CR>", { desc = "Find config files" })

-- LazyGit
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- Plugin management
vim.keymap.set("n", "<leader>pu", function()
	vim.notify("Checking for plugin updates...", vim.log.levels.INFO)
	vim.pack.update()
end, { desc = "[P]lugins [U]pdate" })

-- Show recent update log
vim.keymap.set("n", "<leader>pl", function()
	local log_file = vim.fn.stdpath("log") .. "/nvim-pack.log"
	if vim.fn.filereadable(log_file) == 1 then
		vim.cmd("tabnew " .. log_file)
	else
		vim.notify("No update log found", vim.log.levels.WARN)
	end
end, { desc = "[P]lugin [L]og" })
