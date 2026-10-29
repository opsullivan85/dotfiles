{ pkgs, ... }:

let
  transcribe = import ./faster-whisper/transcribe.nix { inherit pkgs; };
  ctranslate2 = pkgs.ctranslate2.override {
    withCUDA = true;
    withCuDNN = true;
  };
in
{
  home.packages = [
    (transcribe {
      name = "faster-whisper-cuda";
      library = pkgs.python3Packages.faster-whisper.override {
        ctranslate2 = pkgs.python3Packages.ctranslate2.override {
          ctranslate2-cpp = ctranslate2;
        };
      };
      device = "cuda";
      computeType = "float16";
    })
  ];
}
