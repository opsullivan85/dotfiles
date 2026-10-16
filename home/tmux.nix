{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    mouse = true;

    # All of these are plain tmux settings, so they carry over unchanged to
    # a non-Nix tmux.conf. No keybinds or plugins here on purpose.
    escapeTime = 0; # no lag on Esc (matters in nvim)
    baseIndex = 1; # windows/panes number from 1, matching the keyboard row
    keyMode = "vi"; # vi keys in copy-mode
    historyLimit = 50000;
    aggressiveResize = true;

    extraConfig = ''
      set -g renumber-windows on
      set -g focus-events on
      setw -g pane-base-index 1

      set -ga terminal-overrides ',*256col*:Tc'

      # vi-style pane navigation instead of arrow keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
