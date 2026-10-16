require("nvchad.configs.lspconfig").defaults()

-- Binaries come from Nix (home/dev/*.nix in dotfiles), not Mason.
-- gdscript talks to the running Godot editor (language server on port 6005).
local servers = {
  "clangd",
  "basedpyright",
  "ruff",
  "rust_analyzer",
  "texlab",
  "gdscript",
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
