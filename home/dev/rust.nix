{ pkgs, ... }:

{
  # Toolchains are managed by rustup itself (rust-toolchain.toml, nightly on
  # demand), living in ~/.rustup outside Nix, same as on your Ubuntu machines.
  # First time: `rustup default stable && rustup component add rust-analyzer`.
  home.packages = with pkgs; [
    rustup
    clang # provides the `cc` linker rustc invokes (same package as cpp.nix)
  ];
}
