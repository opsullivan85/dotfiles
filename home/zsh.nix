{ config, pkgs, ... }:

{
  home.file.".p10k.zsh".source = ./p10k.zsh;

  # `z` and `zi` (interactive picker, needs fzf) jump to frecent directories.
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

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

      # Tab completion ignores case and treats - and _ as interchangeable
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'

      # Each terminal gets its own independent tmux session (not a shared
      # one — that's what caused typing to mirror across every window).
      if [[ -z "$TMUX" && -o interactive ]]; then
        exec tmux new-session
      fi
    '';
  };
}
