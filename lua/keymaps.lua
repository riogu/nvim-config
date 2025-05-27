-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

local function cmd(string)
  return '<cmd>' .. string .. '<CR>'
end

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
vim.keymap.set('n', '<space>fb', ':Telescope file_browser path=%:p:h select_buffer=true<CR>')
-- vim: ts=2 sts=2 sw=2 et
-- vim.keymap.del('n', '<C-f>')

vim.keymap.set({ 'n' }, 's', '<cmd>w<CR>', { remap = true, desc = 'Save file with ctrl s' })
vim.keymap.set({ 'n', 'i', 'v' }, 'º', '<Esc>', { remap = true, silent = true, desc = 'leave insert mode' })
vim.keymap.set('n', '<leader>fc', '<cmd>Telescope find_files cwd=~/.config/nvim<CR>', { desc = 'Find in config' })
-- vim.keymap.set('n', '<leader>e', cmd ':Oil', { desc = 'Find files or something' })
vim.keymap.set('n', '-', cmd ':Explore', { desc = 'Explore-netrw' })
vim.keymap.set('n', 'e', cmd ':Explore', { desc = 'Explore-netrw' })
vim.keymap.set('n', '<leader>m', cmd ':colorscheme material-palenight', { desc = 'Set material palenight theme' })

-- nmap ^ :<c-u>call netrw#Call('NetrwBrowseUpDir', 1)<cr>
-- vim.keymap.set('n', 'e', function()
--   if vim.api.nvim_buf_get_option(0, 'filetype') == 'netrw' then
--     vim.keymap.set('n', 'e', cmd '-', { desc = 'Explore-netrw' })
--     vim.api.nvim_exec2(':echo-', {})
--   else
--     -- vim.keymap.set('n', 'e', cmd ':Explore', { desc = 'Explore-netrw' })
--     -- vim.api.nvim_exec('-', false)
--     -- vim.api.nvim_exec2(':Explore', {})
--     -- vim.api.nvim_exec(':Explore', false)
--   end
-- end, {})

-- Undo and redo
-- vim.keymap.set({ 'n', 'i' }, '<C-/>', cmd ':FloatermNew')
vim.keymap.set({ 'i', 'n' }, '<z>', cmd 'undo', { desc = 'Undo' })
-- Go bandana dee backwards
vim.keymap.set({ 'n' }, '<S-u>', cmd 'redo', { silent = true, desc = 'Redo' })
local map = vim.keymap.set
-- Same thing but for different terminals
map({ 'i', 't' }, '<C-BS>', '<C-w>', { desc = 'Delete word' })
map({ 'i', 't' }, '<C-h>', '<C-w>', { desc = 'Delete word' })
-- Window Management
map('n', '<leader>wv', '<c-w>v', { desc = 'Split window vertically' })
map('n', '<leader>ws', '<c-w>s', { desc = 'Split window horizontally' })
map('n', '<leader>wh', '<c-w>h', { desc = 'Go left' })
map('n', '<leader>wl', '<c-w>l', { desc = 'Go right' })
map('n', '<leader>wk', '<c-w>k', { desc = 'Go up' })
map('n', '<leader>wj', '<c-w>j', { desc = 'Go down' })
map('n', '<leader>wq', '<c-w>q', { desc = 'Close window' })
map('n', '<leader>wH', '<c-w>H', { desc = 'GO LEFT' })
map('n', '<leader>wL', '<c-w>L', { desc = 'GO RIGHT' })
map('n', '<leader>wK', '<c-w>K', { desc = 'GO UP' })
map('n', '<leader>wJ', '<c-w>J', { desc = 'GO DOWN' })
-- map('n', '<leader>wo', '<c-w>o', { desc = 'Close all other windows' })
map('n', '<leader>w<left>', '<c-w>h', { desc = 'Go left' })
map('n', '<leader>w<right>', '<c-w>l', { desc = 'Go right' })
map('n', '<leader>w<up>', '<c-w>k', { desc = 'Go up' })
map('n', '<leader>w<down>', '<c-w>j', { desc = 'Go down' })
map('n', 'wv', '<c-w>v', { desc = 'Split window vertically' })
map('n', 'ws', '<c-w>s', { desc = 'Split window horizontally' })
map('n', 'wh', '<c-w>h', { desc = 'Go left' })
map('n', 'wl', '<c-w>l', { desc = 'Go right' })
map('n', 'wk', '<c-w>k', { desc = 'Go up' })
map('n', 'wj', '<c-w>j', { desc = 'Go down' })
map('n', 'wq', '<c-w>q', { desc = 'Close window' })
map('n', 'wH', '<c-w>H', { desc = 'GO LEFT' })
map('n', 'wL', '<c-w>L', { desc = 'GO RIGHT' })
map('n', 'wK', '<c-w>K', { desc = 'GO UP' })
map('n', 'wJ', '<c-w>J', { desc = 'GO DOWN' })
-- map('n', 'wo', '<c-w>o', { desc = 'Close all other windows' })
map('n', 'w<left>', '<c-w>h', { desc = 'Go left' })
map('n', 'w<right>', '<c-w>l', { desc = 'Go right' })
map('n', 'w<up>', '<c-w>k', { desc = 'Go up' })
map('n', 'w<down>', '<c-w>j', { desc = 'Go down' })
-- new mappings eeeeee
-- map('n', '<c-left>', '<c-w>h', { desc = 'Go left' })
-- map('n', '<c-right>', '<c-w>l', { desc = 'Go right' })
-- vim.keymap.set('n', '<Tab>', '<Nop>')
-- map('n', '<c-down>', '<c-d>', { desc = 'Go down' })
-- map('n', '<c-up>', '<c-u>', { desc = 'Go up' })

-- map('n', '<Tab><down>', '<c-d>', { desc = 'Go down' })
-- map('n', '<Tab><up>', '<c-u>', { desc = 'Go up' })

-- vim.keymap.set('i', '<c-f>', "<Esc>: silent exec '.!inkscape-figures create "'.getline('.').'" "'.b:vimtex.root.'/figures/"'<CR><CR>:w<CR", { desc="create inkscape figure", silent = true, noremap = true })
-- inoremap <C-f> <Esc>: silent exec '.!inkscape-figures create "'.getline('.').'" "'.b:vimtex.root.'/figures/"'<CR><CR>:w<CR
-- nmap <expr> ^ &ft ==# 'netrw' ? '-' : '^'

-- vim.g.did_load_netrw = 1
--   vim.keymap.set('n', 'e', '<Plug>(NetrwBrowseUpDir)',{silent = true, noremap = true, buffer = true})
--
