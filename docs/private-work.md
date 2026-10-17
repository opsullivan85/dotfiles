# Private work config

The work laptop (Ubuntu, standalone home-manager) is built from a **separate private
repo** that consumes this one. This repo never references the private one.

## What this repo exports

- `homeModules.<name>`: `core`, `os-nixos`, `os-ubuntu`, `shared-apps`, `dev-cpp`,
  `dev-godot`, `dev-latex`, `dev-python`, `dev-rust`. These mirror `home/`; the machine
  file in the private repo picks which it wants, same as `home/machines/personal-laptop.nix`.
- `lib.mkHome { modules; system ? "x86_64-linux"; extraSpecialArgs ? { }; }`: wraps
  `home-manager.lib.homeManagerConfiguration` and passes the `inputs` and `theme`
  args our modules expect (`inputs` there is this repo's, not the private repo's). Always use it instead of calling home-manager directly.

Structure changes to know about: there is no `home/core/dev/` any more (languages are
`home/dev/*`, opt-in per machine), graphical apps are in `home/shared/apps.nix`, and
core contains no personal or work identity.

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
       m.core
       m.os-ubuntu
       m.shared-apps
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
   Don't use this repo's `./switch` there; it is wired for the NixOS laptop.

## Updating

Pull in changes from this repo with `nix flake update dotfiles` in the private repo, then
switch. To test unpublished changes, add
`--override-input dotfiles path:$HOME/dotfiles` to the command.

## If work content was ever committed here

Deleting it in a later commit leaves it in history. Make the repo public only after scrubbing
(`git filter-repo`) or from a fresh history.
