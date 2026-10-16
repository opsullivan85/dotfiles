{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";

    extraConfig = ''
      set -ga terminal-overrides ',*256col*:Tc'

      # vi-style pane navigation instead of arrow keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
