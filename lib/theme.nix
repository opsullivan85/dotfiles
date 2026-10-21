# Single source of truth for the color scheme + its matching font, used by
# both the NixOS module (stylix) and home-manager modules (noctalia).
#
# NvChad doesn't read the base16 scheme, so it gets its matching theme name
# (nvchadTheme) instead; change both together. VS Code likewise (vscodeTheme).
#
# Two variants ship in git (dark, the default, and light). `rebuild --theme`
# can also pick one, or any base16 scheme by name, without touching git: it
# stores the choice in ~/.local/state/dotfiles/theme.json and hands it to this
# file as JSON in $DOTFILES_THEME, which only works with `--impure` (which
# `rebuild` adds). Keys: variant ("dark"|"light"), plus optional overrides of
# scheme (a name in pkgs.base16-schemes), polarity, nvchadTheme, vscodeTheme.
{ pkgs }:

let
  variants = {
    dark = {
      polarity = "dark";
      scheme = "gruvbox-dark-hard";
      nvchadTheme = "gruvbox"; # NvChad has its own theme names, set in modules/tui/nvim/default.nix
      vscodeTheme = "Dark Modern"; # Stylix's generated VS Code theme has poor contrast, so it's off
    };
    light = {
      polarity = "light";
      scheme = "gruvbox-light-hard";
      nvchadTheme = "gruvbox_light";
      vscodeTheme = "Light Modern";
    };
  };

  raw = builtins.getEnv "DOTFILES_THEME"; # "" unless evaluating with --impure
  override = if raw == "" then { } else builtins.fromJSON raw;
  chosen = variants.${override.variant or "dark"} // removeAttrs override [ "variant" ];
in
{
  inherit (chosen) polarity nvchadTheme vscodeTheme;
  base16Scheme = "${pkgs.base16-schemes}/share/themes/${chosen.scheme}.yaml";

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
