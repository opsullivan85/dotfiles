{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      # Colors + font come from Stylix (hosts/laptop/configuration.nix)
      # now, not set here.
      keyboard.bindings = [
        { key = "Equals"; mods = "Control|Shift"; action = "IncreaseFontSize"; }
        { key = "Plus";   mods = "Control|Shift"; action = "IncreaseFontSize"; }
        { key = "Minus";  mods = "Control|Shift"; action = "DecreaseFontSize"; }
        { key = "Key0";   mods = "Control|Shift"; action = "ResetFontSize"; }
      ];
    };
  };

  home.file.".config/niri/config.kdl".source = ./niri/config.kdl;
}
