{ pkgs, ... }:

{
  # The Python interpreter itself, split out from dev-python.nix so a
  # machine can skip it (keeping ruff/basedpyright tooling) when it's
  # already managed system-wide (e.g. locus-pocus/locus_ansible on
  # ROS/catkin laptops, where a Nix-provided python3 ahead on PATH shadows
  # the system one and breaks builds, e.g. missing catkin_pkg).
  home.packages = [ pkgs.python3 ];
}
