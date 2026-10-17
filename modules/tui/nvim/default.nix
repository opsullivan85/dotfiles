{
  config,
  inputs,
  lib,
  pkgs,
  theme,
  ...
}:

let
  cfg = config.dev.nvim;
  toLua = lib.generators.toLua { };

  # Per-language bits collected from modules/dev/<lang>.nix (see
  # options.nix), appended to the shared specs in plugins.lua.
  generatedSpecs = ''
    {
      "stevearc/conform.nvim",
      opts = { formatters_by_ft = ${toLua cfg.formatters} },
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        require("nvchad.configs.lspconfig").defaults()
        vim.lsp.enable(${toLua cfg.lspServers})
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, ${toLua cfg.treesitter})
      end,
    },
  '';
in
{
  imports = [
    inputs.nix4nvchad.homeManagerModules.default
    ./options.nix
  ];

  # nix4nvchad pins the NvChad starter and copies it to ~/.config/nvim on each
  # activation (a writable copy, so edits there are overwritten by the next
  # switch — change modules/tui/nvim/ in this repo instead). Plugins are still fetched by
  # lazy.nvim on first launch, pinned by lazy-lock.json. LSPs and
  # formatters come from Nix on PATH (home/dev/), not Mason.
  programs.nvchad = {
    enable = true;
    backup = false; # otherwise every switch leaves an nvim_<date>.bak behind
    extraPackages = [ pkgs.fd ]; # telescope file search
    chadrcConfig = ''
      local M = {}
      M.base46 = { theme = "${theme.nvchadTheme}" }
      return M
    '';
    extraPlugins = ''
      local specs = (function()
      ${builtins.readFile ./plugins.lua}
      end)()
      vim.list_extend(specs, {
      ${generatedSpecs}
      })
      return specs
    '';
    lazy-lock = builtins.readFile ./lazy-lock.json;
  };
}
