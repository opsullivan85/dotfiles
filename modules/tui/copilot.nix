{ pkgs, ... }:

{
  home.packages = [ pkgs.github-copilot-cli ];

  # VS Code bundles the Copilot extension, so there's nothing to install; this
  # just stops modules/gui/vscode.nix from disabling it. No-op without that module.
  programs.vscode.profiles.default.userSettings."chat.disableAIFeatures" = false;
}
