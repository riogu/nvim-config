local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local config = {
	name = "jdtls",
	cmd = { "jdtls" },
root_dir = vim.fs.root(0, { '.git', 'mvnw' }),
	settings = {
		java = {},
	},
	init_options = {
		bundles = {},
	},
}

require("jdtls").start_or_attach(config)
