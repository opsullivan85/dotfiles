-- Extra lazy.nvim specs, merged into the NvChad starter's by nix4nvchad
-- (programs.nvchad.extraPlugins in modules/tui/nvim.nix).
-- Language-specific parts (LSP servers, formatters, parsers) are not here: each
-- modules/dev/<lang>.nix sets dev.nvim.*, and nvim.nix generates the specs.
-- Binaries come from Nix (modules/dev/*.nix), not Mason.
return {
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { lua = { "stylua" } } },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "vim", "lua", "vimdoc" } },
  },

  -- Telescope pickers for LSP results, replacing nvim's quickfix-based defaults.
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "grr", "<cmd>Telescope lsp_references<cr>", desc = "LSP references" },
      { "grs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "LSP document symbols" },
    },
  },

  -- Animated cursor trail; works in the terminal.
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Animated scrolling (<C-d>, <C-u>, zz, ...).
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
