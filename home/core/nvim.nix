{
  inputs,
  pkgs,
  theme,
  ...
}:

{
  imports = [ inputs.nix4nvchad.homeManagerModules.default ];

  # nix4nvchad pins the NvChad starter and copies it to ~/.config/nvim on each
  # activation (a writable copy, so edits there are overwritten by the next
  # switch — change nvim/ in this repo instead). Plugins are still fetched by
  # lazy.nvim on first launch, pinned by nvim/lazy-lock.json. LSPs and
  # formatters come from Nix on PATH (home/core/dev/), not Mason.
  programs.nvchad = {
    enable = true;
    backup = false; # otherwise every switch leaves an nvim_<date>.bak behind
    extraPackages = [ pkgs.fd ]; # telescope file search
    chadrcConfig = ''
      local M = {}
      M.base46 = { theme = "${theme.nvchadTheme}" }
      return M
    '';
    extraPlugins = builtins.readFile ../../nvim/plugins.lua;
    lazy-lock = builtins.readFile ../../nvim/lazy-lock.json;
  };
}
