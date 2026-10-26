_:

{
  # `z` and `zi` (interactive picker, needs fzf) jump to recent directories.
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreAllDups = true;
      share = true;
      extended = true; # record timestamps
    };

    shellAliases.open = "xdg-open";
    shellAliases.l = "ls -F";
    # `cmd | plain`: strip ANSI escape sequences (colours, cursor moves)
    # (LC_ALL=C: the [@-~] range misbehaves in UTF-8 locales)
    shellAliases.plain = ''LC_ALL=C sed -E 's/\x1b\[[0-9;?]*[ -\/]*[@-~]//g' '';

    initContent = ''
      # Tab completion: exact prefix, then case-insensitive (- and _ interchangeable),
      # then substring (e.g. "cd work<tab>" -> locus_worktrees)
      zstyle ':completion:*' matcher-list \
        ''' 'm:{a-zA-Z-_}={A-Za-z_-}' 'l:|=* r:|=*'

      # Ctrl+Left/Right jump over words
      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word

      # System specs + outstanding jn todos, same as everyone's neofetch-style
      # terminal greeting (see modules/terminal/fastfetch.nix).
      if [[ -o interactive ]] && command -v fastfetch >/dev/null; then
        fastfetch
      fi

      # Each terminal gets its own independent tmux session (not a shared
      # one — that's what caused typing to mirror across every window).
      # Escape hatch if tmux is ever broken: NO_TMUX=1 zsh
      if [[ -z "$TMUX" && -z "$NO_TMUX" && -o interactive ]] && command -v tmux >/dev/null; then
        exec tmux new-session
      fi
    '';
  };
}
