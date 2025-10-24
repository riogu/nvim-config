-- Configure treesitter
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 2 * 1024 * 1024 -- 2 MB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
  indent = {
    enable = true,
    disable = function(lang, buf)
      -- Disable indent for large files - this is expensive
      local line_count = vim.api.nvim_buf_line_count(buf)
      if line_count > 10000 then
        return true
      end
    end,
  },
})

-- Set git as preferred install method
require('nvim-treesitter.install').prefer_git = true

-- Performance tweaks for large files
vim.api.nvim_create_autocmd('BufReadPre', {
  callback = function()
    local line_count = vim.api.nvim_buf_line_count(0)
    if line_count > 10000 then
      -- Keep syntax but disable expensive features
      vim.opt_local.foldmethod = 'manual'
      vim.opt_local.foldexpr = ''
      vim.opt_local.syntax = 'on'
    end
  end,
})
