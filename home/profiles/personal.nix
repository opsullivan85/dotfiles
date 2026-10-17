# What's specific to you-as-yourself, independent of OS.
{ pkgs, ... }:

{
  programs.git.settings.user = {
    name = "Owen Sullivan";
    email = "opsullivan85@gmail.com";
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
    ];
  };

  home.packages = with pkgs; [
    pqiv
  ];
}
