{ pkgs, ... }:

{
  imports = [ ./nvim/options.nix ];

  home.packages = [
    pkgs.github-copilot-cli
    pkgs.nodejs # copilot.vim runs on node
  ];

  # VS Code bundles the Copilot extension, so there's nothing to install; this
  # just stops modules/gui/vscode.nix from disabling it. No-op without that module.
  programs.vscode.profiles.default.userSettings."chat.disableAIFeatures" = false;

  # No-op on machines without modules/tui/nvim.
  dev.nvim.plugins = [
    ''
      {
        "github/copilot.vim",
        lazy = false,
        config = function()
          vim.g.copilot_no_tab_map = true
          vim.keymap.set("i", "<M-l>", 'copilot#Accept("\\<CR>")', {
            expr = true,
            replace_keycodes = false,
            desc = "Accept Copilot suggestion",
          })
        end,
      },
    ''
  ];
}
