# AGENTS.md

Guidance for AI coding agents working in this repo. See README.md for the human overview.

## What this is

A flake driving a NixOS laptop (`nixosConfigurations.laptop`) and an Ubuntu work
laptop (`homeConfigurations."owen@work-laptop"`, standalone home-manager). Keep it
building for both.

## Principles (the owner's, repeatedly stated)

- **Build up minimally and deliberately.** Don't add settings, packages or abstractions that weren't asked for.
- **DRY theming.** Colours/fonts are defined once in `theme.nix`. Never hard-code a colour or font elsewhere.
- **Self-contained units.** Each tool/language is one file (e.g. `home/core/dev/rust.nix`) so it can be removed or updated in one place.
- **Layering.** A machine = `home/core` + `home/os/<nixos|ubuntu>` + `home/profiles/<personal|work>`, composed in `home/machines/`. Put things in the lowest layer where they're true: portable → core; needs NixOS/graphical → os/nixos; identity or hat-specific apps → profiles. Core must not depend on a graphical session or NixOS.
- **The owner has strong preferences. Ask before choosing between real alternatives.**
- **Neovim is fully Nix-managed.** Plugins come from nixpkgs `vimPlugins` via `programs.neovim` (`home/core/nvim.nix`); the Lua in `nvim/` is copied into the store, so it is read-only and edits need a rebuild. No lazy.nvim/Mason. LSPs/formatters come from Nix on PATH (`home/core/dev/`) and are enabled in `nvim/lua/lsp.lua` / `format.lua`. Its colours come from Stylix, so don't set a colourscheme in the Lua.

## Workflow

- Flakes only see **git-tracked** files. `git add` new files before building or evaluating, or Nix won't find them.
- Rebuild with `./switch` (NixOS). It stages, runs pre-commit, builds, and commits `rebuild: generation N` on success. It needs `sudo`, so an agent usually can't run it; verify instead with:
  - `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link`
  - `nix build '.#homeConfigurations."owen@work-laptop".activationPackage' --no-link`
  - `nix flake check`
- Don't commit unless asked; `switch` makes the rebuild commits itself. When you do commit, end the message with the attribution trailer the harness gives you.
- Logs from `switch`/`bootstrap` are in `~/.local/state/dotfiles/logs/` (`*-latest.log`).

## Checks

Pre-commit (installed by `./bootstrap`) runs nixfmt, statix, deadnix, ruff, stylua, shellcheck, and `nix flake check` on push. Run all with `scripts/in-devshell pre-commit run --all-files`. Fix findings rather than suppressing them; the only configured exemptions are in `statix.toml` and `.pre-commit-config.yaml` (generated `hardware-configuration.nix`, `*.zsh`).

## Conventions and gotchas

- Nix: formatted by `nixfmt`; module args like `{ config, pkgs, ... }:` may leave unused names (deadnix runs with `-L`).
- Scripts (`switch`, `bootstrap`, `dotlib/`) are Python 3.11+, **stdlib only** (they must run on a fresh machine). Shared UI lives in `dotlib/ui.py`.
- Stylix has separate NixOS and home-manager switches. HM-side needs `stylix.enable = true` and `stylix.overlays.enable = false` (because of `useGlobalPkgs`).
- tmux: `%` in status strings is strftime-expanded, so write `%%`.
- Stylix lives in `home/core/stylix.nix` with `autoEnable` off (so Ubuntu stays headless-safe); `home/os/nixos/desktop.nix` turns it on. New nvim plugins go in `home/core/nvim.nix`, their setup in a new `nvim/lua/<name>.lua` required from `nvim/init.lua`.
- Manual sync point: Noctalia GUI changes (`~/.local/state/noctalia/settings.toml`) back into `home/os/nixos/noctalia.nix`.
- The work git identity in `home/profiles/work.nix` is a TODO; don't invent one.
