# The NixOS laptop = core + NixOS + personal, plus the units listed below.
# To drop a tool from this machine, delete its line.
{
  imports = [
    ../core
    ../shared/apps.nix
    ../dev/python.nix
    ../dev/rust.nix
    ../dev/cpp.nix
    ../dev/latex.nix
    ../dev/godot.nix
    ../os/nixos
    ../profiles/personal.nix
  ];

  home.username = "owen";
  home.homeDirectory = "/home/owen";
  home.stateVersion = "26.05";
}
