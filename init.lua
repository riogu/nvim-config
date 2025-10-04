--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
vim.o.wrap = false
-- vim.g.did_load_netrw = 1
vim.g.netrw_banner = 0
vim.g.command_height = 0
vim.o.expandtab = true
vim.o.shiftwidth=4
vim.o.swapfile = false
-- [[ Setting options ]]
require 'options'
-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'
-- require 'gruber-riogu'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  vim.o.guifont = 'JetBrainsMono Nerd Font' -- text below applies for VimScript
  -- vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_scroll_animation_length = 0.1
end



vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
})
-- vim.o.winborder = "rounded"
vim.cmd [[
set cmdheight=0
set t_Co=256
syntax on
set mouse=a
" colorscheme materialbox
" let g:sierra_Sunset = 1
" let g:sierra_Twilight = 1
" let g:sierra_Midnight = 1
" let g:sierra_Pitch = 1
colorscheme riogu-minimal
]]
--  vim.api.nvim_create_autocmd("TextYankPost", {
--
-- desc = "Highlight when yanking (copying) text",
--
-- group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
--
-- callback = function()
--
-- 	vim.highlight.on_yank()
--
-- end,


vim.filetype.add({
  extension = { fm = "rs" },
})
vim.diagnostic.config { virtual_text = true }
-- })

-- vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#ADD8E6", fg = "#0000FF" })
--
-- vim.api.nvim_create_autocmd("TextYankPost", {
--
-- desc = "Highlight when yanking (copying) text",
--
-- group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
--
-- callback = function()
--
-- vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 300 })
--
-- end,
-- In your init.lua

-- Only map ctags shortcuts if no LSP client is attached
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    -- Check if any LSP client is attached to current buffer
    if #vim.lsp.get_active_clients({ bufnr = 0 }) == 0 then
      -- No LSP, use ctags
      vim.keymap.set('n', 'gd', '<C-]>', { buffer = true, desc = 'Go to definition (ctags)' })
      vim.keymap.set('n', 'gr', ':ts <C-R><C-W><CR>', { buffer = true, desc = 'Show tags' })
    end
  end,
})

