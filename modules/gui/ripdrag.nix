{ pkgs, ... }:

{
  # Drag files out of the terminal (e.g. from yazi) into other apps: `drag file...`.
  home.packages = [
    (pkgs.writeShellScriptBin "drag" ''
      exec ${pkgs.lib.getExe pkgs.ripdrag} "$@"
    '')
  ];
}
