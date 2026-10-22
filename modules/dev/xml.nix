{ pkgs, ... }:

{
  imports = [ ../tui/nvim/options.nix ];

  home.packages = [ pkgs.lemminx ];

  dev.nvim = {
    lspServers = [ "lemminx" ];
    # ROS launch files are XML.
    luaConfig = [
      ''
        vim.filetype.add { extension = { launch = "xml" } }
      ''
    ];
  };

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default = {
    extensions = [ pkgs.vscode-extensions.redhat.vscode-xml ];
    userSettings = {
      "files.associations"."*.launch" = "xml";
      "xml.server.preferBinary" = true;
    };
  };
}
