{ pkgs, ... }:

{
  home.packages = [ pkgs.thunar ];

  # `open <dir>` (xdg-open) opens folders in Thunar.
  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "thunar.desktop";
  };
}
