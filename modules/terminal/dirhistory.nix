{ pkgs, ... }:

{
  # Alt+Left / Alt+Right step back and forward through the directories you've
  # visited. The plugin also binds Alt+Up (cd ..) and Alt+Down (first child).
  # Taken from oh-my-zsh's plugin folder, so nothing is vendored here.
  programs.zsh.plugins = [
    {
      name = "dirhistory";
      src = pkgs.oh-my-zsh;
      file = "share/oh-my-zsh/plugins/dirhistory/dirhistory.plugin.zsh";
    }
  ];
}
