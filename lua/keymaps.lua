-- Keymaps
local map = vim.keymap.set

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

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
-- Note: It's cleaner to use the built-in :LspDiag to open the quickfix list for diagnostics
map("n", "<leader>q", "<cmd>LspDiag<CR>", { desc = "Quickfix list" })

-- Terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Telescope (FIXED to use Lua function for file_browser extension)
map("n", "<leader>fb", function()
	require("telescope").extensions.file_browser.file_browser()
end, { desc = "File browser" })
map("n", "<leader>fc", "<cmd>Telescope find_files cwd=~/.config/nvim<CR>", { desc = "Find config files" })

-- LazyGit
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- Plugin management
vim.keymap.set('n', '<leader>pu', function()
  vim.notify('Checking for plugin updates...', vim.log.levels.INFO)
  vim.pack.update()
end, { desc = '[P]lugins [U]pdate' })

-- Show recent update log
vim.keymap.set('n', '<leader>pl', function()
  local log_file = vim.fn.stdpath('log') .. '/nvim-pack.log'
  if vim.fn.filereadable(log_file) == 1 then
    vim.cmd('tabnew ' .. log_file)
  else
    vim.notify('No update log found', vim.log.levels.WARN)
  end
end, { desc = '[P]lugin [L]og' })

-- List installed plugins with versions
vim.keymap.set('n', '<leader>pi', function()
  local plugins = vim.pack.get()
  local lines = { '# Installed Plugins' }  -- Removed \n
  table.insert(lines, '')  -- Add empty line separately
  
  for _, p in ipairs(plugins) do
    local status = p.active and '✓' or '○'
    local rev = p.rev and p.rev:sub(1, 7) or 'unknown'
    table.insert(lines, string.format('%s %s (%s)', status, p.spec.name, rev))
  end
  
  -- Show in a floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  
  local width = 60
  local height = #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = math.min(height, 30),
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Plugins ',
    title_pos = 'center',
  })
  
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
end, { desc = '[P]lugin [I]nfo' })
