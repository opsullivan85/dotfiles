# Single source of truth for the color scheme + its matching font, used by
# both the NixOS module (stylix) and home-manager modules (noctalia).
#
# NvChad's own colorscheme (~/.config/nvim/lua/chadrc.lua) can't be driven
# from here — NvChad owns that file entirely outside Nix — so it's a manual
# sync point if this ever changes. Update both when it does.
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
