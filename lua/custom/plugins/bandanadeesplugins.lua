return {
  {
    'akinsho/toggleterm.nvim',
    opts = {
      open_mapping = [[<C-S-7>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
      direction = 'float', -- 'horizontal' or 'float'
    },
  },
  {
    'echasnovski/mini.move',
    version = false,
    -- Module mappings. Use `''` (empty string) to disable one.
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = '<M-left>',
        right = '<M-right>',
        up = '<M-up>',
        down = '<M-down>',
        line_left = '<M-left>',
        line_right = '<M-right>',
        line_up = '<M-up>',
        line_down = '<M-down>',
      },

      -- Options which control moving behavior
      options = {
        -- Automatically reindent selection during linewise vertical move
        reindent_linewise = true,
      },
    },
  },
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },

  {
    'kylelaker/riscv.vim',
    ft = { 'riscv' },
    lazy = true, -- For more speed 😎

    -- NOTE: The code below fixes the comments
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'riscv' },
        callback = function()
          vim.opt.commentstring = '# %s'
        end,
        desc = 'Add commentstring for riscv files',
      })
    end,
  },

  {
    'andweeb/presence.nvim',
    opts = {
      neovim_image_text = 'neovim',
      workspace_text = 'editing a workspace',
      editing_text = 'editing a file',

      show_time = true,
      buttons = {
        {
          label = 'View Code',
          -- WE ARE 🇯🇵👺
          url = 'https://youtu.be/5uaHMmcReI0?si=TLt9fB-ong1hs0jT',
        },
      },
    },
  },
  {
    'marko-cerovac/material.nvim',
    -- lazy = false,
    -- config = function(_, _)
    --   --Lua:
    --   vim.g.material_style = 'deep ocean'
    -- end,
    -- Optional dependencies
    --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'voldikss/vim-floaterm',
  },
  -- {
  --   'HiPhish/rainbow-delimiters.nvim',
  -- },
  -- {
  --   'lukas-reineke/indent-blankline.nvim',
  --   main = 'ibl',
  --   ---@module "ibl"
  --   ---@type ibl.config
  --   opts = {
  --
  --     smart_indent_cap = true,
  --   },
  -- },
  {
    'nvim-neo-tree/neo-tree.nvim',
    keys = {
      { '<leader>b', '<cmd>Neotree toggle<CR>', desc = 'Open Neotree' },
    },
    branch = 'v3.x',
    -- config = function()
    --   require('neo-tree').setup {
    --     default_component_configs = {
    --       auto_expand_width = false,
    --       view = { adaptive_size = true },
    --       window = {
    --         position = 'left',
    --         width = 5,
    --       },
    --     },
    --   }
    -- end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',

      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
  },
  { 'wakatime/vim-wakatime', lazy = false },
  { 'akinsho/toggleterm.nvim', version = '*', config = true },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
}
