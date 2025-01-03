-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- colorscheme = 'palenight',
  require('lspconfig').ruff.setup {
    init_options = {
      settings = {
        -- Server settings should go here
        autoformat = false,
      },
    },
  },
}
