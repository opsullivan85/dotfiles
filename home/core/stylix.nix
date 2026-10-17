# Stylix for the portable core: only the targets that work without a graphical
# session (neovim). autoEnable is off here so the Ubuntu laptop doesn't get
# GTK/etc. config; home/os/nixos/desktop.nix turns it back on.
{
  inputs,
  lib,
  theme,
  ...
}:

{
  imports = [ inputs.stylix.homeModules.stylix ];

  # The NixOS-level stylix module already applies overlays globally, and
  # they conflict with home-manager.useGlobalPkgs.
  stylix.overlays.enable = false;

  # home-manager has its own stylix.enable (default false), separate from the
  # NixOS one, so every target stays inert without this.
  stylix.enable = true;
  stylix.autoEnable = lib.mkDefault false;
  stylix.base16Scheme = theme.base16Scheme;
  stylix.polarity = theme.polarity;
  stylix.fonts.monospace = theme.monoFont;

  stylix.targets.neovim.enable = true;
}
