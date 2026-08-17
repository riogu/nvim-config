-- For every "code" segment mail-segment.lua identifies: strip the
-- quote/diff-marker prefixes, parse the payload with the real cpp
-- treesitter grammar, and project the resulting highlight captures back
-- onto the buffer as extmarks, plus diff-line backgrounds and header
-- styling. Painting is scroll-scoped (see enable_live) so a long thread
-- never re-parses more than what's on screen.

local segment = require("config.mail-segment")

local M = {}

local ns = vim.api.nvim_create_namespace("mail_paint_cpp")

-- Values matched to ~/.gitconfig's [delta]/[color "diff"] sections, so
-- this reads like the aerc delta-colorize pager did.
local HIGHLIGHTS_DEFINED = false
local function ensure_highlights()
	if HIGHLIGHTS_DEFINED then
		return
	end
	HIGHLIGHTS_DEFINED = true

	-- Full-row tints for +/- lines (delta's plus-style/minus-style).
	vim.api.nvim_set_hl(0, "MailDiffAddedBg", { bg = "#2a3a35" })
	vim.api.nvim_set_hl(0, "MailDiffRemovedBg", { bg = "#3a2f32" })

	-- Hunk-range accent ("@@ -A,B +C,D @@"). Underlined to end of line,
	-- including the trailing function-context text -- that part gets real
	-- cpp captures for its own fg color, so its underline comes from
	-- MailHunkHeaderUnderline stacked alongside each capture (see
	-- paint_captures' extra_hl) rather than a plain underlined group,
	-- since overlapping extmarks are winner-take-all per attribute, not
	-- additive.
	vim.api.nvim_set_hl(0, "MailHunkHeader", { fg = "#567CC6", bold = true, underline = false })
	vim.api.nvim_set_hl(0, "MailHunkRangeMinus", { fg = "#e35c5c", bold = true, underline = false })
	vim.api.nvim_set_hl(0, "MailHunkRangePlus", { fg = "#589A8F", bold = true, underline = false })
	vim.api.nvim_set_hl(0, "MailHunkHeaderUnderline", { sp = "#567CC6" })

	-- File-section marker ("diff --git a/x b/x"): delta collapses this
	-- plus index/---/+++ into one "Δ path" line (file-style in
	-- ~/.gitconfig). No bold: the "Δ" glyph and left-margin wash already
	-- carry the "boundary" signal.
	vim.api.nvim_set_hl(0, "MailFileHeader", { fg = "#567CC6", underline = true })

	-- Marker-only variants (no underline) for the "┃"/"Δ" glyphs -- an
	-- underlined glyph reads as a line drawn through the character.
	vim.api.nvim_set_hl(0, "MailFileHeaderMarker", { fg = "#567CC6", bold = true })
	vim.api.nvim_set_hl(0, "MailHunkHeaderMarker", { fg = "#567CC6", bold = true })

	-- Diffstat bar and "N files changed, ..." summary: same green/red as
	-- the diff line backgrounds, applied per-character to the +/- runs.
	vim.api.nvim_set_hl(0, "MailDiffstatPlus", { fg = "#589A8F" })
	vim.api.nvim_set_hl(0, "MailDiffstatMinus", { fg = "#e35c5c" })
	vim.api.nvim_set_hl(0, "MailCursorLine", { bg = "#3A4356" })

	-- Soft full-row wash across an entire header block (diff --git/index/
	-- ---/+++/@@ ... @@, whichever appear) -- editor bg blended ~12%
	-- toward hunk-header blue.
	vim.api.nvim_set_hl(0, "MailHeaderBlockBg", { bg = "#2C3038" })

	-- Top/bottom border closing off a header block (see paint_header_block_edge).
	vim.api.nvim_set_hl(0, "MailHeaderBlockBorder", { fg = "#567CC6" })
end

-- Neovim's own vim.treesitter.highlighter resolves overlapping captures by
-- priority: default vim.hl.priorities.treesitter (100), shifted by
-- whatever a query pattern sets via (#set! "priority" N). Mirror that
-- here, offset onto our own base so captures sit above the diff-bg tints
-- (100) and below nothing else we set.
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

-- Quote-strip `raw` and return (payload, prefix_len) -- the length of the
-- stripped quote prefix, i.e. where the real content starts in `raw`.
local function payload_and_prefix(raw)
	local _, payload = segment.strip_quote(raw)
	return payload, #raw - #payload
end

-- One extmark spanning [scol, ecol) on line `lnum` (1-indexed), plain
-- hl_group + priority -- the shape shared by every single-line accent
-- below (hunk range, diffstat runs, marker characters, ...).
local function mark(bufnr, lnum, scol, ecol, hl_group, priority)
	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, scol, {
		end_row = lnum - 1,
		end_col = ecol,
		hl_group = hl_group,
		priority = priority or 200,
	})
end

-- Full-row background fill via line_hl_group (the mechanism behind
-- `:sign ... linehl=`) -- unlike hl_eol on a single-line mark, this
-- extends the tint all the way to the window edge. text_hl optionally
-- also colors the [scol, ecol) span itself.
local function row_bg(bufnr, lnum, scol, ecol, line_hl, text_hl)
	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, scol, {
		line_hl_group = line_hl,
		end_row = lnum - 1,
		end_col = ecol,
		hl_eol = true,
		hl_group = text_hl,
		priority = 100,
	})
end

-- Split one leading diff-marker char (+/-/space) off a quote-stripped
-- payload. Returns marker ("+", "-", " ", or nil) and the remaining code.
local function strip_diff_marker(payload)
	local marker = payload:sub(1, 1)
	if marker == "+" or marker == "-" or marker == " " then
		return marker, payload:sub(2)
	end
	return nil, payload
end

-- A "diff --git a/x b/x" line missing its "b/" half: almost certainly an
-- intermediate mail client wrapped it mid-line (it's the longest header
-- line, containing the path twice), so whatever follows is its
-- continuation, not source code -- unlike, say, a wrapped
-- "@@ ... funcname(args" continuation, which genuinely is hunk-body context.
local function is_incomplete_file_header(payload)
	return payload:match("^diff %-%-git a/") ~= nil and not payload:find(" b/", 1, true)
end

-- True if the line right above `lnum` is an incomplete "diff --git" line
-- (see is_incomplete_file_header) -- i.e. `lnum` is its wrapped
-- continuation, still diff-header bookkeeping rather than real content.
local function follows_incomplete_file_header(bufnr_lines, lnum)
	if lnum <= 1 then
		return false
	end
	local _, prev_payload = segment.strip_quote(bufnr_lines[lnum - 1])
	return is_incomplete_file_header(prev_payload)
end

-- A long quoted "+"/"-" line can get soft-wrapped by an intermediate mail
-- client, landing its continuation on its own physical line with the same
-- quote-depth arrows but no diff marker. Walk backward within the segment
-- for the nearest line that still has one and inherit it, stopping at a
-- blank or structural line (a real boundary) rather than reaching past it.
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

-- Build one side's ("+"/context, or "-"/context) virtual source text plus
-- a per-virtual-row map back to real buffer positions. Lines with the
-- *other* marker are skipped, since they belong to a different version of
-- the file and don't parse as one coherent unit together. Structural
-- lines (diff --git/index/---/+++/@@) -- and a wrapped continuation of one
-- -- are skipped too: they're diff bookkeeping, not source code, and
-- feeding e.g. a bare wrapped path into the cpp parser produces garbage
-- captures (every "/" reads as a division operator).
local function build_side(bufnr_lines, start_line, end_line, side_marker)
	local other = (side_marker == "+") and "-" or "+"
	local virtual_lines = {}
	local row_map = {} -- virtual_lines[i] came from row_map[i] = {lnum, col_offset}

	for lnum = start_line, end_line do
		local raw = bufnr_lines[lnum]
		local payload, prefix_len = payload_and_prefix(raw)
		if not segment.is_structural(payload) and not follows_incomplete_file_header(bufnr_lines, lnum) then
			local marker, code = strip_diff_marker(payload)
			local effective = marker or find_marker_above(bufnr_lines, start_line, lnum - 1)
			if effective ~= other then
				table.insert(virtual_lines, code)
				table.insert(row_map, { lnum = lnum, col_offset = prefix_len + (#payload - #code) })
			end
		end
	end

	return table.concat(virtual_lines, "\n"), row_map
end

-- Parse `text` as cpp and set one extmark per highlight capture, with each
-- virtual (row, col) remapped to a real buffer position via
-- map_fn(row, col) -> lnum0, col (or nil to drop it). Shared by paint_side
-- (multi-line hunk body, row_map table) and paint_hunk_header (single-line
-- function-context fragment, fixed offset).
--
-- extra_hl, if given, is stacked underneath each capture's own group via
-- nvim_buf_set_extmark's hl_group array form ({extra_hl, "@capture"},
-- highest-priority last). This is how the @@ header's underline survives
-- under real cpp token colors: a separate underlined extmark would just
-- lose to the capture's own (higher-priority, no-underline) group
-- wherever they overlap, since overlapping marks are winner-take-all per
-- attribute, not additive. Stacking within one extmark's hl_group list is
-- the documented way around that -- extra_hl contributes underline+sp,
-- the capture's own group (listed last) still wins the fg color.
local function paint_captures(bufnr, text, hl_query, map_fn, extra_hl)
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
		-- Leading-"_" captures are query-internal predicate bookkeeping,
		-- not meant to be highlighted (same as vim.treesitter.highlighter).
		if start_lnum0 and end_lnum0 and not capture_name:match("^_") then
			local hl_group = "@" .. capture_name
			vim.api.nvim_buf_set_extmark(bufnr, ns, start_lnum0, start_col, {
				end_row = end_lnum0,
				end_col = end_col,
				hl_group = extra_hl and { extra_hl, hl_group } or hl_group,
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
-- accent the range spec (counts picking up the diff-bg red/green), then
-- parse and paint the trailing function context as its own cpp fragment.
local function paint_hunk_header(bufnr, lnum, raw, hl_query)
	local payload, prefix_len = payload_and_prefix(raw)
	local range_part, gap, context = payload:match("^(@@.-@@)(%s*)(.*)$")
	if not range_part then
		return
	end

	local pre, minus_nums, mid, plus_nums, post = range_part:match("^(@@%s*)%-([%d,]+)(%s+)%+([%d,]+)(%s*@@)$")
	if pre then
		local col = prefix_len
		for _, part in ipairs({
			{ pre, "MailHunkHeader" },
			{ "-" .. minus_nums, "MailHunkRangeMinus" },
			{ mid, "MailHunkHeader" },
			{ "+" .. plus_nums, "MailHunkRangePlus" },
			{ post, "MailHunkHeader" },
		}) do
			mark(bufnr, lnum, col, col + #part[1], part[2])
			col = col + #part[1]
		end
	else
		-- Malformed/unexpected shape: accent the whole range as one span.
		mark(bufnr, lnum, prefix_len, prefix_len + #range_part, "MailHunkHeader")
	end

	if context ~= "" then
		local context_col_offset = prefix_len + #range_part + #gap
		paint_captures(bufnr, context, hl_query, function(row, col)
			if row ~= 0 then
				return nil
			end
			return lnum - 1, col + context_col_offset
		end, "MailHunkHeaderUnderline")
	end
end

-- Tint the full row for a "+"/"-" diff line (falling back to
-- find_marker_above for a wrapped continuation with no marker of its
-- own), plus color the marker character itself.
local function paint_diff_line_bg(bufnr, lines, seg_start, lnum)
	local raw = lines[lnum]
	local payload, prefix_len = payload_and_prefix(raw)
	local own_char = payload:sub(1, 1)
	-- A line's own marker is "+", "-", *or* " " (a genuine context line) --
	-- all three mean it already has one. Only some other character (e.g.
	-- the first letter of a wrapped comment continuation) is worth
	-- looking upward for.
	local own_marker = (own_char == "+" or own_char == "-" or own_char == " ") and own_char or nil
	local marker = own_marker or find_marker_above(lines, seg_start, lnum - 1)
	local hl_group = marker == "+" and "MailDiffAddedBg" or marker == "-" and "MailDiffRemovedBg" or nil
	if not hl_group then
		return
	end

	row_bg(bufnr, lnum, prefix_len, #raw, hl_group, hl_group)

	-- Only for a line with a real +/- of its own -- stripped off before
	-- the rest of the line reaches the cpp parser, so nothing else colors
	-- it otherwise.
	if own_marker == "+" or own_marker == "-" then
		local marker_hl = own_marker == "+" and "MailDiffstatPlus" or "MailDiffstatMinus"
		mark(bufnr, lnum, prefix_len, prefix_len + 1, marker_hl)
	end
end

-- "diff --git a/x.cc b/x.cc": file-section marker, plus an inline "Δ "
-- prefix (the glyph delta shows before its consolidated path line).
local function paint_file_header(bufnr, lnum, raw)
	local payload, prefix_len = payload_and_prefix(raw)
	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, prefix_len, {
		end_row = lnum - 1,
		end_col = #raw,
		hl_group = "MailFileHeader",
		virt_text = { { "┃ ", "MailFileHeaderMarker" } },
		virt_text_pos = "inline",
		priority = 200,
	})
end

-- A "┃ " left-edge marker so a header block reads as one connected group
-- while scrolling fast, not just its first line -- extends the file-header
-- glyph down index/---/+++, and marks @@ ... @@ lines in hunk-blue.
local function paint_block_marker(bufnr, lnum, raw, hl_group)
	local _, prefix_len = payload_and_prefix(raw)
	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, prefix_len, {
		virt_text = { { "┃ ", hl_group } }, -- caller passes the *Marker (non-underlined) variant
		virt_text_pos = "inline",
		priority = 200,
	})
end

-- Soft full-row wash for any header line (diff --git/index/---/+++/
-- @@ ... @@, whichever appear). No contiguity tracking: each line shape is
-- inherently "part of a header" on its own, so a standalone @@ ... @@
-- re-quoted alone further down a thread still just gets itself colored.
local function paint_header_block_bg(bufnr, lnum, raw)
	local _, prefix_len = payload_and_prefix(raw)
	row_bg(bufnr, lnum, prefix_len, #raw, "MailHeaderBlockBg")
end

-- "path/to/file.cc | 69 ++++++++----": color just the +/- run, leaving the
-- path/pipe/count in the default fg, matching delta's diffstat.
local function paint_diffstat_line(bufnr, lnum, raw)
	local payload, prefix_len = payload_and_prefix(raw)
	local head, plus, minus = payload:match("^(%s*[%w_./%-]+%s+|%s+%d+%s+)(%+*)(%-*)%s*$")
	if not head then
		return
	end
	local col = prefix_len + #head
	if #plus > 0 then
		mark(bufnr, lnum, col, col + #plus, "MailDiffstatPlus")
		col = col + #plus
	end
	if #minus > 0 then
		mark(bufnr, lnum, col, col + #minus, "MailDiffstatMinus")
	end
end

-- "8 files changed, 627 insertions(+), 37 deletions(-)": accent just the
-- (+)/(-) markers.
local function paint_diffstat_summary(bufnr, lnum, raw)
	local payload, prefix_len = payload_and_prefix(raw)
	local function accent(pat, hl)
		local s, e = payload:find(pat)
		if s then
			mark(bufnr, lnum, prefix_len + s - 1, prefix_len + e, hl)
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

-- The subset of segment.is_structural that actually gets the "┃"/"Δ"
-- left-margin marker (see paint_segment) -- diffstat lines and the
-- "N files changed" summary are is_structural too (for classification)
-- but were never given that marker, so they must not count as part of a
-- run here either, or the closing border ends up floating under a table
-- that was never "boxed" to begin with.
local function is_header_marker_line(payload)
	return payload:match("^diff %-%-git ") ~= nil
		or payload:match("^index ")
		or payload:match("^new file mode ")
		or payload:match("^deleted file mode ")
		or payload:match("^%-%-%- ")
		or payload:match("^%+%+%+ ")
		or payload:match("^@@ ")
end

-- Maximal runs of consecutive marker-bearing header lines (plus any
-- wrapped file-header continuation, see follows_incomplete_file_header)
-- within [start_line, end_line] -- each is one header block
-- (diff --git...@@, or a standalone @@ with nothing preceding it).
-- Returns { {start_lnum, end_lnum, width}, ... } where width is the
-- longest raw line length in that run, used to size the closing borders
-- to the block's actual content instead of a guess.
local function header_runs(lines, start_line, end_line)
	local runs = {}
	local run_start, run_end, run_width = nil, nil, 0
	for lnum = start_line, end_line + 1 do
		local raw = lines[lnum]
		local payload = raw and select(2, segment.strip_quote(raw))
		local continues = payload
			and (is_header_marker_line(payload) or follows_incomplete_file_header(lines, lnum))

		if continues then
			run_start = run_start or lnum
			run_end, run_width = lnum, math.max(run_width, #raw)
		elseif run_start then
			table.insert(runs, { start_lnum = run_start, end_lnum = run_end, width = run_width })
			run_start, run_end, run_width = nil, nil, 0
		end
	end
	return runs
end

-- A "┏━━.../┗━━...": a border closing off a header block above its first
-- line or below its last, drawn as a virt_line so it doesn't shift the
-- buffer's own line numbers -- sized to the block's own content width
-- (see header_runs) rather than the window width, since 'wrap'/
-- 'linebreak' means a header line can visually wrap at different points
-- depending on window size, and a border aligned to that would drift out
-- of sync. When `closed`, the bar gets a matching right corner ("┓"/"┛")
-- to meet the per-line right edges (see paint_header_block_right_edge) --
-- only sensible under 'nowrap', where every line's real end sits at a
-- fixed, predictable screen column.
local function paint_header_block_edge(bufnr, lines, lnum, width, corner, above, closed)
	local raw = lines[lnum]
	local _, prefix_len = payload_and_prefix(raw)
	-- +2 for the inline "Δ "/"┃ " glyph every header line gets (2 display
	-- columns not present in the raw line length `width` is measured
	-- from); the two corners (or the one corner + open end) take up the
	-- rest of the column budget.
	-- Dash count is the same whether or not this is closed, plus one more
	-- when closed: a right corner doesn't replace a dash, it's an extra
	-- column appended past the open end, and the +1 leaves a one-column
	-- gap before it (matching the left side's "┃ " glyph) rather than
	-- butting right up against the widest line's last character -- see
	-- paint_header_block_right_edge, which pads the same extra column.
	local right_corner = closed and (above and "┓" or "┛") or ""
	local bar_width = math.max(width - prefix_len + 1, 8) + (closed and 1 or 0)
	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
		virt_lines = {
			{
				{ string.rep(" ", prefix_len), "Normal" },
				{ corner .. string.rep("━", bar_width) .. right_corner, "MailHeaderBlockBorder" },
			},
		},
		virt_lines_above = above,
	})
end

-- "┃" on the right edge of one header line, column-aligned to the run's
-- widest line (padded with spaces for shorter lines) so the vertical edge
-- lines up down the whole block, plus one extra column of gap so it
-- doesn't butt up against the widest line's last character -- matching
-- the one-space gap the left "┃ " glyph already leaves before content.
-- Only called under 'nowrap' (see closed above) -- with wrap on, a line's
-- real end doesn't sit at a fixed screen column, so this would drift out
-- of alignment as soon as anything wrapped.
local function paint_header_block_right_edge(bufnr, lnum, raw, width)
	local pad = width - #raw + 1
	vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, #raw, {
		virt_text = { { string.rep(" ", pad) .. "┃", "MailHeaderBlockBorder" } },
		virt_text_pos = "inline",
		priority = 200,
	})
end

-- Paint one "code" segment: real cpp tokens for both diff sides, plus
-- diff-line backgrounds and header styling for its structural lines.
-- Shared by the full-buffer path (paint_buffer) and the visible-window
-- path (paint_visible_range) below. winid decides whether header blocks
-- get a full closed box (right edge too) or just top/bottom bars -- see
-- paint_header_block_edge.
local function paint_segment(bufnr, lines, seg, hl_query, winid)
	local new_text, new_map = build_side(lines, seg.start_line, seg.end_line, "+")
	paint_side(bufnr, new_text, new_map, hl_query)

	local old_text, old_map = build_side(lines, seg.start_line, seg.end_line, "-")
	paint_side(bufnr, old_text, old_map, hl_query)

	for lnum = seg.start_line, seg.end_line do
		local raw = lines[lnum]
		local _, payload = segment.strip_quote(raw)
		if segment.is_structural(payload) then
			if payload:match("^@@ ") then
				paint_hunk_header(bufnr, lnum, raw, hl_query)
				paint_block_marker(bufnr, lnum, raw, "MailHunkHeaderMarker")
				paint_header_block_bg(bufnr, lnum, raw)
			elseif payload:match("^diff %-%-git ") then
				paint_file_header(bufnr, lnum, raw)
				paint_header_block_bg(bufnr, lnum, raw)
			elseif
				payload:match("^index ")
				or payload:match("^new file mode ")
				or payload:match("^deleted file mode ")
				or payload:match("^%-%-%- ")
				or payload:match("^%+%+%+ ")
			then
				paint_block_marker(bufnr, lnum, raw, "MailFileHeaderMarker")
				paint_header_block_bg(bufnr, lnum, raw)
			elseif segment.is_diffstat_line(payload) then
				paint_diffstat_line(bufnr, lnum, raw)
			elseif segment.is_diffstat_summary(payload) then
				paint_diffstat_summary(bufnr, lnum, raw)
			end
		elseif follows_incomplete_file_header(lines, lnum) then
			-- The wrapped tail of a "diff --git a/x b/x" line: style it
			-- like the other file-header lines even though it's not one
			-- itself, so the block reads as one continuous thing.
			paint_block_marker(bufnr, lnum, raw, "MailFileHeaderMarker")
			paint_header_block_bg(bufnr, lnum, raw)
		else
			paint_diff_line_bg(bufnr, lines, seg.start_line, lnum)
		end
	end

	local closed = winid ~= nil and vim.api.nvim_win_is_valid(winid) and not vim.api.nvim_get_option_value("wrap", { win = winid })
	for _, run in ipairs(header_runs(lines, seg.start_line, seg.end_line)) do
		paint_header_block_edge(bufnr, lines, run.start_lnum, run.width, "┏", true, closed)
		paint_header_block_edge(bufnr, lines, run.end_lnum, run.width, "┗", false, closed)
		if closed then
			for lnum = run.start_lnum, run.end_lnum do
				paint_header_block_right_edge(bufnr, lnum, lines[lnum], run.width)
			end
		end
	end
end

-- Per-buffer cache: segments plus the changedtick they were computed from,
-- so an edit invalidates it cheaply. Each segment gets a `.painted` flag
-- mutated in place once paint_segment has run for it, so re-entering an
-- already-painted region (scrolling back up, a second window) is a no-op.
local buffer_cache = {}

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
	local winid = vim.api.nvim_get_current_win()

	for _, seg in ipairs(segments) do
		if seg.kind == "code" then
			paint_segment(bufnr, lines, seg, hl_query, winid)
			seg.painted = true
		end
	end
end

-- Paint only the "code" segments intersecting [topline0, botline0]
-- (0-indexed, inclusive) that haven't been painted yet -- what keeps a
-- long patch thread from re-parsing the whole buffer on every scroll.
-- Meant to be driven by enable_live's decoration provider.
function M.paint_visible_range(bufnr, topline0, botline0, winid)
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
			paint_segment(bufnr, lines, seg, hl_query, winid)
			seg.painted = true
		end
	end
end

-- One decoration provider for the whole session, gated per buffer by
-- live_enabled -- nvim_set_decoration_provider replaces any previous
-- callback for this namespace, so it must only ever be registered once.
local live_enabled = {}
local provider_registered = false

local function ensure_provider()
	if provider_registered then
		return
	end
	provider_registered = true

	vim.api.nvim_set_decoration_provider(ns, {
		on_start = function()
			return next(live_enabled) ~= nil
		end,
		on_win = function(_, winid, bufnr, topline, botline)
			if live_enabled[bufnr] then
				M.paint_visible_range(bufnr, topline, botline, winid)
			end
			return false -- marks are set per-segment already, no on_line needed
		end,
	})
end

-- Turn on live, scroll-scoped painting for `bufnr`.
function M.enable_live(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	ensure_highlights()
	live_enabled[bufnr] = true
	ensure_provider()

	-- Scoped to the current window, not the global colorscheme -- :append
	-- so any winhighlight another plugin already set stays intact.
	vim.opt_local.winhighlight:append("CursorLine:MailCursorLine")
end

function M.disable_live(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	live_enabled[bufnr] = nil
	buffer_cache[bufnr] = nil
end

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
