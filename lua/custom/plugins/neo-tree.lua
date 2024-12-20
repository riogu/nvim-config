-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
return {
  'nvim-neo-tree/neo-tree.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree toggle<CR>', { desc = 'NeoTree reveal' } },
    { '<leader>b', '<cmd>Neotree toggle<CR>', desc = 'Open Neotree' },
    { '<C-b>', '<cmd>Neotree toggle<CR>', desc = 'Open Neotree' },
  },
  opts = {
    window = {
      position = 'float',
    },
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<c-b>'] = ':Neotree toggle<CR>',
        },
      },
    },
  },
}
