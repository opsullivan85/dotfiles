{ config, pkgs, ... }:

{
  # NvChad's own config lives at ~/.config/nvim, cloned from the NvChad
  # starter template directly (not Nix-managed) — Nix's job stops at making
  # sure neovim and its runtime deps exist. See dotfiles/README for the
  # clone step.
  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    nodejs
    lua-language-server
  ];
}
