# Home-manager side of a NixOS machine: the niri/Noctalia/Stylix desktop plus
# the NixOS-only rebuild workflow. (System-level config lives in ../../../hosts.)
{
  imports = [ ./desktop.nix ];

  programs.zsh.shellAliases.rebuild = "~/dotfiles/scripts/rebuild";
}
