-- ~/.config/nvim/lua/plugins/mail-syntax.lua
-- lazy.nvim plugin for mail syntax highlighting

return {
  {
    name = 'mail-reply-highlighting',
    dir = vim.fn.stdpath 'config',
    lazy = false,

    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'mail', 'diff', 'gitsendemail' }, -- updated to include .diff and .patch
        callback = function()
          if vim.b.mail_syntax_loaded then
            return
          end
          vim.b.mail_syntax_loaded = true

          -- Helper function to darken colors
          local function darken(hex, factor)
            if not hex then
              return nil
            end
            local h = hex:gsub('^#', '')
            if #h ~= 6 then
              return nil
            end

            local r = tonumber(h:sub(1, 2), 16)
            local g = tonumber(h:sub(3, 4), 16)
            local b = tonumber(h:sub(5, 6), 16)

            r = math.floor(r * factor + 0.5)
            g = math.floor(g * factor + 0.5)
            b = math.floor(b * factor + 0.5)

            return string.format('#%02x%02x%02x', r, g, b)
          end

          vim.schedule(function()
            local factor = 0.65

            -- Your custom colorscheme colors for normal diffs
            local colors = {
              added = '#5C898B', -- dark_green
              removed = '#e35c5c', -- global_red
              changed = '#567CC6', -- global_blue
              text = '#617B85', -- greyish_green_riogu
              file = '#5E6A83', -- even_softer_grey_highlight
              index = '#6F7D9A', -- even_even_softer_grey_highlight
              newfile = '#589A8F', -- string_green
            }

            local comment = '#8897B6'

            -- Load base mail syntax
            vim.cmd [[runtime! syntax/mail.vim]]

            -- Clear any existing diff syntax
            pcall(vim.cmd, [[syntax clear diffAdded]])
            pcall(vim.cmd, [[syntax clear diffRemoved]])
            pcall(vim.cmd, [[syntax clear diffLine]])
            pcall(vim.cmd, [[syntax clear diffFile]])
            pcall(vim.cmd, [[syntax clear diffNewFile]])
            pcall(vim.cmd, [[syntax clear diffIndexLine]])

            -- Define NORMAL (non-quoted) diff patterns with FULL colors
            vim.cmd [[
              syntax match diffAdded "^+[^+].*$"
              syntax match diffRemoved "^-[^-].*$"
              syntax match diffLine "^@@.*@@.*$"
              syntax match diffFile "^---\s.*$"
              syntax match diffNewFile "^+++\s.*$"
              syntax match diffIndexLine "^\(diff\|index\)\s.*$"
            ]]

            -- Set FULL bright colors for normal diffs
            vim.api.nvim_set_hl(0, 'diffAdded', { fg = colors.added })
            vim.api.nvim_set_hl(0, 'diffRemoved', { fg = colors.removed })
            vim.api.nvim_set_hl(0, 'diffLine', { fg = colors.text })
            vim.api.nvim_set_hl(0, 'diffFile', { fg = colors.file })
            vim.api.nvim_set_hl(0, 'diffNewFile', { fg = colors.newfile })
            vim.api.nvim_set_hl(0, 'diffIndexLine', { fg = colors.index })

            -- Define quoted regions
            vim.cmd [[
              syntax region mailQuoted1 start="^>" end="$" contains=mailQuotedDiff keepend
              syntax region mailQuoted2 start="^>>" end="$" contained contains=mailQuotedDiff keepend
              syntax region mailQuoted3 start="^>>>" end="$" contained contains=mailQuotedDiff keepend
            ]]

            -- Define QUOTED diff patterns (inside replies)
            vim.cmd [[
              syntax match mailQuotedDiffAdded "^>\+\s*+[^+].*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
              syntax match mailQuotedDiffRemoved "^>\+\s*-[^-].*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
              syntax match mailQuotedDiffLine "^>\+\s*@@.*@@.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
              syntax match mailQuotedDiffFile "^>\+\s*---\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
              syntax match mailQuotedDiffNewFile "^>\+\s*+++\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
              syntax match mailQuotedDiffIndex "^>\+\s*\(diff\|index\)\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
            ]]

            -- Set DARKENED colors for quoted diffs
            vim.api.nvim_set_hl(0, 'mailQuoted1', { fg = darken(comment, 1.0) })
            vim.api.nvim_set_hl(0, 'mailQuoted2', { fg = darken(comment, 0.85) })
            vim.api.nvim_set_hl(0, 'mailQuoted3', { fg = darken(comment, 0.7) })

            vim.api.nvim_set_hl(0, 'mailQuotedDiffAdded', { fg = darken(colors.added, factor) })
            vim.api.nvim_set_hl(0, 'mailQuotedDiffRemoved', { fg = darken(colors.removed, factor) })
            vim.api.nvim_set_hl(0, 'mailQuotedDiffLine', { fg = darken(colors.text, factor) })
            vim.api.nvim_set_hl(0, 'mailQuotedDiffFile', { fg = darken(colors.file, factor) })
            vim.api.nvim_set_hl(0, 'mailQuotedDiffNewFile', { fg = darken(colors.newfile, factor) })
            vim.api.nvim_set_hl(0, 'mailQuotedDiffIndex', { fg = darken(colors.index, factor) })

            -- Mail settings
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
            vim.opt_local.textwidth = 72
          end)
        end,
      })
    end,
  },
}
