{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    alacritty # terminal
    fuzzel    # app launcher
  ];

  home.file.".config/niri/config.kdl".source = ./niri/config.kdl;
}
