{ pkgs, ... }:

let
  marketplace = pkgs.vscode-utils.extensionFromVscodeMarketplace;
in

{
  # The actual compiler/build-system binaries (clang, cmake) live in the
  # separate dev-cpp-toolchain module so machines can opt out (e.g. when a
  # compiler and build system are already managed system-wide, as with
  # locus-pocus on ROS/catkin laptops) without losing clangd/tooling here.
  imports = [ ../tui/nvim/options.nix ];

  home.packages = with pkgs; [
    clang-tools # clangd, clang-format, clang-tidy
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
      ms-vscode.cmake-tools
      (marketplace {
        publisher = "cschlosser";
        name = "doxdocgen";
        version = "1.4.0";
        sha256 = "sha256-InEfF1X7AgtsV47h8WWq5DZh6k/wxYhl2r/pLZz9JbU=";
      })
      (marketplace {
        publisher = "galarius";
        name = "vscode-opencl";
        version = "0.10.1";
        sha256 = "sha256-r07dP1yiV8F2wP1JLWddiFUfKCsnEHE902+KvgOOh8Q=";
      })
      (marketplace {
        publisher = "kylinideteam";
        name = "cmake-intellisence";
        version = "0.8.2";
        sha256 = "sha256-cjxtHguLTRaofsn7Jae2MYYC6l+XYTOc8HX6izL3N8I=";
      })
    ];
    userSettings = {
      # The extension would otherwise try to download its own clangd.
      "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
      "clangd.arguments" = [
        "--background-index"
        # "--clang-tidy" # noticeably increases CPU/GPU load
        "--all-scopes-completion"
        "--completion-style=detailed"
        "--header-insertion=iwyu"
        "--fallback-style=Microsoft"
      ];
      # clangd is the only C++ language engine (no MS C/C++ extension installed).
      "C_Cpp.intelliSenseEngine" = "disabled";
      "[cpp]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
        "editor.stickyScroll.defaultModel" = "outlineModel";
      };
      # Builds go through a custom task rather than cmake-tools.
      "cmake.configureOnOpen" = false;
    };
  };

  # clangd finds compile_commands.json via CMake's
  # -DCMAKE_EXPORT_COMPILE_COMMANDS=ON (or `bear -- make`).
  home.sessionVariables.CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
}
