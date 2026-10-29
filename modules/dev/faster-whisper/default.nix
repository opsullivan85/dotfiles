{ pkgs, ... }:

let
  writePythonBin = import ./python-bin.nix { inherit pkgs; };
  faster-whisper = pkgs.python3Packages.faster-whisper;
in
{
  home.packages = [
    (writePythonBin {
      name = "faster-whisper";
      script = ./transcribe.py;
      libraries = [ faster-whisper ];
      replacements = {
        "@DEVICE@" = "cpu";
        "@COMPUTE_TYPE@" = "int8";
      };
    })
    (writePythonBin {
      name = "faster-whisper-dictate";
      script = ./dictate.py;
      libraries = [
        faster-whisper
        pkgs.python3Packages.pynput
      ];
      replacements = {
        "@DEVICE@" = "cpu";
        "@COMPUTE_TYPE@" = "int8";
        "@FFMPEG@" = "${pkgs.ffmpeg}/bin/ffmpeg";
        "@XDOTOOL@" = "${pkgs.xdotool}/bin/xdotool";
      };
    })
  ];
}
