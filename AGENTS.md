# AGENTS.md

Guidance for AI coding agents working in this repo. See README.md for the human overview.

## What this is

A flake driving a NixOS laptop (`nixosConfigurations.laptop`). The Ubuntu work laptop
lives in a separate private repo that consumes this one via `homeModules` and
`lib.mkHome` (see `docs/private-work.md`); keep those outputs working, and keep
anything work-specific out of this repo.

## Principles (the owner's, repeatedly stated)

- **DRY theming.** Colours/fonts are defined once in `lib/theme.nix`. Never hard-code a colour or font elsewhere.
- **Self-contained units.** Each tool/language is one file (e.g. `modules/dev/rust.nix`) so it can be removed or updated in one place.
- **Custom tools.** Each CLI tool of ours is `tools/<name>/` with a `default.nix` (a `callPackage` function using the builder for its language: `writeShellApplication`, `writers.writePython3Bin`, `rustPlatform.buildRustPackage`…). `flake.nix` auto-exposes them as `packages.<system>.<name>`; a machine installs one via a three-line wrapper in `modules/<category>/<name>.nix` using `inputs.self.packages`. Scripts are bash, not zsh (shellcheck can't check zsh); zsh is only for shell-integration glue. The stdlib-only rule is for `rebuild`/`bootstrap`, not tools.
- **Hosts.** `mkHost { name; }` in `flake.nix` pairs `hosts/<name>/` with `home/machines/<name>.nix`; a new NixOS machine is those two plus one `nixosConfigurations.<name>` line.
- **Layering.** A machine = `home/os/<nixos|ubuntu>` + `home/profiles/<name>`, plus the units from `modules/<category>/<name>.nix` (terminal, cli, tui, gui, dev; one level deep; a unit that needs several files is a folder, `modules/<category>/<name>/default.nix`, with its files beside it, e.g. `tui/nvim/`) that its file in `home/machines/` imports explicitly. There is no always-on core: if a machine might drop it, it's a module, listed per machine. Modules must not depend on a graphical session or NixOS unless they're in `gui/`. A new category directory is created when its first module is.
- **The owner has strong preferences. Ask before choosing between real alternatives.**
- **NvChad via nix4nvchad.** `modules/tui/nvim/default.nix` uses the `nix4nvchad` HM module: it pins the NvChad starter and copies it to `~/.config/nvim` on every switch, so edits there are overwritten; change this repo instead. Everything nvim lives in `modules/tui/nvim/` (the per-language additions are in `modules/dev/<lang>.nix`, via `options.nix` there). Our additions are `modules/tui/nvim/plugins.lua` (extra lazy specs) and `modules/tui/nvim/lazy-lock.json`; the NvChad theme name is `nvchadTheme` in `lib/theme.nix`. Plugins are still fetched by lazy.nvim on first launch. LSPs/formatters come from Nix on PATH (`modules/dev/`), not Mason (Mason binaries don't run on NixOS).

## Workflow

- Flakes only see **git-tracked** files. `git add` new files before building or evaluating, or Nix won't find them.
- Rebuild with `scripts/rebuild` (NixOS). It stages, runs pre-commit, builds, and commits `rebuild: generation N` on success. It needs `sudo`, so an agent usually can't run it; verify instead with:
  - `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link`
  - `nix flake check`
  - Work-laptop modules are checked by `nix flake check` (`homeModules`) and from the private repo.
- Don't commit unless asked; `rebuild` makes the rebuild commits itself. When you do commit, end the message with the attribution trailer the harness gives you.
- Logs from `rebuild`/`bootstrap` are in `~/.local/state/dotfiles/logs/` (`*-latest.log`).

## Checks

Don't run `nixfmt`, `nix fmt` or other formatters/linters directly; the only way to format and lint is the pre-commit command below. Edit, verify with the build, then run it once at the end.

Pre-commit (installed by `scripts/bootstrap`) runs nixfmt, statix, deadnix, ruff, stylua, shellcheck, and `nix flake check` on push. Run all with `scripts/in-devshell pre-commit run --all-files`. Fix findings rather than suppressing them; the only configured exemptions are in `statix.toml` and `.pre-commit-config.yaml` (generated `hardware-configuration.nix`, `*.zsh`).

## Conventions and gotchas

- Nix: formatted by `nixfmt`; module args like `{ config, pkgs, ... }:` may leave unused names (deadnix runs with `-L`).
- Scripts (`scripts/rebuild`, `scripts/bootstrap`, `scripts/dotlib/`) are Python 3.11+, **stdlib only** (they must run on a fresh machine). Shared UI lives in `scripts/dotlib/ui.py`.
- Stylix has separate NixOS and home-manager switches. HM-side needs `stylix.enable = true` and `stylix.overlays.enable = false` (because of `useGlobalPkgs`).
- tmux: `%` in status strings is strftime-expanded, so write `%%`.
- NvChad's `init.lua` `dofile`s files under `~/.local/share/nvim/base46/`; don't delete that directory. Regenerate with `require('base46').compile()`.
- `programs.neovim.enable` and `programs.nvchad.enable` are mutually exclusive (nix4nvchad asserts it).
- `modules/tui/nvim/lazy-lock.json` is kept in sync by `scripts/rebuild`: after switching it runs `nvim --headless "+Lazy! install"` and stages `~/.config/nvim/lazy-lock.json` into the generation commit. That covers newly added plugins and any `:Lazy update` done in nvim since. Don't hand-edit the lockfile.
- Manual sync points: `nvchadTheme` vs `base16Scheme` in `lib/theme.nix`; Noctalia GUI changes (`~/.local/state/noctalia/settings.toml`) back into `home/os/nixos/noctalia.nix`.
- Work identity and anything else work-specific belong in the private repo; don't add it here or invent values.
