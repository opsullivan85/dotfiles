# Single source of truth for the color scheme + its matching font, used by
# both the NixOS module (stylix) and home-manager modules (noctalia).
#
# NvChad doesn't read the base16 scheme, so it gets its matching theme name
# (nvchadTheme) instead; change both together. VS Code likewise (vscodeTheme).
{ pkgs }:

{
  polarity = "dark";
  base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  noctaliaBuiltin = "Gruvbox";
  nvchadTheme = "gruvbox"; # NvChad has its own theme names, set in modules/tui/nvim/default.nix
  vscodeTheme = "Dark Modern"; # Stylix's generated VS Code theme has poor contrast, so it's off

  cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  monoFont = {
    package = pkgs.nerd-fonts.jetbrains-mono;
    name = "JetBrainsMono Nerd Font";
  };
}
