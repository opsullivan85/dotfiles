# The NixOS laptop = core + NixOS + personal.
{
  imports = [
    ../core
    ../os/nixos
    ../profiles/personal.nix
  ];

  home.username = "owen";
  home.homeDirectory = "/home/owen";
  home.stateVersion = "26.05";
}
