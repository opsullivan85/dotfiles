{
  # The zsh integration adds a `y` wrapper that cd's to yazi's last directory on quit.
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # Open text files in $EDITOR (nvim, set by modules/tui/nvim), falling back
    # to vim on machines without it. Yazi's default opener would use nano.
    settings.opener.edit = [
      {
        run = ''${"$"}{EDITOR:-vim} "$@"'';
        block = true;
        desc = "$EDITOR";
        for = "unix";
      }
    ];
  };
}
