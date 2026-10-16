{ config, pkgs, inputs, ... }:

{
  home.username = "owen";
  home.homeDirectory = "/home/owen";
  home.stateVersion = "26.05";

  imports = [
    ./zsh.nix
    ./tmux.nix
    ./nvim.nix
    ./niri.nix
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    btop
    claude-code
    git
    brave
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Owen Sullivan";
    settings.user.email = "opsullivan85@gmail.com";
  };

  programs.home-manager.enable = true;
}
