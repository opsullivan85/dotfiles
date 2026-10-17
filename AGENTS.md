# AGENTS.md

Guidance for AI coding agents working in this repo. See README.md for the human overview.

## What this is

A flake driving a NixOS laptop (`nixosConfigurations.laptop`). The Ubuntu work laptop
lives in a separate private repo that consumes this one via `homeModules` and
`lib.mkHome` (see `docs/private-work.md`); keep those outputs working, and keep
anything work-specific out of this repo.

## Principles (the owner's, repeatedly stated)

- **Build up minimally and deliberately.** Don't add settings, packages or abstractions that weren't asked for.
- **DRY theming.** Colours/fonts are defined once in `theme.nix`. Never hard-code a colour or font elsewhere.
- **Self-contained units.** Each tool/language is one file (e.g. `home/dev/rust.nix`) so it can be removed or updated in one place.
- **Layering.** A machine = `home/core` + `home/os/<nixos|ubuntu>` + `home/profiles/<name>`, plus the optional units (`home/dev/*`, `home/shared/*`) its file in `home/machines/` imports explicitly. Core is only what every machine always gets (zsh, tmux, nvim, git) and must not depend on a graphical session or NixOS. Anything a machine might drop (a language, an app) is its own unit, listed per machine, never in core.
- **The owner has strong preferences. Ask before choosing between real alternatives.**
- **NvChad via nix4nvchad.** `home/core/nvim.nix` uses the `nix4nvchad` HM module: it pins the NvChad starter and copies it to `~/.config/nvim` on every switch, so edits there are overwritten; change this repo instead. Our additions are `nvim/plugins.lua` (extra lazy specs) and `nvim/lazy-lock.json`; the NvChad theme name is `nvchadTheme` in `theme.nix`. Plugins are still fetched by lazy.nvim on first launch. LSPs/formatters come from Nix on PATH (`home/dev/`), not Mason (Mason binaries don't run on NixOS).

## Workflow

- Flakes only see **git-tracked** files. `git add` new files before building or evaluating, or Nix won't find them.
- Rebuild with `./switch` (NixOS). It stages, runs pre-commit, builds, and commits `rebuild: generation N` on success. It needs `sudo`, so an agent usually can't run it; verify instead with:
  - `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link`
  - Work-laptop modules are checked by `nix flake check` (`homeModules`) and from the private repo.
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
- NvChad's `init.lua` `dofile`s files under `~/.local/share/nvim/base46/`; don't delete that directory. Regenerate with `require('base46').compile()`.
- `programs.neovim.enable` and `programs.nvchad.enable` are mutually exclusive (nix4nvchad asserts it).
- Update `nvim/lazy-lock.json` by hand: run `:Lazy update` in nvim, then copy `~/.config/nvim/lazy-lock.json` into the repo.
- Manual sync points: `nvchadTheme` vs `base16Scheme` in `theme.nix`; Noctalia GUI changes (`~/.local/state/noctalia/settings.toml`) back into `home/os/nixos/noctalia.nix`.
- Work identity and anything else work-specific belong in the private repo; don't add it here or invent values.
