{
  # The zsh integration adds a `y` wrapper that cd's to yazi's last directory on quit.
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };
}
