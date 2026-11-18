{ ... }:

{
  imports = [ ./nvim/options.nix ];

  # No-op on machines without modules/tui/nvim; lazy.nvim fetches the plugin.
  # <leader>g* matches the existing git telescope maps (gt, cm).
  dev.nvim.plugins = [
    ''
      {
        "sindrets/diffview.nvim",
        opts = {},
        keys = {
          { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview working tree changes" },
          { "<leader>gr", "<cmd>DiffviewOpen origin/HEAD...HEAD<cr>", desc = "Diffview review branch vs default" },
          { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview current file history" },
          { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
        },
      },
    ''
  ];
}
