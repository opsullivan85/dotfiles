require("conform").setup {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_organize_imports" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    rust = { "rustfmt" },
  },
}

vim.keymap.set({ "n", "v" }, "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format file" })
