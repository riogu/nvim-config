-- Mail syntax highlighting configuration

-- Setup all mail coloring
local function setup_mail_colors(bufnr, colors, quote_colors)
	-- Contained code-highlighting patterns, layered onto diff +/- lines so
	-- pasted code reads like code instead of one flat diff color. These stay
	-- full brightness no matter how deep the quote nesting is -- code should
	-- be equally readable whether it's a fresh patch or three replies deep;
	-- only plain quoted prose (mailQuoted1/2/3 below) fades with depth.
	-- Keyword lists are cheap (hash lookup, not regex); the dropped generic
	-- "\w\+_t" type-suffix match was the priciest pattern here since it has
	-- to be tried against every word on every diff line, so it's left out.
	vim.cmd([[
    syntax keyword mailCodeKeyword contained if else for while do return static const struct typedef union enum switch case default break continue goto sizeof void inline extern volatile register class public private protected virtual template namespace using new delete this true false nullptr NULL
    syntax keyword mailCodeType contained int char float double long short unsigned signed bool size_t ssize_t wchar_t uint8_t uint16_t uint32_t uint64_t int8_t int16_t int32_t int64_t
    syntax match mailCodeConstant "\C\<[A-Z][A-Z0-9_]\{2,\}\>" contained
    syntax match mailCodeString "\"[^\"]*\"" contained
    syntax match mailCodeString "'[^']*'" contained
    syntax match mailCodeComment "/\*.\{-}\*/" contained
    syntax match mailCodeComment "//.*$" contained
    syntax match mailCodeNumber "\<[0-9]\+\>" contained
  ]])

	vim.api.nvim_set_hl(0, "mailCodeKeyword", { fg = colors.code_keyword })
	vim.api.nvim_set_hl(0, "mailCodeType", { fg = colors.code_type })
	vim.api.nvim_set_hl(0, "mailCodeConstant", { fg = colors.code_constant })
	vim.api.nvim_set_hl(0, "mailCodeString", { fg = colors.code_string })
	vim.api.nvim_set_hl(0, "mailCodeComment", { fg = colors.code_comment })
	vim.api.nvim_set_hl(0, "mailCodeNumber", { fg = colors.code_number })

	local mail_code_contains =
		"mailCodeKeyword,mailCodeType,mailCodeConstant,mailCodeString,mailCodeComment,mailCodeNumber"

	-- Define NORMAL (non-quoted) diff patterns
	-- (built with .. rather than :format() since the quoted patterns below
	-- contain literal '%' from vim's \%(...\) regex syntax)
	vim.cmd(
		'syntax match diffAdded "^+[^+].*$" contains=' .. mail_code_contains .. "\n"
			.. 'syntax match diffRemoved "^-[^-].*$" contains='
			.. mail_code_contains
			.. [[

    syntax match diffLine "^@@.*@@.*$"
    syntax match diffFile "^---\s.*$"
    syntax match diffNewFile "^+++\s.*$"
    syntax match diffIndexLine "^\(diff\|index\)\s.*$"
  ]]
	)

	vim.api.nvim_set_hl(0, "diffAdded", { fg = colors.added })
	vim.api.nvim_set_hl(0, "diffRemoved", { fg = colors.removed })
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

	-- Define QUOTED diff patterns, reusing the same diffAdded/diffRemoved/...
	-- groups (and the same full-brightness code contains) as the bare
	-- patterns above -- quoted diff/code is colored identically to unquoted.
	-- The leading-'>' prefix must tolerate spaces between arrows ("> >",
	-- ">> >", ...) same as the mailQuoted regions above, otherwise diffs
	-- nested under a reply never get diff/code coloring at all and just
	-- fall back to flat mailQuoted2/3 text.
	vim.cmd(
		'syntax match diffAdded "^>\\%(\\s*>\\)*\\s*+[^+].*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3 contains='
			.. mail_code_contains
			.. "\n"
			.. 'syntax match diffRemoved "^>\\%(\\s*>\\)*\\s*-[^-].*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3 contains='
			.. mail_code_contains
			.. [[

    syntax match diffLine "^>\%(\s*>\)*\s*@@.*@@.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffFile "^>\%(\s*>\)*\s*---\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffNewFile "^>\%(\s*>\)*\s*+++\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
    syntax match diffIndexLine "^>\%(\s*>\)*\s*\(diff\|index\)\s.*$" contained containedin=mailQuoted1,mailQuoted2,mailQuoted3
  ]]
	)

	-- Match the depth gradient used by the aerc delta-colorize filter for
	-- plain quoted prose. Diff/code lines (above) intentionally ignore this
	-- and always render at full brightness.
	vim.api.nvim_set_hl(0, "mailQuoted1", { fg = quote_colors[1] })
	vim.api.nvim_set_hl(0, "mailQuoted2", { fg = quote_colors[2] })
	vim.api.nvim_set_hl(0, "mailQuoted3", { fg = quote_colors[3] })
end

-- Setup autocmd (only once)
local augroup = vim.api.nvim_create_augroup("MailSyntaxHighlight", { clear = true })
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
					added = "#589A8F",
					removed = "#e35c5c",
					changed = "#567CC6",
					text = "#617B85",
					file = "#5E6A83",
					index = "#6F7D9A",
					newfile = "#589A8F",
					code_keyword = "#8EA3D9",
					code_type = "#FCBF55",
					code_string = "#5ABCAC",
					code_comment = "#5E6A83",
					code_number = "#E0B4BB",
					code_constant = "#7A8BB8",
				}

				-- Same gradient as the aerc delta-colorize filter's quote1..quote3
				-- quote_colors[1] matches mailQuoted1Marker below, so the whole
				-- depth-1 line (arrow and text) reads as one consistent color.
				local quote_colors = { "#9CD1FF", "#7A8BB8", "#6F7D9A" }

				-- Use the "markdown" filetype (for wrap/preview via mdpls) when its
				-- parser is installed, but skip treesitter highlighting and the
				-- bundled markdown.vim/mail.vim syntax files entirely. Both are
				-- heavy on large patch emails -- treesitter re-parses on every
				-- scroll, and markdown.vim's regex regions for bold/italic/etc.
				-- were also mis-tagging code like "__dynamic_cast" as italic since
				-- they weren't part of what got nulled out below. Our own
				-- lightweight :syntax rules are the only thing that needs to run
				-- here. Setting filetype=markdown auto-loads syntax/markdown.vim
				-- *and* auto-starts treesitter (nvim's bundled ftplugin/markdown.lua
				-- calls vim.treesitter.start() unconditionally) as side effects, so
				-- both get undone explicitly right after.
				local use_markdown = pcall(vim.treesitter.language.add, "markdown")
				if use_markdown then
					vim.bo[bufnr].filetype = "markdown"
					vim.treesitter.stop(bufnr)
				end

				vim.cmd("syntax clear")
				setup_mail_colors(bufnr, colors, quote_colors)

				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true
				vim.opt_local.textwidth = 72
			end, 50)
		end)
	end,
})
