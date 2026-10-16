{ config, pkgs, inputs, ... }:

{
  home.username = "owen";
  home.homeDirectory = "/home/owen";
  home.stateVersion = "26.05";

  imports = [
    inputs.stylix.homeModules.stylix
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

  # Stylix's home-manager module injects per-user nixpkgs overlays, which
  # conflicts with home-manager.useGlobalPkgs (shared pkgs instance). The
  # NixOS-level stylix module already applies its overlays globally.
  stylix.overlays.enable = false;

  programs.git = {
    enable = true;
    settings.user.name = "Owen Sullivan";
    settings.user.email = "opsullivan85@gmail.com";
  };

  programs.home-manager.enable = true;
}
