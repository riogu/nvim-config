return {
	"declancm/cinnamon.nvim",
	config = function()
		local cinnamon = require("cinnamon")
		local map = vim.keymap.set

		-- Plugin Setup
		cinnamon.setup({
			-- Custom scroll options
			options = {
				mode = "cursor", -- Animate cursor and window scrolling for any movement
				delay = 7, -- Delay between each movement step (in ms)
				step_size = {
					vertical = 1, -- Number of cursor/window lines moved per step
					horizontal = 2, -- Number of cursor/window columns moved per step
				},
				max_delta = {
					line = 80, -- Maximum distance for line movements before scroll animation is skipped
					column = false, -- Maximum distance for column movements before scroll animation is skipped
					time = 100, -- Maximum duration for a movement (in ms)
				},
				-- Optional post-movement callback
				callback = function()
					-- print("Scrolling done!")
				end,
			},
			-- keymaps table is empty because we define keymaps manually below
			keymaps = {},
		})

		-- Define Keymaps
		-- Scroll half-page down (C-d) and center (zz)
		map("n", "<c-d>", function()
			cinnamon.scroll("<C-d>zz")
		end, { desc = "Scroll Down (Cinnamon)" })

		-- Scroll half-page up (C-u) and center (zz)
		map("n", "<c-u>", function()
			cinnamon.scroll("<C-u>zz")
		end, { desc = "Scroll Up (Cinnamon)" })
	end,
}
