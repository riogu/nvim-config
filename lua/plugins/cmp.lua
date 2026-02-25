return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		-- Setup LuaSnip
		luasnip.config.setup({})

		-- Setup nvim-cmp
		cmp.setup({
			-- Snippet Configuration
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			-- Completion Menu Behavior
			completion = {
				-- 'noinsert' prevents the completion from forcing insertion on select,
				-- which is crucial for the <Enter>/<Tab> mappings below.
				completeopt = "menu,menuone,noinsert",
			},

			-- Key Mappings (Insert Mode)
			mapping = cmp.mapping.preset.insert({
				-- Select the [n]ext item
				["<C-n>"] = cmp.mapping.select_next_item(),
				-- Select the [p]revious item
				["<C-p>"] = cmp.mapping.select_prev_item(),

				-- Scroll the documentation window [b]ack / [f]orward
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),

				-- Accept completion (C-y, Enter, Tab)
				-- select = true tells cmp to select the currently highlighted item first.
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<Enter>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping.confirm({ select = true }),

				-- Manually trigger a completion
				["<C-Space>"] = cmp.mapping.complete({}),

				-- LuaSnip Jump Forward/Backward
				["<C-l>"] = cmp.mapping(function()
					if luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					end
				end, { "i", "s" }),
			}),

			-- Sources: Ensure these match the plugins you pack.add in init.lua
			sources = {
				{ name = "nvim_lsp", max_item_count = 5 },
				{ name = "luasnip" },
				{ name = "path" },
				{ name = "buffer" },
			},
		})
	end,
}
