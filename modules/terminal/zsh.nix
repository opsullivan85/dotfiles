{ config, pkgs, ... }:

{
  home.file.".p10k.zsh".source = ./p10k.zsh;

  # `z` and `zi` (interactive picker, needs fzf) jump to recent directories.
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases.open = "xdg-open";
    shellAliases.l = "ls -F";

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Tab completion: exact prefix, then case-insensitive (- and _ interchangeable),
      # then substring (e.g. "cd work<tab>" -> locus_worktrees)
      zstyle ':completion:*' matcher-list \
        ''' 'm:{a-zA-Z-_}={A-Za-z_-}' 'l:|=* r:|=*'

      # Ctrl+Left/Right jump over words
      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word

      # Each terminal gets its own independent tmux session (not a shared
      # one — that's what caused typing to mirror across every window).
      # Escape hatch if tmux is ever broken: NO_TMUX=1 zsh
      if [[ -z "$TMUX" && -z "$NO_TMUX" && -o interactive ]] && command -v tmux >/dev/null; then
        exec tmux new-session
      fi
    '';
  };
}
