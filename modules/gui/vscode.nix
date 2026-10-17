{ pkgs, theme, ... }:

{
  programs.vscode = {
    enable = true;
    # Extensions come only from Nix: here for editor-wide ones, and from each
    # modules/dev/<lang>.nix for language support (see those files).
    mutableExtensionsDir = false;
    # Electron picks its password store from XDG_CURRENT_DESKTOP, which is
    # "niri" here and unrecognised, so say explicitly to use the Secret Service.
    argvSettings.password-store = "gnome-libsecret";
    # VS Code writes a generated crash-reporter-id into argv.json at startup,
    # which fails (and pops up an error) as it's a read-only store symlink.
    argvSettings.crash-reporter-id = "34e0f60a-9c14-49e1-a10e-1d511d900f74";
    # Run the neovim extension in its own extension host so it starts first.
    profiles.default.userSettings = {
      "extensions.experimental.affinity"."asvetliakov.vscode-neovim" = 1;
      "workbench.colorTheme" = theme.vscodeTheme;
      "editor.fontFamily" = "'${theme.monoFont.name}', monospace";
      "terminal.integrated.fontFamily" = "'${theme.monoFont.name}'";
    };
    profiles.default.extensions = with pkgs.vscode-extensions; [
      asvetliakov.vscode-neovim
      yzhang.markdown-all-in-one
      mhutchie.git-graph
      tamasfe.even-better-toml
      jnoortheen.nix-ide
    ];
  };
}
