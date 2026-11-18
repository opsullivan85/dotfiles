{ pkgs, ... }:

{
  home.packages = [ pkgs.claude-code ];

  home.sessionVariables.CLAUDE_CODE_DISABLE_BACKGROUND_TASKS = "1";

  # Claude Code registers this URL handler itself and writes ~/.config/mimeapps.list to do it;
  # declaring it keeps that file home-manager-managed (delete the plain file once).
  xdg.mimeApps = {
    enable = true;
    defaultApplications."x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
  };

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default.extensions = [ pkgs.vscode-extensions.anthropic.claude-code ];
}
