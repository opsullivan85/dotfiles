{ pkgs, ... }:

{
  # Interactive search and replace (ripgrep-style regex, $1 capture groups, live preview).
  home.packages = [ pkgs.serpl ];
  programs.zsh.shellAliases.replace = "serpl";
}
