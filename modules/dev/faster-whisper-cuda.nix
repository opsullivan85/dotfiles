{ pkgs, ... }:

let
  writePythonBin = import ./faster-whisper/python-bin.nix { inherit pkgs; };
  # The NVIDIA driver must support the CUDA runtime version. The driver here
  # reports CUDA 13.2 (nvidia-smi), so pin the toolkit to 12.9.
  ctranslate2 = pkgs.ctranslate2.override {
    withCUDA = true;
    withCuDNN = true;
    cudaPackages = pkgs.cudaPackages_12_9;
  };
  faster-whisper-bin = writePythonBin {
    name = "faster-whisper-cuda";
    script = ./faster-whisper/transcribe.py;
    libraries = [
      (pkgs.python3Packages.faster-whisper.override {
        ctranslate2 = pkgs.python3Packages.ctranslate2.override {
          ctranslate2-cpp = ctranslate2;
        };
      })
    ];
    replacements = {
      "@DEVICE@" = "cuda";
      "@COMPUTE_TYPE@" = "float16";
    };
  };
  # The host driver lives outside the Nix store and the Nix loader does not
  # search /usr/lib, so expose only libcuda.so.1 to the dynamic loader.
  hostLibcuda = pkgs.runCommand "host-libcuda" { } ''
    mkdir -p $out
    ln -s /usr/lib/x86_64-linux-gnu/libcuda.so.1 $out/libcuda.so.1
  '';
in
{
  home.packages = [
    (pkgs.runCommand "faster-whisper-cuda" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      makeWrapper ${faster-whisper-bin}/bin/faster-whisper-cuda $out/bin/faster-whisper-cuda \
        --prefix LD_LIBRARY_PATH : ${hostLibcuda}
    '')
  ];
}
