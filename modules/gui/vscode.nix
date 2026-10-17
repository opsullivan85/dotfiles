{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    # Extensions come only from Nix: here for editor-wide ones, and from each
    # modules/dev/<lang>.nix for language support (see those files).
    mutableExtensionsDir = false;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      anthropic.claude-code
      yzhang.markdown-all-in-one
      mhutchie.git-graph
      tamasfe.even-better-toml
      jnoortheen.nix-ide
    ];
  };
}
