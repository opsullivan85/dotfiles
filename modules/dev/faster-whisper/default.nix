{ pkgs, ... }:

let
  writePythonBin = import ./python-bin.nix { inherit pkgs; };
  # The NVIDIA driver must support the CUDA runtime version. The driver here
  # reports CUDA 13.2 (nvidia-smi), so pin the toolkit to 12.9.
  ctranslate2 = pkgs.ctranslate2.override {
    withCUDA = true;
    withCuDNN = true;
    cudaPackages = pkgs.cudaPackages_12_9;
  };
  faster-whisper = pkgs.python3Packages.faster-whisper.override {
    ctranslate2 = pkgs.python3Packages.ctranslate2.override {
      ctranslate2-cpp = ctranslate2;
    };
  };
  # The host driver lives outside the Nix store and the Nix loader does not
  # search /usr/lib, so expose only libcuda.so.1. Without a GPU the link
  # dangles and CTranslate2 falls back to the CPU.
  hostLibcuda = pkgs.runCommand "host-libcuda" { } ''
    mkdir -p $out
    ln -s /usr/lib/x86_64-linux-gnu/libcuda.so.1 $out/libcuda.so.1
  '';
  withHostCuda =
    name: bin:
    pkgs.runCommand name { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper ${bin}/bin/${name} $out/bin/${name} --prefix LD_LIBRARY_PATH : ${hostLibcuda}
    '';
in
{
  home.packages = [
    (withHostCuda "faster-whisper" (writePythonBin {
      name = "faster-whisper";
      script = ./transcribe.py;
      libraries = [ faster-whisper ];
    }))
    (withHostCuda "faster-whisper-dictate" (writePythonBin {
      name = "faster-whisper-dictate";
      script = ./dictate.py;
      libraries = [
        faster-whisper
        pkgs.python3Packages.pynput
      ];
      replacements = {
        "@FFMPEG@" = "${pkgs.ffmpeg}/bin/ffmpeg";
        "@XDOTOOL@" = "${pkgs.xdotool}/bin/xdotool";
      };
    }))
  ];
}
