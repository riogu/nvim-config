-- File: ~/.config/nvim/lua/plugins/cinnamon.lua
-- Last Change: Wed, Jul 2024/07/17 - 08:38:44
-- Author: Sergio Araujo--
--
-- This plugin is for animated scrolling

return {
  'declancm/cinnamon.nvim',
  version = '*', -- use latest release
  opts = {
    -- change default options here
    -- Enable all provided keymaps
    keymaps = {
      -- i removed this line below this comment
      -- basic = true,
      -- extra = true,
    },
    -- Custom scroll options
    options = {
      mode = 'cursor', -- Animate cursor and window scrolling for any movement
      delay = 7, -- Delay between each movement step (in ms)
      step_size = {
        vertical = 1, -- Number of cursor/window lines moved per step
        horizontal = 2, -- Number of cursor/window columns moved per step
      },
      max_delta = {
        line = 80, -- Maximum distance for line movements before scroll animation is skipped
        column = false, -- Maximum distance for column movements before scroll animation is skipped
        time = 100, -- Maximum duration for a movement (in ms)
      },
      -- Optional post-movement callback
      callback = function()
        -- print("Scrolling done!")
      end,
    },
  },
  keys = {
    { '<c-d>', '<cmd>lua require("cinnamon").scroll("<C-d>zz")<cr>', mode = 'n' },
    { '<c-u>', '<cmd>lua require("cinnamon").scroll("<C-u>zz")<cr>', mode = 'n' },
    -- kyun da kyun says: I am assuming that you're not actually using these
    -- { '<c-f>', '<cmd>lua require("cinnamon").scroll("<C-f>zz")<cr>', mode = 'n' },
    -- { '<c-b>', '<cmd>lua require("cinnamon").scroll("<C-b>zz")<cr>', mode = 'n' },
    -- { 'zz', '<cmd>lua require("cinnamon").scroll("zz")<cr>', mode = 'n' },
    -- { 'zt', '<cmd>lua require("cinnamon").scroll("zt")<cr>', mode = 'n' },
    -- { 'zb', '<cmd>lua require("cinnamon").scroll("zb")<cr>', mode = 'n' },
    -- { 'gg', '<cmd>lua require("cinnamon").scroll("gg")<cr>', mode = 'n' },
    -- { 'G', '<cmd>lua require("cinnamon").scroll("G")<cr>', mode = 'n' },
  },
}
