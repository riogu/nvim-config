return {
  {
    'blazkowolf/gruber-darker.nvim',
    -- 'riogu/gruber-darker-theme.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      require('gruber-darker').setup()
      vim.cmd 'colorscheme gruber-darker'
    end,
  },
}
