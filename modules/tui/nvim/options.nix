# Options the language modules (modules/dev/<lang>.nix) fill in to build up
# nvim; modules/tui/nvim/default.nix turns them into lua. Lives here, imported by each
# language file, so they still evaluate on machines without nvim.
{ lib, ... }:

{
  options.dev.nvim = {
    lspServers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "nvim-lspconfig server names to enable.";
    };
    formatters = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      description = "conform.nvim formatters, by filetype.";
    };
    treesitter = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Treesitter parsers to install.";
    };
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.lines;
      default = [ ];
      description = "Extra lazy.nvim specs (lua tables, each ending in a comma).";
    };
  };
}
