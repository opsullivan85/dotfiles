# NixOS graphical desktop: niri + Noctalia + the Stylix theme.
{
  pkgs,
  inputs,
  theme,
  ...
}:

{
  imports = [
    inputs.stylix.homeModules.stylix
    ./niri.nix
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard # Wayland clipboard (gh, nvim, anything that copies)
  ];

  # Stylix's home-manager module injects per-user nixpkgs overlays, which
  # conflicts with home-manager.useGlobalPkgs (shared pkgs instance). The
  # NixOS-level stylix module already applies its overlays globally.
  stylix.overlays.enable = false;

  # home-manager has its own stylix.enable (default false), separate from the
  # NixOS one, so the targets here (tmux, alacritty, ...) stay inert without this.
  stylix.enable = true;
  stylix.base16Scheme = theme.base16Scheme;
  stylix.polarity = theme.polarity;
  stylix.fonts.monospace = theme.monoFont;

  # stylix is ugly here, handle seperately
  stylix.targets.vscode.enable = false;
}
