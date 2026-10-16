# The Ubuntu work laptop = core + Ubuntu + work. Apply with:
#   home-manager switch --flake ~/dotfiles#owen@work-laptop
# Adjust username/homeDirectory if they differ on that machine.
{
  imports = [
    ../core
    ../os/ubuntu
    ../profiles/work.nix
  ];

  home.username = "owen";
  home.homeDirectory = "/home/owen";
  home.stateVersion = "26.05";
}
