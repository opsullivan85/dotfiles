{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    # Extensions come only from Nix: here for editor-wide ones, and from each
    # modules/dev/<lang>.nix for language support (see those files).
    mutableExtensionsDir = false;
    # Electron picks its password store from XDG_CURRENT_DESKTOP, which is
    # "niri" here and unrecognised, so say explicitly to use the Secret Service.
    argvSettings.password-store = "gnome-libsecret";
    # Run the neovim extension in its own extension host so it starts first.
    profiles.default.userSettings."extensions.experimental.affinity"."asvetliakov.vscode-neovim" = 1;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      asvetliakov.vscode-neovim
      yzhang.markdown-all-in-one
      mhutchie.git-graph
      tamasfe.even-better-toml
      jnoortheen.nix-ide
    ];
  };
}
