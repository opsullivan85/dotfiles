{ pkgs, ... }:

{
  # Renders markdown in the terminal; with no arguments, browses the markdown
  # files under the current directory.
  home.packages = [ pkgs.glow ];
  programs.zsh.shellAliases.md = "glow";

  # Preview markdown through glow in yazi. No-op on machines without
  # modules/tui/yazi.nix.
  programs.yazi = {
    plugins.glow = pkgs.yaziPlugins.glow;
    settings.plugin.prepend_previewers = [
      {
        url = "*.md";
        run = "glow";
      }
    ];
  };
}
