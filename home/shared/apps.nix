# Graphical apps wanted on every machine (personal and work). Kept out of core
# because core must not assume a graphical session.
{ pkgs, ... }:

{
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
