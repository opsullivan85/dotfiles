{ pkgs }:

{
  name,
  library,
  device,
  computeType,
}:

# ruff allows 110 columns (ruff.toml); writePython3Bin's flake8 check uses 79.
pkgs.writers.writePython3Bin name
  {
    libraries = [ library ];
    flakeIgnore = [ "E501" ];
  }
  (
    builtins.replaceStrings [ "@DEVICE@" "@COMPUTE_TYPE@" ] [ device computeType ] (
      builtins.readFile ./transcribe.py
    )
  )
