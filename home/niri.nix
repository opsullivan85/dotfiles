{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 11;
      };
    };
  };

  home.file.".config/niri/config.kdl".source = ./niri/config.kdl;
}
