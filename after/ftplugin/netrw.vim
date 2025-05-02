" -- vim.keymap.set('n', 'e', '<Plug>(NetrwBrowseUpDir)', { silent = true, noremap = true, buffer = true })
" nmap <expr> e &ft ==# 'netrw' ? '-' : ''
nmap <expr> e &ft ==# 'netrw' ? '-' : '<Cmd>Explore<CR>'
" nmap <buffer> e &ft ==# 'netrw' ? <Plug>NetrwBrowseUpDir
