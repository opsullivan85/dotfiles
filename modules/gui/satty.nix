{ pkgs, ... }:

{
  # Annotates screenshots after capture (niri's Print binding takes the shot).
  home.packages = [ pkgs.satty ];
}
