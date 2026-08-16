-- Step 1 of the "real C++ inside diffs" rework: classify every buffer line
-- as code or prose, per quote depth, before any painting happens.
--
-- This is deliberately NOT wired into any FileType autocmd yet. It's a
-- standalone module you drive manually (or via :MailSegmentDebug) to
-- validate classification quality against real threads before we build a
-- treesitter/extmark painter on top of it. See the design discussion in
-- conversation history for the full architecture; this file is just the
-- per-line scorer + hysteresis smoother + segment coalescer.

local M = {}

-- Strip leading quote markers ("> ", ">> > ", "> > > ", ...), tolerating
-- spaces between arrows same as the mail-syntax.lua region patterns.
-- Returns depth (number of '>' seen) and the remaining payload.
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

-- Deliberately NOT scoring "if"/"for"/"return"/"static"/"class"/etc as a
-- code signal: this is a C++ mailing list, so plain English sentences use
-- these words constantly ("so *for* expr == ...", "a *static* analysis
-- tool", "the *class* hierarchy"). Punctuation (;{}()::->) and
-- ALL_CAPS_WITH_UNDERSCORE tokens are far more reliably code-only in
-- human-written prose, so those carry the code signal instead.

-- Lines that are structurally blank after stripping quote/diff markers:
-- "", ">", ">   ", "+ ", "- ", etc. Treated as a paragraph/statement-block
-- boundary (see classify_buffer) rather than scored either way.
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

-- "path/to/file.cc | 123 +++++++------": a `git format-patch`/diffstat
-- summary line, e.g. the block above "Signed-off-by:" or after a bare
-- "---". Exported separately from is_structural since mail-paint needs to
-- re-parse the +/- run itself to color it.
local function is_diffstat_line(payload)
	return payload:match("^%s*[%w_./%-]+%s+|%s+%d+%s+[+%-]*%s*$") ~= nil
end
M.is_diffstat_line = is_diffstat_line

-- "8 files changed, 627 insertions(+), 37 deletions(-)": the summary line
-- that closes a diffstat block.
local function is_diffstat_summary(payload)
	return payload:match("^%s*%d+ files? changed") ~= nil
end
M.is_diffstat_summary = is_diffstat_summary

-- Structural diff headers: unambiguous, force state to "code" and bypass
-- hysteresis entirely -- but only ever used as a strong hint, never as the
-- thing that *ends* a hunk (a maintainer's comment or a deleted line can't
-- be detected this way, which is why we still classify every line).
local function is_structural(payload)
	return payload:match("^diff %-%-git ") ~= nil
		or payload:match("^index ")
		or payload:match("^%-%-%- ")
		or payload:match("^%+%+%+ ")
		or payload:match("^@@ ")
		or is_diffstat_line(payload)
		or is_diffstat_summary(payload)
end
M.is_structural = is_structural

-- "On <date>, X wrote:" marks the start of a new quoted message. Quote
-- depth is only a meaningful continuous signal *within* one logical
-- message -- a thread view or a multi-message paste (like this file) can
-- have several unrelated messages back to back, each restarting what
-- depth 1/2/3 mean, so state from the previous message must not leak in.
local function is_attribution(payload)
	return payload:match("^On .* wrote:%s*$") ~= nil
end

-- Score one payload line: positive = looks like code, negative = looks
-- like prose, 0 = neutral/blank (inherits whatever state we're in).
local function score_line(payload)
	if is_blank(payload) then
		return 0
	end

	-- git-send-email scissors line and the standard "-- " signature
	-- delimiter: neither is code, but both start with '-' so they'd
	-- otherwise pick up the diff-marker nudge below.
	if payload:match("^%-%- >8 %-%-%s*$") or payload:match("^%-%-%s*$") then
		return 0
	end

	local marker = payload:sub(1, 1)
	local has_diff_marker = marker == "+" or marker == "-" or marker == " "
	local inner = has_diff_marker and payload:sub(2) or payload

	if inner:match("^%s*$") then
		return 0
	end

	-- A "-"/"+" line whose payload is prose is a maintainer comment or a
	-- signature, not a diff line -- e.g. "- I don't think this is right".
	local prose_score = 0
	if inner:match("^%s*%u") and inner:match("[%.%?!]%s*$") then
		prose_score = prose_score + 2
	end
	if inner:match("^%s*On .* wrote:%s*$") then
		prose_score = prose_score + 3
	end
	-- Long runs of words (contractions like "don't" included) with spaces
	-- and no code punctuation read as prose even without terminal
	-- punctuation (mid-sentence wrapped lines, question fragments, etc).
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
	-- A bare "BINFO_OFFSET"/"NULL_TREE"-shaped identifier is *not* code
	-- evidence on its own -- prose about this codebase mentions macro and
	-- constant names constantly ("the usage of BINFO_OFFSET is ..."). Only
	-- count it when it's next to actual code punctuation corroborating
	-- that this is a real reference, not a passing mention.
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
-- { lnum, depth, kind = "code"|"prose", score }, 1-indexed.
-- State is tracked independently per quote depth so an interleaved reply
-- at one depth doesn't reset the hunk state of the depth above/below it.
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

	-- Resolve every record currently sitting in st.pending to `state` and
	-- clear the run. Used both when a flip is confirmed (resolve to the NEW
	-- state) and when a run turns out to have been a false alarm (resolve
	-- to the state it never actually left).
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
			-- New message starts here: whatever "code" state a deeper
			-- quote level was in belongs to a different message's hunk,
			-- not this one. Wipe every depth's state, not just this line's.
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
			-- Paragraph/statement-block boundary: resolve whatever's
			-- pending now instead of letting ambiguity drift across it.
			-- Genuinely wrapped prose is *always* blank-line-delimited in
			-- plain-text mail, so this bounds how far a run of neutral or
			-- weakly-scored lines (which wrapped prose produces a lot of,
			-- since only a paragraph's last line usually ends in
			-- punctuation) can drift before getting resolved.
			flush(st, st.state)
			rec.kind = st.state
			rec.score = 0
		else
			local score = score_line(payload)
			rec.score = score

			if score == 0 then
				-- Neutral: park it in the run so it gets relabeled
				-- along with its neighbors if they end up flipping.
				table.insert(st.pending, rec)
			elseif (score > 0) == (st.state == "code") then
				-- Agrees with current state: whatever was pending was an
				-- unconfirmed blip, resolve it to the state it never left.
				flush(st, st.state)
				rec.kind = st.state
			else
				-- Contradicts current state.
				table.insert(st.pending, rec)
				st.contrary_count = st.contrary_count + 1
				if st.contrary_count >= 2 then
					-- Confirmed: retroactively relabel the whole run
					-- (including any neutral lines caught inside it), not
					-- just the lines from this point forward.
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
		table.insert(
			out,
			string.format("%4d d%d %-4s %+2d  %s", c.lnum, c.depth, c.kind, c.score, text)
		)
	end

	vim.cmd("botright new")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
	vim.bo.modifiable = false
end, { desc = "Dump mail-segment classification for the current buffer" })

return M
