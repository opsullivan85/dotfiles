{ pkgs, theme, ... }:

{
  # Renders markdown in the terminal; with no arguments, browses the markdown
  # files under the current directory.
  home.packages = [ pkgs.glow ];
  programs.zsh.shellAliases.md = "glow";

  # Preview markdown through glow in yazi, via piper (runs a command as a
  # previewer). No-op on machines without modules/tui/yazi.nix.
  programs.yazi = {
    plugins.piper = pkgs.yaziPlugins.piper;
    settings.plugin.prepend_previewers = [
      {
        url = "*.md";
        # No TTY here, so glow can't pick dark/light itself.
        run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=${theme.polarity} "$1"'';
      }
    ];
  };
}
