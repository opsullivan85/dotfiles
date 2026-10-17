{ pkgs, ... }:

{
  imports = [ ../tui/nvim-options.nix ];

  home.packages = with pkgs; [
    clang
    clang-tools # clangd, clang-format, clang-tidy
    cmake
    ninja
    lldb
    gdb
    bear # generate compile_commands.json for non-CMake builds
  ];

  dev.nvim = {
    lspServers = [ "clangd" ];
    formatters = {
      c = [ "clang-format" ];
      cpp = [ "clang-format" ];
    };
    treesitter = [
      "c"
      "cpp"
      "cmake"
    ];
  };

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      llvm-vs-code-extensions.vscode-clangd
      vadimcn.vscode-lldb
    ];
    # The extension would otherwise try to download its own clangd.
    userSettings."clangd.path" = "${pkgs.clang-tools}/bin/clangd";
  };

  # clangd finds compile_commands.json via CMake's
  # -DCMAKE_EXPORT_COMPILE_COMMANDS=ON (or `bear -- make`).
  home.sessionVariables.CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
}
