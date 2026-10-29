{ pkgs, ... }:

let
  transcribe = import ./transcribe.nix { inherit pkgs; };
in
{
  home.packages = [
    (transcribe {
      name = "faster-whisper";
      library = pkgs.python3Packages.faster-whisper;
      device = "cpu";
      computeType = "int8";
    })
  ];
}
