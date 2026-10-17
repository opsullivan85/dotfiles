# NixOS graphical desktop: niri + Noctalia + the Stylix theme.
{
  pkgs,
  ...
}:

{
  imports = [
    ./niri.nix
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard # Wayland clipboard (gh, nvim, anything that copies)
  ];

  # Core (home/core/stylix.nix) holds the theme and leaves autoEnable off;
  # the desktop wants every target (tmux, alacritty, ...).
  stylix.autoEnable = true;
}
