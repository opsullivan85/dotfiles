-- Extra lazy.nvim specs, merged into the NvChad starter's by nix4nvchad
-- (programs.nvchad.extraPlugins in home/core/nvim.nix).
-- Binaries come from Nix (home/dev/*.nix), not Mason.
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        rust = { "rustfmt" },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      -- gdscript talks to the running Godot editor (language server on port 6005).
      vim.lsp.enable {
        "clangd",
        "basedpyright",
        "ruff",
        "rust_analyzer",
        "texlab",
        "gdscript",
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "python",
        "rust",
        "cpp",
        "c",
        "cmake",
        "toml",
        "latex",
        "gdscript",
        "godot_resource",
      },
    },
  },
}
