# Portable core: everything that makes a shell/dev environment feel like
# home on any machine, NixOS or not. Nothing here may depend on a graphical
# session, on NixOS, or on which of your hats (personal/work) you're wearing.
{ pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./nvim.nix
    ./dev
  ];

  home.packages = with pkgs; [
    btop
    claude-code
    git
    gh
    keifu
    tldr
  ];

  programs.git.enable = true;
  programs.home-manager.enable = true;
}
