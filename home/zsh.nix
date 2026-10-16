{ config, pkgs, ... }:

{
  home.file.".p10k.zsh".source = ./p10k.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = {
      rebuild = "~/dotfiles/switch";
    };

    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Each terminal gets its own independent tmux session (not a shared
      # one — that's what caused typing to mirror across every window).
      if [[ -z "$TMUX" && -o interactive ]]; then
        exec tmux new-session
      fi
    '';
  };
}
