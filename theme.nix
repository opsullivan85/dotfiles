# Single source of truth for the color scheme + its matching font, used by
# both the NixOS module (stylix) and home-manager modules (noctalia).
#
# Neovim is themed from here too, via Stylix (home/core/stylix.nix).
{ pkgs }:

{
  polarity = "dark";
  base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  noctaliaBuiltin = "Gruvbox";

  monoFont = {
    package = pkgs.nerd-fonts.jetbrains-mono;
    name = "JetBrainsMono Nerd Font";
  };
}
