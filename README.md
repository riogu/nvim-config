# nvim config

## Installation

```bash
git clone https://github.com/riogu/nvim ~/.config/nvim
nvim
```

On first launch, lazy.nvim will automatically install itself and all plugins.

## Features

- **LSP**: clangd, lua_ls
- **Completion**: nvim-cmp with snippets
- **Fuzzy finding**: Telescope
- **Git**: gitsigns, lazygit
- **Formatting**: conform.nvim (supports C/C++, Lua, Rust, OCaml)
- **Syntax**: Treesitter
- **Custom**: Mail syntax highlighting, log highlighting

## Key Plugins

| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Plugin manager |
| nvim-lspconfig | LSP configuration |
| nvim-cmp | Autocompletion |
| telescope.nvim | Fuzzy finder |
| nvim-treesitter | Syntax highlighting |
| gitsigns.nvim | Git integration |
| conform.nvim | Code formatting |
| lualine.nvim | Status line |

## Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── options.lua       # Vim options
│   ├── keymaps.lua       # Key mappings
│   ├── config/           # Custom configs
│   │   └── mail-syntax.lua
│   ├── plugins/          # Plugin specs
│   │   ├── lsp.lua
│   │   ├── cmp.lua
│   │   ├── telescope.lua
│   │   ├── treesitter.lua
│   │   ├── gitsigns.lua
│   │   ├── lualine.lua
│   │   ├── autosession.lua
│   │   ├── cinnamon.lua
│   │   ├── log-highlight.lua
│   │   └── misc.lua      # Small plugins
│   └── space-mining/     # Colorscheme
└── after/                # Filetype configs
```

## License

MIT
