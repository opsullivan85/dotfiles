{ pkgs }:

{
  name,
  script,
  libraries,
  replacements ? { },
}:

# ruff allows 110 columns (ruff.toml); writePython3Bin's flake8 check uses 79.
pkgs.writers.writePython3Bin name
  {
    inherit libraries;
    flakeIgnore = [ "E501" ];
  }
  (
    builtins.replaceStrings (builtins.attrNames replacements) (builtins.attrValues replacements) (
      builtins.readFile script
    )
  )
