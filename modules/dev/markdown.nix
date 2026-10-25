{
  imports = [ ../tui/nvim/options.nix ];

  dev.nvim = {
    treesitter = [
      "markdown"
      "markdown_inline"
    ];
    # Renders headings, code blocks, tables, checkboxes, ... in the buffer;
    # the line under the cursor stays raw for editing. Colours come from the
    # base46 highlight groups.
    plugins = [
      ''
        {
          "MeanderingProgrammer/render-markdown.nvim",
          ft = "markdown",
          dependencies = { "nvim-treesitter/nvim-treesitter" },
          opts = {},
        },
      ''
    ];
  };
}
