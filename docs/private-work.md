# Private work config

The work laptop (Ubuntu, standalone home-manager) is built from a **separate private
repo** that consumes this one. This repo never references the private one.

## What this repo exports

- `homeModules.<name>`: `os-nixos`, `os-ubuntu`, plus every file or folder unit in `modules/` as
  `<category>-<name>` (`terminal-zsh`, `cli-git`, `tui-claude-code`, `dev-rust`, …), generated
  from the directory. The machine file in the private repo picks which it wants, same as
  `home/machines/laptop.nix`.
- `lib.mkHome { modules; system ? "x86_64-linux"; extraSpecialArgs ? { }; }`: wraps
  `home-manager.lib.homeManagerConfiguration` and passes the `inputs` and `theme`
  args our modules expect (`inputs` there is this repo's, not the private repo's). Always use it instead of calling home-manager directly.

Note there is no always-on core: the private machine file lists everything it wants, including
`cli-git` and `cli-home-manager` (needed for the `home-manager` command).

## Set up the private repo

1. Create a private repo (e.g. `dotfiles-work`) and clone it to `~/dotfiles-work`.
2. Add `flake.nix`:

   ```nix
   {
     description = "Owen's work laptop";

     inputs.dotfiles.url = "github:<you>/dotfiles";

     outputs =
       { dotfiles, ... }:
       {
         homeConfigurations."owen@work-laptop" = dotfiles.lib.mkHome {
           modules = [ ./work-laptop.nix ];
           extraSpecialArgs = { inherit dotfiles; };
         };
       };
   }
   ```

3. Add `work-laptop.nix` (username/home directory may differ on that machine):

   ```nix
   { dotfiles, ... }:
   let
     m = dotfiles.homeModules;
   in
   {
     imports = [
       m.os-ubuntu
       m.terminal-zsh
       m.terminal-tmux
       m.cli-git
       m.cli-home-manager
       m.cli-gh
       m.tui-btop
       m.gui-brave
       m.tui-nvim
       m.dev-python
       m.dev-rust
       m.dev-cpp
       m.dev-latex
       ./work.nix
     ];

     home.username = "owen";
     home.homeDirectory = "/home/owen";
     home.stateVersion = "26.05";
   }
   ```

4. Add `work.nix` with what's specific to work (git identity, work-only tools):

   ```nix
   {
     programs.git.settings.user = {
       name = "...";
       email = "...";
     };
   }
   ```

5. `git add` everything (flakes only see tracked files), then on the work laptop:

   ```sh
   nix run home-manager/master -- switch --flake ~/dotfiles-work#owen@work-laptop
   ```

   Afterwards plain `home-manager switch --flake ~/dotfiles-work#owen@work-laptop` works.
   Don't use this repo's `scripts/rebuild` there; it is wired for the NixOS laptop.

## Updating

Pull in changes from this repo with `nix flake update dotfiles` in the private repo, then
switch. To test unpublished changes, add
`--override-input dotfiles path:$HOME/dotfiles` to the command.
