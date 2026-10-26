{ pkgs, ... }:

{
  home.packages = [ pkgs.lazygit ];
  programs.zsh.shellAliases.lg = "lazygit";
}
