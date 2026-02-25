return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			ensure_installed = { "bash", "c", "html", "lua", "luadoc", "markdown", "vim", "vimdoc" },
			auto_install = true,
		})

		-- Highlight and indent are now native vim features, just enable them
		vim.treesitter.start = (function(original)
			return function(bufnr, lang)
				bufnr = bufnr or vim.api.nvim_get_current_buf()
				local max_filesize = 2 * 1024 * 1024 -- 2 MB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				if ok and stats and stats.size > max_filesize then
					return
				end
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				if line_count > 10000 then
					return
				end
				original(bufnr, lang)
			end
		end)(vim.treesitter.start)

		-- Performance tweaks for large files
		vim.api.nvim_create_autocmd("BufReadPre", {
			callback = function()
				local line_count = vim.api.nvim_buf_line_count(0)
				if line_count > 10000 then
					vim.opt_local.foldmethod = "manual"
					vim.opt_local.foldexpr = ""
					vim.opt_local.syntax = "on"
				end
			end,
		})
	end,
}
