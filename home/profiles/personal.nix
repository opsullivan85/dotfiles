# What's specific to you-as-yourself, independent of OS.
{ pkgs, ... }:

{
  programs.git.settings.user = {
    name = "Owen Sullivan";
    email = "opsullivan85@gmail.com";
  };

  home.packages = with pkgs; [
    brave
    pqiv
  ];
}
