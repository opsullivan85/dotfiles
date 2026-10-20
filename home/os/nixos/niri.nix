{ config, pkgs, ... }:

let
  # Win+Enter: new terminal in the focused window's working directory. Only
  # terminals can be "duplicated" this way; for other windows it falls back
  # to a plain terminal. Looks up the focused alacritty's tmux client and
  # asks tmux for that pane's path.
  dupTerminal = pkgs.writeShellApplication {
    name = "dup-terminal";
    runtimeInputs = [
      pkgs.jq
      pkgs.procps
      pkgs.tmux
    ];
    text = ''
      descendants() {
        echo "$1"
        for c in $(pgrep -P "$1" || true); do descendants "$c"; done
      }

      cwd=""
      pid=$(niri msg --json focused-window | jq -r '.pid // empty')
      if [ -n "$pid" ]; then
        tree=$(descendants "$pid")
        while read -r cpid path; do
          if echo "$tree" | grep -qx "$cpid"; then cwd=$path; break; fi
        done < <(tmux list-clients -F '#{client_pid} #{pane_current_path}' 2>/dev/null || true)
      fi

      if [ -n "$cwd" ]; then
        exec alacritty --working-directory "$cwd"
      fi
      exec alacritty
    '';
  };
in
{
  home.packages = [ dupTerminal ];

  programs.alacritty = {
    enable = true;
    settings = {
      # Colors + font come from Stylix (hosts/laptop/configuration.nix)
      # now, not set here.
      keyboard.bindings = [
        {
          key = "Equals";
          mods = "Control|Shift";
          action = "IncreaseFontSize";
        }
        {
          key = "Plus";
          mods = "Control|Shift";
          action = "IncreaseFontSize";
        }
        {
          key = "Minus";
          mods = "Control|Shift";
          action = "DecreaseFontSize";
        }
        {
          key = "Key0";
          mods = "Control|Shift";
          action = "ResetFontSize";
        }
      ];
    };
  };

  home.file.".config/niri/config.kdl".source = pkgs.replaceVars ./niri/config.kdl {
    background = "#${config.lib.stylix.colors.base00}";
  };
}
