{ pkgs, ... }:

{
  # scripts/rebuild -v streams its build through nom when it's on PATH.
  home.packages = [ pkgs.nix-output-monitor ];
}
