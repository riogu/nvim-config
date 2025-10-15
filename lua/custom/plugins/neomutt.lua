-- ~/.config/nvim/lua/plugins/mail-syntax.lua
-- lazy.nvim plugin for mail syntax highlighting

return {
  {
    name = 'mail-reply-highlighting',
    dir = vim.fn.stdpath 'config',
    lazy = false,

    config = function()
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

      -- Setup all mail coloring
      local function setup_mail_colors(bufnr, factor, colors, comment)
        -- Define NORMAL (non-quoted) diff patterns
        vim.cmd [[
          syntax match diffAdded "^+[^+].*$"
          syntax match diffRemoved "^-[^-].*$"
          syntax match diffLine "^@@.*@@.*$"
          syntax match diffFile "^---\s.*$"
          syntax match diffNewFile "^+++\s.*$"
          syntax match diffIndexLine "^\(diff\|index\)\s.*$"
        ]]

        vim.api.nvim_set_hl(0, 'diffAdded', { fg = colors.added })
        vim.api.nvim_set_hl(0, 'diffRemoved', { fg = colors.removed })
        vim.api.nvim_set_hl(0, 'diffLine', { fg = colors.text })
        vim.api.nvim_set_hl(0, 'diffFile', { fg = colors.file })
        vim.api.nvim_set_hl(0, 'diffNewFile', { fg = colors.newfile })
        vim.api.nvim_set_hl(0, 'diffIndexLine', { fg = colors.index })

        -- Define quoted regions - markdown will use > as quotes, so we override
        -- NOTE: Changed region definitions to allow spaces between '>' characters
        vim.cmd [[
          " mailQuoted3: At least 3 '>' separated by 0 or more spaces. Matches things like '>>>', '> > >', '>> >' etc.
          syntax region mailQuoted3 start="^>\%(\s*>\)\{2,\}" end="$" keepend

          " mailQuoted2: Exactly 2 '>' separated by 0 or more spaces. Matches '>>', '> >'.
          " It must exclude the mailQuoted3 pattern, so we start it after the quoted3 block.
          syntax region mailQuoted2 start="^>\s*>" end="$" keepend contains=mailQuoted3

          " mailQuoted1: At least 1 '>', excluding the other patterns. Matches '>', '> '
          syntax region mailQuoted1 start="^>" end="$" keepend contains=mailQuoted2,mailQuoted3
        ]]

        -- Define QUOTED diff patterns - no change needed here, as it uses ^>\+\s* which already handles spaces
        vim.cmd [[
          syntax match mailQuotedDiffAdded "^>\+\s*+[^+].*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
          syntax match mailQuotedDiffRemoved "^>\+\s*-[^-].*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
          syntax match mailQuotedDiffLine "^>\+\s*@@.*@@.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
          syntax match mailQuotedDiffFile "^>\+\s*---\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
          syntax match mailQuotedDiffNewFile "^>\+\s*+++\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
          syntax match mailQuotedDiffIndex "^>\+\s*\(diff\|index\)\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
        ]]

        vim.api.nvim_set_hl(0, 'mailQuoted1', { fg = darken(comment, 1.0) })
        vim.api.nvim_set_hl(0, 'mailQuoted2', { fg = darken(comment, 0.85) })
        vim.api.nvim_set_hl(0, 'mailQuoted3', { fg = darken(comment, 0.7) })

        vim.api.nvim_set_hl(0, 'mailQuotedDiffAdded', { fg = darken(colors.added, factor) })
        vim.api.nvim_set_hl(0, 'mailQuotedDiffRemoved', { fg = darken(colors.removed, factor) })
        vim.api.nvim_set_hl(0, 'mailQuotedDiffLine', { fg = darken(colors.text, factor) })
        vim.api.nvim_set_hl(0, 'mailQuotedDiffFile', { fg = darken(colors.file, factor) })
        vim.api.nvim_set_hl(0, 'mailQuotedDiffNewFile', { fg = darken(colors.newfile, factor) })
        vim.api.nvim_set_hl(0, 'mailQuotedDiffIndex', { fg = darken(colors.index, factor) })
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'mail', 'diff', 'gitsendemail' },
        callback = function()
          if vim.b.mail_syntax_loaded then
            return
          end
          vim.b.mail_syntax_loaded = true

          vim.schedule(function()
            vim.defer_fn(function()
              local bufnr = vim.api.nvim_get_current_buf()
              local factor = 0.65

              local colors = {
                added = '#5C898B',
                removed = '#e35c5c',
                changed = '#567CC6',
                text = '#617B85',
                file = '#5E6A83',
                index = '#6F7D9A',
                newfile = '#589A8F',
              }

              local comment = '#8897B6'

              -- Check if treesitter is available and markdown parser exists
              local has_ts, ts_parsers = pcall(require, 'nvim-treesitter.parsers')
              local use_markdown = has_ts and ts_parsers.has_parser 'markdown'

              if use_markdown then
                -- FIRST: Set up highlight overrides BEFORE changing filetype
                -- This ensures our highlights take priority
                local ns = vim.api.nvim_create_namespace 'mail_syntax_override'

                -- Override all markdown treesitter highlights to be invisible/normal
                local markdown_groups = {
                  '@spell.markdown',
                  '@text.markdown',
                  '@none.markdown',
                  '@markup.quote.markdown',
                  '@markup.quote',
                  '@markup.heading.1.markdown',
                  '@markup.heading.2.markdown',
                  '@markup.heading.3.markdown',
                  '@markup.heading.4.markdown',
                  '@markup.heading.5.markdown',
                  '@markup.heading.6.markdown',
                  '@markup.heading.markdown',
                  '@markup.list.markdown',
                  '@markup.list',
                  '@markup.link.markdown',
                  '@markup.link.label.markdown',
                  '@markup.link.url.markdown',
                  '@markup.raw.markdown_inline',
                  '@markup.raw.block.markdown',
                  '@markup.italic.markdown',
                  '@markup.strong.markdown',
                  '@markup.strikethrough.markdown',
                  'markdownH1',
                  'markdownH2',
                  'markdownH3',
                  'markdownH4',
                  'markdownH5',
                  'markdownH6',
                  'markdownHeadingDelimiter',
                  'markdownRule',
                  'markdownListMarker',
                  'markdownOrderedListMarker',
                  'markdownBlockquote',
                  'markdownLinkText',
                  'markdownUrl',
                  'markdownLink',
                }

                for _, group in ipairs(markdown_groups) do
                  vim.api.nvim_set_hl(0, group, { fg = 'NONE', bg = 'NONE', default = false })
                end

                -- SECOND: Change filetype to markdown
                vim.bo[bufnr].filetype = 'markdown'

                -- THIRD: Start treesitter (this will handle code blocks)
                vim.defer_fn(function()
                  pcall(vim.treesitter.start, bufnr, 'markdown')

                  -- FOURTH: Apply our mail syntax patterns on top
                  -- Use priority to ensure our patterns win
                  vim.cmd [[syntax clear]]

                  -- Re-apply markdown syntax but only for code blocks
                  vim.cmd [[runtime! syntax/markdown.vim]]

                  -- Now override with our patterns at high priority
                  setup_mail_colors(bufnr, factor, colors, comment)

                  -- Reapply highlight overrides after syntax loads
                  for _, group in ipairs(markdown_groups) do
                    vim.api.nvim_set_hl(0, group, { fg = 'NONE', bg = 'NONE', default = false })
                  end

                  -- Mail settings
                  vim.opt_local.wrap = true
                  vim.opt_local.linebreak = true
                  vim.opt_local.textwidth = 72
                end, 100)
              else
                -- Fallback to original mail syntax without code blocks
                vim.cmd 'syntax clear'
                vim.cmd [[runtime! syntax/mail.vim]]

                setup_mail_colors(bufnr, factor, colors, comment)

                -- Mail settings
                vim.opt_local.wrap = true
                vim.opt_local.linebreak = true
                vim.opt_local.textwidth = 72
              end
            end, 50)
          end)
        end,
      })
    end,
  },
}
