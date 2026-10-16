# Settings shared by every NixOS host. Host-specific ones live in hosts/<name>/.
{
  # Runs prebuilt generic-Linux binaries (e.g. zig-built test executables
  # from uvx toolchains) that expect /lib64/ld-linux-x86-64.so.2.
  programs.nix-ld.enable = true;
}
