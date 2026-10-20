{
  # The zsh integration aliases ls (plus ll, la, lt, ...) to eza.
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };
}
