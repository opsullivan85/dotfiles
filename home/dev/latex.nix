{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tectonic # self-contained engine; fetches packages on demand
    texlab # LSP
  ];
}
