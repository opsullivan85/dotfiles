{ pkgs, ... }:

{
  # The actual interpreter binary (python3) lives in the separate
  # dev-python-toolchain module so machines can opt out (e.g. when the
  # interpreter is already managed system-wide, as with locus-pocus on
  # ROS/catkin laptops) without losing ruff/basedpyright tooling here.
  imports = [ ../tui/nvim/options.nix ];

  home.packages = with pkgs; [
    uv
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
