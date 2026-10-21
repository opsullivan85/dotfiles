{
  lib,
  pkgs,
  theme,
  ...
}:

let
  # p10k colours are taken from the theme's base16 scheme (so they match the
  # terminal exactly, with or without Stylix). Roles name the base16 slot;
  # p10k.zsh refers to $p10k_<role> (hex) and $p10k_f_<role> (a %F{} prefix,
  # for use inside ${...:+...} where a literal "}" would end the expansion).
  roles = {
    grey_dark = "03";
    grey = "04";
    fg = "05";
    fg_bright = "06";
    red = "08";
    orange = "09";
    yellow = "0A";
    green = "0B";
    aqua = "0C";
    blue = "0D";
    purple = "0E";
  };
  p10kColors = pkgs.runCommand "p10k-colors.zsh" { } ''
    scheme=${theme.base16Scheme}
    base() { sed -nE "s/^ *base$1: *[\"']?#?([0-9a-fA-F]{6}).*/\1/p" "$scheme"; }
    # bg sits halfway between base00 (terminal background) and base01.
    mix() {
      local a=$1 b=$2 c
      for c in 0 2 4; do printf '%02x' $(( (0x''${a:$c:2} + 0x''${b:$c:2}) / 2 )); done
    }
    {
    echo "typeset -g p10k_bg='#$(mix "$(base 00)" "$(base 01)")'"
    echo "typeset -g p10k_f_bg='%F{#$(mix "$(base 00)" "$(base 01)")}'"
    ${builtins.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (role: slot: ''
        hex=$(base ${slot})
        echo "typeset -g p10k_${role}='#$hex'"
        echo "typeset -g p10k_f_${role}='%F{#$hex}'"
      '') roles
    )}
    } > $out
  '';
in
{
  home.file.".p10k.zsh".source = ./p10k.zsh;
  home.file.".p10k-colors.zsh".source = p10kColors;

  programs.zsh = {
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = lib.mkBefore ''
      source ~/.p10k-colors.zsh
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };
}
