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
    -- The lockfile pins nvim-treesitter's `main` branch, which ignores
    -- `ensure_installed` and doesn't start highlighting itself (NvChad's config
    -- targets the old `master`), so install the parsers and start it here.
    -- Without parsers, treesitter features such as flash's `S` do nothing.
    config = function(_, opts)
      require("nvim-treesitter").install(opts.ensure_installed or {})
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- Telescope pickers for LSP results, replacing nvim's quickfix-based defaults.
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "grr", "<cmd>Telescope lsp_references<cr>", desc = "LSP references" },
      {
        "grs",
        function()
          -- Everything except variables/constants/etc., which are too noisy.
          require("telescope.builtin").lsp_document_symbols {
            symbols = {
              "Module",
              "Namespace",
              "Package",
              "Class",
              "Method",
              "Constructor",
              "Enum",
              "Interface",
              "Function",
              "Struct",
              "Event",
              "Operator",
              "TypeParameter",
            },
          }
        end,
        desc = "LSP document symbols (no variables)",
      },
    },
  },

  -- Jump to any visible text in a few keystrokes.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter",
      },
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
