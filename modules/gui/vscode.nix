{
  lib,
  pkgs,
  theme,
  ...
}:

let
  formatSelectionContext = "editorHasDocumentSelectionFormattingProvider && editorTextFocus && !editorReadonly";
  excludes = {
    "**/build/**" = true;
    "**/devel/**" = true;
    "**/install/**" = true;
    "**/log/**" = true;
    "**/.cache/**" = true;
    "**/venv/**" = true;
    "**/__pycache__/**" = true;
  };
in

{
  programs.vscode = {
    enable = true;
    # Extensions come only from Nix: here for editor-wide ones, and from each
    # modules/dev/<lang>.nix for language support (see those files).
    mutableExtensionsDir = false;
    # Electron picks its password store from XDG_CURRENT_DESKTOP, which is
    # "niri" here and unrecognised, so say explicitly to use the Secret Service.
    argvSettings.password-store = "gnome-libsecret";
    # If this is unset, VS Code writes it (plus a crash-reporter-id) into
    # argv.json at startup, which fails and pops up an error as it's a
    # read-only store symlink. true is what it would write by default.
    argvSettings.enable-crash-reporter = true;
    # Run the neovim extension in its own extension host so it starts first.
    profiles.default.userSettings = {
      "extensions.experimental.affinity"."asvetliakov.vscode-neovim" = 1;
      # Hides the bundled Copilot and its chat UI; modules/tui/copilot.nix turns it back on.
      "chat.disableAIFeatures" = lib.mkDefault true;
      # Nix owns updates and extensions, so nothing should check for or suggest either.
      "update.mode" = "none";
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "extensions.ignoreRecommendations" = true;
      "workbench.startupEditor" = "none";
      "workbench.enableExperiments" = false;
      # Empty list hides the neovim extension's status bar entries (mode, pending keys, messages).
      # it always looks ugly on my machines
      "vscode-neovim.statusLineItems" = [ ];
      "workbench.colorTheme" = theme.vscodeTheme;
      "editor.fontFamily" = "'${theme.monoFont.name}', monospace";
      "terminal.integrated.fontFamily" = "'${theme.monoFont.name}'";
      "editor.fontLigatures" = true;
      "terminal.integrated.fontLigatures.enabled" = true;
      "workbench.iconTheme" = "material-icon-theme";
      "material-icon-theme.opacity" = 0.75;
      "window.restoreWindows" = "none";
      "editor.mouseWheelZoom" = true;
      "editor.formatOnPaste" = true;
      "editor.formatOnSave" = false;
      # Software rendering avoids GPU load/glitches on large projects.
      "terminal.integrated.gpuAcceleration" = "off";
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "terminal.integrated.initialHint" = false;
      "git.autofetch" = true;
      "git.openRepositoryInParentFolders" = "always";
      "git.ignoreRebaseWarning" = true;
      "git-graph.repository.onLoad.scrollToHead" = true;
      "githubPullRequests.pullBranch" = "never";
      "remote.SSH.remoteServerListenOnSocket" = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      "diffEditor.renderSideBySide" = false;
      "diffEditor.experimental.showMoves" = true;
      "files.associations"."*.onnx" = "code-text-binary";
      "[markdown]"."editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
      "markdown-preview-enhanced.enableHTML5Embed" = true;
      "markdown-preview-enhanced.previewTheme" = "github-light.css";
      "markdown-preview-enhanced.enablePreviewZenMode" = true;
      # Keeps the file watcher and search cheap in big workspaces (ROS/colcon, Python).
      "search.exclude" = excludes;
      "files.watcherExclude" = excludes;
    };
    profiles.default.keybindings = [
      {
        key = "ctrl+shift+alt+t";
        command = "workbench.action.tasks.test";
      }
      {
        key = "ctrl+shift+alt+b";
        command = "workbench.action.tasks.build";
        when = "taskCommandsRegistered";
      }
      {
        key = "ctrl+shift+alt+f";
        command = "editor.action.formatSelection";
        when = formatSelectionContext;
      }
      {
        key = "ctrl+k ctrl+f";
        command = "-editor.action.formatSelection";
        when = formatSelectionContext;
      }
    ];
    profiles.default.extensions = with pkgs.vscode-extensions; [
      asvetliakov.vscode-neovim
      yzhang.markdown-all-in-one
      mhutchie.git-graph
      tamasfe.even-better-toml
      jnoortheen.nix-ide
      pkief.material-icon-theme
      ms-azuretools.vscode-containers
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-containers
      davidanson.vscode-markdownlint
      shd101wyy.markdown-preview-enhanced
      streetsidesoftware.code-spell-checker
      mechatroner.rainbow-csv
      ms-vscode.hexeditor
      mads-hartmann.bash-ide-vscode
      drblury.protobuf-vsc
      redhat.vscode-yaml
      ms-vscode-remote.remote-ssh
      github.vscode-pull-request-github
    ];
  };
}
