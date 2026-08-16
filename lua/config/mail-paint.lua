-- Step 2 of the "real C++ inside diffs" rework: for every "code" segment
-- found by mail-segment.lua, strip the quote/diff-marker prefixes, parse
-- the payload with the real cpp treesitter grammar, and project the
-- resulting highlight captures back onto the buffer as extmarks.
--
-- Deliberately NOT wired into any FileType autocmd yet -- drive it
-- manually or via :MailPaintDebug to validate against real threads before
-- this replaces the regex-based code coloring in mail-syntax.lua.

local segment = require("config.mail-segment")

local M = {}

local ns = vim.api.nvim_create_namespace("mail_paint_cpp")

-- Same values as ~/.gitconfig's [delta]/[color "diff"] sections, so this
-- reads identically to the aerc delta-colorize pager.
local HIGHLIGHTS_DEFINED = false
local function ensure_highlights()
	if HIGHLIGHTS_DEFINED then
		return
	end
	HIGHLIGHTS_DEFINED = true
	-- Full-row tints for +/- lines (delta's plus-style/minus-style).
	vim.api.nvim_set_hl(0, "MailDiffAddedBg", { bg = "#2a3a35" })
	vim.api.nvim_set_hl(0, "MailDiffRemovedBg", { bg = "#3a2f32" })
	-- Hunk-range accent ("@@ -A,B +C,D @@", delta's hunk-header-style).
	-- No background -- real delta's own rendering is text-only here, no
	-- loud wash -- underlined instead, same restrained treatment as the
	-- file-section marker below. Underline is scoped to just the range
	-- spec (not the trailing function-context, which gets real cpp
	-- captures at higher priority that would otherwise fully override --
	-- not merge with -- this underline for whatever they cover).
	vim.api.nvim_set_hl(0, "MailHunkHeader", { fg = "#567CC6", bold = true, underline = true })
	-- The "-A,B" / "+C,D" range numbers inside the header (delta's
	-- line-numbers-minus-style/line-numbers-plus-style).
	vim.api.nvim_set_hl(0, "MailHunkRangeMinus", { fg = "#e35c5c", bold = true, underline = true })
	vim.api.nvim_set_hl(0, "MailHunkRangePlus", { fg = "#589A8F", bold = true, underline = true })
	-- File-section marker ("diff --git a/x b/x"): delta collapses this
	-- plus "index .../"---"/"+++" into one "Δ path" line, styled per
	-- file-style/file-decoration-style in ~/.gitconfig (bold, underlined,
	-- yellow). We can't hide the raw lines the way delta rewrites its
	-- output, so this is the closest single-line equivalent.
	vim.api.nvim_set_hl(0, "MailFileHeader", { fg = "#FCBF55", bold = true, underline = true })
	-- Diffstat bar ("path/to/file.cc | 69 ++++++++----") and the
	-- "N files changed, X insertions(+), Y deletions(-)" summary: same
	-- green/red as the diff line backgrounds, applied per-character to
	-- just the +/- runs.
	vim.api.nvim_set_hl(0, "MailDiffstatPlus", { fg = "#589A8F" })
	vim.api.nvim_set_hl(0, "MailDiffstatMinus", { fg = "#e35c5c" })
end

-- Neovim's own vim.treesitter.highlighter resolves overlapping captures at
-- the same span by priority: default vim.hl.priorities.treesitter (100),
-- shifted by whatever a query pattern sets via (#set! "priority" N) --
-- e.g. the cpp query deliberately drops generic "@variable" to 95 so a
-- more specific overlapping capture like "@constant" (default 100) wins.
-- Mirror that here, offset onto our own base so it still sits above the
-- diff-bg tints (100) and below nothing else we set.
local CAPTURE_BASE_PRIORITY = 200
local TS_DEFAULT_PRIORITY = vim.hl.priorities.treesitter
local function capture_priority(metadata, capture)
	local explicit = metadata.priority or (metadata[capture] and metadata[capture].priority)
	local n = tonumber(explicit)
	if not n then
		return CAPTURE_BASE_PRIORITY
	end
	return CAPTURE_BASE_PRIORITY + (n - TS_DEFAULT_PRIORITY)
end

-- Split one leading diff-marker char (+/-/space) off an already
-- quote-stripped payload. Returns marker ("+", "-", " ", or nil if the
-- line has no diff marker at all) and the remaining code text.
local function strip_diff_marker(payload)
	local marker = payload:sub(1, 1)
	if marker == "+" or marker == "-" or marker == " " then
		return marker, payload:sub(2)
	end
	return nil, payload
end

-- A quoted "+"/"-" line whose content is long enough (a wordy comment, a
-- long string) can get soft-wrapped by an intermediate mail client before
-- it reaches the reader -- the continuation lands on its own physical
-- line with the same quote-depth arrows but no diff marker, since the
-- wrapping client has no idea it's cutting a diff line in half. Rather
-- than treat that continuation as markerless/ambiguous, walk backward
-- within the segment for the nearest line that still has an explicit
-- marker and inherit it. Stops at a blank or structural line (a real
-- context/hunk boundary) rather than reaching across one.
local function find_marker_above(bufnr_lines, seg_start, lnum)
	for i = lnum, seg_start, -1 do
		local _, payload = segment.strip_quote(bufnr_lines[i])
		if payload:match("^%s*$") or segment.is_structural(payload) then
			return nil
		end
		local marker = strip_diff_marker(payload)
		if marker then
			return marker
		end
	end
	return nil
end

-- Build one side's ("+"/context lines, or "-"/context lines) virtual
-- source text plus a per-virtual-row map back to real buffer positions.
-- side_marker is "+" or "-"; lines with the *other* marker are skipped
-- since they belong to a different version of the file and don't parse
-- as one coherent unit together.
local function build_side(bufnr_lines, start_line, end_line, side_marker)
	local other = (side_marker == "+") and "-" or "+"
	local virtual_lines = {}
	local row_map = {} -- virtual_lines[i] came from row_map[i] = {lnum, col_offset}

	for lnum = start_line, end_line do
		local raw = bufnr_lines[lnum]
		local _, payload = segment.strip_quote(raw)
		-- "diff --git"/"index"/"---"/"+++"/"@@" lines are diff bookkeeping,
		-- not source code -- classify_buffer treats them as "code" so
		-- quote-depth tracking flips into a hunk correctly, but feeding
		-- them to the cpp parser produces garbage (e.g. "diff --git a/x.cc
		-- b/x.cc" tokenizes as division operators). mail-syntax.lua's
		-- existing diffFile/diffIndexLine/diffLine groups already color
		-- these lines, so just skip them here.
		if not segment.is_structural(payload) then
			local marker, code = strip_diff_marker(payload)
			local effective = marker or find_marker_above(bufnr_lines, start_line, lnum - 1)
			if effective ~= other then
				local prefix_len = #raw - #code
				table.insert(virtual_lines, code)
				table.insert(row_map, { lnum = lnum, col_offset = prefix_len })
			end
		end
	end

	return table.concat(virtual_lines, "\n"), row_map
end

-- Parse `text` as cpp and set one extmark per highlight capture, with each
-- virtual (row, col) remapped to a real buffer position via map_fn(row,
-- col) -> lnum0, col (or nil to drop a capture that maps outside what the
-- caller tracked). Shared by paint_side (multi-line hunk body, row_map
-- table) and paint_hunk_header (single-line function-context fragment,
-- fixed offset).
local function paint_captures(bufnr, text, hl_query, map_fn)
	if text == "" then
		return
	end
	local parser = vim.treesitter.get_string_parser(text, "cpp")
	local trees = parser:parse()
	if not trees or not trees[1] then
		return
	end
	local root = trees[1]:root()

	for id, node, metadata in hl_query:iter_captures(root, text) do
		local capture_name = hl_query.captures[id]
		local srow, scol, erow, ecol = node:range()

		local start_lnum0, start_col = map_fn(srow, scol)
		local end_lnum0, end_col = map_fn(erow, ecol)
		-- Leading-"_" captures (e.g. "@_parent") are query-internal
		-- bookkeeping for predicates, not meant to be highlighted --
		-- vim.treesitter.highlighter skips these the same way.
		if start_lnum0 and end_lnum0 and not capture_name:match("^_") then
			vim.api.nvim_buf_set_extmark(bufnr, ns, start_lnum0, start_col, {
				end_row = end_lnum0,
				end_col = end_col,
				hl_group = "@" .. capture_name,
				priority = capture_priority(metadata, id),
			})
		end
	end
end

-- Captures spanning a virtual row not in row_map (shouldn't happen --
-- every source row has an entry) are dropped defensively.
local function paint_side(bufnr, text, row_map, hl_query)
	paint_captures(bufnr, text, hl_query, function(row, col)
		local m = row_map[row + 1]
		if not m then
			return nil
		end
		return m.lnum - 1, col + m.col_offset
	end)
end

-- "@@ -100,6 +100,20 @@ region_model::get_type_from_tinfo_arg (tree arg)":
-- accent the range spec (with the -A,B/+C,D counts picking up the same
-- red/green as the diff line backgrounds, delta's
-- line-numbers-minus/plus-style), then parse and paint the trailing
-- function context (if any) as its own tiny cpp fragment -- it's a real,
-- if incomplete, C++ declaration, same as delta highlights it.
local function paint_hunk_header(bufnr, lnum, raw, hl_query)
	local _, payload = segment.strip_quote(raw)
	local prefix_len = #raw - #payload
	local range_part, gap, context = payload:match("^(@@.-@@)(%s*)(.*)$")
	if not range_part then
		return
	end

	local pre, minus_nums, mid, plus_nums, post = range_part:match("^(@@%s*)%-([%d,]+)(%s+)%+([%d,]+)(%s*@@)$")
	if pre then
		local col = prefix_len
		local function emit(str, hl)
			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, col, {
				end_row = lnum - 1,
				end_col = col + #str,
				hl_group = hl,
				priority = 200,
			})
			col = col + #str
		end
		emit(pre, "MailHunkHeader")
		emit("-" .. minus_nums, "MailHunkRangeMinus")
		emit(mid, "MailHunkHeader")
		emit("+" .. plus_nums, "MailHunkRangePlus")
		emit(post, "MailHunkHeader")
	else
		-- Unexpected shape (rare/malformed hunk header) -- fall back to
		-- accenting the whole range as one span rather than dropping it.
		vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, prefix_len, {
			end_row = lnum - 1,
			end_col = prefix_len + #range_part,
			hl_group = "MailHunkHeader",
			priority = 200,
		})
	end

	if context ~= "" then
		local context_col_offset = prefix_len + #range_part + #gap
		paint_captures(bufnr, context, hl_query, function(row, col)
			if row ~= 0 then
				return nil
			end
			return lnum - 1, col + context_col_offset
		end)
	end
end

-- Tint the full row for a "+"/"-" diff line, extending past the last
-- character to the window edge like diffview/delta do -- NOT achievable
-- with hl_eol on a single-line mark (it's documented as only extending a
-- *multiline* highlight's last line; that's almost certainly the
-- "no good way to do this" wall from before). line_hl_group is the actual
-- mechanism: it rides the same full-width row-fill Vim has always given
-- `:sign define ... linehl=`, independent of hl_eol. I can't visually
-- confirm the render from here (no display in this session) -- if the
-- quote-arrow prefix on the left also ends up tinted rather than staying
-- clipped to just the diff-marker-onward span, that's line_hl_group being
-- whole-line by nature; the arrows keep their own foreground color either
-- way since these groups only set bg, so it should still read fine, but
-- worth checking.
-- lines/seg_start let this fall back to find_marker_above for a line that
-- lost its own marker to mail-client wrapping (see find_marker_above) --
-- same background as its unwrapped neighbor, just no marker-character
-- accent, since there's no literal +/- in the buffer there to color.
local function paint_diff_line_bg(bufnr, lines, seg_start, lnum)
	local raw = lines[lnum]
	local _, payload = segment.strip_quote(raw)
	local prefix_len = #raw - #payload
	local own_char = payload:sub(1, 1)
	-- A line's own marker is "+", "-", *or* " " (a genuine unchanged
	-- context line) -- all three mean it already has one and must never
	-- fall through to inheritance below. Only a character that's none of
	-- these (e.g. the first letter of a wrapped comment continuation) is
	-- a genuinely absent marker worth looking upward for.
	local own_marker = (own_char == "+" or own_char == "-" or own_char == " ") and own_char or nil
	local marker = own_marker or find_marker_above(lines, seg_start, lnum - 1)
	local hl_group = marker == "+" and "MailDiffAddedBg" or marker == "-" and "MailDiffRemovedBg" or nil
	if not hl_group then
		return
	end

	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, prefix_len, {
		line_hl_group = hl_group,
		end_row = lnum - 1,
		end_col = #raw,
		hl_eol = true,
		hl_group = hl_group,
		priority = 100,
	})

	-- The marker character itself, colored the same green/red as the
	-- diffstat bar -- it's stripped off before the rest of the line goes
	-- to the cpp parser, so nothing else ever colors it otherwise. Only
	-- for a line with a real +/- of its own -- not a context line's " "
	-- and not an inherited/wrapped one (nothing there to color).
	if own_marker == "+" or own_marker == "-" then
		local marker_hl = own_marker == "+" and "MailDiffstatPlus" or "MailDiffstatMinus"
		vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, prefix_len, {
			end_row = lnum - 1,
			end_col = prefix_len + 1,
			hl_group = marker_hl,
			priority = 200,
		})
	end
end

-- "diff --git a/x.cc b/x.cc": style it as the file-section marker (see
-- ensure_highlights), plus an inline "Δ " prefix to actually get the
-- glyph delta shows before its consolidated path line.
local function paint_file_header(bufnr, lnum, raw)
	local _, payload = segment.strip_quote(raw)
	local prefix_len = #raw - #payload
	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, prefix_len, {
		end_row = lnum - 1,
		end_col = #raw,
		hl_group = "MailFileHeader",
		virt_text = { { "Δ ", "MailFileHeader" } },
		virt_text_pos = "inline",
		priority = 200,
	})
end

-- "path/to/file.cc | 69 ++++++++----": color just the +/- run, leaving
-- the path/pipe/count in the default fg, matching delta's diffstat.
local function paint_diffstat_line(bufnr, lnum, raw)
	local _, payload = segment.strip_quote(raw)
	local prefix_len = #raw - #payload
	local head, plus, minus = payload:match("^(%s*[%w_./%-]+%s+|%s+%d+%s+)(%+*)(%-*)%s*$")
	if not head then
		return
	end
	local col = prefix_len + #head
	if #plus > 0 then
		vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, col, {
			end_row = lnum - 1,
			end_col = col + #plus,
			hl_group = "MailDiffstatPlus",
			priority = 200,
		})
		col = col + #plus
	end
	if #minus > 0 then
		vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, col, {
			end_row = lnum - 1,
			end_col = col + #minus,
			hl_group = "MailDiffstatMinus",
			priority = 200,
		})
	end
end

-- "8 files changed, 627 insertions(+), 37 deletions(-)": accent just the
-- (+)/(-) markers.
local function paint_diffstat_summary(bufnr, lnum, raw)
	local _, payload = segment.strip_quote(raw)
	local prefix_len = #raw - #payload
	local function accent(pat, hl)
		local s, e = payload:find(pat)
		if s then
			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, prefix_len + s - 1, {
				end_row = lnum - 1,
				end_col = prefix_len + e,
				hl_group = hl,
				priority = 200,
			})
		end
	end
	accent("%(%+%)", "MailDiffstatPlus")
	accent("%(%-%)", "MailDiffstatMinus")
end

local function get_hl_query()
	local ok = pcall(vim.treesitter.language.add, "cpp")
	if not ok then
		return nil
	end
	return vim.treesitter.query.get("cpp", "highlights")
end

-- Paint one "code" segment: real cpp tokens for both diff sides, plus the
-- diff-line backgrounds and hunk-header treatment for its lines. Shared by
-- the full-buffer path (paint_buffer) and the visible-window path
-- (paint_visible_range) below.
local function paint_segment(bufnr, lines, seg, hl_query)
	local new_text, new_map = build_side(lines, seg.start_line, seg.end_line, "+")
	paint_side(bufnr, new_text, new_map, hl_query)

	local old_text, old_map = build_side(lines, seg.start_line, seg.end_line, "-")
	paint_side(bufnr, old_text, old_map, hl_query)

	for lnum = seg.start_line, seg.end_line do
		local raw = lines[lnum]
		local _, payload = segment.strip_quote(raw)
		if segment.is_structural(payload) then
			-- "@@ ... @@" gets the hunk-range treatment; "diff --git"
			-- becomes the file-section marker; diffstat lines/summary get
			-- their +/- runs accented. "index"/"---"/"+++" are left
			-- alone, matching how delta consolidates them into the single
			-- file marker above and doesn't show them distinctly at all.
			if payload:match("^@@ ") then
				paint_hunk_header(bufnr, lnum, raw, hl_query)
			elseif payload:match("^diff %-%-git ") then
				paint_file_header(bufnr, lnum, raw)
			elseif segment.is_diffstat_line(payload) then
				paint_diffstat_line(bufnr, lnum, raw)
			elseif segment.is_diffstat_summary(payload) then
				paint_diffstat_summary(bufnr, lnum, raw)
			end
		else
			paint_diff_line_bg(bufnr, lines, seg.start_line, lnum)
		end
	end
end

-- Per-buffer cache: segments (from mail-segment.lua) plus the changedtick
-- they were computed from, so an edit invalidates it cheaply. Each segment
-- table gets a `.painted` flag mutated in place once paint_segment has run
-- for it, so re-entering an already-painted region (scrolling back up, a
-- second window on the same buffer) is a no-op instead of a re-parse.
local buffer_cache = {}

-- (Re)compute the segment list for `bufnr` if the buffer has changed since
-- last time, clearing stale extmarks first. Returns the current segments.
local function get_segments(bufnr)
	local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
	local cache = buffer_cache[bufnr]
	if cache and cache.changedtick == changedtick then
		return cache.segments
	end

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	local segments = segment.segment(bufnr)
	buffer_cache[bufnr] = { changedtick = changedtick, segments = segments }
	return segments
end

-- Paint every "code" segment in the buffer right now. Fine for manual/debug
-- use (:MailPaintDebug) -- for live use see paint_visible_range/enable_live
-- below, which only do this work for segments actually on screen.
function M.paint_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	ensure_highlights()
	local hl_query = get_hl_query()
	if not hl_query then
		return
	end

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local segments = segment.segment(bufnr)
	buffer_cache[bufnr] = { changedtick = vim.api.nvim_buf_get_changedtick(bufnr), segments = segments }

	for _, seg in ipairs(segments) do
		if seg.kind == "code" then
			paint_segment(bufnr, lines, seg, hl_query)
			seg.painted = true
		end
	end
end

-- Paint only the "code" segments intersecting [topline0, botline0]
-- (0-indexed, inclusive) that haven't been painted yet. This is what keeps
-- a long patch thread from re-parsing the whole buffer on every scroll --
-- the exact mistake that made treesitter+regex highlighting laggy earlier
-- in this buffer's history (see mail-syntax.lua's markdown/treesitter
-- notes). Meant to be driven by enable_live's decoration provider, not
-- called directly, though it's harmless to call by hand.
function M.paint_visible_range(bufnr, topline0, botline0)
	ensure_highlights()
	local hl_query = get_hl_query()
	if not hl_query then
		return
	end

	local segments = get_segments(bufnr)
	local top1, bot1 = topline0 + 1, botline0 + 1
	local lines -- fetched lazily, only if something in range actually needs painting

	for _, seg in ipairs(segments) do
		if seg.kind == "code" and not seg.painted and seg.end_line >= top1 and seg.start_line <= bot1 then
			lines = lines or vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			paint_segment(bufnr, lines, seg, hl_query)
			seg.painted = true
		end
	end
end

-- One decoration provider for the whole session, gated per buffer by
-- live_enabled -- nvim_set_decoration_provider replaces any previous
-- callback registered for this namespace, so it must only ever be called
-- once, not once per buffer.
local live_enabled = {}
local provider_registered = false

local function ensure_provider()
	if provider_registered then
		return
	end
	provider_registered = true

	vim.api.nvim_set_decoration_provider(ns, {
		-- Skip the provider entirely for redraws where no buffer has live
		-- painting on, rather than paying an on_win call per window.
		on_start = function()
			return next(live_enabled) ~= nil
		end,
		-- Real signature is (_, winid, bufnr, topline, botline); the first
		-- two are unused here, matching how vim.treesitter.highlighter's
		-- own _on_win ignores them too.
		on_win = function(_, _winid, bufnr, topline, botline)
			if live_enabled[bufnr] then
				M.paint_visible_range(bufnr, topline, botline)
			end
			return false -- we set marks per-segment already, no on_line needed
		end,
	})
end

-- Turn on live, scroll-scoped painting for `bufnr`.
function M.enable_live(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	live_enabled[bufnr] = true
	ensure_provider()
end

function M.disable_live(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	live_enabled[bufnr] = nil
	buffer_cache[bufnr] = nil
end

-- Don't let closed buffers linger in these tables for the life of the
-- session.
vim.api.nvim_create_autocmd("BufWipeout", {
	group = vim.api.nvim_create_augroup("MailPaintCleanup", { clear = true }),
	callback = function(args)
		live_enabled[args.buf] = nil
		buffer_cache[args.buf] = nil
	end,
})

vim.api.nvim_create_user_command("MailPaintDebug", function()
	M.paint_buffer(0)
end, { desc = "Paint real cpp treesitter highlights over code segments in the current buffer" })

vim.api.nvim_create_user_command("MailPaintClear", function()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	buffer_cache[bufnr] = nil
end, { desc = "Clear mail-paint extmarks in the current buffer" })

vim.api.nvim_create_user_command("MailPaintLive", function()
	M.enable_live(0)
end, { desc = "Enable scroll-scoped live cpp painting for the current buffer" })

vim.api.nvim_create_user_command("MailPaintLiveStop", function()
	M.disable_live(0)
end, { desc = "Disable live cpp painting for the current buffer" })

return M
