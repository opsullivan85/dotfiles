{ pkgs, ... }:

{
  # The C/C++ compiler and build system themselves, split out from
  # dev-cpp.nix so a machine can skip them (keeping clangd/tooling) when
  # they're already managed system-wide (e.g. locus-pocus/locus_ansible on
  # ROS/catkin laptops, where a Nix-provided clang/cmake ahead on PATH
  # shadows the system ones and breaks builds).
  home.packages = with pkgs; [
    clang
    cmake
  ];
}
