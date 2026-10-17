{ pkgs, ... }:

{
  imports = [ ../tui/nvim-options.nix ];

  home.packages = with pkgs; [
    tectonic # self-contained engine; fetches packages on demand
    texlab # LSP
  ];

  dev.nvim = {
    lspServers = [ "texlab" ];
    treesitter = [ "latex" ];
  };

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default = {
    extensions = [ pkgs.vscode-extensions.james-yu.latex-workshop ];
    # LaTeX Workshop assumes latexmk; build with tectonic instead.
    userSettings = {
      "latex-workshop.latex.tools" = [
        {
          name = "tectonic";
          command = "tectonic";
          args = [
            "-X"
            "compile"
            "--synctex"
            "--keep-logs"
            "--keep-intermediates"
            "%DOC_EXT%"
          ];
        }
      ];
      "latex-workshop.latex.recipes" = [
        {
          name = "tectonic";
          tools = [ "tectonic" ];
        }
      ];
    };
  };
}
