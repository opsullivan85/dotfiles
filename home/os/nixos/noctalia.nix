{
  config,
  pkgs,
  inputs,
  theme,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Noctalia already ships its own native "Gruvbox" builtin (used below via
  # theme.noctaliaBuiltin), so Stylix's rendering of it is redundant here.
  stylix.targets.noctalia.enable = false;

  programs.noctalia = {
    enable = true;
    # Launched directly via niri's spawn-at-startup instead (see
    # home/os/nixos/niri/config.kdl) rather than as a systemd user service — simpler,
    # and avoids the two fighting over who starts it.
    systemd.enable = false;

    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = theme.noctaliaBuiltin;
      };

      # Hidden until the pointer hits the top edge; reserve_space off so
      # windows use that strip instead of leaving a gap.
      bar.main = {
        auto_hide = true;
        reserve_space = false;
        capsule = true;
      };

      # Noctalia defaults to 24h and ignores the system locale.
      shell.time_format = "{:%I:%M %p}";
      widget.clock.format = "{:%I:%M %p}";

      # dock = {
      #   enabled = true;
      #   auto_hide = true;
      #   reserve_space = false;
      # };

      desktop_widgets.enabled = false;
      lockscreen_widgets.enabled = false;
    };
  };
}
