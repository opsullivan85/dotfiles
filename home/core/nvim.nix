{ pkgs, ... }:

{
  # Neovim is configured entirely by Nix: plugins come from nixpkgs and the
  # Lua in ../../nvim is copied into the store (read-only, rebuild to apply).
  # Colours come from Stylix (home/core/stylix.nix), so there is no
  # colourscheme set in the Lua. LSPs/formatters are on PATH from home/core/dev.
  programs.neovim = {
    enable = true;
    initLua = builtins.readFile ../../nvim/init.lua;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      conform-nvim
      blink-cmp
      telescope-nvim
      plenary-nvim
      (nvim-treesitter.withPlugins (
        p: with p; [
          vim
          lua
          vimdoc
          python
          rust
          cpp
          c
          cmake
          toml
          latex
          gdscript
          godot_resource
        ]
      ))
    ];
    extraPackages = with pkgs; [
      ripgrep # telescope live grep
      fd # telescope find files
      lua-language-server
    ];
  };

  xdg.configFile."nvim/lua".source = ../../nvim/lua;
}
