-- lua/plugins/log-highlight.lua
return {
  'fei6409/log-highlight.nvim',
  event = 'VeryLazy',
  opts = {
    extension = { 'log', 'out', 'err', 'txt' },
    filename = { 'test_results.log' },
    keyword = {
      error = {
        'ERROR',
        'FATAL',
        'FAIL',
        'XFAIL',
        'Internal compiler error',
      },
      warning = {
        'WARN',
        'WARNING',
        'NOTE',
        'TIMEOUT',
      },
      pass = {
        'PASS',
        'OK',
        'SUCCESS',
      },
      info = {
        'INFO',
        'NOTICE',
        'TEST',
        'set paths',
      },
      compiler_flag = {
        '-O0',
        '-std=c++20',
        '-std=c++26',
        '-flto',
        '-pedantic-errors',
        '-nostdinc++',
        'spawn',
        'Executing on host:',
      },
      debug = {
        'DEBUG',
        'TRACE',
      },
    },
    highlight_groups = {
      error = 'Error',
      warning = 'WarningMsg',
      info = 'Statement',
      debug = 'Comment',
      pass = 'Constant',
      compiler_flag = 'PreProc',
    },
  },
  config = function(_, opts)
    require('log-highlight').setup(opts)
    local function setup_gcc_syntax()
      if vim.bo.filetype ~= 'log' then
        return
      end
      vim.cmd 'silent! syntax clear'
      vim.cmd 'runtime syntax/log.vim'
      
      -- 1. logAddress: Matches the 0x[HEX] at the start of the line
      vim.cmd [[syn match logAddress /^0x[0-9a-fA-F]\+/]]
      
      -- 2. logFunction: Matches everything between address and opening paren, handling ^M
      vim.cmd [[syn match logFunction /^0x[0-9a-fA-F]\+\s\+\zs.\{-}\ze(\|^0x[0-9a-fA-F]\+\s\+\zs.\{-}\ze\r*$/]]
      
      -- 3. logArguments: Matches the content inside the parentheses
      vim.cmd [[syn match logArguments /(\zs[^)]*\ze)/]]
      
      -- 4. logLocation: Matches the file path and line number
      vim.cmd [[syn match logLocation /^\s\+[^ ]\+:[0-9]\+$/]]
      
      -- === Link the Custom Groups to Your Colorscheme ===
      vim.cmd [[hi! link logFunction Function]]
      vim.cmd [[hi! link logAddress SpecialKey]]
      vim.cmd [[hi! link logArguments Function]]
      vim.cmd [[hi! link logLocation LogPath]]
    end
    
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'log',
      callback = setup_gcc_syntax,
      group = vim.api.nvim_create_augroup('CustomGccLogSyntax', { clear = true }),
    })
  end,
}
