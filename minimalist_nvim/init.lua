-- options for neovim
---------------------------------------------------------------------------------
vim.g.netrw_banner = 0
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.undofile = true
vim.opt.clipboard = 'unnamedplus'
vim.opt['tabstop'] = 4

-- functionality and etc
---------------------------------------------------------------------------------
vim.cmd [[
  highlight CursorLine ctermbg=236 cterm=NONE 
]]
vim.cmd [[
set t_Co=256
syntax on
colorscheme   materialbox
]]

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- keymaps
---------------------------------------------------------------------------------
local function cmd(string)
  return '<cmd>' .. string .. '<CR>'
end
local map = vim.keymap.set
map({ 'n' }, '<S-u>', cmd 'redo', { desc = 'Redo' })
map({ 'n', 'i' }, '<C-s>', '<cmd>w<CR>', { desc = 'Save file with ctrl s' })
map({ 'i', 't' }, '<C-BS>', '<C-w>', { desc = 'Delete word' })

-- Window Management
map('n', 'wv', '<c-w>v', { desc = 'Split window vertically' })
map('n', 'ws', '<c-w>s', { desc = 'Split window horizontally' })
map('n', 'wq', '<c-w>q', { desc = 'Close window' })
map('n', 'w<left>', '<c-w>h', { desc = 'Go left' })
map('n', 'w<right>', '<c-w>l', { desc = 'Go right' })

map('n', 'w<up>', '<c-w>k', { desc = 'Go up' })
map('n', 'w<down>', '<c-w>j', { desc = 'Go down' })

map({ 'n', 'i' }, '<A-up>', ':m-2<CR>==')
map({ 'n', 'i' }, '<A-down>', ':m+<CR>==')
map({ 'n', 'i' }, '<A-down>', '<Esc>:m+<CR>')
map({ 'n', 'i' }, '<A-up>', '<Esc>:m-2<CR>')
map({ 'v' }, '<A-down>', "<cmd>m'>+<CR>")
map({ 'v' }, '<A-up>', ':m-2<CR>')

-- nmap <expr> e &ft ==# 'netrw' ? '-' : '<Cmd>Explore<CR>'
