{ config, pkgs, ... }:

{
  # NvChad's config lives in this repo (../nvim) and is linked into place as
  # a plain symlink to the checkout, NOT copied into the Nix store. That keeps
  # it writable: NvChad rewrites lazy-lock.json and chadrc.lua itself. Nix
  # doesn't manage its contents, only the link and the runtime deps below.
  # Assumes the repo is checked out at ~/dotfiles.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";

  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    nodejs
    lua-language-server
  ];
}
