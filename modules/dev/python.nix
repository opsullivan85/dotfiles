{ pkgs, ... }:

{
  imports = [ ../tui/nvim/options.nix ];

  home.packages = with pkgs; [
    uv
    python3 # fallback interpreter; uv downloads others as needed
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
    ms-toolsai.jupyter
  ];
}
