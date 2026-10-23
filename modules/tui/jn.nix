{ inputs, pkgs, ... }:

{
  home.packages = [ inputs.jn.packages.${pkgs.stdenv.hostPlatform.system}.jn ];
}
