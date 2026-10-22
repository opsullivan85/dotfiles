# The NixOS laptop = NixOS + personal, plus the modules listed below.
# To drop a tool from this machine, delete its line.
{
  imports = [
    ../os/nixos
    ../profiles/personal.nix

    ../../modules/terminal/zsh.nix
    ../../modules/terminal/p10k
    ../../modules/terminal/tmux.nix

    ../../modules/cli/bat.nix
    ../../modules/cli/copy.nix
    ../../modules/cli/delta.nix
    ../../modules/cli/eza.nix
    ../../modules/cli/git.nix
    ../../modules/cli/gh.nix
    ../../modules/cli/home-manager.nix
    ../../modules/cli/jq.nix
    ../../modules/cli/nom.nix
    ../../modules/cli/ripgrep.nix
    ../../modules/cli/tldr.nix

    ../../modules/tui/btop.nix
    ../../modules/tui/chat.nix
    ../../modules/tui/claude-code.nix
    ../../modules/tui/keifu.nix
    ../../modules/tui/nvim

    ../../modules/gui/brave.nix
    ../../modules/gui/pqiv.nix
    ../../modules/gui/discord.nix
    ../../modules/gui/freecad.nix
    ../../modules/gui/pinta.nix
    ../../modules/gui/spotify.nix
    ../../modules/gui/libreoffice.nix
    ../../modules/gui/vscode.nix

    ../../modules/dev/python.nix
    ../../modules/dev/python-toolchain.nix
    ../../modules/dev/rust.nix
    ../../modules/dev/cpp.nix
    ../../modules/dev/cpp-toolchain.nix
    ../../modules/dev/latex.nix
    ../../modules/dev/godot.nix
  ];

  home.username = "owen";
  home.homeDirectory = "/home/owen";
  home.stateVersion = "26.05";
}
