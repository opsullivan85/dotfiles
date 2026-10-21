-- Loaded after NvChad's init.lua (programs.nvchad.extraConfig in default.nix).
vim.opt.relativenumber = true

-- Inlay hints for every attached server that supports them (nvim 0.10+).
vim.lsp.inlay_hint.enable(true)
vim.keymap.set("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- Telescope pickers for definitions/implementations/type definitions. Set
-- buffer-locally on attach so they win over NvChad's own on_attach mappings.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local builtin = require "telescope.builtin"
    local function map(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = args.buf, desc = desc })
    end
    map("gd", builtin.lsp_definitions, "LSP definitions")
    map("gri", builtin.lsp_implementations, "LSP implementations")
    map("grt", builtin.lsp_type_definitions, "LSP type definitions")
  end,
})
