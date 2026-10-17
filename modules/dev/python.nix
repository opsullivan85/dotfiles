{ pkgs, ... }:

{
  imports = [ ../tui/nvim-options.nix ];

  home.packages = with pkgs; [
    uv
    python3 # the interpreter uv uses (see below)
    ruff # linter + formatter
    basedpyright # LSP / type checking
  ];

  dev.nvim = {
    lspServers = [
      "basedpyright"
      "ruff"
    ];
    formatters.python = [
      "ruff_format"
      "ruff_organize_imports"
    ];
    treesitter = [ "python" ];
  };

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    ms-python.python
    charliermarsh.ruff
    detachhead.basedpyright
  ];

  # uv's downloaded standalone Pythons are generic Linux binaries, which
  # don't run on NixOS. Use the Nix-provided interpreter instead; uv still
  # manages venvs, deps, lockfiles and scripts as usual.
  home.sessionVariables = {
    UV_PYTHON_DOWNLOADS = "never";
    UV_PYTHON_PREFERENCE = "only-system";
  };
}
