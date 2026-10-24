# Settings shared by every NixOS host. Host-specific ones live in hosts/<name>/.
{ pkgs, ... }:

{
  imports = [ ./brave.nix ];

  # nano is on by default and sets EDITOR=nano system-wide; editors come from
  # home-manager (modules/tui/nvim sets EDITOR).
  programs.nano.enable = false;

  # Runs prebuilt generic-Linux binaries (e.g. zig-built test executables
  # from uvx toolchains) that expect /lib64/ld-linux-x86-64.so.2.
  programs.nix-ld.enable = true;

  # Libraries such binaries dlopen at runtime, e.g. miniquad games
  # (libX11 and friends, GL, Wayland).
  programs.nix-ld.libraries = with pkgs; [
    xorg.libX11
    xorg.libXi
    xorg.libXcursor
    xorg.libXrandr
    libxkbcommon
    libGL
    wayland
    alsa-lib
  ];

  # Every rebuild adds a generation; without this the store only grows.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true; # weekly hardlink dedupe of the store

  nix.settings = {
    warn-dirty = false; # the tree is dirty on every rebuild
    download-buffer-size = 268435456; # 256 MiB, avoids "download buffer is full"
  };
}
