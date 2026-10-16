{ pkgs, ... }:

{
  home.packages = with pkgs; [
    uv
    python3 # the interpreter uv uses (see below)
    ruff # linter + formatter
    basedpyright # LSP / type checking
  ];

  # uv's downloaded standalone Pythons are generic Linux binaries, which
  # don't run on NixOS. Use the Nix-provided interpreter instead; uv still
  # manages venvs, deps, lockfiles and scripts as usual.
  home.sessionVariables = {
    UV_PYTHON_DOWNLOADS = "never";
    UV_PYTHON_PREFERENCE = "only-system";
  };
}
