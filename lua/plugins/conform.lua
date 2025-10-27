require('conform').setup {
  notify_on_error = false,
  format_on_save = false,
  formatters_by_ft = {
    lua = { 'stylua' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    ocaml = { 'ocamlformat' },
    rust = { 'rustfmt' },  -- Add this line
  },
}
-- Set up the formatting keymap.
vim.keymap.set({ 'n', 'v' }, 'F', function()
  require('conform').format { async = true, lsp_fallback = true }
end, { desc = '[F]ormat buffer' })
