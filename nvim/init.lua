-- Plugins are installed by Nix (home/core/nvim.nix); this only configures them.
vim.g.mapleader = " "

require "options"
require "mappings"
require "lsp"
require "format"
require "treesitter"
require "completion"
require "finder"
