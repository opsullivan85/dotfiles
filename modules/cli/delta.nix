{
  # Wires itself into git as the pager and interactive diff filter, so
  # git.nix needn't know about it.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true; # n/N jump between files and hunks
      line-numbers = true;
    };
  };

  # Delta shows conflicts best with the three-way style.
  programs.git.settings.merge.conflictStyle = "zdiff3";
}
