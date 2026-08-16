-- Mail syntax highlighting configuration

-- Setup all mail coloring
-- Code-token colors and diffAdded/diffRemoved's own fg tint used to live
-- here, applied via :syntax regex. Both are superseded now that
-- mail-paint.lua parses hunk bodies with the real cpp treesitter grammar
-- and paints backgrounds via extmarks (enabled per-buffer at the bottom of
-- this file) -- extmarks render above :syntax regardless, so keeping the
-- regex versions around would just be wasted work on every redraw for
-- output nothing shows. What's left here is what mail-paint doesn't touch:
-- quote-depth prose coloring and the non-"@@" structural diff lines
-- ("diff --git"/"index"/"---"/"+++").
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

	-- Define quoted regions. mailQuoted1Marker must be defined FIRST: when
	-- several matches start at the same column, vim gives priority to
	-- whichever was defined *last* (:help :syn-priority), so defining it
	-- ahead of mailQuoted2/mailQuoted3 lets those regions (which only match
	-- when a second '>' is actually present) take over the whole line
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

	-- Same blue as mailQuoted1 itself (set below) so the arrow doesn't stand
	-- out on its own -- the whole depth-1 line reads as one consistent color,
	-- making the reply you're actually responding to spottable at a glance.
	vim.api.nvim_set_hl(0, "mailQuoted1Marker", { fg = "#9CD1FF" })

	-- Define QUOTED variants of the structural diff lines, reusing the same
	-- diffLine/diffFile/diffNewFile/diffIndexLine groups as the bare
	-- patterns above. The leading-'>' prefix must tolerate spaces between
	-- arrows ("> >", ">> >", ...) same as the mailQuoted regions above,
	-- otherwise a hunk header nested under a reply never gets colored and
	-- just falls back to flat mailQuoted2/3 text.
	vim.cmd([[
    syntax match diffLine "^>\%(\s*>\)*\s*@@.*@@.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffFile "^>\%(\s*>\)*\s*---\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffNewFile "^>\%(\s*>\)*\s*+++\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffIndexLine "^>\%(\s*>\)*\s*\(diff\|index\)\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
  ]])

	-- Match the depth gradient used by the aerc delta-colorize filter for
	-- plain quoted prose. Diff/code lines (above) intentionally ignore this
	-- and always render at full brightness.
	vim.api.nvim_set_hl(0, "mailQuoted1", { fg = quote_colors[1] })
	vim.api.nvim_set_hl(0, "mailQuoted2", { fg = quote_colors[2] })
	vim.api.nvim_set_hl(0, "mailQuoted3", { fg = quote_colors[3] })
end

-- Setup autocmd (only once)
local augroup = vim.api.nvim_create_augroup("MailSyntaxHighlight", { clear = true })

-- aerc's [viewer] pager pipes the message straight into nvim's stdin with
-- no filename and (per aerc-config(5): "if show-headers is enabled, only
-- the currently viewed part body is piped") no From:/To:/Subject: header
-- lines when show-headers=false, the default -- there's nothing for
-- Neovim's own filetype heuristics to key off, so the FileType autocmd
-- below never fires for it (composing works because edit-headers=true
-- means the temp .eml file the editor opens DOES have header lines/a
-- recognized extension). Detect a diff/patch shape directly from content
-- on stdin and set filetype ourselves, which is what actually triggers
-- the FileType event this file listens for.
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

				-- Same gradient as the aerc delta-colorize filter's quote1..quote3
				-- quote_colors[1] matches mailQuoted1Marker below, so the whole
				-- depth-1 line (arrow and text) reads as one consistent color.
				local quote_colors = { "#9CD1FF", "#7A8BB8", "#6F7D9A" }

				-- Buffers keep their native filetype (mail/diff/gitsendemail) now
				-- -- no more forcing "markdown" to get wrap/mdpls-preview. None of
				-- these three filetypes auto-start treesitter via a bundled
				-- ftplugin (markdown's did, which is what made that workaround
				-- necessary in the first place), so there's nothing to stop here.
				-- syntax clear still matters: Neovim auto-loads syntax/mail.vim,
				-- syntax/diff.vim, or syntax/gitsendemail.vim for these filetypes
				-- before this callback runs, and we want only our own rules active.
				vim.cmd("syntax clear")
				setup_mail_colors(bufnr, colors, quote_colors)
				require("config.mail-paint").enable_live(bufnr)

				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true
				vim.opt_local.textwidth = 72

				-- One fold per file section ("diff --git" up to the next one).
				-- foldlevel=99 keeps folds available without auto-closing any of
				-- them on open, since folds aren't part of the normal workflow here
				-- -- just a tool for when they're wanted.
				vim.opt_local.foldmethod = "expr"
				vim.opt_local.foldexpr = "v:lua.require'config.mail-segment'.foldexpr()"
				vim.opt_local.foldlevel = 99

				-- ]1/[1 jump to the next/previous reply with no ">>>" at all
				-- (depth 0 -- the most recent reply in the thread); ]2/[2 jump
				-- one quote level back (depth 1), ]3/[3 two levels back, and so
				-- on, mirroring gitsigns' ]c/[c UX but keyed by depth instead of
				-- just "next comment in document order" (document order jumps
				-- into older, more-quoted replies just as readily as newer ones,
				-- which isn't what's wanted here). Mostly a no-op on a bare
				-- .patch buffer (no quoting to interrupt), which is expected.
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
