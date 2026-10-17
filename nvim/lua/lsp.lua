-- Binaries come from Nix (home/core/dev/*.nix), not Mason.
-- gdscript talks to the running Godot editor (language server on port 6005).
-- nvim-lspconfig supplies the per-server defaults that vim.lsp.enable uses.
vim.lsp.enable {
  "clangd",
  "basedpyright",
  "ruff",
  "rust_analyzer",
  "texlab",
  "gdscript",
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = args.buf, desc = "LSP " .. desc })
    end
    map("gd", vim.lsp.buf.definition, "definition")
    map("gr", vim.lsp.buf.references, "references")
    map("<leader>ra", vim.lsp.buf.rename, "rename")
    map("<leader>ca", vim.lsp.buf.code_action, "code action")
    map("<leader>ds", vim.diagnostic.setloclist, "diagnostics")
  end,
})
