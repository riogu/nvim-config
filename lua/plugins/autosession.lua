-- Setup the plugin (replaces the opts and config function)
require('auto-session').setup({
  enabled = true,
  auto_save = true,
  auto_restore = false,
  auto_create = true,
  suppressed_dirs = { '~/', '~/Downloads', '/', 'home/riogu' },
  pre_save_cmds = {
    function()
      local has_real_file = false
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local buftype = vim.bo[buf].buftype
          local bufname = vim.api.nvim_buf_get_name(buf)
          if buftype == '' and bufname ~= '' then
            has_real_file = true
            break
          end
        end
      end
      if not has_real_file then
        vim.cmd('SessionDisableAutoSave')
      end
    end,
  },
})

-- Keymaps (replaces the keys table)
vim.keymap.set('n', '<leader>qs', '<cmd>SessionRestore<cr>', { desc = 'Restore Session' })
vim.keymap.set('n', '<c-l>', '<cmd>AutoSession search<cr>', { desc = 'Select Session' })
vim.keymap.set('n', '<leader>ql', '<cmd>SessionRestoreLast<cr>', { desc = 'Restore Last Session' })
vim.keymap.set('n', '<leader>qd', '<cmd>SessionDisableAutoSave<cr>', { desc = "Don't Save Current Session" })

-- Custom autocmd (from your config function)
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    local has_real_file = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        local buftype = vim.bo[buf].buftype
        local bufname = vim.api.nvim_buf_get_name(buf)
        if buftype == '' and bufname ~= '' then
          has_real_file = true
          break
        end
      end
    end
    if has_real_file then
      require('auto-session').save_session()
    end
  end,
})
