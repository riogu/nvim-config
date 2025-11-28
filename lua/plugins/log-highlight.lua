return {
	"fei6409/log-highlight.nvim",
	config = function()
		require("log-highlight").setup({
			extension = { "log", "out", "err", "txt" },
			filename = { "test_results.log" },
			keyword = {
				error = {
					"ERROR",
					"FATAL",
					"FAIL",
					"XFAIL",
					"Internal compiler error",
				},
				warning = {
					"WARN",
					"WARNING",
					"NOTE",
					"TIMEOUT",
				},
				pass = {
					"PASS",
					"OK",
					"SUCCESS",
				},
				info = {
					"INFO",
					"NOTICE",
					"TEST",
					"set paths",
				},
				compiler_flag = {
					"-O0",
					"-std=c++20",
					"-std=c++26",
					"-flto",
					"-pedantic-errors",
					"-nostdinc++",
					"spawn",
					"Executing on host:",
				},
				debug = {
					"DEBUG",
					"TRACE",
				},
			},
			highlight_groups = {
				error = "Error",
				warning = "WarningMsg",
				info = "Statement",
				debug = "Comment",
				pass = "Constant",
				compiler_flag = "PreProc",
			},
		})

		-- Custom GCC log syntax highlighting
		local function setup_gcc_syntax()
			if vim.bo.filetype ~= "log" then
				return
			end

			vim.cmd("silent! syntax clear")
			vim.cmd("runtime syntax/log.vim")

			-- Address pattern: 0x[HEX] at start of line
			vim.cmd([[syn match logAddress /^0x[0-9a-fA-F]\+/]])

			-- Function name: between address and opening paren
			vim.cmd([[syn match logFunction /^0x[0-9a-fA-F]\+\s\+\zs.\{-}\ze(\|^0x[0-9a-fA-F]\+\s\+\zs.\{-}\ze\r*$/]])

			-- Arguments: content inside parentheses
			vim.cmd([[syn match logArguments /(\zs[^)]*\ze)/]])

			-- Location: file path and line number
			vim.cmd([[syn match logLocation /^\s\+[^ ]\+:[0-9]\+$/]])

			-- Link to highlight groups
			vim.cmd([[hi! link logFunction Function]])
			vim.cmd([[hi! link logAddress SpecialKey]])
			vim.cmd([[hi! link logArguments Function]])
			vim.cmd([[hi! link logLocation LogPath]])
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "log",
			callback = setup_gcc_syntax,
			group = vim.api.nvim_create_augroup("CustomGccLogSyntax", { clear = true }),
		})
	end,
}
