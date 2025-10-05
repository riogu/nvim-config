return {
  'rmagatti/auto-session',
  event = 'VeryLazy',
  opts = {
    enabled = true,
    auto_save = true,
    auto_restore = false,
    auto_create = true,
    suppressed_dirs = { '~/', '~/Downloads', '/' , 'home/riogu'},
    -- Only save if session has real files (not empty buffers, help, etc)
    pre_save_cmds = {
      function()
        -- Check if there's at least one real file buffer
        local has_real_file = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            local buftype = vim.bo[buf].buftype
            local bufname = vim.api.nvim_buf_get_name(buf)
            -- Check if it's a real file (not empty, not special buffer)
            if buftype == '' and bufname ~= '' then
              has_real_file = true
              break
            end
          end
        end
        -- Disable auto-save if no real files
        if not has_real_file then
          vim.cmd 'SessionDisableAutoSave'
        end
      end,
    },
  },
  keys = {
    { '<leader>qs', '<cmd>SessionRestore<cr>', desc = 'Restore Session' },
    { '<c-l>', '<cmd>AutoSession search<cr>', desc = 'Select Session' },
    { '<leader>ql', '<cmd>SessionRestoreLast<cr>', desc = 'Restore Last Session' },
    { '<leader>qd', '<cmd>SessionDisableAutoSave<cr>', desc = "Don't Save Current Session" },
  },
  config = function(_, opts)
    require('auto-session').setup(opts)

    -- Only save on exit if at least one real file is open
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        -- Check if there's at least one real file buffer
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

        -- Only save if we have real files
        if has_real_file then
          require('auto-session').save_session()
        end
      end,
    })
  end,
}
