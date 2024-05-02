return {
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
      -- TODO: Change these
      neovim_image_text = '',
      workspace_text = '',
      editing_text = '',

      show_time = true,
      buttons = {
        {
          label = 'View Code',
          -- >> WE ARE <<
          url = 'https://www.youtube.com/watch?v=UIp6_0kct_U',
        },
      },
    },
  },
}
