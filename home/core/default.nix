# Portable core: the shell/editor basics every machine gets (zsh, tmux, nvim,
# git). Nothing here may depend on a graphical session, on NixOS, or on which
# of your hats (personal/work) you're wearing. Anything a machine might want to
# drop (languages, apps) belongs in ../dev or ../shared, imported per machine.
{ pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./nvim.nix
  ];

  home.packages = with pkgs; [
    btop
    claude-code
    git
    gh
    keifu
    tldr
  ];

  programs.git.enable = true;
  programs.home-manager.enable = true;
}
