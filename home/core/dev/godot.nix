{ config, pkgs, ... }:

let
  # External-editor hook: Godot -> nvim in an alacritty window, reusing one
  # nvim instance (via a socket) so files open as buffers instead of new
  # windows. In Godot: Editor Settings > Text Editor > External, enable
  # "Use External Editor", Exec Path = godot-edit, Exec Flags = {file} {line} {col}
  godotEdit = pkgs.writeShellApplication {
    name = "godot-edit";
    runtimeInputs = [ config.programs.neovim.finalPackage ];
    text = ''
      sock="''${XDG_RUNTIME_DIR:-/tmp}/godot-nvim.sock"
      file=$1
      line=''${2:-1}
      col=''${3:-0}

      if [ -S "$sock" ] && nvim --server "$sock" --remote-expr 1 >/dev/null 2>&1; then
        nvim --server "$sock" --remote-send "<C-\\><C-N>:e $file<CR>:call cursor($line,$col)<CR>"
      else
        rm -f "$sock"
        exec alacritty -e nvim --listen "$sock" "+call cursor($line,$col)" "$file"
      fi
    '';
  };
in
{
  home.packages = [
    pkgs.godot
    godotEdit
  ];
}
