return {
  {
    'akinsho/toggleterm.nvim',
    opts = {
      open_mapping = { [[<C-S-7>]], [[<c-/>]] }, -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
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
  -- {
  --   'ilof2/posterpole.nvim',
  --   priority = 1000,
  --   config = function()
  --     require('posterpole').setup {
  --       lualine = {
  --         transparent = true,
  --       }, -- config here
  --     }
  --     -- vim.cmd 'colorscheme posterpole'
  --
  --     -- if you need colorscheme without termguicolors support
  --     -- This variant set termguicolors to false, be aware of using it
  --     -- vim.cmd("colorscheme posterpole-term")
  --   end,
  -- },
  {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme 'nordic'

      require('nordic').setup {
        -- This callback can be used to override the colors used in the base palette.
        on_palette = function(palette) end,
        -- This callback can be used to override the colors used in the extended palette.
        after_palette = function(palette) end,
        -- This callback can be used to override highlights before they are applied.
        on_highlight = function(highlights, palette) end,
        -- Enable bold keywords.
        bold_keywords = true,
        -- Enable italic comments.
        italic_comments = false,
        -- Enable editor background transparency.
        transparent = {
          -- Enable transparent background.
          bg = false,
          -- Enable transparent background for floating windows.
          float = false,
        },
        -- Enable brighter float border.
        bright_border = false,
        -- Reduce the overall amount of blue in the theme (diverges from base Nord).
        reduced_blue = true,
        -- Swap the dark background with the normal one.
        swap_backgrounds = false,
        -- Cursorline options.  Also includes visual/selection.
        cursorline = {
          -- Bold font in cursorline.
          bold = false,
          -- Bold cursorline number.
          bold_number = true,
          -- Available styles: 'dark', 'light'.
          theme = 'light',
          -- Blending the cursorline bg with the buffer bg.
          blend = 0.85,
        },
        noice = {
          -- Available styles: `classic`, `flat`.
          style = 'classic',
        },
        telescope = {
          -- Available styles: `classic`, `flat`.
          style = 'classic',
        },
        leap = {
          -- Dims the backdrop when using leap.
          dim_backdrop = false,
        },
        ts_context = {
          -- Enables dark background for treesitter-context window
          dark_background = true,
        },
      }
      require('nordic').load()
    end,
  },
  -- config = function()
  --   require('lualine').setup {
  --     options = {
  --       -- theme = 'auto',
  --     },
  --   }
  -- end,
  {
    'marko-cerovac/material.nvim',
    lazy = false,
    priority = 1000,
    config = function(_, _)
      --Lua:
      -- vim.g.material_style = 'deep ocean'
      -- vim.cmd 'colorscheme material-palenight'
    end,
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'voldikss/vim-floaterm',
  },
  -- { 'olivercederborg/poimandres.nvim' },
  -- { 'fxn/vim-monochrome' },
  {
    'zenbones-theme/zenbones.nvim',
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = 'rktjmp/lush.nvim',
    lazy = false,
    priority = 1000,
    -- you can set set configuration options here
    config = function()
      --     vim.g.zenbones_darken_comments = 45
      --
      -- vim.cmd.colorscheme 'zenbones'
    end,
  },
  -- { 'ellisonleao/gruvbox.nvim', priority = 1000, config = true },
  -- { 'rebelot/kanagawa.nvim', priority = 1000, config = true },
  { 'sainnhe/gruvbox-material', priority = 1000 }, -- {
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
  -- {
  --   'nvim-neo-tree/neo-tree.nvim',
  --   keys = {
  --     { '<leader>b', '<cmd>Neotree toggle<CR>', desc = 'Open Neotree' },
  --   },
  --   branch = 'v3.x',
  --   -- config = function()
  --   --   require('neo-tree').setup {
  --   --     default_component_configs = {
  --   --       auto_expand_width = false,
  --   --       view = { adaptive_size = true },
  --   --       window = {
  --   --         position = 'left',
  --   --         width = 5,
  --   --       },
  --   --     },
  --   --   }
  --   -- end,
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
  --     'MunifTanjim/nui.nvim',
  --
  --     -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  --   },
  -- },
  { 'wakatime/vim-wakatime', lazy = false },
  { 'akinsho/toggleterm.nvim', version = '*', config = true },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  -- {
  --   'nvim-lualine/lualine.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   config = function()
  --     require('lualine').setup {
  --       options = {
  --         theme = 'nordic',
  --       },
  --     }
  --   end,
  -- },
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      {
        '<leader>qs',
        function()
          require('persistence').load()
        end,
        desc = 'Restore Session',
      },
      {
        '<c-l>',
        function()
          require('persistence').select()
        end,
        desc = 'Select Session',
      },
      {
        '<leader>ql',
        function()
          require('persistence').load { last = true }
        end,
        desc = 'Restore Last Session',
      },
      {
        '<leader>qd',
        function()
          require('persistence').stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
  {
    'prichrd/netrw.nvim',
    config = function()
      require('netrw').setup {
        -- File icons to use when `use_devicons` is false or if
        -- no icon is found for the given file type.
        icons = {
          symlink = '',
          directory = '',
          file = '',
        },
        -- Uses mini.icon or nvim-web-devicons if true, otherwise use the file icon specified above
        use_devicons = true,
        mappings = {
          -- Function mappings receive an object describing the node under the cursor
          ['p'] = function(payload)
            print(vim.inspect(payload))
          end,
          -- String mappings are executed as vim commands
        },
      }
    end,
  },
}
