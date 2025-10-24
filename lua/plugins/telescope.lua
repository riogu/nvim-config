-- Configure Telescope
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"%.cache/.*",
			"%.git/.*",
			-- "build/.*",
		},
		preview = {
			mime_hook = function(filepath, bufnr, opts)
				local is_image = function(filepath)
					local image_extensions = { "png", "jpg" }
					local split_path = vim.split(filepath:lower(), ".", { plain = true })
					local extension = split_path[#split_path]
					return vim.tbl_contains(image_extensions, extension)
				end
				if is_image(filepath) then
					local term = vim.api.nvim_open_term(bufnr, {})
					local function send_output(_, data, _)
						for _, d in ipairs(data) do
							vim.api.nvim_chan_send(term, d .. "\r\n")
						end
					end
					vim.fn.jobstart({
						"catimg",
						filepath,
					}, { ostdout = send_output, stdout_buffered = true, pty = true })
				else
					require("telescope.previewers.utils").set_preview_message(
						bufnr,
						opts.winid,
						"Binary cannot be previewed"
					)
				end
			end,
		},
	},
	pickers = {
		find_files = {
			theme = "dropdown",
			previewer = true,
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown(),
		},
	},
})

-- Load extensions
pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")

-- Keymaps
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "wp", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>ft", "<cmd>Telescope tags<cr>", { desc = "Find tags" })
vim.keymap.set("n", "<leader>fT", "<cmd>Telescope current_buffer_tags<cr>", { desc = "Find buffer tags" })

-- Search in current buffer
vim.keymap.set("n", "we", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = true,
	}))
end, { desc = "([W]indow [E]xplore) Fuzzily search in current buffer" })

-- Live grep with dropdown theme
vim.keymap.set("n", "sg", function()
	builtin.live_grep(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = true,
	}))
end, { desc = "[S]earch [/] in Open Files" })

-- Search Neovim config files
vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })
-- Build fzf-native if needed
vim.schedule(function()
	local fzf_path = vim.fn.stdpath("data") .. "/pack/*/start/telescope-fzf-native.nvim"
	if vim.fn.glob(fzf_path) ~= "" and vim.fn.executable("make") == 1 then
		vim.fn.system("cd " .. fzf_path .. " && make")
	end
end)
