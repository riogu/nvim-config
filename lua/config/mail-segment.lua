-- Classifies each buffer line as code or prose per quote depth, before
-- mail-paint.lua paints anything on top. Also provides the fold and
-- reply-navigation helpers built on that same classification.

local M = {}

-- Strip leading quote markers (">", ">> >", ...), tolerating spaces
-- between arrows. Returns depth (number of '>') and the remaining payload.
local function strip_quote(line)
	local depth = 0
	local rest = line
	while true do
		local matched = rest:match("^>[ \t]*")
		if not matched then
			break
		end
		depth = depth + 1
		rest = rest:sub(#matched + 1)
	end
	return depth, rest
end
M.strip_quote = strip_quote

-- A line blank after stripping quote/diff markers: "", ">", "+ ", "- ".
-- Treated as a paragraph/statement-block boundary, not scored either way.
local function is_blank(payload)
	if payload:match("^%s*$") then
		return true
	end
	local marker = payload:sub(1, 1)
	if marker == "+" or marker == "-" or marker == " " then
		return payload:sub(2):match("^%s*$") ~= nil
	end
	return false
end

-- "path/to/file.cc | 123 +++++++------": a diffstat summary row. Exported
-- separately since mail-paint re-parses the +/- run itself to color it.
local function is_diffstat_line(payload)
	return payload:match("^%s*[%w_./%-]+%s+|%s+%d+%s+[+%-]*%s*$") ~= nil
end
M.is_diffstat_line = is_diffstat_line

-- "8 files changed, 627 insertions(+), 37 deletions(-)": closes a diffstat block.
local function is_diffstat_summary(payload)
	return payload:match("^%s*%d+ files? changed") ~= nil
end
M.is_diffstat_summary = is_diffstat_summary

-- Unambiguous diff headers: force state to "code". Only ever used as a
-- hint, never as what *ends* a hunk -- a maintainer's comment or a deleted
-- line can't be detected this way, so every line still gets classified.
local function is_structural(payload)
	return payload:match("^diff %-%-git ") ~= nil
		or payload:match("^index ")
		or payload:match("^new file mode %d+$")
		or payload:match("^deleted file mode %d+$")
		or payload:match("^%-%-%- ")
		or payload:match("^%+%+%+ ")
		or payload:match("^@@ ")
		or is_diffstat_line(payload)
		or is_diffstat_summary(payload)
end
M.is_structural = is_structural

-- "On <date>, X wrote:": starts a new quoted message. Quote depth only
-- means one consistent thing *within* a message, so this resets tracked
-- state everywhere rather than let a previous message's hunk state leak in.
local function is_attribution(payload)
	return payload:match("^On .* wrote:%s*$") ~= nil
end

-- Score one payload line: positive = looks like code, negative = prose,
-- 0 = neutral/blank (inherits whatever state we're in). Deliberately does
-- NOT score keywords like if/for/class/static as code signal -- this is a
-- C++ mailing list, so prose uses those words constantly. Punctuation
-- (;{}()::->) and ALL_CAPS_WITH_UNDERSCORE identifiers are more reliably
-- code-only in human-written prose, so those carry the signal instead.
local function score_line(payload)
	if is_blank(payload) then
		return 0
	end

	-- git-send-email scissors line / "-- " signature delimiter: not code,
	-- but both start with '-' so they'd pick up the diff-marker nudge below.
	if payload:match("^%-%- >8 %-%-%s*$") or payload:match("^%-%-%s*$") then
		return 0
	end

	local marker = payload:sub(1, 1)
	local has_diff_marker = marker == "+" or marker == "-" or marker == " "
	local inner = has_diff_marker and payload:sub(2) or payload

	if inner:match("^%s*$") then
		return 0
	end

	-- A "-"/"+" line whose payload reads as prose is a maintainer comment
	-- or a signature, not a diff line -- e.g. "- I don't think this is right".
	local prose_score = 0
	if inner:match("^%s*%u") and inner:match("[%.%?!]%s*$") then
		prose_score = prose_score + 2
	end
	if inner:match("^%s*On .* wrote:%s*$") then
		prose_score = prose_score + 3
	end
	-- Long word runs with no code punctuation read as prose even without
	-- terminal punctuation (mid-sentence wrapped lines, question fragments).
	local word_run = inner:match("^%s*[%a']+%s+[%a']+%s+[%a']+%s+[%a']+")
	local has_code_punct = inner:find("[;{}()]") or inner:find("::") or inner:find("%->")
	if word_run and not has_code_punct then
		prose_score = prose_score + 1
	end

	local code_score = 0
	if inner:find("[;{}]") then
		code_score = code_score + 1
	end
	if inner:find("::") or inner:find("%->") then
		code_score = code_score + 1
	end
	if inner:find("%(") and inner:find("%)") then
		code_score = code_score + 1
	end
	-- A bare "BINFO_OFFSET"-shaped identifier isn't code evidence on its
	-- own -- prose mentions macro/constant names constantly. Only count it
	-- alongside actual code punctuation corroborating a real reference.
	if has_code_punct and (inner:match("%u%u+_[%u%d_]*") or inner:match("[%u][%u%d_][%u%d_]+")) then
		code_score = code_score + 1
	end

	local score = code_score - prose_score
	if has_diff_marker then
		score = score + 1
	end
	if score > 3 then
		score = 3
	elseif score < -3 then
		score = -3
	end
	return score
end

-- Classify every line of the buffer. Returns an array of
-- { lnum, depth, kind = "code"|"prose", score }, 1-indexed. State is
-- tracked independently per quote depth so an interleaved reply at one
-- depth doesn't reset the hunk state of the depth above/below it. A
-- line's score only flips the tracked state after two consecutive
-- contradicting lines (contrary_count >= 2), which then retroactively
-- relabels the whole pending run -- this absorbs one-off ambiguous lines
-- instead of flip-flopping on every neutral or borderline line.
function M.classify_buffer(bufnr)
	bufnr = bufnr or 0
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local state_by_depth = {}
	local results = {}

	local function get_state(depth)
		local st = state_by_depth[depth]
		if not st then
			st = { state = "prose", pending = {}, contrary_count = 0 }
			state_by_depth[depth] = st
		end
		return st
	end

	-- Resolve every record in st.pending to `state` and clear the run --
	-- used both when a flip is confirmed and when a run was a false alarm.
	local function flush(st, state)
		for _, rec in ipairs(st.pending) do
			rec.kind = state
		end
		st.pending = {}
		st.contrary_count = 0
	end

	for i, line in ipairs(lines) do
		local depth, payload = strip_quote(line)
		local rec = { lnum = i, depth = depth, kind = nil, score = nil }
		results[i] = rec

		if is_attribution(payload) then
			state_by_depth = {}
			rec.kind = "prose"
			rec.score = -3
			goto continue
		end

		local st = get_state(depth)

		if is_structural(payload) then
			flush(st, st.state)
			st.state = "code"
			rec.kind = "code"
			rec.score = 3
		elseif is_blank(payload) then
			-- Paragraph boundary: resolve pending now rather than let
			-- ambiguity drift further (wrapped prose is always
			-- blank-delimited in plain-text mail).
			flush(st, st.state)
			rec.kind = st.state
			rec.score = 0
		else
			local score = score_line(payload)
			rec.score = score

			if score == 0 then
				table.insert(st.pending, rec)
			elseif (score > 0) == (st.state == "code") then
				-- Agrees with current state: pending was an unconfirmed blip.
				flush(st, st.state)
				rec.kind = st.state
			else
				table.insert(st.pending, rec)
				st.contrary_count = st.contrary_count + 1
				if st.contrary_count >= 2 then
					st.state = (score > 0) and "code" or "prose"
					flush(st, st.state)
				end
			end
		end

		::continue::
	end

	-- Anything still pending at EOF never reached the flip threshold;
	-- resolve it to whatever state it was tentatively contradicting.
	for _, st in pairs(state_by_depth) do
		flush(st, st.state)
	end

	return results
end

-- Coalesce classify_buffer()'s per-line output into contiguous segments of
-- { start_line, end_line, kind, depth }.
function M.segment(bufnr)
	local classified = M.classify_buffer(bufnr)
	local segments = {}
	local current = nil

	for _, line in ipairs(classified) do
		if current and current.kind == line.kind and current.depth == line.depth then
			current.end_line = line.lnum
		else
			if current then
				table.insert(segments, current)
			end
			current = { start_line = line.lnum, end_line = line.lnum, kind = line.kind, depth = line.depth }
		end
	end
	if current then
		table.insert(segments, current)
	end

	return segments
end

-- foldexpr: one fold per file section, starting a new fold at each
-- "diff --git" line (any quote depth) up to the next one. Not per-@@ hunk.
function M.foldexpr()
	local _, payload = strip_quote(vim.fn.getline(vim.v.lnum))
	if payload:match("^diff %-%-git ") then
		return ">1"
	end
	return "="
end

-- Jump to the start of the next/previous prose segment at an exact quote
-- depth: depth 0 is unquoted (the most recent reply in the thread), depth
-- 1 is one level of quoting back, and so on -- matching ]1/[1, ]2/[2, ...
-- in mail-syntax.lua. Pass depth = nil to match any depth. direction is 1
-- (forward) or -1 (back).
function M.jump_to_reply(bufnr, direction, depth)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local cur = vim.api.nvim_win_get_cursor(0)[1]
	local segments = M.segment(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- A segment's start_line is often a blank separator line rather than
	-- its actual text; land on the first non-blank line instead. Returns
	-- nil for a segment that's blank throughout (e.g. a lone blank line
	-- sandwiched between two differently-quoted blocks), so the caller
	-- skips it rather than stopping on empty whitespace.
	local function landing_line(seg)
		for l = seg.start_line, seg.end_line do
			if not lines[l]:match("^%s*$") then
				return l
			end
		end
		return nil
	end

	local function matches(seg)
		return seg.kind == "prose" and (depth == nil or seg.depth == depth)
	end

	if direction > 0 then
		for _, seg in ipairs(segments) do
			if matches(seg) and seg.start_line > cur then
				local ll = landing_line(seg)
				if ll then
					vim.api.nvim_win_set_cursor(0, { ll, 0 })
					return true
				end
			end
		end
	else
		for i = #segments, 1, -1 do
			local seg = segments[i]
			-- end_line < cur, not start_line: if the cursor is inside the
			-- current segment, it must not count as "previous" or this
			-- would just land back where the cursor already is.
			if matches(seg) and seg.end_line < cur then
				local ll = landing_line(seg)
				if ll then
					vim.api.nvim_win_set_cursor(0, { ll, 0 })
					return true
				end
			end
		end
	end

	vim.notify("No more mail replies in that direction", vim.log.levels.INFO)
	return false
end

vim.api.nvim_create_user_command("MailSegmentDebug", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local classified = M.classify_buffer(bufnr)

	local out = {}
	for _, c in ipairs(classified) do
		local text = lines[c.lnum] or ""
		if #text > 60 then
			text = text:sub(1, 57) .. "..."
		end
		table.insert(out, string.format("%4d d%d %-4s %+2d  %s", c.lnum, c.depth, c.kind, c.score, text))
	end

	vim.cmd("botright new")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
	vim.bo.modifiable = false
end, { desc = "Dump mail-segment classification for the current buffer" })

return M
