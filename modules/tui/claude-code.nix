{ pkgs, ... }:

{
  imports = [ ./nvim/options.nix ];

  home.packages = [ pkgs.claude-code ];

  # Claude Code registers this URL handler itself and writes ~/.config/mimeapps.list to do it;
  # declaring it keeps that file home-manager-managed (delete the plain file once).
  xdg.mimeApps = {
    enable = true;
    defaultApplications."x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
  };

  # No-op on machines without modules/tui/nvim; lazy.nvim fetches the plugin.
  # <leader>a* maps are provided by the plugin's lazy `keys`.
  dev.nvim.plugins = [
    ''
      {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {},
        keys = {
          { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
          { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
          { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
          { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
          { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
          { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
      },
    ''
  ];

  # No-op on machines without modules/gui/vscode.nix.
  programs.vscode.profiles.default.extensions = [ pkgs.vscode-extensions.anthropic.claude-code ];
}
