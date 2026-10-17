# The NixOS laptop = NixOS + personal, plus the modules listed below.
# To drop a tool from this machine, delete its line.
{
  imports = [
    ../os/nixos
    ../profiles/personal.nix

    ../../modules/terminal/zsh.nix
    ../../modules/terminal/tmux.nix

    ../../modules/cli/git.nix
    ../../modules/cli/gh.nix
    ../../modules/cli/home-manager.nix
    ../../modules/cli/tldr.nix

    ../../modules/tui/btop.nix
    ../../modules/tui/claude-code.nix
    ../../modules/tui/keifu.nix

    ../../modules/gui/brave.nix
    ../../modules/gui/pqiv.nix

    ../../modules/dev/nvim.nix
    ../../modules/dev/python.nix
    ../../modules/dev/rust.nix
    ../../modules/dev/cpp.nix
    ../../modules/dev/latex.nix
    ../../modules/dev/godot.nix
  ];

  home.username = "owen";
  home.homeDirectory = "/home/owen";
  home.stateVersion = "26.05";
}
