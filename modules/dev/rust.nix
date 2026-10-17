{ pkgs, ... }:

{
  imports = [ ../tui/nvim-options.nix ];

  # Toolchains are managed by rustup itself (rust-toolchain.toml, nightly on
  # demand), living in ~/.rustup outside Nix, same as on your Ubuntu machines.
  # First time: `rustup default stable && rustup component add rust-analyzer`.
  home.packages = with pkgs; [
    rustup
    clang # provides the `cc` linker rustc invokes (same package as cpp.nix)
  ];

  dev.nvim = {
    lspServers = [ "rust_analyzer" ];
    formatters.rust = [ "rustfmt" ];
    treesitter = [
      "rust"
      "toml"
    ];
  };

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default = {
    extensions = [ pkgs.vscode-extensions.rust-lang.rust-analyzer ];
    # Use rustup's rust-analyzer (same one nvim gets) instead of the bundled one.
    userSettings."rust-analyzer.server.path" = "rust-analyzer";
  };
}
