# One self-contained module per language/tool. To drop one, delete its file
# and its line here; to add one, do the reverse. Nothing outside this folder
# references them.
#
# LSP servers/formatters are provided here (on PATH) rather than installed by
# NvChad's Mason, since Mason's prebuilt binaries don't run on NixOS. Enabling
# them in nvim is NvChad-side config (outside Nix).
{
  imports = [
    ./python.nix
    ./rust.nix
    ./cpp.nix
    ./latex.nix
    ./godot.nix
  ];
}
