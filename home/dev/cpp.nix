{ pkgs, ... }:

{
  home.packages = with pkgs; [
    clang
    clang-tools # clangd, clang-format, clang-tidy
    cmake
    ninja
    lldb
    gdb
    bear # generate compile_commands.json for non-CMake builds
  ];

  # clangd finds compile_commands.json via CMake's
  # -DCMAKE_EXPORT_COMPILE_COMMANDS=ON (or `bear -- make`).
  home.sessionVariables.CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
}
