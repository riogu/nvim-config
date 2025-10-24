-- lua/plugins/lsp.lua

-- LSP capabilities (for nvim-cmp integration)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

-- LSP keymaps and settings (runs when LSP attaches to a buffer)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Core navigation
		map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
		map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
		map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
		map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

		-- Symbols
		map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

		-- Actions
		map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
		map("K", vim.lsp.buf.hover, "Hover Documentation")

		-- Inlay hints toggle (if supported)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			end, "[T]oggle Inlay [H]ints")
		end

		-- Clear references on cursor move
		if client and client.server_capabilities.documentHighlightProvider then
			local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

-- Cleanup on LSP detach
vim.api.nvim_create_autocmd("LspDetach", {
	group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
	callback = function(event)
		vim.lsp.buf.clear_references()
	end,
})

-- Configure clangd (only if you have it installed)
if vim.fn.executable("clangd") == 1 then
	vim.lsp.config.clangd = {
		cmd = {
			"clangd",
			"--header-insertion=never",
			"--limit-results=50",
			"--pch-storage=memory",
			"--clang-tidy=true",
			"--completion-parse=auto",
			"--j=4",
		},
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "h", "hpp" },
		root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },
		capabilities = capabilities,
		init_options = {
			clangdFileStatus = false,
		},
		on_attach = function(client, bufnr)
			local size = vim.fn.getfsize(vim.fn.expand("%"))
			if size > 100000 then
				client.server_capabilities.semanticTokensProvider = nil
			end
		end,
	}
	vim.lsp.enable("clangd")
end

-- Only configure lua_ls if it's installed
if vim.fn.executable("lua-language-server") == 1 then
	vim.lsp.config.lua_ls = {
		capabilities = capabilities,
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = { enable = false },
				completion = { callSnippet = "Replace" },
			},
		},
	}
	vim.lsp.enable("lua_ls")
end
