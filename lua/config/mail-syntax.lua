-- Mail syntax highlighting: quote-depth prose coloring and the non-"@@"
-- structural diff lines ("diff --git"/"index"/"---"/"+++"). Everything
-- else (code tokens, diff backgrounds, @@ hunk headers) is painted by
-- mail-paint.lua via extmarks, which render above :syntax regardless.
local function setup_mail_colors(bufnr, colors, quote_colors)
	-- (built with .. rather than :format() since the quoted patterns below
	-- contain literal '%' from vim's \%(...\) regex syntax)
	vim.cmd([[
    syntax match diffLine "^@@.*@@.*$"
    syntax match diffFile "^---\s.*$"
    syntax match diffNewFile "^+++\s.*$"
    syntax match diffIndexLine "^\(diff\|index\)\s.*$"
  ]])

	vim.api.nvim_set_hl(0, "diffLine", { fg = colors.text })
	vim.api.nvim_set_hl(0, "diffFile", { fg = colors.file })
	vim.api.nvim_set_hl(0, "diffNewFile", { fg = colors.newfile })
	vim.api.nvim_set_hl(0, "diffIndexLine", { fg = colors.index })

	-- mailQuoted1Marker must be defined FIRST: when several matches start
	-- at the same column, vim gives priority to whichever was defined
	-- *last* (:help :syn-priority), so defining it ahead of
	-- mailQuoted2/mailQuoted3 lets those regions take over the whole line
	-- wherever they apply, leaving the marker to show through only on
	-- genuine depth-1 lines.
	vim.cmd([[
    syntax match mailQuoted1Marker "^>" contained containedin=mailQuoted1

    " mailQuoted3: At least 3 '>' separated by 0 or more spaces
    syntax region mailQuoted3 start="^>\%(\s*>\)\{2,\}" end="$" keepend

    " mailQuoted2: Exactly 2 '>' separated by 0 or more spaces
    syntax region mailQuoted2 start="^>\s*>" end="$" keepend contains=mailQuoted3

    " mailQuoted1: At least 1 '>'
    syntax region mailQuoted1 start="^>" end="$" keepend contains=mailQuoted2,mailQuoted3
  ]])

	-- Same blue as mailQuoted1 itself so the arrow doesn't stand out on its
	-- own -- the whole depth-1 line reads as one consistent color.
	vim.api.nvim_set_hl(0, "mailQuoted1Marker", { fg = "#9CD1FF" })

	-- Quoted variants of the structural diff lines above, reusing the same
	-- groups. The leading-'>' prefix must tolerate spaces between arrows
	-- ("> >", ">> >", ...) same as the mailQuoted regions, otherwise a
	-- hunk header nested under a reply never gets colored.
	vim.cmd([[
    syntax match diffLine "^>\%(\s*>\)*\s*@@.*@@.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffFile "^>\%(\s*>\)*\s*---\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffNewFile "^>\%(\s*>\)*\s*+++\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffIndexLine "^>\%(\s*>\)*\s*\(diff\|index\)\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
  ]])

	-- Match the depth gradient used by the aerc delta-colorize filter for
	-- plain quoted prose. Diff/code lines (above) always render at full
	-- brightness regardless of depth.
	vim.api.nvim_set_hl(0, "mailQuoted1", { fg = quote_colors[1] })
	vim.api.nvim_set_hl(0, "mailQuoted2", { fg = quote_colors[2] })
	vim.api.nvim_set_hl(0, "mailQuoted3", { fg = quote_colors[3] })
end

local augroup = vim.api.nvim_create_augroup("MailSyntaxHighlight", { clear = true })

-- aerc's [viewer] pager pipes the message into nvim's stdin with no
-- filename and (show-headers=false, the default) no header lines --
-- nothing for Neovim's own filetype heuristics to key off, so the
-- FileType autocmd below never fires on its own. Detect a diff/patch
-- shape directly from content and set filetype ourselves to trigger it.
-- (Composing works without this since edit-headers=true gives the editor
-- a temp .eml file with real headers.)
vim.api.nvim_create_autocmd("StdinReadPost", {
	group = augroup,
	callback = function(args)
		if vim.bo[args.buf].filetype ~= "" then
			return
		end
		for _, line in ipairs(vim.api.nvim_buf_get_lines(args.buf, 0, 40, false)) do
			if
				line:match("^diff %-%-git ")
				or line:match("^@@ %-")
				or line:match("^From ")
				or line:match("^Subject: ")
				or line:match("^>%s*diff %-%-git ")
				or line:match("^>%s*@@ %-")
			then
				vim.bo[args.buf].filetype = "mail"
				return
			end
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "mail", "diff", "gitsendemail" },
	callback = function()
		if vim.b.mail_syntax_loaded then
			return
		end
		vim.b.mail_syntax_loaded = true

		vim.schedule(function()
			vim.defer_fn(function()
				local bufnr = vim.api.nvim_get_current_buf()

				local colors = {
					text = "#617B85",
					file = "#5E6A83",
					index = "#6F7D9A",
					newfile = "#589A8F",
				}
				-- Same gradient as the aerc delta-colorize filter's
				-- quote1..quote3; quote_colors[1] matches mailQuoted1Marker.
				local quote_colors = { "#9CD1FF", "#7A8BB8", "#6F7D9A" }

				-- syntax clear: Neovim auto-loads syntax/mail.vim,
				-- syntax/diff.vim, or syntax/gitsendemail.vim for these
				-- filetypes before this callback runs; only our own rules
				-- should be active.
				vim.cmd("syntax clear")
				setup_mail_colors(bufnr, colors, quote_colors)
				require("config.mail-paint").enable_live(bufnr)

				-- Not forcing wrap/linebreak here -- respect whatever the
				-- user has set globally (options.lua sets wrap=false).
				vim.opt_local.textwidth = 72

				-- One fold per file section ("diff --git" up to the next
				-- one). foldlevel=99 keeps folds available without
				-- auto-closing any of them on open.
				vim.opt_local.foldmethod = "expr"
				vim.opt_local.foldexpr = "v:lua.require'config.mail-segment'.foldexpr()"
				vim.opt_local.foldlevel = 99

				-- ]1/[1 jump to the next/previous reply with no ">>>" at
				-- all (depth 0, the most recent reply); ]2/[2 jump one
				-- quote level back, and so on -- mirrors gitsigns' ]c/[c
				-- but keyed by depth rather than document order, so it
				-- doesn't jump into older, more-quoted replies just as
				-- readily as newer ones.
				local mail_segment = require("config.mail-segment")
				for n = 1, 9 do
					local depth = n - 1
					vim.keymap.set("n", "]" .. n, function()
						mail_segment.jump_to_reply(bufnr, 1, depth)
					end, { buffer = bufnr, desc = "Next mail reply (depth " .. depth .. ")" })
					vim.keymap.set("n", "[" .. n, function()
						mail_segment.jump_to_reply(bufnr, -1, depth)
					end, { buffer = bufnr, desc = "Previous mail reply (depth " .. depth .. ")" })
				end
			end, 50)
		end)
	end,
})
