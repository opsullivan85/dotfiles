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
# `rebuild` adds). Keys: variant ("dark"|"light"), scheme (a name in
# pkgs.base16-schemes), and optional nvchadTheme / vscodeTheme / polarity.
#
# For a scheme that isn't one of the variants, whatever isn't given is guessed:
# light vs dark from "light" in its name, the NvChad theme as the scheme name
# (hyphens to underscores; wrong guesses show up as an error in nvim), VS Code
# as plain Dark/Light Modern.
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
  guessedVariant = if pkgs.lib.hasInfix "light" (override.scheme or "") then "light" else "dark";
  guessed = pkgs.lib.optionalAttrs (override ? scheme) {
    nvchadTheme = builtins.replaceStrings [ "-" ] [ "_" ] override.scheme;
  };
  chosen =
    variants.${override.variant or guessedVariant} // guessed // removeAttrs override [ "variant" ];
in
{
  inherit (chosen) polarity nvchadTheme vscodeTheme;
  base16Scheme = "${pkgs.base16-schemes}/share/themes/${chosen.scheme}.yaml";

  # Hex (no '#') halfway between base00 (terminal background) and base01: the
  # off-background colour of the p10k prompt bar and the tmux status bar.
  panelBg = pkgs.runCommand "panel-bg" { } ''
    scheme=${pkgs.base16-schemes}/share/themes/${chosen.scheme}.yaml
    base() { sed -nE "s/^ *base$1: *[\"']?#?([0-9a-fA-F]{6}).*/\1/p" "$scheme"; }
    a=$(base 00)
    b=$(base 01)
    for c in 0 2 4; do printf '%02x' $(( (0x''${a:$c:2} + 0x''${b:$c:2}) / 2 )); done > $out
  '';

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
