-- Highlight todo, notes, etc in comments
return {
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      keywords = {
        FIX = {
          icon = ' ', -- icon used for the sign, and in search results
          color = '#B9545E', -- can be a hex color, or a named color (see below)
          alt = { 'FIXME', 'BUG', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = ' ', color = '#3D6F64' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = ' ', color = 'info', alt = { 'INFO' } },
        TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
      signs = false,
      merge_keywords = false,
    },
  },
  -- FIXME: dsadkasjdkajskj
  --
  -- kdaslkld
  -- vim.keymap.set("n", "]t", function()
  --   require("todo-comments").jump_next()
  -- end, { desc = "Next todo comment" })
  --
  -- vim.keymap.set("n", "[t", function()
  --   require("todo-comments").jump_prev()
  -- end, { desc = "Previous todo comment" })
  --
  -- -- You can also specify a list of valid jump keywords
  --
  -- vim.keymap.set("n", "]t", function()
  --   require("todo-comments").jump_next({keywords = { "ERROR", "WARNING" }})
  -- end, { desc = "Next error/warning todo comment" })
}
-- vim: ts=2 sts=2 sw=2 et
