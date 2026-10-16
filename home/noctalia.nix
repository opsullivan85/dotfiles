{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    # Launched directly via niri's spawn-at-startup instead (see
    # home/niri/config.kdl) rather than as a systemd user service — simpler,
    # and avoids the two fighting over who starts it.
    systemd.enable = false;

    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };
}
