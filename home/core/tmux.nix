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
      # New splits/windows open in the current pane's directory
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Status bar content (colors come from Stylix). The battery segment
      # prints nothing on machines without /sys/class/power_supply/BAT*,
      # so this stays portable to desktops.
      set -g status-interval 15
      set -g status-left-length 30
      set -g status-right-length 60
      set -g status-left " #S  "
      set -g status-right "#(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 | sed 's/$/%%  /')%a %d %b  %H:%M "

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
